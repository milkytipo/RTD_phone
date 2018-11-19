function channel = acq_l1ca_cold(config, channel, satelliteTable, sis, N)
% 加速版CA码冷捕获，修改内容：
% 1. 取消跳采样点操作，本地扩频码始终使用零多普勒；
% 2. 对于载波生成和本地码的傅里叶变换放在while循环外，避免重复计算；
% 3. 傅里叶长度从2ms降至1ms;
% 4. 局部采用单精度计算。
% 默认1ms相干积分时间，不支持其他长度

global GSAR_CONSTANTS;
switch (channel.SYST)
    case 'GPS_L1CA'
        channel_spc = channel.CH_L1CA;
    case 'GPS_L1CA_L2C'
        channel_spc = channel.CH_L1CA_L2C;
end

if (channel_spc.acq.resiN > 0 )
    sis = [channel_spc.acq.resiData sis];  %如果有剩余数据，先合并
    N = N + channel_spc.acq.resiN;
    channel_spc.acq.resiData = [];
end

N_1ms = GSAR_CONSTANTS.STR_RECV.fs * 0.001;  %1ms数据对应的采样点数  (sampPerCode)

roughAcq = 0; %控制开关
%注：由于傅里叶变换在点数包含2,3,5等质因数时计算更快，因此降采样倍率不是越大越好。对于62M的采样率，降采样率以2,4,8为宜。
if (roughAcq)
    roughAcqStep = 1/7; %62M：对应8倍降采样
    downRate = floor(roughAcqStep*GSAR_CONSTANTS.STR_RECV.fs/1.023e6); %降采样倍率
    if (downRate >= 8)
        downRate = 8;
    elseif (downRate>= 4)
        downRate = 4;
    elseif (downRate>= 2)
        downRate = 2;
    elseif (downRate == 0)
        downRate = 1;
    end
    N_down = ceil(N_1ms/downRate); %降采样后的数据点数
else
    downRate = 1;
    N_down = N_1ms;
end

L1CA_acq_config = config.recvConfig.configPage.acqConfig.GPS_L1CA;
freqN = round( L1CA_acq_config.freqRange / L1CA_acq_config.freqBin )+1; %频率搜索数
fd_search = ( -L1CA_acq_config.freqRange/2 : L1CA_acq_config.freqBin : L1CA_acq_config.freqRange/2 ); %多普勒搜索位置
IF_search = GSAR_CONSTANTS.STR_RECV.IF_L1CA + fd_search; %实际搜索频率位置
Nc = L1CA_acq_config.nnchList(1);

if (channel_spc.acq.processing ~= 1) %第一次进来要初始化
    channel_spc.codeTable = GSAR_CONSTANTS.PRN_CODE.CA_code(channel_spc.PRNID,:);
    channel_spc.acq.accum = 0; %非相干累加次数
    channel_spc.acq.corr = zeros(freqN,N_down); %总积分结果
   
    channel_spc.acq.processing = 1;
end

fprintf('     %s GPS PRN%d:  Coherent accumulation: %1.3fs ; FreqBin: %dHz ; FreqRange: -%d~+%dHz\n', ...
            channel_spc.CH_STATUS, channel_spc.PRNID, L1CA_acq_config.tcoh, L1CA_acq_config.freqBin, L1CA_acq_config.freqRange/2, L1CA_acq_config.freqRange/2);
      
sis = single(sis);
%预先计算本地载波和本地码的fft
t_1ms = single( downRate*(0:N_down-1)/GSAR_CONSTANTS.STR_RECV.fs );  %1ms时间戳
carrierTable = single( zeros(freqN, N_down) );  %保存本地复载波
for i = 1:freqN
    carrierTable(i,:) = exp( -1j*2*pi*IF_search(i).*t_1ms );
end
codeTable = single(channel_spc.codeTable( mod( floor(1.023e6*t_1ms),1023 ) + 1));  
codeTable_fft = conj(fft(codeTable));

% 主循环
while 1
    sis_seg = sis( channel_spc.Samp_Posi + (1:downRate:N_1ms) );
    
    for i = 1:freqN
        sis_fft = fft(sis_seg.*carrierTable(i,:));
        channel_spc.acq.corr(i,:) = channel_spc.acq.corr(i,:) + abs( ifft(sis_fft.*codeTable_fft) );
    end
    
    channel_spc.acq.accum = channel_spc.acq.accum + 1;
    channel_spc.Samp_Posi = channel_spc.Samp_Posi + N_1ms;
    
    if ( channel_spc.acq.accum == Nc ) %达到累加次数
        [~, peak_freq_idx, peak_code_idx, svSnr] = find2DPeak(channel_spc.acq.corr);
                  
        if (svSnr>L1CA_acq_config.thre_stronmode ) %捕获成功
            if (config.logConfig.isAcqPlotMesh)
                acq_plot_new('GPS_L1CA',channel_spc.acq.corr, fd_search, peak_freq_idx, peak_code_idx, channel_spc.PRNID);
            end
            peak_code_idx = downRate*peak_code_idx+1-downRate; %从降采样点回推原来的采样点位置
            channel_spc.acq.ACQ_STATUS = 1; %升级                               
            channel_spc.LO2_fd = fd_search(peak_freq_idx);
            channel_spc.LO_Fcode_fd = channel_spc.LO2_fd / 1540;
            channel_spc.Samp_Posi = channel_spc.Samp_Posi - channel_spc.acq.resiN + peak_code_idx;
            channel_spc.CN0_Estimator.CN0 = 10*log10(svSnr/L1CA_acq_config.tcoh); 
            fprintf('                    Succeed!  NonCohn_Accu: %d (StrongMode) -- ', Nc);
            fprintf('CodeIndx: %d ; Doppler: %.2fHz ; CN0: %.1fdB \n', ...
                channel_spc.Samp_Posi, channel.bpSampling_OddFold*channel_spc.LO2_fd, channel_spc.CN0_Estimator.CN0);
            
        else %捕获失败
            fprintf('                    Fail! NonCohn_Accu: : %d.\n', Nc);
            if satelliteTable(2).satVisible(channel_spc.PRNID)==1 % 若判断卫星可见则捕获两次
                channel.STATUS = 'COLD_ACQ_AGAIN';
                channel_spc.CH_STATUS = channel.STATUS;
                channel_spc.Samp_Posi = 0;
            else
                channel.STATUS = 'ACQ_FAIL'; 
                channel_spc.CH_STATUS = 'ACQ_FAIL';     
            end
        end
        
        channel_spc.acq.accum = 0;
        channel_spc.acq.corr = [];
        channel_spc.acq.resiData = [];
        channel_spc.acq.resiN = 0;        
        channel_spc.acq.processing = 0;
        
        switch (channel.SYST)
            case 'GPS_L1CA'
                channel.CH_L1CA = channel_spc;                
            case 'GPS_L1CA_L2C'
                channel.CH_L1CA_L2C = channel_spc;
        end
        return;
    end
    
    %循环过程中需要判断数据余量
    if (channel_spc.Samp_Posi + N_1ms > N) %如数据不足，留到下回
        channel_spc.acq.resiData = sis(channel_spc.Samp_Posi+1:N);
        channel_spc.acq.resiN = N - channel_spc.Samp_Posi;
        channel_spc.Samp_Posi = 0;
        switch (channel.SYST)
            case 'GPS_L1CA'
                channel.CH_L1CA = channel_spc;
            case 'GPS_L1CA_L2C'
                channel.CH_L1CA_L2C = channel_spc;
        end
        return;
    end
    
end
    
    