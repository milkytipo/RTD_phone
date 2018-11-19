function [channel, acqResults] = acquireCompass_1ms(logConfig, channel, sis, acqResults, bpSampling_OddFold)

global GSAR_CONSTANTS;

% generate the sampling instances for carrier phase, sampPer2TC_s long
% 将两毫秒按采样率等间隔平分
crt = ((0:channel.acq.sampPer2TC_s-1)+channel.acq.carriPhase) ...
    / GSAR_CONSTANTS.STR_RECV.fs;

channel.acq.carriPhase = channel.acq.carriPhase + channel.acq.sampPerTC_s + channel.acq.skipNumberOfSamples;

samplingCodes = zeros(1, channel.acq.sampPer2TC_s);

channel.acq.accum = channel.acq.accum + 1;

if strcmp(channel.acq.STATUS,'HOT')    % 热启动模式下需要消除NH码
    nhIndex = mod(channel.acq.accum-1, channel.acq.nhLength) + 1;
    nhCode = channel.acq.nhCode(nhIndex);
end

% First of all, search in strong signal mode 
for f=1:channel.acq.freqSearch         % 并行码相位搜索，共设置9个频点，每个频点采用fft求相关峰
    %the frequency search cell
    %     IFsearch = IF0 + (freqOrder(f) - (freqSearch + 1)/2)*freqBin;
    IFsearch = channel.acq.IF0 + channel.acq.freqOrder(f)*channel.acq.freqBin;
    %the corresponding code frequency in this frequency search cell
    Fcodesearch = bpSampling_OddFold * (IFsearch - GSAR_CONSTANTS.STR_RECV.IF_B1I) / channel.acq.L0Fc0_R + GSAR_CONSTANTS.STR_B1I.Fcode0;       % 实际码率，即码多普勒+标称码率 
    
    % carrier
    carrierTable = generateCarrier(IFsearch, crt);
    % wipe off carrier
    siswipeoff = sis.* carrierTable;
    
    %sampling the local PRN code
    t = (0 : channel.acq.sampPerTC_s-1) / GSAR_CONSTANTS.STR_RECV.fs;
    codePhase = mod(floor(Fcodesearch.*t), GSAR_CONSTANTS.STR_B1I.ChipNum) + 1;
    
    % sampling gold code and rep for N times and zero-padding to 2N ms
    samplingCodes(1, 1:channel.acq.sampPerTC_s) = channel.codeTable(codePhase);     % 生成1ms本地CA码，第二毫秒补0，因为相关可以看做循环卷积，因此需要2ms数据
    if ~strcmp(channel.acq.STATUS,'HOT')    % 热启动模式下已考虑多普勒频移，无需此处补偿
        % calculate the compensation of the code phase
        skipNumberOfSamples = floor(channel.acq.skipNumberOfCodes(1, f) * channel.acq.sampPerTC_s * 1000 / Fcodesearch);
        max = size(samplingCodes, 2);
        samplingCodes(1, :) = samplingCodes(1, mod((1:max)+skipNumberOfSamples-1, max)+1 );
        channel.acq.skipNumberOfCodes(1, f) = channel.acq.skipNumberOfCodes(1, f) + Fcodesearch / 1000 - GSAR_CONSTANTS.STR_B1I.ChipNum;        % 相对于标称码率，由于码多普勒的影响，每毫秒数据多传输多少码片
    end
    
    if strcmp(channel.acq.STATUS,'HOT')
        codeTableFFT =  conj(fft(samplingCodes(1:channel.acq.sampPerTC_s), channel.acq.sampPerTC_s));     % 求本地生成CA码的FFT，并取共轭
        indx_mt = 1 : channel.acq.sampPerTC_s;
        %get the needed pieces of siswipeoff
        sis_wpf_pieces_mt = siswipeoff(indx_mt);
        %do the FFT operations along the rowwise directions
        sis_FFT_pieces_mt = fft(sis_wpf_pieces_mt, channel.acq.sampPerTC_s, 2);
        corr_mt = ifft(repmat(codeTableFFT, 1, 1) .* sis_FFT_pieces_mt, channel.acq.sampPerTC_s, 2);
        corr_mt = corr_mt * nhCode;
    else
        codeTableFFT =  conj(fft(samplingCodes, channel.acq.sampPer2TC_s));     % 求本地生成CA码的FFT，并取共轭
        indx_mt = 1 : channel.acq.sampPer2TC_s;
        %get the needed pieces of siswipeoff
        sis_wpf_pieces_mt = siswipeoff(indx_mt);
        %do the FFT operations along the rowwise directions
        sis_FFT_pieces_mt = fft(sis_wpf_pieces_mt, channel.acq.sampPer2TC_s, 2);
        corr_mt = ifft(repmat(codeTableFFT, 1, 1) .* sis_FFT_pieces_mt, channel.acq.sampPer2TC_s, 2);      % 此频点下CA码相关结果
    end
%     if strcmp(channel.acq.STATUS,'HOT')    % 热启动模式下需要消除NH码
%         corr_mt = corr_mt * nhCode;
%     end
    channel.acq.corrtmp(f,:) = channel.acq.corrtmp(f,:) + corr_mt(1:channel.acq.sampPerTC_s);
    if mod(channel.acq.accum, channel.acq.TC) == 0      % 达到相干积分时间
        channel.acq.corr(f, :) = channel.acq.corr(f, :) + abs(channel.acq.corrtmp(f,:));       % 进行非相干累加
        channel.acq.corrtmp(f,:) = 0;
    end
end%EOF "for f=1:acq.freqSearch"




if (strcmp(channel.acq.STATUS,'strong'))&&(channel.acq.accum == channel.acq.acq_parameters.noncoh(1)*channel.acq.TC) % sv_acq_cfg.nnchList(2))

    % find spike and determine variable
    [peak_nc_corr, peak_freq_idx, peak_code_idx, svSnr] = find2DPeak(channel.acq.corr);
    
    % set threshold
%     th = thresholdDetermine(channel.acq.acq_parameters.tcoh, channel.acq.acq_parameters.noncoh(1));
    th = channel.acq.acq_parameters.thre_stronmode;
    
    % Mark acquired satellite
    if svSnr > th
        acqResults.sv = channel.PRNID;
        acqResults.acqed   = 1;
%         acqResults.corr    = channel.acq.corr;
%         acqResults.corrpeak= peak_nc_corr;
        acqResults.freqOrder = (channel.acq.freqOrder)*channel.acq.freqBin;
        acqResults.samps = (1:channel.acq.sampPerTC_s);
        acqResults.freqIdx = peak_freq_idx;
        % 计算码相位（由采样率决定了精度），即捕获得到的码相位减去码多普勒造成的码偏移
        acqResults.codeIdx = peak_code_idx - floor(channel.acq.skipNumberOfCodes(1, peak_freq_idx) * channel.acq.sampPerTC_s * 1000 / Fcodesearch);
        acqResults.nc      = channel.acq.acq_parameters.noncoh(1); %sv_acq_cfg.nnchList(2);
        acqResults.snr     = svSnr;
        acqResults.doppler = channel.acq.freqOrder(peak_freq_idx) *channel.acq.freqBin;
        % 每个采样点包含多少个码片，（即：（标称码率+码多普勒）/采样率）
        acqResults.RcFsratio = (GSAR_CONSTANTS.STR_B1I.Fcode0 + bpSampling_OddFold*(channel.acq.IF0 + acqResults.doppler - ...
            GSAR_CONSTANTS.STR_RECV.IF_B1I) / channel.acq.L0Fc0_R) / GSAR_CONSTANTS.STR_RECV.fs;
        if logConfig.isAcqPlotMesh  % plot acquisition results
            acq_plot('COLD_ACQ','BDS_B1I',channel.acq.corr,acqResults);
        end
        fprintf('                    Succeed!  NonCohn_Accu: %d (StrongMode) -- ', acqResults.nc);
        channel.acq.corr = [];
        return;
    else
        channel.acq.accum = 0;
        channel.acq.corr = zeros(channel.acq.freqSearch, channel.acq.sampPerTC_s);
        channel.acq.STATUS = 'weak';      
    end
end     % EOF: if (strcmp(channel.acq.STATUS,'strong'))
    
if (strcmp(channel.acq.STATUS,'weak'))&&(channel.acq.accum == channel.acq.acq_parameters.noncoh(2)*channel.acq.TC) %sv_acq_cfg.nnchList(3))   
    % find spike and determine variable
    [peak_nc_corr, peak_freq_idx, peak_code_idx, svSnr] = find2DPeak(channel.acq.corr);
    
    % set threshold
%     th = thresholdDetermine(channel.acq.acq_parameters.tcoh, channel.acq.acq_parameters.noncoh(2));
    th = channel.acq.acq_parameters.thre_weakmode;
    
    if svSnr > th
        acqResults.sv = channel.PRNID;
        acqResults.acqed   = 1;
%         acqResults.corr    = channel.acq.corr;
%         acqResults.corrpeak= peak_nc_corr;
        acqResults.freqOrder = (channel.acq.freqOrder)*channel.acq.freqBin;
        acqResults.samps = (1:channel.acq.sampPerTC_s);
        acqResults.freqIdx = peak_freq_idx;
        acqResults.codeIdx = peak_code_idx - floor(channel.acq.skipNumberOfCodes(1, peak_freq_idx) * channel.acq.sampPerTC_s * 1000 / Fcodesearch);
        acqResults.nc      = channel.acq.acq_parameters.noncoh(2);  %sv_acq_cfg.nnchList(3);
        acqResults.snr     = svSnr;
        acqResults.codePhase= 0;
        acqResults.doppler = channel.acq.freqOrder(peak_freq_idx) *channel.acq.freqBin;
        acqResults.RcFsratio = (GSAR_CONSTANTS.STR_B1I.Fcode0 + bpSampling_OddFold*(channel.acq.IF0 + acqResults.doppler - ...
            GSAR_CONSTANTS.STR_RECV.IF_B1I) / channel.acq.L0Fc0_R) / GSAR_CONSTANTS.STR_RECV.fs;
        if logConfig.isAcqPlotMesh  % plot acquisition results
            acq_plot('COLD_ACQ','BDS_B1I',channel.acq.corr,acqResults);
        end
        fprintf('                    Succeed!  NonCohn_Accu: %d (WeakMode) -- ', acqResults.nc);
        channel.acq.corr = [];
        return;
    else
        channel.acq.corr = [];
        channel.acq.accum = 0; % Prepare for reacquire
        acqResults.sv = channel.PRNID;
        acqResults.acqed = -1;
        acqResults.snr = 0;
        acqResults.nc = channel.acq.acq_parameters.noncoh(2);  %sv_acq_cfg.nnchList(3);
        fprintf('                    Fail! NonCohn_Accu: : %d.\n', acqResults.nc);
        return;
    end
end     % EOF: if (strcmp(channel.acq.STATUS,'weak'))

if (strcmp(channel.acq.STATUS,'HOT'))&&(channel.acq.accum == channel.acq.acq_parameters.noncoh(1)*channel.acq.TC) %sv_acq_cfg.nnchList(3)   
    % find spike and determine variable
    [peak_nc_corr, peak_freq_idx, peak_code_idx, svSnr] = find2DPeak(channel.acq.corr);
    
    % set threshold
%     th = thresholdDetermine(channel.acq.acq_parameters.tcoh, channel.acq.acq_parameters.noncoh(2));
    th = channel.acq.acq_parameters.thre_weakmode;
    
    if svSnr > th
        acqResults.sv = channel.PRNID;
        acqResults.acqed   = 1;
%         acqResults.corr    = channel.acq.corr;
%         acqResults.corrpeak= peak_nc_corr;
        acqResults.freqOrder = (channel.acq.freqOrder)*channel.acq.freqBin;
        acqResults.samps = (1:channel.acq.sampPerTC_s);
        acqResults.freqIdx = peak_freq_idx;
        acqResults.codeIdx = peak_code_idx;
        acqResults.nc      = channel.acq.acq_parameters.noncoh(1);  %sv_acq_cfg.nnchList(3);
        acqResults.snr     = svSnr;
        acqResults.codePhase= 0;
        acqResults.doppler = channel.acq.freqOrder(peak_freq_idx) *channel.acq.freqBin;
        acqResults.RcFsratio = (GSAR_CONSTANTS.STR_L1CA.Fcode0 + bpSampling_OddFold*(channel.acq.IF0 + acqResults.doppler - ...
            GSAR_CONSTANTS.STR_RECV.IF_L1CA) / channel.acq.L0Fc0_R) / GSAR_CONSTANTS.STR_RECV.fs;
        if logConfig.isAcqPlotMesh  % plot acquisition results
            acq_plot('HOT_ACQ','BDS_B1I',channel.acq.corr,acqResults);
        end
        fprintf('                    Acquired sv %d ! Non-coherent accumulation: %d.    Mode:HOT\n', acqResults.sv, acqResults.nc);
        channel.acq.corr = [];
        return;
    else
        channel.acq.corr = [];
        channel.acq.accum = 0; % Prepare for reacquire
        acqResults.sv = channel.PRNID;
        acqResults.acqed = -1;
        acqResults.snr = 0;
        acqResults.nc = channel.acq.acq_parameters.noncoh(1);  %sv_acq_cfg.nnchList(3);
        fprintf('                    Cannot acquire sv %d ! non-coherent accumulation: %d.    Mode:HOT \n', acqResults.sv, acqResults.nc);
        return;
    end
end     % EOF: if (strcmp(channel.acq.STATUS,'HOT'))


