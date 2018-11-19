function predictInfo = framePredict(oldInfo, TimeLen, codeDopp, carriDopp, SYST, prn, mode)
%共分为三种模式，ACQ，BITSYNC，NORM
%分别对应捕获成功后、bite同步成功后，和标准模式三种
%
%
%
%
% 推算帧信息
global GSAR_CONSTANTS;
predictInfo = struct( ...
    'WN',                    0,                 ...Week number counter
    'SOW',                   0,                 ...Second number counter of current subframe beginning in a week
    'Frame_N',               0,                 ...Frame counter, 0~23 for D1, 0~119 for D2
    'SubFrame_N',            0,                 ...Frame counter, 0~4
    'Word_N',                0,                 ...word counter,0~9
    'Bit_N',                 0,                 ...navigation bit counter in a word,0~29       
    'T1ms_N',                0,                 ...PRN period counter in a bit, 0~19 for D1, 0~1 for D2
    'bitInMessage',          0,                 ...
    'CM_in_CL',              0,                 ...
    'codePhase',             0,                 ...
    'carriPhase',            0,                 ...
    'carriDopp',             0,                 ...
    'codeDopp',              0                  ...
    );

elapseTime = TimeLen / GSAR_CONSTANTS.STR_RECV.fs; % 失锁检测器保存时间后经过的时间 / 数据捕获所使用的时间  
predictInfo.carriDopp = carriDopp;
predictInfo.codeDopp = codeDopp;

switch SYST
    case 'BDS_B1I'
        % 各参数信息推算
        carriPhaseAll = (carriDopp+GSAR_CONSTANTS.STR_RECV.IF_B1I)*elapseTime;
        codePhaseAll = (codeDopp+GSAR_CONSTANTS.STR_B1I.Fcode0)*elapseTime; 
        predictInfo.codePhase = mod((oldInfo.codePhase + codePhaseAll), GSAR_CONSTANTS.STR_B1I.ChipNum);
        predictInfo.carriPhase = mod(oldInfo.carriPhase+carriPhaseAll, 1);
        if strcmp(mode, 'ACQ') || strcmp(mode, 'BITSYNC')
            % 若推算正确，则codePhase应该在0附近波动，所以采用round
            T1ms_N_Num = round((oldInfo.codePhase + codePhaseAll)/GSAR_CONSTANTS.STR_B1I.ChipNum); % T1ms_N的个数
        elseif strcmp(mode, 'NORM')
            T1ms_N_Num = floor((oldInfo.codePhase + codePhaseAll)/GSAR_CONSTANTS.STR_B1I.ChipNum); % T1ms_N的个数
        end
        if prn <= 5
            predictInfo.T1ms_N = mod(oldInfo.T1ms_N+T1ms_N_Num, 2);
            if strcmp(mode, 'ACQ') || strcmp(mode, 'NORM')
                bit_Num = floor((oldInfo.T1ms_N+T1ms_N_Num)/2); % bit的个数
            elseif strcmp(mode, 'BITSYNC')
                bit_Num = round((oldInfo.T1ms_N+T1ms_N_Num)/2); % bit的个数
            end
        else
            predictInfo.T1ms_N = mod(oldInfo.T1ms_N+T1ms_N_Num, 20);
            if strcmp(mode, 'ACQ') || strcmp(mode, 'NORM')
                bit_Num = floor((oldInfo.T1ms_N+T1ms_N_Num)/20); % bit的个数
            elseif strcmp(mode, 'BITSYNC')
                bit_Num = round((oldInfo.T1ms_N+T1ms_N_Num)/20); % bit的个数
            end
        end
        predictInfo.Bit_N = mod((oldInfo.Bit_N+bit_Num), 30);
        word_Num = floor((oldInfo.Bit_N+bit_Num)/30);% word的个数
        predictInfo.Word_N = mod((oldInfo.Word_N+word_Num), 10);
        SubFrame_N_Num = floor((oldInfo.Word_N+word_Num)/10);
        predictInfo.SubFrame_N = mod((oldInfo.SubFrame_N+SubFrame_N_Num), 5);
        Frame_N_Num = floor((oldInfo.SubFrame_N+SubFrame_N_Num)/5);
        if prn <= 5
            predictInfo.Frame_N = mod((oldInfo.Frame_N+Frame_N_Num), 120);  % D2有120个主帧
            predictInfo.SOW = mod((oldInfo.SOW + Frame_N_Num*3), 604800);    % 3s per frame in D2
            predictInfo.WN = oldInfo.WN + floor((oldInfo.SOW + Frame_N_Num*3)/604800);
        else
            predictInfo.Frame_N = mod((oldInfo.Frame_N+Frame_N_Num), 24);   % D1有24个主帧
            predictInfo.SOW = mod((oldInfo.SOW + SubFrame_N_Num*6), 604800);    % 6s per subframe in D1
            predictInfo.WN = oldInfo.WN + floor((oldInfo.SOW + SubFrame_N_Num*6)/604800);
        end
       
        
    case 'GPS_L1CA'
        carriPhaseAll = (predictInfo.carriDopp+GSAR_CONSTANTS.STR_RECV.IF_L1CA)*elapseTime;
        codePhaseAll = (predictInfo.codeDopp+GSAR_CONSTANTS.STR_L1CA.Fcode0)*elapseTime; 
        predictInfo.codePhase = mod((oldInfo.codePhase + codePhaseAll), GSAR_CONSTANTS.STR_L1CA.ChipNum);
        predictInfo.carriPhase = mod(oldInfo.carriPhase+carriPhaseAll, 1);
        if strcmp(mode, 'ACQ') || strcmp(mode, 'BITSYNC')
            T1ms_N_Num = round((oldInfo.codePhase + codePhaseAll)/GSAR_CONSTANTS.STR_L1CA.ChipNum);
        elseif strcmp(mode, 'NORM')
            T1ms_N_Num = floor((oldInfo.codePhase + codePhaseAll)/GSAR_CONSTANTS.STR_L1CA.ChipNum); % T1ms_N的个数
        end
        predictInfo.T1ms_N = mod(oldInfo.T1ms_N+T1ms_N_Num, 20);
        if strcmp(mode, 'ACQ') || strcmp(mode, 'NORM')
            bit_Num = floor((oldInfo.T1ms_N+T1ms_N_Num)/20); % bit的个数
        elseif strcmp(mode, 'BITSYNC')
            bit_Num = round((oldInfo.T1ms_N+T1ms_N_Num)/20); % bit的个数
        end
        predictInfo.Bit_N = mod((oldInfo.Bit_N+bit_Num), 30);
        word_Num = floor((oldInfo.Bit_N+bit_Num)/30);
        predictInfo.Word_N = mod((oldInfo.Word_N+word_Num), 10);
        SubFrame_N_Num = floor((oldInfo.Word_N+word_Num)/10);
        predictInfo.SubFrame_N = mod((oldInfo.SubFrame_N+SubFrame_N_Num), 5);
        Frame_N_Num = floor((oldInfo.SubFrame_N+SubFrame_N_Num)/5);
        predictInfo.Frame_N = oldInfo.Frame_N+Frame_N_Num;
        predictInfo.SOW = mod((oldInfo.SOW + SubFrame_N_Num), 100800);    % GPS中SOW计数每6s加1
        predictInfo.WN = oldInfo.WN + floor((oldInfo.SOW + SubFrame_N_Num)/100800);
        
    case 'GPS_L1CA_L2C'
        predictInfo.codeDopp = predictInfo.carriDopp / 1540;
        codePhaseAll = (predictInfo.codeDopp+GSAR_CONSTANTS.STR_L1CA.Fcode0)*elapseTime; 
        predictInfo.codePhase = mod((oldInfo.codePhase + codePhaseAll), GSAR_CONSTANTS.STR_L1CA.ChipNum);

        if strcmp(mode, 'ACQ') || strcmp(mode, 'BITSYNC')
            T1ms_N_Num = round((oldInfo.codePhase + codePhaseAll)/GSAR_CONSTANTS.STR_L1CA.ChipNum);
        elseif strcmp(mode, 'NORM')
            T1ms_N_Num = floor((oldInfo.codePhase + codePhaseAll)/GSAR_CONSTANTS.STR_L1CA.ChipNum); % T1ms_N的个数
        end
        
        predictInfo.T1ms_N = mod(oldInfo.T1ms_N+T1ms_N_Num, 20);
        if strcmp(mode, 'ACQ') || strcmp(mode, 'NORM')
            bit_Num = floor((oldInfo.T1ms_N+T1ms_N_Num)/20); % bit的个数
        elseif strcmp(mode, 'BITSYNC')
            bit_Num = round((oldInfo.T1ms_N+T1ms_N_Num)/20); % bit的个数
        end
        predictInfo.bitInMessage = mod((oldInfo.bitInMessage+bit_Num), 600);
        predictInfo.CM_in_CL = mod((oldInfo.CM_in_CL+bit_Num), 75);
        predictInfo.Bit_N = mod((oldInfo.Bit_N+bit_Num), 30);
        word_Num = floor((oldInfo.Bit_N+bit_Num)/30);
        predictInfo.Word_N = mod((oldInfo.Word_N+word_Num), 10);
        SubFrame_N_Num = floor((oldInfo.Word_N+word_Num)/10);
        predictInfo.SubFrame_N = mod((oldInfo.SubFrame_N+SubFrame_N_Num), 5);
        Frame_N_Num = floor((oldInfo.SubFrame_N+SubFrame_N_Num)/5);
        predictInfo.Frame_N = oldInfo.Frame_N+Frame_N_Num;
        predictInfo.SOW = mod((oldInfo.SOW + SubFrame_N_Num), 100800);    % GPS中SOW计数每6s加1
        predictInfo.WN = oldInfo.WN + floor((oldInfo.SOW + SubFrame_N_Num)/100800);
               
end % EOF：switch SYST