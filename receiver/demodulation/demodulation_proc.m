function [channel, naviMsg] = demodulation_proc(channel, naviMsg)

switch channel.SYST
	case 'GPS_L1CA'
        CH_in = channel.CH_L1CA(1);
        if CH_in.SF_Complete == 1 % a whole subframe is received, 300 navBits in SFNav_prev are all valid.
    
            % navBits are saved on integer in C program by bit, should be transfer to matrix of matlab
            navBits = zeros(1,300);
            str1 = dec2bin(CH_in.SFNav_prev, 30); % a subframe contains 10 words, every word contains 30 bits

            for i = 1:300
                word_num = ceil(i/30);
                bit_pos = mod(i,30);
                if bit_pos == 0
                    bit_num = 1;
                else
                    bit_num = 31 - bit_pos;
                end
                navBits(i) = str2double(str1(word_num,bit_num));
            end

            [outbits,flag] = preable_OddEven(navBits); % Preamble verification and BCH decode, when flag is 0, the navbits is right
            if flag == 0
            % decode ephemeris
                bits = char(outbits+'0');
                [naviMsg.GPS_L1CA.almanac, naviMsg.GPS_L1CA.ephemeris(CH_in.PRNID), CH_in] = ...
                    GPS_all(bits, naviMsg.GPS_L1CA.almanac, naviMsg.GPS_L1CA.ephemeris(CH_in.PRNID), CH_in);
                    
            end  % flag == 0;
            CH_in.SF_Complete = 0; % wait for next complete subframe
        end 
        channel.CH_L1CA(1) = CH_in; 
    
    case 'GPS_L1CA_L2C'
        %双频时同样要解调NAV
        CH_in = channel.CH_L1CA_L2C(1);
        if CH_in.SF_Complete == 1 % a whole subframe is received, 300 navBits in SFNav_prev are all valid.
    
            % navBits are saved on integer in C program by bit, should be transfer to matrix of matlab
            navBits = zeros(1,300);
            str1 = dec2bin(CH_in.SFNav_prev, 30); % a subframe contains 10 words, every word contains 30 bits

            for i = 1:300
                word_num = ceil(i/30);
                bit_pos = mod(i,30);
                if bit_pos == 0
                    bit_num = 1;
                else
                    bit_num = 31 - bit_pos;
                end
                navBits(i) = str2double(str1(word_num,bit_num));
            end

            [outbits,flag] = preable_OddEven(navBits); % Preamble verification and BCH decode, when flag is 0, the navbits is right
            if flag == 0
            % decode ephemeris
                bits = char(outbits+'0');
                [naviMsg.GPS_L1CA.almanac, naviMsg.GPS_L1CA.ephemeris(CH_in.PRNID), CH_in] = ...
                    GPS_all(bits, naviMsg.GPS_L1CA.almanac, naviMsg.GPS_L1CA.ephemeris(CH_in.PRNID), CH_in);
                    
            end  % flag == 0;
            CH_in.SF_Complete = 0; % wait for next complete subframe
        end 
        channel.CH_L1CA_L2C(1) = CH_in; 
        
        %解调CNAV。由于卷积解码的延时，需要额外接收70个比特才能完成解调
        if (channel.CH_L1CA_L2C(1).Msg_Complete && channel.CH_L1CA_L2C(1).bitInMessage>=70)
            [naviMsg.GPS_L2C, SOW_CNAV] = CNAV_decoder(naviMsg.GPS_L2C, channel.CH_L1CA_L2C(1)); %周内秒咋用？
            channel.CH_L1CA_L2C(1).Msg_Complete = 0;
        end
        
    case 'BDS_B1I'
        CH_in = channel.CH_B1I(1);
        if CH_in.SF_Complete == 1 % a whole subframe is received, 300 navBits in SFNav_prev are all valid.
    
            % navBits are saved on integer in C program by bit, should be transfer to matrix of matlab
            navBits = zeros(1,300);
            str1 = dec2bin(CH_in.SFNav_prev, 30); % a subframe contains 10 words, every word contains 30 bits

            for i = 1:300
                word_num = ceil(i/30);
                bit_pos = mod(i,30);
                if bit_pos == 0
                    bit_num = 1;
                else
                    bit_num = 31 - bit_pos;
                end
                navBits(i) = str2double(str1(word_num,bit_num));
            end

            [outbits,flag] = preamble_BCH(navBits); % Preamble verification and BCH decode, when flag is 0, the navbits is right
            if flag == 0
            % decode ephemeris
                bits=char(outbits+'0');
                switch CH_in.navType
                    case 'B1I_D1'
                        [naviMsg.BDS_B1I.almanac, naviMsg.BDS_B1I.ephemeris(CH_in.PRNID), CH_in] = ...
                            ephemeris_d1_all(bits, naviMsg.BDS_B1I.almanac, naviMsg.BDS_B1I.ephemeris(CH_in.PRNID), CH_in);
                    case 'B1I_D2'
                        [naviMsg.BDS_B1I.almanac, naviMsg.BDS_B1I.ephemeris(CH_in.PRNID), CH_in] = ...
                            ephemeris_d2_all(bits, naviMsg.BDS_B1I.almanac, naviMsg.BDS_B1I.ephemeris(CH_in.PRNID), CH_in);
                end % switch
            end  % flag == 0;
            CH_in.SF_Complete = 0; % wait for next complete subframe
        end
       channel.CH_B1I(1) = CH_in; 
end

