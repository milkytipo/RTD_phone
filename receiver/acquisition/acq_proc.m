function [channel] = acq_proc(config, channel, satelliteTable, sis, N)
global GSAR_CONSTANTS;

%% ———————————————————————— GPS L1 通道捕获 ————————————————————————%  
if strcmp(channel.SYST, 'GPS_L1CA')
    % Acquisition for GPS L1 C/A signal
    [channel.CH_L1CA, channel.CH_L1CA.acq.acqResults] = acquireGPS(channel.CH_L1CA, sis, channel.CH_L1CA.acq.acqResults, channel.bpSampling_OddFold, config.logConfig);
    
    %———————————————————————— 信号捕获成功 ————————————————————————%   
    if (channel.CH_L1CA.acq.acqResults.acqed == 1) % 信号捕获成功
        if channel.CH_L1CA.acq.acqID == 0
            channel.CH_L1CA.LO2_fd = channel.CH_L1CA.LO2_fd + channel.CH_L1CA.acq.acqResults.doppler; % + acq_cfg.oscOffset;
            channel.CH_L1CA.LO_Fcode_fd = channel.bpSampling_OddFold * channel.CH_L1CA.LO2_fd / GSAR_CONSTANTS.STR_L1CA.L0Fc0_R;
            channel.CH_L1CA.LO_CodPhs = 0;
            channel.CH_L1CA.CN0_Estimator.CN0 = 10 * log10(channel.CH_L1CA.acq.acqResults.snr / channel.CH_L1CA.acq.acq_parameters.tcoh);
            channel.CH_L1CA.Samp_Posi = channel.CH_L1CA.Samp_Posi + channel.CH_L1CA.acq.acqResults.codeIdx;
            channel.CH_L1CA.acq.TimeLen = channel.CH_L1CA.acq.TimeLen + channel.CH_L1CA.acq.acqResults.codeIdx;
            channel.CH_L1CA.Samp_Posi = channel.CH_L1CA.Samp_Posi - channel.CH_L1CA.acq.resiN;      % 扣除resiData中的数据点数
            channel.CH_L1CA.acq.resiN = 0;
            channel.CH_L1CA.acq.acqID = 1;
            channel.CH_L1CA.acq.resiData = [];
            channel.CH_L1CA.acq.corrtmp = [];
            channel.CH_L1CA.acq.corr = [];
        end
        while (channel.CH_L1CA.Samp_Posi < 0)
            nPerCode = round(1/(GSAR_CONSTANTS.STR_L1CA.Fcode0+channel.CH_L1CA.LO_Fcode_fd)*GSAR_CONSTANTS.STR_L1CA.ChipNum*GSAR_CONSTANTS.STR_RECV.RECV_fs0);%考虑多普勒频移后的1个ca码采样点数
            channel.CH_L1CA.Samp_Posi = channel.CH_L1CA.Samp_Posi + nPerCode;
            channel.CH_L1CA.acq.TimeLen = channel.CH_L1CA.acq.TimeLen + nPerCode;
        end
        if channel.CH_L1CA.Samp_Posi >= N
            if strcmp(channel.STATUS, 'COLD_ACQ')
                channel.STATUS = 'COLD_ACQ';
            elseif strcmp(channel.STATUS, 'COLD_ACQ_AGAIN')
                channel.STATUS = 'COLD_ACQ_AGAIN';
            elseif strcmp(channel.STATUS, 'HOT_ACQ')
                channel.STATUS = 'HOT_ACQ'; 
            end
            channel.CH_L1CA.Samp_Posi =  channel.CH_L1CA.Samp_Posi - N;
        else
    %———————————————————————— bit同步配置 ————————————————————————% 
            if strcmp(channel.STATUS, 'COLD_ACQ') || strcmp(channel.STATUS, 'COLD_ACQ_AGAIN')               % 冷启动捕获成功
                channel.CH_L1CA.acq.ACQ_STATUS = 1; %精捕获
            
            elseif strcmp(channel.STATUS, 'HOT_ACQ')            % 热启动捕获成功
                channel.STATUS = 'HOT_BIT_SYNC';
                channel.CH_L1CA.CH_STATUS = channel.STATUS;
                channel = hotBitSync_init(channel, config); % 失锁重补条件下参数配置
                timeLen = round(channel.CH_L1CA.acq.TimeLen); % 若捕获时长大于N，则在每次进入channel_scheduler中会做N点推算
                [verify, channel.CH_L1CA] = hotInfoCheck(channel.CH_L1CA, timeLen, channel.SYST,'ACQ'); % 检验热启动所预测的各项参数的正确性
            end
%             fprintf('                    GPS PRN%d AcqResults -- CodeIndx: %d ; Doppler: %.2fHz ; CN0: %.1fdB \n', ...
%                 channel.CH_L1CA.PRNID, channel.CH_L1CA.Samp_Posi, channel.bpSampling_OddFold*channel.CH_L1CA.LO2_fd, channel.CH_L1CA.CN0_Estimator.CN0);
            fprintf('CodeIndx: %d ; Doppler: %.2fHz ; CN0: %.1fdB \n', ...
                channel.CH_L1CA.Samp_Posi, channel.bpSampling_OddFold*channel.CH_L1CA.LO2_fd, channel.CH_L1CA.CN0_Estimator.CN0);
        end
        
    %———————————————————————— 信号捕获失败 ————————————————————————% 
    elseif (channel.CH_L1CA.acq.acqResults.acqed == -1) % 信号捕获失败
        if strcmp(channel.STATUS, 'COLD_ACQ')           % 冷捕获失败
            if satelliteTable(2).satVisible(channel.CH_L1CA.PRNID)==1 % 若判断卫星可见则捕获两次
                channel.STATUS = 'COLD_ACQ_AGAIN';
                channel.CH_L1CA.CH_STATUS = channel.STATUS;
                channel.CH_L1CA.acq.acqResults.acqed = 0;   % 捕获初始化
                channel.CH_L1CA.Samp_Posi = 0; % Ensure reacquisition not exceed index limit
            else
                channel.STATUS = 'ACQ_FAIL';
                channel.CH_L1CA.CH_STATUS = channel.STATUS;
                channel.CH_L1CA.Samp_Posi = 0; % Ensure reacquisition not exceed index limit
            end
        elseif strcmp(channel.STATUS, 'COLD_ACQ_AGAIN')     % 重捕获失败
            channel.STATUS = 'ACQ_FAIL';
            channel.CH_L1CA.CH_STATUS = channel.STATUS;
            channel.CH_L1CA.Samp_Posi = 0; % Ensure reacquisition not exceed index limit
      %———————————————————————— 热捕获失败 ————————————————————————% 
        elseif strcmp(channel.STATUS, 'HOT_ACQ')            % 热捕获失败
            if channel.CH_L1CA.acq.hotWaitTime==-9999   % 首次热捕获失败
                channel.STATUS = 'HOT_ACQ_WAIT';
                channel.CH_L1CA.CH_STATUS = channel.STATUS;
                channel.CH_L1CA.acq.hotWaitTime = config.recvConfig.hotTime;
                channel.CH_L1CA.acq.hotAcqTime = config.recvConfig.hotAcqPeriod;
                channel.CH_L1CA.acq.acqResults.acqed = 0;   % 捕获初始化
            else
                channel.STATUS = 'HOT_ACQ_WAIT';
                channel.CH_L1CA.CH_STATUS = channel.STATUS; 
                channel.CH_L1CA.acq.hotAcqTime = config.recvConfig.hotAcqPeriod;
                channel.CH_L1CA.acq.acqResults.acqed = 0;   % 捕获初始化
            end

        end% EOF: if strcmp(channel.STATUS, 'COLD_ACQ')% 冷捕获失败
    end % EOF: if (channel.CH_L1CA.acq.acqResults.acqed == 1)
end  % EOF: if strcmp(channel.SYST, 'GPS_L1CA')
    
%% ———————————————————————— GPS L1_L2C 通道捕获 ————————————————————————%
if strcmp(channel.SYST, 'GPS_L1CA_L2C')

    [channel.CH_L1CA_L2C, channel.CH_L1CA_L2C.acq.acqResults] = acquireGPS(channel.CH_L1CA_L2C, sis, channel.CH_L1CA_L2C.acq.acqResults, channel.bpSampling_OddFold, config.logConfig);
    
    %———————————————————————— 信号捕获成功 ————————————————————————%   
    if (channel.CH_L1CA_L2C.acq.acqResults.acqed == 1) % 信号捕获成功
        if channel.CH_L1CA_L2C.acq.acqID == 0
            channel.CH_L1CA_L2C.LO2_fd = channel.CH_L1CA_L2C.LO2_fd + channel.CH_L1CA_L2C.acq.acqResults.doppler; % + acq_cfg.oscOffset;
            channel.CH_L1CA_L2C.LO_Fcode_fd = channel.bpSampling_OddFold * channel.CH_L1CA_L2C.LO2_fd / GSAR_CONSTANTS.STR_L1CA.L0Fc0_R;
            channel.CH_L1CA_L2C.LO_CodPhs = 0;
            channel.CH_L1CA_L2C.CN0_Estimator.CN0 = 10 * log10(channel.CH_L1CA_L2C.acq.acqResults.snr / channel.CH_L1CA_L2C.acq.acq_parameters.tcoh);
            channel.CH_L1CA_L2C.Samp_Posi = channel.CH_L1CA_L2C.Samp_Posi + channel.CH_L1CA_L2C.acq.acqResults.codeIdx;
            channel.CH_L1CA_L2C.acq.TimeLen = channel.CH_L1CA_L2C.acq.TimeLen + channel.CH_L1CA_L2C.acq.acqResults.codeIdx;
            channel.CH_L1CA_L2C.Samp_Posi = channel.CH_L1CA_L2C.Samp_Posi - channel.CH_L1CA_L2C.acq.resiN;      % 扣除resiData中的数据点数
            channel.CH_L1CA_L2C.acq.resiN = 0;
            channel.CH_L1CA_L2C.acq.acqID = 1;
            %新增部分 20170409
            channel.CH_L1CA_L2C.acq.resiData = [];
            channel.CH_L1CA_L2C.acq.corrtmp = [];
            channel.CH_L1CA_L2C.acq.corr = [];
        end
        while (channel.CH_L1CA_L2C.Samp_Posi < 0)
            nPerCode = round(1/(GSAR_CONSTANTS.STR_L1CA.Fcode0+channel.CH_L1CA_L2C.LO_Fcode_fd)*GSAR_CONSTANTS.STR_L1CA.ChipNum*GSAR_CONSTANTS.STR_RECV.RECV_fs0);%考虑多普勒频移后的1个ca码采样点数
            channel.CH_L1CA_L2C.Samp_Posi = channel.CH_L1CA_L2C.Samp_Posi + nPerCode;
            channel.CH_L1CA_L2C.acq.TimeLen = channel.CH_L1CA_L2C.acq.TimeLen + nPerCode;
        end
        if channel.CH_L1CA_L2C.Samp_Posi >= N
            channel.CH_L1CA_L2C.Samp_Posi =  channel.CH_L1CA_L2C.Samp_Posi - N;
        else
            if strcmp(channel.STATUS, 'COLD_ACQ') || strcmp(channel.STATUS, 'COLD_ACQ_AGAIN')               % 冷启动捕获成功
                channel.CH_L1CA_L2C.acq.ACQ_STATUS = 1; %精捕获        
            elseif strcmp(channel.STATUS, 'HOT_ACQ')            % 热启动捕获成功
                %nothing 暂未实现
            end
            fprintf('CodeIndx: %d ; Doppler: %.2fHz ; CN0: %.1fdB \n', ...
                channel.CH_L1CA_L2C.Samp_Posi, channel.bpSampling_OddFold*channel.CH_L1CA_L2C.LO2_fd, channel.CH_L1CA_L2C.CN0_Estimator.CN0);
        end
        
    %———————————————————————— 信号捕获失败 ————————————————————————% 
    elseif (channel.CH_L1CA_L2C.acq.acqResults.acqed == -1) % 信号捕获失败
        if strcmp(channel.STATUS, 'COLD_ACQ')           % 冷捕获失败
            if satelliteTable(2).satVisible(channel.CH_L1CA_L2C.PRNID)==1 % 若判断卫星可见则捕获两次
                channel.STATUS = 'COLD_ACQ_AGAIN';
                channel.CH_L1CA_L2C.CH_STATUS = channel.STATUS;
                channel.CH_L1CA_L2C.acq.acqResults.acqed = 0;   % 捕获初始化
                channel.CH_L1CA_L2C.Samp_Posi = 0; % Ensure reacquisition not exceed index limit
            else
                channel.STATUS = 'ACQ_FAIL';
                channel.CH_L1CA_L2C.CH_STATUS = channel.STATUS;
                channel.CH_L1CA_L2C.Samp_Posi = 0; % Ensure reacquisition not exceed index limit
            end
        elseif strcmp(channel.STATUS, 'COLD_ACQ_AGAIN')     % 重捕获失败
            channel.STATUS = 'ACQ_FAIL';
            channel.CH_L1CA_L2C.CH_STATUS = channel.STATUS;
            channel.CH_L1CA_L2C.Samp_Posi = 0; % Ensure reacquisition not exceed index limit
      %———————————————————————— 热捕获失败 ————————————————————————% 
        elseif strcmp(channel.STATUS, 'HOT_ACQ')            % 热捕获失败
            if channel.CH_L1CA_L2C.acq.hotWaitTime==-9999   % 首次热捕获失败
                channel.STATUS = 'HOT_ACQ_WAIT';
                channel.CH_L1CA_L2C.CH_STATUS = channel.STATUS;
                channel.CH_L1CA_L2C.acq.hotWaitTime = config.recvConfig.hotTime;
                channel.CH_L1CA_L2C.acq.hotAcqTime = config.recvConfig.hotAcqPeriod;
                channel.CH_L1CA_L2C.acq.acqResults.acqed = 0;   % 捕获初始化
            else
                channel.STATUS = 'HOT_ACQ_WAIT';
                channel.CH_L1CA_L2C.CH_STATUS = channel.STATUS; 
                channel.CH_L1CA_L2C.acq.hotAcqTime = config.recvConfig.hotAcqPeriod;
                channel.CH_L1CA_L2C.acq.acqResults.acqed = 0;   % 捕获初始化
            end

        end% EOF: if strcmp(channel.STATUS, 'COLD_ACQ')% 冷捕获失败
    end % EOF: if (channel.CH_L1CA_L2C.acq.acqResults.acqed == 1)
end % EOF: if strcmp(channel.SYST, 'GPS_L1CA_L2C')

%% ———————————————————————— BDS捕获 ————————————————————————% 
if strcmp(channel.SYST, 'BDS_B1I') 
    [channel.CH_B1I, channel.CH_B1I.acq.acqResults] = acquireCompass(channel.CH_B1I, sis, channel.CH_B1I.acq.acqResults, channel.bpSampling_OddFold, config.logConfig);   
 
 %———————————————————————— 信号捕获成功 ————————————————————————%   
    if (channel.CH_B1I.acq.acqResults.acqed==1)
        if channel.CH_B1I.acq.acqID == 0
            channel.CH_B1I.LO2_fd = channel.CH_B1I.LO2_fd + channel.CH_B1I.acq.acqResults.doppler;   % + sv_acq_cfg.oscOffset;          % 载波多普勒偏移
            channel.CH_B1I.LO_Fcode_fd = channel.bpSampling_OddFold * channel.CH_B1I.LO2_fd / GSAR_CONSTANTS.STR_B1I.L0Fc0_R;       % 码多普勒偏移
            channel.CH_B1I.LO_CodPhs = 0;
            channel.CH_B1I.CN0_Estimator.CN0 = 10*log10(channel.CH_B1I.acq.acqResults.snr / channel.CH_B1I.acq.acq_parameters.tcoh);        % 载噪比
            channel.CH_B1I.Samp_Posi = channel.CH_B1I.Samp_Posi + channel.CH_B1I.acq.acqResults.codeIdx;       % 捕获所使用的采样点数（一般为20ms） + 码相位在整码周期采样点中的位置
            channel.CH_B1I.acq.TimeLen = channel.CH_B1I.acq.TimeLen + channel.CH_B1I.acq.acqResults.codeIdx;
            channel.CH_B1I.Samp_Posi = channel.CH_B1I.Samp_Posi - channel.CH_B1I.acq.resiN;      % 扣除resiData中的数据点数
            channel.CH_B1I.acq.resiN = 0;
            channel.CH_B1I.acq.acqID = 1;
        end
        while (channel.CH_B1I.Samp_Posi < 0)
            nPerCode = round(1/(GSAR_CONSTANTS.STR_B1I.Fcode0+channel.CH_B1I.LO_Fcode_fd)*GSAR_CONSTANTS.STR_B1I.ChipNum*GSAR_CONSTANTS.STR_RECV.RECV_fs0);%考虑多普勒频移后的1个ca码采样点数
            channel.CH_B1I.Samp_Posi = channel.CH_B1I.Samp_Posi + nPerCode;
            channel.CH_B1I.acq.TimeLen = channel.CH_B1I.acq.TimeLen + nPerCode;
        end
        if channel.CH_B1I.Samp_Posi > N
            if strcmp(channel.STATUS, 'COLD_ACQ')
                channel.STATUS = 'COLD_ACQ';
            elseif strcmp(channel.STATUS, 'COLD_ACQ_AGAIN')
                channel.STATUS = 'COLD_ACQ_AGAIN';
            elseif strcmp(channel.STATUS, 'HOT_ACQ')
                channel.STATUS = 'HOT_ACQ';  
            end
            channel.CH_B1I.Samp_Posi =  channel.CH_B1I.Samp_Posi - N;
        else
    %———————————————————————— bite同步配置 ————————————————————————% 
            if strcmp(channel.STATUS, 'COLD_ACQ') || strcmp(channel.STATUS, 'COLD_ACQ_AGAIN')
                channel.STATUS = 'BIT_SYNC';
                channel.CH_B1I.CH_STATUS = channel.STATUS;
                % BitSync Initialize
                channel = coldBitSync_init(channel, config);
            elseif strcmp(channel.STATUS, 'HOT_ACQ')
                channel.STATUS = 'HOT_BIT_SYNC';
                channel.CH_B1I.CH_STATUS = channel.STATUS;
                channel = hotBitSync_init(channel, config); % 失锁重补条件下参数配置
                timeLen = round(channel.CH_B1I.acq.TimeLen); % 若捕获时长大于N，则在每次进入channel_scheduler中会做N点推算
                [verify, channel.CH_B1I] = hotInfoCheck(channel.CH_B1I, timeLen, channel.SYST,'ACQ'); % 检验热启动所预测的各项参数的正确性
            end
                        
            fprintf('CodeIndx: %d ; Doppler: %.2fHz ; CN0: %.1fdB \n', ...
                channel.CH_B1I.Samp_Posi, channel.bpSampling_OddFold*channel.CH_B1I.LO2_fd, channel.CH_B1I.CN0_Estimator.CN0);
        end
    %———————————————————————— 信号捕获失败 ————————————————————————% 
    elseif (channel.CH_B1I.acq.acqResults.acqed==-1)
         if strcmp(channel.STATUS, 'COLD_ACQ')
            if satelliteTable(1).satVisible(channel.CH_B1I.PRNID)==1 % 若判断卫星可见则捕获两次
                channel.STATUS = 'COLD_ACQ_AGAIN';
                channel.CH_B1I.CH_STATUS = channel.STATUS;
                channel.CH_B1I.Samp_Posi = 0; % Ensure reacquisition not exceed index limit
                channel.CH_B1I.acq.acqResults.acqed = 0;
            else
                channel.STATUS = 'ACQ_FAIL';
                channel.CH_B1I.CH_STATUS = channel.STATUS;
                channel.CH_B1I.Samp_Posi = 0; % Ensure reacquisition not exceed index limit
            end
         elseif strcmp(channel.STATUS, 'COLD_ACQ_AGAIN')
            channel.STATUS = 'ACQ_FAIL';
            channel.CH_B1I.CH_STATUS = channel.STATUS;
            channel.CH_B1I.Samp_Posi = 0; % Ensure reacquisition not exceed index limit
       %———————————————————————— 热捕获失败 ————————————————————————% 
         elseif strcmp(channel.STATUS, 'HOT_ACQ')
             if channel.CH_B1I.acq.hotWaitTime==-9999   % 首次热捕获失败
                channel.STATUS = 'HOT_ACQ_WAIT';
                channel.CH_B1I.CH_STATUS = channel.STATUS;
                channel.CH_B1I.acq.hotWaitTime = config.recvConfig.hotTime;
                channel.CH_B1I.acq.hotAcqTime = config.recvConfig.hotAcqPeriod;
                channel.CH_B1I.acq.acqResults.acqed = 0;   % 捕获初始化
            else
                channel.STATUS = 'HOT_ACQ_WAIT';
                channel.CH_B1I.CH_STATUS = channel.STATUS; 
                channel.CH_B1I.acq.hotAcqTime = config.recvConfig.hotAcqPeriod;
                channel.CH_B1I.acq.acqResults.acqed = 0;   % 捕获初始化
            end
%             if isnan(channel.CH_B1I.acq.hotWaitTime)   % 首次热捕获失败
%                 channel.STATUS = 'HOT_ACQ';
%                 channel.CH_B1I.CH_STATUS = channel.STATUS;
%                 % 推算码相位信息
%                 [~, channel.CH_B1I] = hotInfoCheck(channel.CH_B1I, N, channel.SYST,'NORM'); 
%                 channel.CH_B1I.Samp_Posi = 0;
%                 channel.CH_B1I.acq.acqResults.acqed = 0;
%                 channel.CH_B1I.acq.hotWaitTime = 15;
%             elseif channel.CH_B1I.acq.hotWaitTime > 0
%                 channel.STATUS = 'HOT_ACQ';
%                 channel.CH_B1I.CH_STATUS = channel.STATUS;
%                 % 推算码相位信息
%                 [~, channel.CH_B1I] = hotInfoCheck(channel.CH_B1I, N, channel.SYST,'NORM'); 
%                 channel.CH_B1I.Samp_Posi = 0;
%                 channel.CH_B1I.acq.acqResults.acqed = 0;
%                 channel.CH_B1I.acq.hotWaitTime = channel.CH_B1I.acq.hotWaitTime - N/GSAR_CONSTANTS.STR_RECV.fs;
%             elseif channel.CH_B1I.acq.hotWaitTime <= 0
%                 channel.STATUS = 'COLD_ACQ';
%                 channel.CH_B1I.CH_STATUS = channel.STATUS;
%                 channel = BdsCH_ColdInitialize...
%                             (channel, channel.SYST, 'COLD_ACQ', channel.CH_B1I.PRNID, config.recvConfig.configPage, GSAR_CONSTANTS); % 更新CHANNEL
%             end% EOF: if isnan(channel.CH_L1CA.acq.hotWaitTime)   % 首次热捕获失败
         end
    end % EOF: if (channel.CH_L1CA.acq.acqResults.acqed == 1)
end % EOF: if strcmp(channel.SYST, 'BDS_B1I')

