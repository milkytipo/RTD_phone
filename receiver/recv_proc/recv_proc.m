function receiver = recv_proc(receiver, sis, N)

global GSAR_CONSTANTS;

for n = 1:receiver.config.recvConfig.numberOfChannels(1).channelNumAll
    
    switch receiver.channels(n).STATUS
        case 'IDLE'
            
        case {'COLD_ACQ', 'WARM_ACQ', 'BIT_SYNC'}
            if strcmp(receiver.channels(n).STATUS, 'COLD_ACQ')
                receiver.channels(n) = acq_proc(receiver.config, receiver.channels(n), sis, N);
            end
            
            if strcmp(receiver.channels(n).STATUS, 'WARM_ACQ')
                % TO DO Warm_Acq
                % ......
            end
            
            if strcmp(receiver.channels(n).STATUS,'BIT_SYNC')
                receiver.channels(n) = bitSync_proc(receiver.config, receiver.channels(n), sis, N);
            end
            
%             if strcmp(receiver.channels(n).STATUS,'PULLIN_INI')
%                 receiver.channels(n) = pullin_ini(receiver.channels(n));
%             end
            
            if strcmp(receiver.channels(n).STATUS,'PULLIN')
                receiver.channels(n) = mx_Recv_Prc_track(receiver.channels(n).SYST, sis, receiver.channels(n), ...
                    GSAR_CONSTANTS.STR_RECV.fs, N, receiver.recorder(n), receiver.device.gpuExist);
            end
            
        case {'PULLIN', 'TRACK'}
%             tic
            receiver.channels(n) = mx_Recv_Prc_track(receiver.channels(n).SYST, sis, receiver.channels(n), ...
                GSAR_CONSTANTS.STR_RECV.fs, N, receiver.recorder(n), receiver.device.gpuExist);
%             toc
            if strcmp(receiver.channels(n).STATUS, 'SUBFRAME_SYNCED')
                [receiver.channels(n),receiver.almanac, receiver.ephemeris] = demodulation_proc( ... 
                    receiver.channels(n), receiver.almanac, receiver.ephemeris); % Epheremis demodulation
            end

        case 'SUBFRAME_SYNCED'
            receiver.channels(n) = mx_Recv_Prc_track(receiver.channels(n).SYST, sis, receiver.channels(n), ...
                GSAR_CONSTANTS.STR_RECV.fs, N, receiver.recorder(n), receiver.device.gpuExist);
                [receiver.channels(n),receiver.almanac, receiver.ephemeris] = demodulation_proc( ... 
                    receiver.channels(n), receiver.almanac, receiver.ephemeris); % Epheremis demodulation
            
    end
    
    % 
    if strcmp(receiver.channels(n).STATUS, 'PULLIN') || strcmp(receiver.channels(n).STATUS, 'TRACK') || strcmp(receiver.channels(n).STATUS, 'SUBFRAME_SYNCED')
%       if (N_ms~=0)&&(floor(Loop*((N-N_ms)/N_ms/500))-floor((Loop-1)*((N-N_ms)/N_ms/500))>0)
        PlotTrackResults(receiver.recorder(n), receiver.channels(n).SYST, receiver.channels(n), receiver.config.logConfig.isTrackPlot, receiver.timer);
%       end
    end   

end

% Update receiver according to channels' info, need to be placed after pvt calculation
[receiver] = UpdateReceiver(receiver);


%% PVT
% if receiver.pvtCalculator.dataNum == 0
%     if receiver.config.recvConfig.positionType == 1
%         [receiver.timer, receiver.ephemeris, receiver.pvtCalculator, receiver.config] = pointPos...
%             (receiver.syst,receiver.channels, receiver.config, receiver.timer, receiver.ephemeris, receiver.pvtCalculator);
%     end
%     
% end
end

