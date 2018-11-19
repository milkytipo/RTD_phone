function [channel, bitSyncResults] = bitSyncCOMPASS_1ms(logConfig, channel, sis, bitSyncResults)

global GSAR_CONSTANTS;

%number of circulation   相干积分时间（每次1ms）
channel.bitSync.accum = channel.bitSync.accum + 1;
if (strcmp(channel.bitSync.STATUS,'strong'))
    nnchList = channel.bitSync.noncoh(1);
else
    nnchList = channel.bitSync.noncoh(2);
end

%the code frequency
Fcodesearch = channel.LO_Fcode0 + channel.LO_Fcode_fd;      % 加上码多普勒的CA码率
t = (0:channel.bitSync.sampPerCode-1) / GSAR_CONSTANTS.STR_RECV.fs;     %，将1ms时间做62000等份，即1ms中每个采样点的时间
codePhase = mod( floor( (Fcodesearch).*t ),  GSAR_CONSTANTS.STR_B1I.ChipNum)+1; % 计算1ms采样点中，各个采样点的码相位值（范围：1-2046）
%samples of the PNR code
samplingCodes = channel.codeTable(codePhase);   % 本地生成采样过后的标准CA码

% skipNumberOfSamples = floor(channel.skipNumberOfChips * sampPerCode_s * 1000 / Fcodesearch);
% sis = sis(mod((1:samp2Code_s)-skipNumberOfSamples-1, samp2Code_s)+1 );
% channel.skipNumberOfChips = channel.skipNumberOfChips + Fcodesearch/1000 - 2046;

% wipe off code     去除CA码
siswipeoffcodes = sis.* samplingCodes;      
% generate the sampling instances for carrier phase, sampPerCode long
% 本次1ms的数据中的每个采样点在所取数据段内所对应的时间（将捕获所得到的码相位的采样点设为初始点）
crt = ((0:channel.bitSync.sampPerCode-1) + channel.bitSync.carriPhase) / GSAR_CONSTANTS.STR_RECV.fs;
% 更新载波相位起始位以保证bit同步阶段载波相位是连续的
channel.bitSync.carriPhase = channel.bitSync.sampPerCode + channel.bitSync.carriPhase + channel.bitSync.skipNumberOfSamples;

if channel.bitSync.accum<=channel.bitSync.nhLength        % 小于码长（20）
    nhCode = zeros(1, channel.bitSync.nhLength-channel.bitSync.accum);          % 根据移动的码相位，将NH码前面补零
    nhCode = [nhCode channel.bitSync.nhCode(1:channel.bitSync.accum)];
elseif channel.bitSync.accum >nnchList*channel.bitSync.TC
    nhCode = zeros(1, channel.bitSync.accum-nnchList*channel.bitSync.TC);
    nhCode = [channel.bitSync.nhCode(channel.bitSync.accum+1-nnchList*channel.bitSync.TC:channel.bitSync.nhLength) nhCode];
else
    m = rem(channel.bitSync.accum-1, channel.bitSync.nhLength)+1;
    nhCode = channel.bitSync.nhCode(mod((1:channel.bitSync.nhLength)+m-1, channel.bitSync.nhLength)+1);
end

%-
% nhDoppler = GSAR_CONSTANTS.STR_RECV.bpSampling_OddFold * channel.LO2_fd * 1000 / GSAR_CONSTANTS.STR_B1I.B0;


% Ensure the noncoherent integration time
L = rem(channel.bitSync.accum-channel.bitSync.TC, channel.bitSync.TC)+1;    

for k=1:channel.bitSync.fnum         % 对各个频段做相干积分
    
    dopplerfreq = (k-1)*channel.bitSync.fbin - channel.bitSync.frange/2;
    
    carrierFreq = GSAR_CONSTANTS.STR_RECV.IF_B1I + channel.LO2_fd + dopplerfreq;
    
    % carrier   用cos()+j*sin()表示
    carrierTable = generateCarrier(carrierFreq, crt);
     
    % wipe off carrier
    siswpf_2 = siswipeoffcodes.*carrierTable;
    
    corr = sum(siswpf_2, 2);
    
    channel.bitSync.corrtmp(k,:) = channel.bitSync.corrtmp(k,:) + corr * fliplr(nhCode);        % 对1ms数据在各个码相位上做积分
    
% Consider the doppler frequency of nh code, actually the effect is very small.   
%     for m = 1:channel.bitSync.nhLength
%         tt = (((m - 1) * channel.bitSync.sampPerCode) : (m * channel.bitSync.sampPerCode - 1)) / GSAR_CONSTANTS.STR_RECV.fs;
%         nhPhase = mod(floor((1000 + nhDoppler) .* tt), channel.bitSync.nhLength) + 1;
%         nhCodeR = fliplr(nhCode);
%         samplingnhCodes = nhCodeR(nhPhase); % NH sampling codes
%         siswpf_3 = siswpf_2 .* samplingnhCodes;
%         corr = sum(siswpf_3, 2);
%         channel.bitSync.corrtmp(k, m) = channel.bitSync.corrtmp(k, m) + corr;
%     end
   
    if channel.bitSync.accum>= channel.bitSync.TC      % 判断是否到达10ms相干积分时间
        channel.bitSync.corr(k, L) = channel.bitSync.corr(k, L) + abs(channel.bitSync.corrtmp(k,L));
        channel.bitSync.corrtmp(k,L)=0;
        if channel.PRNID > 5
            channel.bitSync.corr(k, L+channel.bitSync.TC) = channel.bitSync.corr(k, L+channel.bitSync.TC) + ...
                abs(channel.bitSync.corrtmp(k,L+channel.bitSync.TC));
            channel.bitSync.corrtmp(k,L+channel.bitSync.TC)=0;
        end
    end
end



if (channel.bitSync.accum == nnchList*channel.bitSync.TC+channel.bitSync.nhLength) && (strcmp(channel.bitSync.STATUS,'strong'))
    % find spike and determine variable
    [peak_nc_corr, peak_freq_idx, peak_code_idx, snr] = find2DPeak(channel.bitSync.corr);
    peak_code = sort(channel.bitSync.corr(peak_freq_idx,:),'descend');
    th = thresholdDetermineBitSync(channel.bitSync.TC, channel.bitSync.noncoh(1),'BDS');
    if (peak_code(1)/peak_code(end)) > th
        bitSyncResults.sv = channel.PRNID;
        bitSyncResults.synced = 1;
        bitSyncResults.nc_corr = channel.bitSync.corr;
        bitSyncResults.freqIdx = peak_freq_idx;
        bitSyncResults.bitIdx = peak_code_idx;
        bitSyncResults.doppler = (bitSyncResults.freqIdx-1)*channel.bitSync.fbin - channel.bitSync.frange/2;
        %correct bitsync
        fcorrect = bitSync_fcorrect(channel.bitSync.corr',channel.bitSync,bitSyncResults);
        bitSyncResults.doppler = bitSyncResults.doppler + fcorrect;
        %plot bitsync
        if logConfig.isSyncPlotMesh
            bitSync_plot(channel.bitSync.corr,bitSyncResults );
        end
    else
        channel.bitSync.accum = 0;
        channel.bitSync.corr = zeros(channel.bitSync.fnum, channel.bitSync.nhLength);
        channel.bitSync.STATUS = 'weak';
    end
end
if (channel.bitSync.accum == nnchList*channel.bitSync.TC+channel.bitSync.nhLength) && (strcmp(channel.bitSync.STATUS,'weak'))
    % find spike and determine variable
    [peak_nc_corr, peak_freq_idx, peak_code_idx, snr] = find2DPeak(channel.bitSync.corr);
    peak_code = sort(channel.bitSync.corr(peak_freq_idx,:),'descend');
    th = thresholdDetermineBitSync(channel.bitSync.TC, channel.bitSync.noncoh(2),'BDS');
    
    if (peak_code(1)/peak_code(end)) > th
        bitSyncResults.sv = channel.PRNID;
        bitSyncResults.synced = 1;
        bitSyncResults.nc_corr = channel.bitSync.corr;
        bitSyncResults.freqIdx = peak_freq_idx;
        bitSyncResults.bitIdx = peak_code_idx;
        bitSyncResults.doppler = (bitSyncResults.freqIdx-1)*channel.bitSync.fbin - channel.bitSync.frange/2;
        %correct bitsync
        fcorrect = bitSync_fcorrect(channel.bitSync.corr',channel.bitSync,bitSyncResults);
        bitSyncResults.doppler = bitSyncResults.doppler + fcorrect;
        %plot bitsync
        if logConfig.isSyncPlotMesh
            bitSync_plot(channel.bitSync.corr,bitSyncResults );
        end
    else
        channel.bitSync.accum = 0;
        channel.bitSync.corr = zeros(channel.bitSync.fnum, channel.bitSync.nhLength);
        channel.bitSync.STATUS = 'wait';
        channel.bitSync.waitNum = GSAR_CONSTANTS.STR_RECV.fs*channel.bitSync.waitSec;
    end
end
if (channel.bitSync.accum == nnchList*channel.bitSync.TC+channel.bitSync.nhLength) && (strcmp(channel.bitSync.STATUS,'wait'))
    % find spike and determine variable
    [peak_nc_corr, peak_freq_idx, peak_code_idx, snr] = find2DPeak(channel.bitSync.corr);
    peak_code = sort(channel.bitSync.corr(peak_freq_idx,:),'descend');
    th = thresholdDetermineBitSync(channel.bitSync.TC, channel.bitSync.noncoh(2),'BDS');
    
    if (peak_code(1)/peak_code(end)) > th
        bitSyncResults.sv = channel.PRNID;
        bitSyncResults.synced = 1;
        bitSyncResults.nc_corr = channel.bitSync.corr;
        bitSyncResults.freqIdx = peak_freq_idx;
        bitSyncResults.bitIdx = peak_code_idx;
        bitSyncResults.doppler = (bitSyncResults.freqIdx-1)*channel.bitSync.fbin - channel.bitSync.frange/2;
        %correct bitsync
        fcorrect = bitSync_fcorrect(channel.bitSync.corr',channel.bitSync,bitSyncResults);
        bitSyncResults.doppler = bitSyncResults.doppler + fcorrect;
        %plot bitsync
        if logConfig.isSyncPlotMesh
            bitSync_plot(channel.bitSync.corr,bitSyncResults );
        end
    elseif channel.bitSync.waitTimes > 0
        channel.bitSync.accum = 0;
        channel.bitSync.corr = zeros(channel.bitSync.fnum, channel.bitSync.nhLength);
        channel.bitSync.STATUS = 'wait';
        channel.bitSync.waitNum = GSAR_CONSTANTS.STR_RECV.fs*channel.bitSync.waitSec;
        channel.bitSync.waitTimes = channel.bitSync.waitTimes - 1;
    else
        channel.bitSync.accum = 0;
        channel.bitSync.corr = zeros(channel.bitSync.fnum, channel.bitSync.nhLength);
        bitSyncResults.synced = -1;
    end
end

