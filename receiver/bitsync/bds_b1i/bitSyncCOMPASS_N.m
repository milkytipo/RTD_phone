function [channel, bitSyncResults, sis,N] = bitSyncCOMPASS_N(config, sv_bitSync_cfg, channel, sis, N, bitSyncResults)

global GSAR_CONSTANTS;
Nms = 4;                    % 每次处理的毫秒数
if ~size(channel.bitSync.offCarri)
    if strcmp(channel.navType, 'B1I_D2')
        fprintf('BitSyncing BD GEO PRN%d ; Coherent accumulation: %1.3fs ; Non-coherent: %d ; FreqBin: %dHz ; FreqRange: -%d~+%dHz\n', ...
            channel.PRNID, sv_bitSync_cfg.tcoh, sv_bitSync_cfg.nnchList, sv_bitSync_cfg.freqBin, sv_bitSync_cfg.freqRange/2, sv_bitSync_cfg.freqRange/2);
    else
        fprintf('BitSyncing BD NGEO PRN%d ; Coherent accumulation: %1.3fs ; Non-coherent: %d ; FreqBin: %dHz ; FreqRange: -%d~+%dHz\n', ...
            channel.PRNID, sv_bitSync_cfg.tcoh, sv_bitSync_cfg.nnchList, sv_bitSync_cfg.freqBin, sv_bitSync_cfg.freqRange/2, sv_bitSync_cfg.freqRange/2);
    end
    
    bitSyncResults.sv = channel.PRNID;
    
    % TC: coherent time length at nominal code frequency
    channel.bitSync.TC = round(sv_bitSync_cfg.tcoh*1e3);
    
    % finer dopplar search
    channel.bitSync.frange = sv_bitSync_cfg.freqRange;
    channel.bitSync.fbin = sv_bitSync_cfg.freqBin;
    channel.bitSync.fnum = channel.bitSync.frange/channel.bitSync.fbin + 1;
    
    % NH code for each channel
    % Get the NH code and its samplings; by default NH code frequency is 1000Hz
    if channel.PRNID > 5
        channel.bitSync.nhCode = [0 0 0 0 0 1 0 0 1 1 0 1 0 1 0 0 1 1 1 0];
        channel.bitSync.nhLength = 20;
    else
        channel.bitSync.nhCode = [1 1];
        channel.bitSync.nhLength = 2;
    end
    channel.bitSync.nhCode(channel.bitSync.nhCode == 0) = -1;       % 将NH码转为双极性码
    
    %the code frequency
    % 经过码多普勒矫正后，CA码的码频率
    channel.bitSync.Fcodesearch = channel.LO_Fcode0 + channel.LO_Fcode_fd; 
    % 一个标准CA码整周期的采样点数
    channel.bitSync.sampPerCode = round(GSAR_CONSTANTS.STR_B1I.ChipNum / channel.bitSync.Fcodesearch *  GSAR_CONSTANTS.STR_RECV.fs);       
    channel.bitSync.skipNumberOfSamples = 0;
    % 每个CA码整周期(即62000个采样点)的码多普勒造成少的的采样点的变化
    channel.bitSync.skipNperCode = channel.bitSync.sampPerCode * (1 - GSAR_CONSTANTS.STR_B1I.Fcode0/channel.bitSync.Fcodesearch);       
    
    channel.bitSync.accum = 0;
    channel.bitSync.corr = [];
    channel.bitSync.corrtmp = [];
    channel.bitSync.carriPhase = channel.Samp_Posi - channel.bitSync.sampPerCode*Nms;     % 本地生成载波的起始时间对应的采样点
end    

% Num_Code = floor((N+1-channel.Samp_Posi)/channel.bitSync.sampPerCode);      % 除去捕获阶段所用的20ms数据和码相位，读入的数据还剩多少个CA码周期
%  Num_Processed = 0;
Samp_Posi = channel.Samp_Posi + round(channel.bitSync.Samp_Posi_dot);              % 取整后的采样点位置
Samp_Posi_dot = channel.Samp_Posi + channel.bitSync.Samp_Posi_dot;          % 考虑码多普勒的采样点位置
sis = [sis(1:62000) channel.bitSync.resiData sis(62001:end)];       % 加上前次余留的数据
N = length(sis);                            % 新数据的长度

while 1
    if(bitSyncResults.synced==1)||(bitSyncResults.synced==-1)
        channel.Samp_Posi = Samp_Posi;
        break;
    elseif(bitSyncResults.synced==0)&&(Samp_Posi+channel.bitSync.sampPerCode*Nms<=N)
        % 1 code of sis data(2046 chips)
        sis_index = (1:channel.bitSync.sampPerCode*Nms)+Samp_Posi;
        % 1ms bitSync
        [channel, bitSyncResults] = bitSyncCOMPASS_Nms(config, sv_bitSync_cfg, channel, sis(sis_index), bitSyncResults,Nms);
%         % compensation of code phase
%         channel.bitSync.skipNumberOfSamples = channel.bitSync.skipNumberOfSamples + channel.bitSync.skipNperCode;
%         skipNumberOfSamples = floor(channel.bitSync.skipNumberOfSamples);
%         channel.bitSync.skipNumberOfSamples = channel.bitSync.skipNumberOfSamples - skipNumberOfSamples;
        
        % This statement seems to be wrong, compensation may lead to a doppler frequency bias, delete 'skipNumberOfSamples' results correct value.
%         Samp_Posi = Samp_Posi + channel.bitSync.sampPerCode - skipNumberOfSamples;
        % 采样点数目加一个NH码片，考虑码多普勒的影响
        Samp_Posi_dot = Samp_Posi_dot + channel.bitSync.sampPerCode*Nms - channel.bitSync.skipNperCode*Nms;
        channel.bitSync.Samp_Posi_dot = Samp_Posi_dot - (Samp_Posi+channel.bitSync.sampPerCode*Nms);
        % 跳过的采样点数
        channel.bitSync.skipNumberOfSamples = round(Samp_Posi_dot) - (Samp_Posi+channel.bitSync.sampPerCode*Nms);
        Samp_Posi = round(Samp_Posi_dot);   % 采样点取整
%         channel.bitSync.accum = Num_Processed + 1;
    elseif (Samp_Posi+channel.bitSync.sampPerCode*Nms>N)
        channel.bitSync.resiData = sis(Samp_Posi+(0:(N-Samp_Posi)));        % 多传入一个采样点，以防下次循环需要减一个采样点
        channel.Samp_Posi = 1;      
        break; 
%     elseif 
    end
end






