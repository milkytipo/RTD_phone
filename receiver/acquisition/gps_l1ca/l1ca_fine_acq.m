function [channel_spc, STATUS] = l1ca_fine_acq(CH_SYST, channel_spc, config, sis, N, ~)

%bpSampling_oddFold暂未使用

global GSAR_CONSTANTS;
STATUS = channel_spc.CH_STATUS;  %设定默认返回值

if (channel_spc.acq.resiN > 0 )
    sis = [channel_spc.acq.resiData sis];  %如果有剩余数据，先合并
    N = N + channel_spc.acq.resiN;
    channel_spc.acq.resiData = [];
end

N_1ms = GSAR_CONSTANTS.STR_RECV.fs * 0.001;  %1ms数据对应的采样点数  (sampPerCode)
if (channel_spc.Samp_Posi + N_1ms >= N) %如数据不足，留到下回  大于等于：谨防数据边沿的跳采样
    channel_spc.acq.resiData = sis(channel_spc.Samp_Posi+1:N);
    channel_spc.acq.resiN = N - channel_spc.Samp_Posi;
    channel_spc.Samp_Posi = 0;
    return;
end

roughAcq = 1; %控制开关
if (roughAcq)
    roughAcqStep = 1/7; %62M：对应8倍降采样
    downRate = floor(roughAcqStep*GSAR_CONSTANTS.STR_RECV.fs/1.023e6); %降采样倍率
    if (downRate == 0)
        downRate = 1;
    end
    N_down = ceil(N_1ms/downRate); %降采样后的数据点数
else
    downRate = 1;
    N_down = N_1ms;
end

L1CA_acq_config = config.recvConfig.configPage.acqConfig.GPS_L1CA;
fd0 = channel_spc.LO2_fd;  %精捕获频率搜索中心
freqN = round( L1CA_acq_config.fineFreqRange / L1CA_acq_config.fineFreqBin )+1; %频率搜索数
fd_search = fd0 + ( -L1CA_acq_config.fineFreqRange/2 : L1CA_acq_config.fineFreqBin : L1CA_acq_config.fineFreqRange/2 ); %多普勒搜索位置
IF_search = GSAR_CONSTANTS.STR_RECV.IF_L1CA + fd_search; %实际搜索频率位置
Tc = round(L1CA_acq_config.tcoh_fine*1000); %相干积分毫秒数
Nc = L1CA_acq_config.ncoh_fine;
     
if (channel_spc.acq.processing ~= 1) %第一次进来要初始化
    channel_spc.acq.accum = 0; %非相干累加次数
    channel_spc.acq.corr_fine = zeros(1,freqN); %总积分结果
    channel_spc.acq.corrtmp_fine  = zeros(1,freqN); %每次相干积分结果
    channel_spc.acq.carriPhase = 0;
    channel_spc.acq.Samp_Posi_dot = 0; %采样点位置的小数部分
    %skipNperCode：每1ms的跳采样点数。如值为1，则表示每次1ms积分后要将Samp_Posi减1。
    channel_spc.acq.skipNperCode = N_1ms * channel_spc.LO_Fcode_fd / GSAR_CONSTANTS.STR_L1CA.Fcode0; 
    
    channel_spc.acq.processing = 1;
end

fprintf('\t\tFine acq GPS L1CA PRN%2.2d:  Coherent time: %d*%.3fs ; FreqBin: %.0fHz ; FreqRange: %.0f~%.0fHz\n', ...
    channel_spc.PRNID, Nc, L1CA_acq_config.tcoh_fine, L1CA_acq_config.fineFreqBin, fd_search(1), fd_search(freqN));
    
t = downRate*(0:N_down-1)/ GSAR_CONSTANTS.STR_RECV.fs; %采样点的毫秒内时间戳

%对于本地采样码，可以统一采用搜索中心频率生成，给不同的频点用。由于各个频率差距小，这样做的相关损失是很小的。
%对GPS的精捕获而言，积分时间可能超过1ms, 因此本地载波信号不宜先计算。但是北斗可行。
codePhase = mod( floor((GSAR_CONSTANTS.STR_L1CA.Fcode0 + channel_spc.LO_Fcode_fd)*t), 1023 ) + 1;
samplingCodes = channel_spc.codeTable(codePhase);

% 1ms主循环
while(1)
    sis_seg = sis( channel_spc.Samp_Posi + (1:downRate:N_1ms) );
    crt = ( downRate*(0:N_down-1) + channel_spc.acq.carriPhase) / GSAR_CONSTANTS.STR_RECV.fs;  %积分时间戳，需要在一次相干积分时间内保持连续
    channel_spc.acq.carriPhase = channel_spc.acq.carriPhase + N_1ms;
    
    for i = 1:freqN
        carrierTable = exp( -1i*2*pi*IF_search(i).*crt );  %本地载波信号
        channel_spc.acq.corrtmp_fine(i) = channel_spc.acq.corrtmp_fine(i) + sum(sis_seg.*carrierTable.*samplingCodes);
    end
    channel_spc.acq.accum = channel_spc.acq.accum + 1;
    channel_spc.acq.Samp_Posi_dot = channel_spc.acq.Samp_Posi_dot - channel_spc.acq.skipNperCode;
    channel_spc.Samp_Posi = channel_spc.Samp_Posi + N_1ms + round(channel_spc.acq.Samp_Posi_dot);
    channel_spc.acq.carriPhase = channel_spc.acq.carriPhase + round(channel_spc.acq.Samp_Posi_dot); %注意跳采样时保证载波相位连续
    channel_spc.acq.Samp_Posi_dot = channel_spc.acq.Samp_Posi_dot - round(channel_spc.acq.Samp_Posi_dot);
    
    if ( mod(channel_spc.acq.accum,Tc)==0 ) %达到相干积分时间
        channel_spc.acq.corr_fine = channel_spc.acq.corr_fine + abs(channel_spc.acq.corrtmp_fine);
        channel_spc.acq.corrtmp_fine = zeros(1,freqN);
    end
    
    if ( channel_spc.acq.accum == Tc*Nc ) %达到累加次数
        [~, peak_freq_idx] = max(channel_spc.acq.corr_fine);
        if config.logConfig.isAcqPlotMesh
            Title = ['Fine Acq GPS PRN=',num2str(channel_spc.PRNID)];
            figure('Name',Title,'NumberTitle','off');
            plot(fd_search,channel_spc.acq.corr_fine); 
            xlabel('Freq doppler / Hz');
            ylabel('Corr');
        end
        channel_spc.acq.ACQ_STATUS = 2;
        channel_spc.LO2_fd = fd_search(peak_freq_idx);
        channel_spc.LO_Fcode_fd = channel_spc.LO2_fd / GSAR_CONSTANTS.STR_L1CA.L0Fc0_R;
        fprintf('\t\t\tSamp_Posi:%d,  Result: %.2fHz\n', channel_spc.Samp_Posi, channel_spc.LO2_fd );
      
        channel_spc.acq.processing = 0;
        channel_spc.acq.accum = 0;
        channel_spc.acq.corr_fine = zeros(1,freqN);
        channel_spc.acq.corrtmp_fine = zeros(1,freqN);       
        channel_spc.Samp_Posi = channel_spc.Samp_Posi - channel_spc.acq.resiN; %回推拼接前的采样点位置
        channel_spc.acq.resiData = [];
        channel_spc.acq.resiN = 0;
        
        switch (CH_SYST)
            case 'GPS_L1CA'
                channel_spc.CH_STATUS = 'BIT_SYNC';
                STATUS = 'BIT_SYNC';
                channel_spc = coldBitSync_init_new(channel_spc, config, 'GPS_L1CA');
                
            case 'GPS_L1CA_L2C'
                STATUS = 'COLD_ACQ';
        end
        return;
    end
    
    %循环过程中需要判断数据余量
    if (channel_spc.Samp_Posi + N_1ms >= N) %如数据不足，留到下回  大于等于：谨防数据边沿的跳采样
        channel_spc.acq.resiData = sis(channel_spc.Samp_Posi+1:N);
        channel_spc.acq.resiN = N - channel_spc.Samp_Posi;
        channel_spc.Samp_Posi = 0;
        return;
    end
    
end
    
