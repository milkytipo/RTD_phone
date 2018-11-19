function [channel, bitSyncResults] = bitSyncCOMPASS_Nms(config, sv_bitSync_cfg, channel, sis, bitSyncResults, Nms)

global GSAR_CONSTANTS;

%number of circulation   相干积分时间（每次1ms）
channel.bitSync.accum = channel.bitSync.accum + 1;

%the code frequency
Fcodesearch = channel.LO_Fcode0 + channel.LO_Fcode_fd;      % 加上码多普勒的CA码率
t = (0:channel.bitSync.sampPerCode*Nms-1) / GSAR_CONSTANTS.STR_RECV.fs;     %，将Nms时间做62000等份，即1ms中每个采样点的时间
codePhase = mod( floor( (Fcodesearch).*t ),  GSAR_CONSTANTS.STR_B1I.ChipNum)+1; % 计算Nms采样点中，各个采样点的码相位值（范围：1-2046）
%samples of the PNR code
samplingCodes = channel.codeTable(codePhase);   % 本地生成采样过后的标准CA码

% skipNumberOfSamples = floor(channel.skipNumberOfChips * sampPerCode_s * 1000 / Fcodesearch);
% sis = sis(mod((1:samp2Code_s)-skipNumberOfSamples-1, samp2Code_s)+1 );
% channel.skipNumberOfChips = channel.skipNumberOfChips + Fcodesearch/1000 - 2046;

% wipe off code     去除CA码
siswipeoffcodes = sis.* samplingCodes;      
% generate the sampling instances for carrier phase, sampPerCode long
% 更新载波相位起始位以保证bit同步阶段载波相位是连续的
channel.bitSync.carriPhase = channel.bitSync.sampPerCode*Nms + channel.bitSync.carriPhase + channel.bitSync.skipNumberOfSamples;
% 本次Nms的数据中的每个采样点在所取数据段内所对应的时间（将捕获所得到的码相位的采样点设为初始点）
crt = ((0:channel.bitSync.sampPerCode*Nms-1) + channel.bitSync.carriPhase) / GSAR_CONSTANTS.STR_RECV.fs;
% if channel.bitSync.accum<=channel.bitSync.nhLength        % 小于非相干累加次数（20）
%     nhCode = zeros(1, channel.bitSync.nhLength-channel.bitSync.accum);          % 根据移动的码相位，将NH码前面补零
%     nhCode = [nhCode channel.bitSync.nhCode(1:channel.bitSync.accum)];
% elseif channel.bitSync.accum >sv_bitSync_cfg.nnchList*channel.bitSync.TC
%     nhCode = zeros(1, channel.bitSync.accum-sv_bitSync_cfg.nnchList*channel.bitSync.TC);
%     nhCode = [channel.bitSync.nhCode(channel.bitSync.accum+1-sv_bitSync_cfg.nnchList*channel.bitSync.TC:channel.bitSync.nhLength) nhCode];
% else
%     m = rem(channel.bitSync.accum-1, channel.bitSync.nhLength)+1;
%     nhCode = channel.bitSync.nhCode(mod((1:channel.bitSync.nhLength)+m-1, channel.bitSync.nhLength)+1);
% end

%-
% nhDoppler = GSAR_CONSTANTS.STR_RECV.bpSampling_OddFold * channel.LO2_fd * 1000 / GSAR_CONSTANTS.STR_B1I.B0;


% Ensure the noncoherent integration time
% L = rem(channel.bitSync.accum-channel.bitSync.TC, channel.bitSync.TC)+1;    

for k=1:channel.bitSync.fnum         % 对各个频段做相干积分
    
    dopplerfreq = (k-1)*channel.bitSync.fbin - channel.bitSync.frange/2;
    
    carrierFreq = GSAR_CONSTANTS.STR_RECV.IF + channel.LO2_fd + dopplerfreq;
    
    % carrier   用cos()+j*sin()表示
    carrierTable = generateCarrier(carrierFreq, crt);
     
    % wipe off carrier
    siswpf_2 = siswipeoffcodes.*carrierTable;
    
    % 对Nms数据去除载波
    for kk = 1 : Nms
        channel.bitSync.offCarri(k,(channel.bitSync.accum-1)*Nms+kk) = ...
            sum(siswpf_2((kk-1)*channel.bitSync.sampPerCode+(1:channel.bitSync.sampPerCode)));
    end
    
end 


%     channel.bitSync.corrtmp(k,:) = channel.bitSync.corrtmp(k,:) + corr * fliplr(nhCode);        % 对1ms数据在各个码相位上做积分  
%     if channel.bitSync.accum>= channel.bitSync.TC      % 判断是否到达10ms相干积分时间
%         channel.bitSync.corr(k, L) = channel.bitSync.corr(k, L) + abs(channel.bitSync.corrtmp(k,L));
%         channel.bitSync.corrtmp(k,L)=0;
%         if channel.PRNID > 5
%             channel.bitSync.corr(k, L+channel.bitSync.TC) = channel.bitSync.corr(k, L+channel.bitSync.TC) + ...
%                 abs(channel.bitSync.corrtmp(k,L+channel.bitSync.TC));
%             channel.bitSync.corrtmp(k,L+channel.bitSync.TC)=0;
%         end
%     end




if channel.bitSync.accum*Nms == sv_bitSync_cfg.nnchList*channel.bitSync.TC
    nhCode = repmat(channel.bitSync.nhCode,[13,10]);     % 将NH码扩展10次，并重复13行
    for nhPhase = 1 : 20
        % 对20个码相位做点乘
        channel.bitSync.corrtmp(:,:,rem(nhPhase,20)+1) = channel.bitSync.offCarri.*circshift(nhCode',nhPhase)';
    end
    for sumTimes = 1:sv_bitSync_cfg.nnchList
        % 做10ms的相干积分
        cohMatrix(:,sumTimes,:) = sum(channel.bitSync.corrtmp(:,(sumTimes-1)*channel.bitSync.TC+(1:channel.bitSync.TC),:),2);
    end
    cohMatrix = sum(abs(cohMatrix),2);  % 非相干累加
    channel.bitSync.corr = cohMatrix(:,:);      % 降维
    % find spike and determine variable
    [peak_nc_corr, peak_freq_idx, peak_code_idx, ~] = find2DPeak(channel.bitSync.corr);
    bitSyncResults.sv = channel.PRNID;
    bitSyncResults.synced = 1;
    bitSyncResults.nc_corr = channel.bitSync.corr;
    bitSyncResults.freqIdx = peak_freq_idx;
    bitSyncResults.bitIdx = peak_code_idx;
    bitSyncResults.doppler = (bitSyncResults.freqIdx-1)*channel.bitSync.fbin - channel.bitSync.frange/2;
    %correct bitsync
    if  sv_bitSync_cfg.fcorrect
        fcorrect = bitSync_fcorrect(channel.bitSync.corr',sv_bitSync_cfg,bitSyncResults);
    end
    bitSyncResults.doppler = bitSyncResults.doppler + fcorrect;
    %plot bitsync
    if config.isSyncPlotMesh
        bitSync_plot(channel.bitSync.corr,bitSyncResults );
    end
elseif channel.bitSync.accum > sv_bitSync_cfg.nnchList*channel.bitSync.TC+channel.bitSync.nhLength
    bitSyncResults.synced = -1;
end