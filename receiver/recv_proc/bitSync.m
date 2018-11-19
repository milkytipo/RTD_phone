function channels = bitSync(config, channels, sis, N)
fprintf('BITSYNC PROC INFO:\n');
for n = 1 : config.recvConfig.numberOfChannels(1).channelNumAll   
    if strcmp(channels(n).STATUS, 'BIT_SYNC')||strcmp(channels(n).STATUS, 'HOT_BIT_SYNC')
        channels(n) = bitSync_proc(config, channels(n), sis, N);
    end
end
fprintf('  \n');
end % EOF: function