function [channel_spec, bitSyncResults] = bitSyncGPS(logConfig, channel_spec, sis, bitSyncResults)

if ~size(channel_spec.bitSync.corr)
%     fprintf('/----------------------------------------------------------------------------------------------/\n');
    fprintf('     BitSyncing GPS PRN%d:  Coherent accumulation: %1.3fs ; Non-coherent: %d ; FreqBin: %dHz ; FreqRange: -%d~+%dHz\n', ...
        channel_spec.PRNID, channel_spec.bitSync.TC/1000, channel_spec.bitSync.noncoh(1), channel_spec.bitSync.fbin, channel_spec.bitSync.frange/2, channel_spec.bitSync.frange/2);
    
    bitSyncResults.sv = channel_spec.PRNID;
    channel_spec.bitSync.corr = zeros(channel_spec.bitSync.fnum, channel_spec.bitSync.nhLength);
    channel_spec.bitSync.corrtmp = zeros(channel_spec.bitSync.fnum, channel_spec.bitSync.nhLength);
    channel_spec.bitSync.TimeLen = 0;
end    

Samp_Posi = channel_spec.Samp_Posi;              % 采样点传递
Samp_Posi_dot = channel_spec.Samp_Posi + channel_spec.bitSync.Samp_Posi_dot;          % 考虑码多普勒的采样点位置
sis = [channel_spec.bitSync.resiData sis];       % 加上前次余留的数据
N = length(sis);                            % 新数据的长度
channel_spec.bitSync.resiData = [];

while 1
    if (bitSyncResults.synced==1)||(bitSyncResults.synced==-1)
        channel_spec.Samp_Posi = Samp_Posi;
        break;
    elseif (bitSyncResults.synced==0)&&(Samp_Posi+channel_spec.bitSync.sampPerCode<N)
        % 1 code of sis data(2046 chips)
        sis_index = (1:channel_spec.bitSync.sampPerCode)+Samp_Posi;
        % add time
        channel_spec.bitSync.TimeLen = channel_spec.bitSync.TimeLen + channel_spec.bitSync.sampPerCode - channel_spec.bitSync.skipNperCode;
        % 1ms bitSync
        if channel_spec.bitSync.waitNum <= 0
            [channel_spec, bitSyncResults] = bitSyncGPS_1ms(logConfig, channel_spec, sis(sis_index), bitSyncResults);
        else
            channel_spec.bitSync.waitNum = channel_spec.bitSync.waitNum - length(sis_index);
        end
        % 采样点数目加一个NH码片，考虑码多普勒的影响
        Samp_Posi_dot = Samp_Posi_dot + channel_spec.bitSync.sampPerCode - channel_spec.bitSync.skipNperCode;
        % 跳过的采样点数
        channel_spec.bitSync.skipNumberOfSamples = round(Samp_Posi_dot) - (Samp_Posi+channel_spec.bitSync.sampPerCode);
        Samp_Posi = round(Samp_Posi_dot);   % 采样点取整，在当前循环中更新下一循环采样点起始位，采样点只在此处发生跳变  
        channel_spec.bitSync.Samp_Posi_dot = Samp_Posi_dot - Samp_Posi; % 下一循环起始位已更新，因而此处值小于0.5
        
    elseif (Samp_Posi+channel_spec.bitSync.sampPerCode>=N)    % 为了防止在总数据边缘处发生采样点跳跃导致出错，此处判断条件设为大于等于
        channel_spec.bitSync.resiData = sis(Samp_Posi+(1:(N-Samp_Posi)));        
        channel_spec.Samp_Posi = 0; 
        channel_spec.bitSync.resiN = length(channel_spec.bitSync.resiData);
        break;
    end
end
