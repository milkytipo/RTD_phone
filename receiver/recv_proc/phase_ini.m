function [recv_channel]=phase_ini(recv_channel)
global GSAR_CONSTANTS;
switch recv_channel.SYST
    case 'GPS_L1CA'
        Fcode = recv_channel.CH_L1CA.LO_Fcode0 + recv_channel.CH_L1CA.LO_Fcode_fd; % 实际码率
        Fcarri = recv_channel.CH_L1CA.LO2_IF0 + recv_channel.CH_L1CA.LO2_fd; % 实际码率
        codePhase = Fcode/GSAR_CONSTANTS.STR_RECV.fs;   % 每个采样点间隔的码相位变化
        carriPhase = Fcarri/GSAR_CONSTANTS.STR_RECV.fs;
        codePhaseAll = recv_channel.CH_L1CA.Samp_Posi * codePhase; % 
        carriPhaseAll = carriPhase * recv_channel.CH_L1CA.Samp_Posi;
        T1msIndex = floor(codePhaseAll/GSAR_CONSTANTS.STR_L1CA.ChipNum);  % 
        T1msIndex = 19 - mod(T1msIndex,20);
        phaseIndex = GSAR_CONSTANTS.STR_L1CA.ChipNum - mod(codePhaseAll,GSAR_CONSTANTS.STR_L1CA.ChipNum);
        carriIndex = ceil(carriPhaseAll) - carriPhaseAll;
        recv_channel.CH_L1CA.T1ms_N = T1msIndex;
        recv_channel.CH_L1CA.CN0_Estimator.muk_cnt = T1msIndex;
        recv_channel.CH_L1CA.Tcohn_cnt = mod(T1msIndex, recv_channel.CH_L1CA.Tcohn_N);
        recv_channel.CH_L1CA.LO_CodPhs  = phaseIndex;
        recv_channel.CH_L1CA.Samp_Posi = 0;
        recv_channel.CH_L1CA.LO2_CarPhs  = carriIndex;
        %注意：channel中有许多counter，需要同步起来
        recv_channel.CH_L1CA.Trk_Count = recv_channel.CH_L1CA.T1ms_N;
        recv_channel.ALL.acnt = recv_channel.CH_L1CA.Tcohn_N*floor(recv_channel.CH_L1CA.T1ms_N/recv_channel.CH_L1CA.Tcohn_N);
        
    case 'GPS_L1CA_L2C'
        Fcode = recv_channel.CH_L1CA_L2C.LO_Fcode0 + recv_channel.CH_L1CA_L2C.LO_Fcode_fd; % 实际码率
        codePhase = Fcode/GSAR_CONSTANTS.STR_RECV.fs;   % 每个采样点间隔的码相位变化
        codePhaseAll = recv_channel.CH_L1CA_L2C.Samp_Posi * codePhase; %回推的码片数

        T1msIndex = ceil(codePhaseAll/GSAR_CONSTANTS.STR_L1CA.ChipNum);  %回推的CA码周期数，取ceil
        T1msIndex = mod(20-T1msIndex,20);  %%回推后的CA码在比特中的位置 0~19        
        phaseIndex = mod( GSAR_CONSTANTS.STR_L1CA.ChipNum-codePhaseAll, GSAR_CONSTANTS.STR_L1CA.ChipNum); %回推后的码相位 0~1022.9999
 
        recv_channel.CH_L1CA_L2C.T1ms_N = T1msIndex;  %比特内毫秒数
        recv_channel.CH_L1CA_L2C.CN0_Estimator.muk_cnt = T1msIndex; %载噪比估计计数器
        recv_channel.CH_L1CA_L2C.Trk_Count = T1msIndex;  %总积分次数计数器
        recv_channel.CH_L1CA_L2C.Tcohn_cnt = mod(T1msIndex, recv_channel.CH_L1CA.Tcohn_N); %相干积分时间内的1ms积分次数
        recv_channel.CH_L1CA_L2C.LO_CodPhs  = phaseIndex;
        recv_channel.CH_L1CA_L2C.Samp_Posi = 0;
        
        
        recv_channel.CH_L1CA_L2C.CM_in_CL = floor(recv_channel.CH_L1CA_L2C.CL_time/0.02);
        recv_channel.CH_L1CA_L2C.bitInMessage = recv_channel.CH_L1CA_L2C.CM_in_CL;
        recv_channel.CH_L1CA_L2C.Bit_N = mod(recv_channel.CH_L1CA_L2C.CM_in_CL,30);
        recv_channel.CH_L1CA_L2C.Word_N = floor(recv_channel.CH_L1CA_L2C.CM_in_CL/30);
        %recv_channel.CH_L1CA_L2C.LO_CodPhs_L2 = recv_channel.CH_L1CA_L2C.CL_time * GSAR_CONSTANTS.STR_L1CA.Fcode0; %CL码相位，0~1534499.9999
        recv_channel.CH_L1CA_L2C.LO_CodPhs_L2 = 20460*recv_channel.CH_L1CA_L2C.CM_in_CL + 1023*T1msIndex + phaseIndex;
        recv_channel.CH_L1CA_L2C.CL_time = -1;
        
        %recv_channel.ALL.acnt = floor(recv_channel.CH_L1CA.T1ms_N/recv_channel.CH_L1CA.Tcohn_N);
        
    case 'BDS_B1I'
        Fcode = recv_channel.CH_B1I.LO_Fcode0 + recv_channel.CH_B1I.LO_Fcode_fd; % 实际码率
        Fcarri = recv_channel.CH_B1I.LO2_IF0 + recv_channel.CH_B1I.LO2_fd; % 实际码率
        codePhase = Fcode/GSAR_CONSTANTS.STR_RECV.fs;   % 每个采样点间隔的码相位变化
        carriPhase = Fcarri/GSAR_CONSTANTS.STR_RECV.fs;
        codePhaseAll = recv_channel.CH_B1I.Samp_Posi * codePhase; % 
        carriPhaseAll = carriPhase * recv_channel.CH_B1I.Samp_Posi;
        if strcmp(recv_channel.CH_B1I.navType,'B1I_D1')
            T1msIndex = floor(codePhaseAll/GSAR_CONSTANTS.STR_B1I.ChipNum);  % 
            T1msIndex = 19 - mod(T1msIndex,20);
        else
            T1msIndex = floor(codePhaseAll/GSAR_CONSTANTS.STR_B1I.ChipNum);  % 
            T1msIndex = 1 - mod(T1msIndex,2);
        end
        phaseIndex = GSAR_CONSTANTS.STR_B1I.ChipNum - mod(codePhaseAll,GSAR_CONSTANTS.STR_B1I.ChipNum);
        carriIndex = ceil(carriPhaseAll) - carriPhaseAll;
        recv_channel.CH_B1I.T1ms_N = T1msIndex;
        recv_channel.CH_B1I.CN0_Estimator.muk_cnt = T1msIndex;
        recv_channel.CH_B1I.Tcohn_cnt = mod(T1msIndex, recv_channel.CH_B1I.Tcohn_N);
        recv_channel.CH_B1I.LO_CodPhs  = phaseIndex;
        recv_channel.CH_B1I.Samp_Posi = 0;
        recv_channel.CH_B1I.LO2_CarPhs  = carriIndex;
        %注意：channel中有许多counter，需要同步起来
        recv_channel.CH_B1I.Trk_Count = recv_channel.CH_B1I.T1ms_N;
        recv_channel.ALL.acnt = recv_channel.CH_B1I.Tcohn_N*floor(recv_channel.CH_B1I.T1ms_N/recv_channel.CH_B1I.Tcohn_N);%% This code has bugs
end