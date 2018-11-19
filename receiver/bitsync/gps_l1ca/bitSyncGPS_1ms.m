function [channel, bitSyncResults] = bitSyncGPS_1ms(logConfig, channel, sis, bitSyncResults)
global GSAR_CONSTANTS;

%number of circulation
channel.bitSync.accum = channel.bitSync.accum + 1;

if (strcmp(channel.bitSync.STATUS,'strong'))
    nnchList = channel.bitSync.noncoh(1);
else
    nnchList = channel.bitSync.noncoh(2);
end

%the code frequency
Fcodesearch = channel.bitSync.Fcodesearch;
t = (0:channel.bitSync.sampPerCode-1)/ GSAR_CONSTANTS.STR_RECV.fs;
codePhase = mod(floor((Fcodesearch) .* t),  GSAR_CONSTANTS.STR_L1CA.ChipNum) + 1;
%samples of the PNR code
samplingCodes = channel.codeTable(codePhase);

% wipe off code
siswipeoffcodes = sis.* samplingCodes;

% 本次1ms的数据中的每个采样点在所取数据段内所对应的时间（将捕获所得到的码相位的采样点设为初始点）
crt = ((0:channel.bitSync.sampPerCode-1) + channel.bitSync.carriPhase) / GSAR_CONSTANTS.STR_RECV.fs;

% 更新载波相位起始位以保证bit同步阶段载波相位是连续的
channel.bitSync.carriPhase = channel.bitSync.sampPerCode + channel.bitSync.carriPhase + channel.bitSync.skipNumberOfSamples;

if channel.bitSync.accum <= channel.bitSync.nhLength
    nhCode = zeros(1, channel.bitSync.nhLength - channel.bitSync.accum);
    nhCode = [nhCode channel.bitSync.nhCode(1 : channel.bitSync.accum)];
    
elseif channel.bitSync.accum > nnchList*channel.bitSync.TC
    nhCode = zeros(1, channel.bitSync.accum - nnchList*channel.bitSync.TC);
    nhCode = [channel.bitSync.nhCode(channel.bitSync.accum+1-nnchList*channel.bitSync.TC:channel.bitSync.nhLength) nhCode];
    
else
    m = rem(channel.bitSync.accum-1, channel.bitSync.nhLength)+1;
    nhCode = channel.bitSync.nhCode(mod((1:channel.bitSync.nhLength)+m-1, channel.bitSync.nhLength)+1);
end

L = rem(channel.bitSync.accum-channel.bitSync.TC, channel.bitSync.TC)+1;

for k=1:channel.bitSync.fnum
    
    dopplerfreq = (k-1)*channel.bitSync.fbin - channel.bitSync.frange/2;
    carrierFreq =  channel.bitSync.freqCenter + dopplerfreq;
    % carrier
    carrierTable = generateCarrier(carrierFreq, crt);
    % wipe off carrier
    siswpf_2 = siswipeoffcodes.*carrierTable;
    
    corr = sum(siswpf_2, 2);
    channel.bitSync.corrtmp(k,:) = channel.bitSync.corrtmp(k,:) + corr * fliplr(nhCode);
    
    if channel.bitSync.accum>= channel.bitSync.TC
        channel.bitSync.corr(k, L) = channel.bitSync.corr(k, L) + abs(channel.bitSync.corrtmp(k,L));
        channel.bitSync.corrtmp(k,L) = 0;
    end
end


if (channel.bitSync.accum == nnchList * channel.bitSync.TC + channel.bitSync.nhLength) && (strcmp(channel.bitSync.STATUS,'strong'))
    % find spike and determine variable
    [peak_nc_corr, peak_freq_idx, peak_code_idx, snr] = find2DPeak(channel.bitSync.corr);
    peak_code = sort(channel.bitSync.corr(peak_freq_idx,:),'descend');  
    th = thresholdDetermineBitSync(channel.bitSync.TC, channel.bitSync.noncoh(1),'GPS');
    
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

if (channel.bitSync.accum == nnchList * channel.bitSync.TC + channel.bitSync.nhLength) && (strcmp(channel.bitSync.STATUS,'weak'))
    % find spike and determine variable
    [peak_nc_corr, peak_freq_idx, peak_code_idx, snr] = find2DPeak(channel.bitSync.corr);
    peak_code = sort(channel.bitSync.corr(peak_freq_idx,:),'descend');
    th = thresholdDetermineBitSync(channel.bitSync.TC, channel.bitSync.noncoh(2),'GPS');
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

if (channel.bitSync.accum == nnchList * channel.bitSync.TC + channel.bitSync.nhLength) && (strcmp(channel.bitSync.STATUS,'wait'))
    % find spike and determine variable
    [peak_nc_corr, peak_freq_idx, peak_code_idx, snr] = find2DPeak(channel.bitSync.corr);
    peak_code = sort(channel.bitSync.corr(peak_freq_idx,:),'descend');
    th = thresholdDetermineBitSync(channel.bitSync.TC, channel.bitSync.noncoh(2),'GPS');
    
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
