function [recv_channel]=track_phase_ini(recv_channel)

switch recv_channel.SYST
    case 'GPS_L1CA'
        TimeLen = 0 - recv_channel.CH_L1CA.Samp_Posi;
        % 帧信息推算和校验
        [~, recv_channel.CH_L1CA] = hotInfoCheck(recv_channel.CH_L1CA, TimeLen, recv_channel.SYST,'NORM');               
        recv_channel.CH_L1CA.CN0_Estimator.muk_cnt = recv_channel.CH_L1CA.T1ms_N;
        recv_channel.CH_L1CA.Tcohn_cnt = mod(recv_channel.CH_L1CA.T1ms_N, recv_channel.CH_L1CA.Tcohn_N);
        %注意：channel中有许多counter，需要同步起来
        recv_channel.CH_L1CA.Trk_Count = recv_channel.CH_L1CA.T1ms_N;
        recv_channel.ALL.acnt = floor(recv_channel.CH_L1CA.T1ms_N/recv_channel.CH_L1CA.Tcohn_N);
        recv_channel.CH_L1CA.Samp_Posi = 0;
        
    case 'BDS_B1I'
        TimeLen = 0 - recv_channel.CH_B1I.Samp_Posi;
        % 帧信息推算和校验
        [~, recv_channel.CH_B1I] = hotInfoCheck(recv_channel.CH_B1I, TimeLen, recv_channel.SYST,'NORM');               
        recv_channel.CH_B1I.CN0_Estimator.muk_cnt = recv_channel.CH_B1I.T1ms_N;
        recv_channel.CH_B1I.Tcohn_cnt = mod(recv_channel.CH_B1I.T1ms_N, recv_channel.CH_B1I.Tcohn_N);
        %注意：channel中有许多counter，需要同步起来
        recv_channel.CH_B1I.Trk_Count = recv_channel.CH_B1I.T1ms_N;
        recv_channel.ALL.acnt = floor(recv_channel.CH_B1I.T1ms_N/recv_channel.CH_B1I.Tcohn_N);
        recv_channel.CH_B1I.Samp_Posi = 0;
        
    case 'GPS_L1CA_L2C' %acq_l1ca_l2c_hot 热捕成功后进入此处
        recv_channel.DLL.SPACING = 0.5;
        recv_channel.DLL.SPACING_MP = 0.5;
        recv_channel.CH_L1CA_L2C.CN0_Estimator.CN0EstActive = 1;
        recv_channel.CH_L1CA_L2C.CN0_Estimator.muk_cnt = recv_channel.CH_L1CA_L2C.T1ms_N;
        recv_channel.CH_L1CA_L2C.Tcohn_cnt = mod(recv_channel.CH_L1CA_L2C.T1ms_N, recv_channel.CH_L1CA_L2C.Tcohn_N);
        recv_channel.CH_L1CA_L2C.Trk_Count = recv_channel.CH_L1CA_L2C.T1ms_N;
        %recv_channel.ALL.acnt = floor(recv_channel.CH_L1CA_L2C.T1ms_N/recv_channel.CH_L1CA_L2C.Tcohn_N);
end
        






% switch recv_channel.SYST
%     case 'GPS_L1CA'
%         Fcode = recv_channel.CH_L1CA.LO_Fcode0 + recv_channel.CH_L1CA.LO_Fcode_fd; % 实际码率
%         Fcarri = recv_channel.CH_L1CA.LO2_IF0 + recv_channel.CH_L1CA.LO2_fd; % 实际码率
%         codePhase = Fcode/GSAR_CONSTANTS.STR_RECV.fs;   % 每个采样点间隔的码相位变化
%         carriPhase = Fcarri/GSAR_CONSTANTS.STR_RECV.fs;
%         codePhaseAll = recv_channel.CH_L1CA.Samp_Posi * codePhase; % 
%         carriPhaseAll = carriPhase * recv_channel.CH_L1CA.Samp_Posi;
%         phaseIndex = GSAR_CONSTANTS.STR_L1CA.ChipNum - mod(codePhaseAll,GSAR_CONSTANTS.STR_L1CA.ChipNum);
%         recv_channel.CH_L1CA.LO_CodPhs  = phaseIndex;
%         carriIndex = ceil(carriPhaseAll) - carriPhaseAll;
%         recv_channel.CH_L1CA.LO2_CarPhs  = carriIndex;
%         
%         T1msNum = floor((0-codePhaseAll)/GSAR_CONSTANTS.STR_L1CA.ChipNum); % 为负数，所以用floor
%         T1msIndex = mod(recv_channel.CH_L1CA.T1ms_N + T1msNum, 20);
%         bitNum = floor((recv_channel.CH_L1CA.T1ms_N+T1msNum)/20);% 往前推bit的总数量（由于比特同步后T1ms为0）       注意：由于结果为负数，所以用floor
%         recv_channel.CH_L1CA.T1ms_N = T1msIndex;
%         recv_channel.CH_L1CA.CN0_Estimator.muk_cnt = T1msIndex;
%         recv_channel.CH_L1CA.Tcohn_cnt = mod(T1msIndex, recv_channel.CH_L1CA.Tcohn_N);
%         
%         
%                     
%         
%         
%        
%         
%         % 热启动中所有帧参数都需要向前推算
%         % 
%         bitIndex = mod(recv_channel.CH_L1CA.Bit_N+bitNum, 30); % bitNum结果为负数,所以用+
%         wordNum = floor((recv_channel.CH_L1CA.Bit_N+bitNum)/30); % 和前面wordNum计算保持一致
%         recv_channel.CH_L1CA.Bit_N = bitIndex;  
%         
%         wordIndex = mod(recv_channel.CH_L1CA.Word_N+wordNum, 10);
%         subframeNum = floor((recv_channel.CH_L1CA.Word_N+wordNum)/10);
%         recv_channel.CH_L1CA.Word_N = wordIndex;
%         
%         subframeIndex = mod((recv_channel.CH_L1CA.SubFrame_N+subframeNum), 5);
%         recv_channel.CH_L1CA.SubFrame_N = subframeIndex;
%         % 推算SOW和WN值
%         recv_channel.CH_L1CA.TOW_6SEC = mod((recv_channel.CH_L1CA.TOW_6SEC+subframeNum), 100800);
%         recv_channel.CH_L1CA.WN = recv_channel.CH_L1CA.WN + floor((recv_channel.CH_L1CA.TOW_6SEC + subframeNum)/100800);
%         %注意：channel中有许多counter，需要同步起来
%         recv_channel.CH_L1CA.Trk_Count = recv_channel.CH_L1CA.T1ms_N;
%         recv_channel.ALL.acnt = floor(recv_channel.CH_L1CA.T1ms_N/recv_channel.CH_L1CA.Tcohn_N);
%         
%          recv_channel.CH_L1CA.Samp_Posi = 0;
%     case 'BDS_B1I'
%         Fcode = recv_channel.CH_B1I.LO_Fcode0 + recv_channel.CH_B1I.LO_Fcode_fd; % 实际码率
%         Fcarri = recv_channel.CH_B1I.LO2_IF0 + recv_channel.CH_B1I.LO2_fd; % 实际码率
%         codePhase = Fcode/GSAR_CONSTANTS.STR_RECV.fs;   % 每个采样点间隔的码相位变化
%         carriPhase = Fcarri/GSAR_CONSTANTS.STR_RECV.fs;
%         codePhaseAll = recv_channel.CH_B1I.Samp_Posi * codePhase; % 
%         carriPhaseAll = carriPhase * recv_channel.CH_B1I.Samp_Posi;
%         if strcmp(recv_channel.CH_B1I.navType,'B1I_D1')
%             T1msIndex = floor(codePhaseAll/GSAR_CONSTANTS.STR_B1I.ChipNum);  % 
%             bitNum = floor((0-T1msIndex)/20);    % 往前推bit的总数量       注意：由于结果为负数，所以用floor
%             T1msIndex = 19 - mod(T1msIndex,20);
%              % 热启动中所有帧参数都需要向前推算
%             bitIndex = mod(recv_channel.CH_B1I.Bit_N+bitNum, 30); % bitNum结果为负数,所以用+
%             wordNum = floor((recv_channel.CH_B1I.Bit_N+bitNum)/30); % 和前面wordNum计算保持一致
%             recv_channel.CH_B1I.Bit_N = bitIndex;
%             
%             wordIndex = mod(recv_channel.CH_B1I.Word_N+wordNum, 10);
%             subframeNum = floor((recv_channel.CH_B1I.Word_N+wordNum)/10);
%             recv_channel.CH_B1I.Word_N = wordIndex;
%             
%             subframeIndex = mod((recv_channel.CH_B1I.SubFrame_N+subframeNum), 5);
%             frameNum = floor((recv_channel.CH_B1I.SubFrame_N+subframeNum)/5);
%             recv_channel.CH_B1I.SubFrame_N = subframeIndex;
%             
%             frameIndex = mod((recv_channel.CH_B1I.Frame_N+frameNum), 24);   % D1有24个主帧
%             recv_channel.CH_B1I.Frame_N = frameIndex;
%             % 推算SOW和WN值
%             recv_channel.CH_B1I.SOW = mod((recv_channel.CH_B1I.SOW+subframeNum*6), 604800);
%             recv_channel.CH_B1I.WN = recv_channel.CH_B1I.WN + floor((recv_channel.CH_B1I.SOW + subframeNum*6)/604800);
%         else
%             T1msIndex = floor(codePhaseAll/GSAR_CONSTANTS.STR_B1I.ChipNum);  % 
%             bitNum = floor((0-T1msIndex)/2);    % 往前推bit的总数量       注意：由于结果为负数，所以用floor
%             T1msIndex = 1 - mod(T1msIndex,2);
%              % 热启动中所有帧参数都需要向前推算
%             bitIndex = mod(recv_channel.CH_B1I.Bit_N+bitNum, 30); % bitNum结果为负数,所以用+
%             wordNum = floor((recv_channel.CH_B1I.Bit_N+bitNum)/30); % 和前面wordNum计算保持一致
%             recv_channel.CH_B1I.Bit_N = bitIndex;
%             
%             wordIndex = mod(recv_channel.CH_B1I.Word_N+wordNum, 10);
%             subframeNum = floor((recv_channel.CH_B1I.Word_N+wordNum)/10);
%             recv_channel.CH_B1I.Word_N = wordIndex;
%             
%             subframeIndex = mod((recv_channel.CH_B1I.SubFrame_N+subframeNum), 5);
%             frameNum = floor((recv_channel.CH_B1I.SubFrame_N+subframeNum)/5);
%             recv_channel.CH_B1I.SubFrame_N = subframeIndex;
%             
%             frameIndex = mod((recv_channel.CH_B1I.Frame_N+frameNum), 120);   % D2有120个主帧
%             recv_channel.CH_B1I.Frame_N = frameIndex;
%             % 推算SOW和WN值
%             recv_channel.CH_B1I.SOW = mod((recv_channel.CH_B1I.SOW+frameNum*3), 604800);
%             recv_channel.CH_B1I.WN = recv_channel.CH_B1I.WN + floor((recv_channel.CH_B1I.SOW + frameNum*3)/604800);
%         end
%         phaseIndex = GSAR_CONSTANTS.STR_B1I.ChipNum - mod(codePhaseAll,GSAR_CONSTANTS.STR_B1I.ChipNum);
%         carriIndex = ceil(carriPhaseAll) - carriPhaseAll;
%         recv_channel.CH_B1I.T1ms_N = T1msIndex;
%         recv_channel.CH_B1I.CN0_Estimator.muk_cnt = T1msIndex;
%         recv_channel.CH_B1I.Tcohn_cnt = mod(T1msIndex, recv_channel.CH_B1I.Tcohn_N);
%         recv_channel.CH_B1I.LO_CodPhs  = phaseIndex;
%         recv_channel.CH_B1I.Samp_Posi = 0;
%         recv_channel.CH_B1I.LO2_CarPhs  = carriIndex;
%         %注意：channel中有许多counter，需要同步起来
%         recv_channel.CH_B1I.Trk_Count = recv_channel.CH_B1I.T1ms_N;
%         recv_channel.ALL.acnt = floor(recv_channel.CH_B1I.T1ms_N/recv_channel.CH_B1I.Tcohn_N);
% end