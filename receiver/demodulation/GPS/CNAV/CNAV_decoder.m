function [CNAV, SOW] = CNAV_decoder(CNAV, channel_spc)
%进行CNAV的解卷积，CRC校验和电文解调

%% 进制转换
rawBits = zeros(1,670);
for i=1:20
    bits_str = dec2bin(channel_spc.Msg_CNAV_prev(i),32);
    bits_double = double(bits_str-'0');
    rawBits(30*(i-1)+(1:30)) = bits_double(32:-1:3);
end
for i=1:2
    bits_str = dec2bin(channel_spc.Msg_CNAV(i),32);
    bits_double = double(bits_str-'0');
    rawBits(600+30*(i-1)+(1:30)) = bits_double(32:-1:3);
end
bits_str = dec2bin(channel_spc.Msg_CNAV(3),32);
bits_double = double(bits_str-'0');
rawBits(661:670) = bits_double(32:-1:23);
%解卷积码时使用的寄存器初始状态为零，因此对前12个比特做特殊处理
rawBits(1:12) = [1 1 1 0   1 1 1 1   1 1 1 1]; 

%% 解码与校验
trellis = poly2trellis(7,[171 133]);
cnavBits = vitdec(rawBits, trellis, 35, 'cont', 'hard'); %默认路径长度取35，为编码器限制长度的五倍
cnavBits = cnavBits(36:end); %解调后的300bits序列。前35位是无意义的0，需要去除

g = [1 1 0 0 0   0 1 1 0 0   1 0 0 1 1   0 0 1 1 1   1 1 0 1 1];  %校验位生成多项式g(x) 24->0 降幂排列

cnav_check = cnavBits;
for i=1:276
    if (cnav_check(i))
        cnav_check(i:i+24) = mod( cnav_check(i:i+24)+g, 2);
    end
end
parity = cnav_check(277:300);
if (sum(parity)>0) 
    fprintf('\tCRC check failed! PRN = %2d\n', channel_spc.PRNID);
    SOW = -1; %无效返回值
    return; %若校验失败，不进行解调
end

%% 电文解调
ephReceiveFlag = 0;

prn = channel_spc.PRNID;
bits = char(cnavBits+'0'); %转字符串类型

messageID = bin2dec(bits(15:20));
SOW = bin2dec(bits(21:37));

switch messageID
    
    case 10 %星历 part 1
        CNAV.ephemeris(prn).ephUpdate = CNAV_get_eph( ...
            CNAV.ephemeris(prn).ephUpdate, bits, messageID);         
        ephReceiveFlag = 1;
        
        if ( 0==mod(CNAV.ephemeris(prn).updateLevel,2) )  %取末位
            CNAV.ephemeris(prn).updateLevel = CNAV.ephemeris(prn).updateLevel + 1;
        end
    
    case 11 %星历 part 2
        CNAV.ephemeris(prn).ephUpdate = CNAV_get_eph( ...
            CNAV.ephemeris(prn).ephUpdate, bits, messageID);       
        ephReceiveFlag = 1;
        
        if ( mod(floor(CNAV.ephemeris(prn).updateLevel/2),2)==0 ) %右移1位取末位得到接收状态
            CNAV.ephemeris(prn).updateLevel = CNAV.ephemeris(prn).updateLevel + 2;
        end       
        
    case 30 %时钟、IONO、Group delay
        CNAV.ephemeris(prn).ephUpdate = CNAV_get_eph( ...
            CNAV.ephemeris(prn).ephUpdate, bits, messageID);
        ephReceiveFlag = 1;
        if ( floor(CNAV.ephemeris(prn).updateLevel/4)==0 ) %右移2位得到时钟接收状态
            CNAV.ephemeris(prn).updateLevel = CNAV.ephemeris(prn).updateLevel + 4;
        end
        
        CNAV.ISC(prn).ISC_ready = 1;
        if (strcmp(bits(128:140),'1000000000000'))
            CNAV.ISC(prn).T_GD       = 0;
        else
            CNAV.ISC(prn).T_GD       = twosComp2dec(bits(128:140))*2^(-35);
        end
        if (strcmp(bits(141:153),'1000000000000'))
            CNAV.ISC(prn).ISC_L1CA   = 0;
        else
            CNAV.ISC(prn).ISC_L1CA   = twosComp2dec(bits(141:153))*2^(-35);
        end
        if (strcmp(bits(154:166),'1000000000000'))
            CNAV.ISC(prn).ISC_L2C    = 0;
        else
            CNAV.ISC(prn).ISC_L2C    = twosComp2dec(bits(154:166))*2^(-35);
        end
        if (strcmp(bits(167:179),'1000000000000'))
            CNAV.ISC(prn).ISC_L5I5   = 0;
        else
            CNAV.ISC(prn).ISC_L5I5   = twosComp2dec(bits(167:179))*2^(-35);
        end
        if (strcmp(bits(180:192),'1000000000000'))
            CNAV.ISC(prn).ISC_L5Q5   = 0;
        else
            CNAV.ISC(prn).ISC_L5Q5   = twosComp2dec(bits(180:192))*2^(-35);
        end
        
        CNAV.IONO(prn).IONO_ready = 1;
        CNAV.IONO(prn).alpha0 = twosComp2dec(bits(193:200))*2^(-30);
        CNAV.IONO(prn).alpha1 = twosComp2dec(bits(201:208))*2^(-27);
        CNAV.IONO(prn).alpha2 = twosComp2dec(bits(209:216))*2^(-24);
        CNAV.IONO(prn).alpha3 = twosComp2dec(bits(217:224))*2^(-24);
        CNAV.IONO(prn).beta0  = twosComp2dec(bits(225:232))*2^11;
        CNAV.IONO(prn).beta1  = twosComp2dec(bits(233:240))*2^14;
        CNAV.IONO(prn).beta2  = twosComp2dec(bits(241:248))*2^16;
        CNAV.IONO(prn).beta3  = twosComp2dec(bits(249:256))*2^16;
        CNAV.IONO(prn).WN_OP  = 0; %unused
    
    case 31 %时钟、精简历书
        CNAV.ephemeris(prn).ephUpdate = CNAV_get_eph( ...
            CNAV.ephemeris(prn).ephUpdate, bits, messageID);
        ephReceiveFlag = 1;
        if ( floor(CNAV.ephemeris(prn).updateLevel/4)==0 ) %右移2位得到时钟接收状态
            CNAV.ephemeris(prn).updateLevel = CNAV.ephemeris(prn).updateLevel + 4;
        end
        
    case 32 %时钟、EOP
        CNAV.ephemeris(prn).ephUpdate = CNAV_get_eph( ...
            CNAV.ephemeris(prn).ephUpdate, bits, messageID);
        ephReceiveFlag = 1;
        if ( floor(CNAV.ephemeris(prn).updateLevel/4)==0 ) %右移2位得到时钟接收状态
            CNAV.ephemeris(prn).updateLevel = CNAV.ephemeris(prn).updateLevel + 4;
        end
                
    case 33 %时钟、UTC
        CNAV.ephemeris(prn).ephUpdate = CNAV_get_eph( ...
            CNAV.ephemeris(prn).ephUpdate, bits, messageID);
        ephReceiveFlag = 1;
        if ( floor(CNAV.ephemeris(prn).updateLevel/4)==0 ) %右移2位得到时钟接收状态
            CNAV.ephemeris(prn).updateLevel = CNAV.ephemeris(prn).updateLevel + 4;
        end
        
    case 34 %时钟、差分信息
        CNAV.ephemeris(prn).ephUpdate = CNAV_get_eph( ...
            CNAV.ephemeris(prn).ephUpdate, bits, messageID);
        ephReceiveFlag = 1;
        if ( floor(CNAV.ephemeris(prn).updateLevel/4)==0 ) %右移2位得到时钟接收状态
            CNAV.ephemeris(prn).updateLevel = CNAV.ephemeris(prn).updateLevel + 4;
        end
                
    case 35 %时钟、GGTO
        CNAV.ephemeris(prn).ephUpdate = CNAV_get_eph( ...
            CNAV.ephemeris(prn).ephUpdate, bits, messageID);
        ephReceiveFlag = 1;
        if ( floor(CNAV.ephemeris(prn).updateLevel/4)==0 ) %右移2位得到时钟接收状态
            CNAV.ephemeris(prn).updateLevel = CNAV.ephemeris(prn).updateLevel + 4;
        end
                
    case 36 %时钟、Text
        CNAV.ephemeris(prn).ephUpdate = CNAV_get_eph( ...
            CNAV.ephemeris(prn).ephUpdate, bits, messageID);
        ephReceiveFlag = 1;
        if ( floor(CNAV.ephemeris(prn).updateLevel/4)==0 ) %右移2位得到时钟接收状态
            CNAV.ephemeris(prn).updateLevel = CNAV.ephemeris(prn).updateLevel + 4;
        end
        
    case 37 %时钟、中等历书
        CNAV.ephemeris(prn).ephUpdate = CNAV_get_eph( ...
            CNAV.ephemeris(prn).ephUpdate, bits, messageID);
        ephReceiveFlag = 1;
        if ( floor(CNAV.ephemeris(prn).updateLevel/4)==0 ) %右移2位得到时钟接收状态
            CNAV.ephemeris(prn).updateLevel = CNAV.ephemeris(prn).updateLevel + 4;
        end
        
    case 12 %精简历书
        
    case 13 %时钟差分
        
    case 14 %星历差分
        
    case 15 %Text
        
end

%% 星历参数更新程序
if (ephReceiveFlag)
    if (0==CNAV.ephemeris(prn).ephReady) %首次获取星历信息
        if (7==CNAV.ephemeris(prn).updateLevel) %两部分星历和时钟均已完整
            if (CNAV.ephemeris(prn).ephUpdate.t_oe_10 == CNAV.ephemeris(prn).ephUpdate.t_oe_11)
                %两部分星历参考时间要相同，否则需重新接收
                CNAV.ephemeris(prn).eph = CNAV.ephemeris(prn).ephUpdate;
                CNAV.ephemeris(prn).ephReady = 1;
            end
            CNAV.ephemeris(prn).updateLevel = 0;
        end
    else %已有星历信息
        if (7==CNAV.ephemeris(prn).updateLevel)
            if (0==CNAV.ephemeris(prn).updating) %未处于更新状态           
                ephEqualFlag = CNAV_eph_compare(CNAV.ephemeris(prn).ephUpdate, CNAV.ephemeris(prn).eph);
                if (~ephEqualFlag) %若两次接收不相同，则检查更新
                    CNAV.ephemeris(prn).ephRaid = CNAV.ephemeris(prn).ephUpdate;
                    CNAV.ephemeris(prn).updating = 1;
                end         
            else  %处于检查更新状态
                ephEqualFlag = CNAV_eph_compare(CNAV.ephemeris(prn).ephUpdate, CNAV.ephemeris(prn).ephRaid);
                if (ephEqualFlag) %连续收到两次相同的星历信息，则确认更新,否则放弃更新
                    CNAV.ephemeris(prn).eph = CNAV.ephemeris(prn).ephUpdate;
                end
                CNAV.ephemeris(prn).updating = 0; %还原标志位
            end
            CNAV.ephemeris(prn).updateLevel = 0;
        end
    end   
end



