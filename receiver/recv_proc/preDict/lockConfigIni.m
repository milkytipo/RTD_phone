function [lockConfig, lockDect] = lockConfigIni(lockDect, GSAR_CONSTANTS, prn, SYST, N)

lockConfig = struct( ...
    'WN',                    0,                 ...Week number counter
    'SOW',                   0,                 ...Second number counter of current subframe beginning in a week
    'Frame_N',               0,                 ...Frame counter, 0~23 for D1, 0~119 for D2
    'SubFrame_N',            0,                 ...Frame counter, 0~4
    'Word_N',                0,                 ...word counter,0~9
    'Bit_N',                 0,                 ...navigation bit counter in a word,0~29       
    'T1ms_N',                0,                 ...PRN period counter in a bit, 0~19 for D1, 0~1 for D2
    'codePhase',             0,                 ...
    'carriPhase',            0,                 ...
    'carriDopp',             0,                 ...
    'codeDopp',              0                  ...
    );
elapseTime = lockDect.lockTime/GSAR_CONSTANTS.STR_RECV.fs;
lockConfig.codeDopp = lockDect.codeDopp;
lockConfig.carriDopp = lockDect.carriDopp;
switch SYST
    case 'BDS_B1I'
        carriPhaseAll = (lockDect.carriDopp+GSAR_CONSTANTS.STR_RECV.IF_B1I)*elapseTime;
        codePhaseAll = (lockDect.codeDopp+GSAR_CONSTANTS.STR_B1I.Fcode0)*elapseTime; 
        lockConfig.codePhase = mod((lockDect.codePhase + codePhaseAll), GSAR_CONSTANTS.STR_B1I.ChipNum);
        lockConfig.carriPhase = lockDect.carriPhase + carriPhaseAll - floor(lockDect.carriPhase + carriPhaseAll);
        T1ms_N_Num = floor((lockDect.codePhase + codePhaseAll)/GSAR_CONSTANTS.STR_B1I.ChipNum); % T1ms_N的个数
        if prn <= 5
            lockConfig.T1ms_N = mod(lockDect.T1ms_N+T1ms_N_Num, 2);
            bit_Num = floor((lockDect.T1ms_N+T1ms_N_Num)/2); % bit的个数
        else
            lockConfig.T1ms_N = mod(lockDect.T1ms_N+T1ms_N_Num, 20);
            bit_Num = floor((lockDect.T1ms_N+T1ms_N_Num)/20);
        end
        lockConfig.Bit_N = mod((lockDect.Bit_N+bit_Num), 30);
        word_Num = floor((lockDect.Bit_N+bit_Num)/30);% word的个数
        lockConfig.Word_N = mod((lockDect.Word_N+word_Num), 10);
        SubFrame_N_Num = floor((lockDect.Word_N+word_Num)/10);
        lockConfig.SubFrame_N = mod((lockDect.SubFrame_N+SubFrame_N_Num), 5);
        Frame_N_Num = floor((lockDect.SubFrame_N+SubFrame_N_Num)/5);
        if prn <= 5
            lockConfig.Frame_N = mod((lockDect.Frame_N+Frame_N_Num), 120);  % D2有120个主帧
            lockConfig.SOW = mod((lockDect.SOW + Frame_N_Num*3), 604800);    % 3s per frame in D2
            lockConfig.WN = lockDect.WN + floor((lockDect.SOW + Frame_N_Num*3)/604800);
        else
            lockConfig.Frame_N = mod((lockDect.Frame_N+Frame_N_Num), 24);   % D1有24个主帧
            lockConfig.SOW = mod((lockDect.SOW + SubFrame_N_Num*6), 604800);    % 6s per subframe in D1
            lockConfig.WN = lockDect.WN + floor((lockDect.SOW + SubFrame_N_Num*6)/604800);
        end
        % lockDect反馈
        lockDect.WN = lockConfig.WN;
        lockDect.SOW = lockConfig.SOW;
        lockDect.Frame_N = lockConfig.Frame_N;
        lockDect.SubFrame_N = lockConfig.SubFrame_N;
        lockDect.Word_N = lockConfig.Word_N;
        lockDect.Bit_N = lockConfig.Bit_N;
        lockDect.T1ms_N = lockConfig.T1ms_N;
        lockDect.WN = lockConfig.WN;
        lockDect.codePhase = lockConfig.codePhase;
        lockDect.carriPhase = lockConfig.carriPhase;
    case 'GPS_L1CA'
        carriPhaseAll = (lockDect.carriDopp+GSAR_CONSTANTS.STR_RECV.IF_L1CA)*elapseTime;
        codePhaseAll = (lockDect.codeDopp+GSAR_CONSTANTS.STR_L1CA.Fcode0)*elapseTime; 
        lockConfig.codePhase = mod((lockDect.codePhase + codePhaseAll), GSAR_CONSTANTS.STR_L1CA.ChipNum);
        lockConfig.carriPhase = lockDect.carriPhase + carriPhaseAll - floor(lockDect.carriPhase + carriPhaseAll);
        T1ms_N_Num = floor((lockDect.codePhase + codePhaseAll)/GSAR_CONSTANTS.STR_L1CA.ChipNum);
        lockConfig.T1ms_N = mod(lockDect.T1ms_N+T1ms_N_Num, 20);
        bit_Num = floor((lockDect.T1ms_N+T1ms_N_Num)/20);
        lockConfig.Bit_N = mod((lockDect.Bit_N+bit_Num), 30);
        word_Num = floor((lockDect.Bit_N+bit_Num)/30);
        lockConfig.Word_N = mod((lockDect.Word_N+word_Num), 10);
        SubFrame_N_Num = floor((lockDect.Word_N+word_Num)/10);
        lockConfig.SubFrame_N = mod((lockDect.SubFrame_N+SubFrame_N_Num), 5);
        Frame_N_Num = floor((lockDect.SubFrame_N+SubFrame_N_Num)/5);
        lockConfig.Frame_N = lockDect.Frame_N+Frame_N_Num;
        lockConfig.SOW = mod((lockDect.SOW + SubFrame_N_Num), 100800);    % GPS中SOW计数每6s加1
        lockConfig.WN = lockDect.WN + floor((lockDect.SOW + SubFrame_N_Num)/100800);    
         % lockDect反馈
        lockDect.WN = lockConfig.WN;
        lockDect.SOW = lockConfig.SOW;
        lockDect.Frame_N = lockConfig.Frame_N;
        lockDect.SubFrame_N = lockConfig.SubFrame_N;
        lockDect.Word_N = lockConfig.Word_N;
        lockDect.Bit_N = lockConfig.Bit_N;
        lockDect.T1ms_N = lockConfig.T1ms_N;
        lockDect.WN = lockConfig.WN;
        lockDect.codePhase = lockConfig.codePhase;
        lockDect.carriPhase = lockConfig.carriPhase;
end % EOF: switch SYST


end % EOF: function




