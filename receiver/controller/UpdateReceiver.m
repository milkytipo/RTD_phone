%% Update receiver according to channels' info
function [receiver] = UpdateReceiver(receiver)

global GSAR_CONSTANTS;
updatedChannels_BDS = []; % Channels are assigned by new satellites
newSatellites_BDS = []; % New satellites assign to channels
updatedChannels_GPS = []; % Channels are assigned by new satellites
newSatellites_GPS = []; % New satellites assign to channels
% Determine wait list
waitList_BDS = find(strcmp(receiver.satelliteTable(1).processState, 'WAIT_FOR_PROCESS'));
waitList_GPS = find(strcmp(receiver.satelliteTable(2).processState, 'WAIT_FOR_PROCESS'));
% Determine idle list
idleList_BDS = find(strcmp(receiver.satelliteTable(1).processState, 'IDLE'));
idleList_GPS = find(strcmp(receiver.satelliteTable(2).processState, 'IDLE'));
almanacReadyList_BDS = []; % Satellites which almanac shows visible
almanacReadyList_GPS = []; % Satellites which almanac shows visible

if ~rem(round(receiver.elapseTime), receiver.config.recvConfig.reacquireInterval) && receiver.pvtCalculator.dataNum == 0 % Every interval
%     if find(receiver.almanac(1).dect)    % BDS_B1I   »±…ŸŒ¿–«Ω°øµ±Í ∂µƒ≈–∂œ
%         % Some satellites' almanac are available, check satellites' visibleness
%         [visibleList_BDS, dopFreq_BDS] = ReadAlmanac(receiver.almanac(1), 'BDS_B1I', receiver.config, receiver.elapseTime);
%         almanacReadyList_BDS = intersect(visibleList_BDS, waitList_BDS); % Those satellites in waitlist which are visible told by almanac
%         dopFreq_BDS = dopFreq_BDS(find(ismember(visibleList_BDS, almanacReadyList_BDS)));
%         waitList_BDS = setdiff(waitList_BDS, almanacReadyList_BDS); % Decrease almanacReadyList in waitList
%     end
%     if find(receiver.almanac(2).dect)    % GPS_L1CA
%         [visibleList_GPS, dopFreq_GPS] = ReadAlmanac(receiver.almanac(2), 'GPS_L1CA', receiver.config, receiver.elapseTime);
%         almanacReadyList_GPS = intersect(visibleList_GPS, waitList_GPS); % Those satellites in waitlist which are visible told by almanac
%         dopFreq_GPS = dopFreq_GPS(find(ismember(visibleList_GPS, almanacReadyList_GPS)));
%         waitList_GPS = setdiff(waitList_GPS, almanacReadyList_GPS); % Decrease almanacReadyList in waitList
%     end

    % If there is no more WAIT_FOR_PROCESS satellite, pick a IDLE satellite into waitList
    if isempty(waitList_BDS) && ~isempty(idleList_BDS)
        % Pick a satellite in idleList randomly
        index = randperm(length(idleList_BDS));
        for i = 1:length(idleList_BDS)
            pickNum = idleList_BDS(index(i));
            % This satellite's almanac hasn't been detected, and the number is less than 33
            if pickNum <= 32 %&& receiver.almanac(1).dect(pickNum) == 0 
                waitList_BDS = [waitList_BDS, pickNum];
            end
        end
    end
    if isempty(waitList_GPS) && ~isempty(idleList_GPS)
        % Pick a satellite in idleList randomly
        index = randperm(length(idleList_GPS));
        for i = 1:length(idleList_GPS)
            pickNum = idleList_GPS(index(i));
            % This satellite's almanac hasn't been detected, and the number is less than 33
            if pickNum <= 32 %&& receiver.almanac(2).dect(pickNum) == 0 
                waitList_GPS = [waitList_GPS, pickNum];
            end
        end
    end
end
%%
%-------------  status update of all channels  --------------------%
for i = 1 : receiver.config.recvConfig.numberOfChannels(1).channelNumAll
    switch receiver.channels(i).SYST
        case 'BDS_B1I'
            prn = receiver.channels(i).CH_B1I.PRNID;
            % Check idle channel, means no satellite in this channel
            if isnan(prn)
                if ~isempty(almanacReadyList_BDS)
                    receiver.channels(i) = BdsCH_ColdInitialize(receiver.channels(i), receiver.syst, 'WARM_ACQ', almanacReadyList_BDS(1), receiver.config.recvConfig.configPage, GSAR_CONSTANTS);
                    receiver.satelliteTable(1).processState(almanacReadyList_BDS(1)) = {'WARM_ACQ'};            
                    % Record the updated channel and satellite
                    updatedChannels_BDS = [updatedChannels_BDS, i];
                    newSatellites_BDS = [newSatellites_BDS, almanacReadyList_BDS(1)];
                    % Set the acquisition's initial central search position
                    receiver.channels(i).CH_B1I.LO2_fd = dopFreq_BDS(1);
                    receiver.channels(i).CH_B1I.LO_Fcode_fd = receiver.channels(i).CH_B1I.LO2_fd / GSAR_CONSTANTS.STR_B1I.L0Fc0_R;
                    almanacReadyList_BDS(1) = []; % This satellite has been used
                    dopFreq_BDS(1) = [];
                elseif ~isempty(waitList_BDS)
                    receiver.channels(i) = BdsCH_ColdInitialize(receiver.channels(i), receiver.syst, 'COLD_ACQ', waitList_BDS(1), receiver.config.recvConfig.configPage, GSAR_CONSTANTS);
                    receiver.satelliteTable(1).processState(waitList_BDS(1)) = {'COLD_ACQ'};
                    % Record the updated channel and satellite
                    updatedChannels_BDS = [updatedChannels_BDS, i];
                    newSatellites_BDS = [newSatellites_BDS, waitList_BDS(1)];
                    waitList_BDS(1) = [];
                end
                continue; % Skip this channel
            end
            switch receiver.channels(i).STATUS 
                case 'IDLE'
                    if strcmp(receiver.satelliteTable(1).processState(prn), 'WARM_ACQ') 
                        % Warm acquisition is failed, try cold acquisition
                        receiver.satelliteTable(1).processState(prn) = {'COLD_ACQ'};
                        receiver.channels(i).STATUS = 'COLD_ACQ';
                        receiver.channels(i).CH_B1I.CH_STATUS = receiver.channels(i).STATUS;
                        % Set central frequency of acquisition
                        receiver.channels(i).CH_B1I.LO2_fd = 0;
                        receiver.channels(i).CH_B1I.LO_Fcode_fd = 0;
                    elseif strcmp(receiver.satelliteTable(1).processState(prn), 'COLD_ACQ')
                        % Cold acquisition is failed
                        if (receiver.satelliteTable(1).almanacReady(prn) == 1) && (receiver.satelliteTable(1).satVisible(prn) == 1)
                            % Almanac shows the satellite is visible, so it should be blocked
                            receiver.satelliteTable(1).satBlock(prn) = 1;
                            receiver.satelliteTable(1).processState(prn) = {'WAIT_FOR_PROCESS'}; % Maybe next time
                        else
                            % No almanac info, consider it is invisible, or truely invisible
                            receiver.satelliteTable(1).satVisible(prn) = 0;
                            receiver.satelliteTable(1).processState(prn) = {'IDLE'};
                        end
                        
                        if ~isempty(almanacReadyList_BDS)
                            receiver.channels(i) = BdsCH_ColdInitialize(receiver.channels(i), receiver.syst, 'WARM_ACQ', almanacReadyList_BDS(1), receiver.config.recvConfig.configPage, GSAR_CONSTANTS);
                            receiver.satelliteTable(1).processState(almanacReadyList_BDS(1)) = {'WARM_ACQ'};            
                            % Record the updated channel and satellite
                            updatedChannels_BDS = [updatedChannels_BDS, i];
                            newSatellites_BDS = [newSatellites_BDS, almanacReadyList_BDS(1)];
                            % Set the acquisition's initial central search position
                            receiver.channels(i).CH_B1I.LO2_fd = dopFreq_BDS(1);
                            receiver.channels(i).CH_B1I.LO_Fcode_fd = receiver.channels(i).CH_B1I.LO2_fd / GSAR_CONSTANTS.STR_B1I.L0Fc0_R;
                            almanacReadyList_BDS(1) = []; % This satellite has been used
                            dopFreq_BDS(1) = [];
                        elseif ~isempty(waitList_BDS)
                            receiver.channels(i) = BdsCH_ColdInitialize(receiver.channels(i), receiver.syst, 'COLD_ACQ', waitList_BDS(1), receiver.config.recvConfig.configPage, GSAR_CONSTANTS);
                            receiver.satelliteTable(1).processState(waitList_BDS(1)) = {'COLD_ACQ'};
                            % Record the updated channel and satellite
                            updatedChannels_BDS = [updatedChannels_BDS, i];
                            newSatellites_BDS = [newSatellites_BDS, waitList_BDS(1)];
                            waitList_BDS(1) = [];
                        end
                    elseif strcmp(receiver.satelliteTable(1).processState(prn), 'RE_ACQ')
                        if strcmp(receiver.config.recvConfig.reacquireMode, 'HEAVY')
                            % The satellite has been acquired before, then lost of lock, reacquire it until succeed
                            receiver.channels(i).STATUS = 'COLD_ACQ';
                            receiver.channels(i).CH_B1I.CH_STATUS = receiver.channels(i).STATUS;
                        elseif strcmp(receiver.config.recvConfig.reacquireMode, 'LIGHT')
                            % Treat the satellite which has been acquired before like normal satellite after one more time acquisition
                            receiver.satelliteTable(1).processState(prn) = {'COLD_ACQ'};
                            receiver.channels(i).STATUS = 'COLD_ACQ';
                            receiver.channels(i).CH_B1I.CH_STATUS = receiver.channels(i).STATUS;
                        elseif strcmp(receiver.config.recvConfig.reacquireMode, 'MEDIUM')
                            error('MEDIUM mode isn''t supported yet!');
                        end
                    elseif strcmp(receiver.satelliteTable(1).processState(prn), 'IDLE')
                        % This state copes with the following situation:
                        %   the channel is in 'IDLE' for a couple of seconds,  
                        %   means the satellite in this idle channel is also
                        %   idle, pick a idle sv into waitlist then process it.
                        if ~isempty(almanacReadyList_BDS)
                            receiver.channels(i) = BdsCH_ColdInitialize(receiver.channels(i), receiver.syst, 'WARM_ACQ', almanacReadyList_BDS(1), receiver.config.recvConfig.configPage, GSAR_CONSTANTS);
                            receiver.satelliteTable(1).processState(almanacReadyList_BDS(1)) = {'WARM_ACQ'};            
                            % Record the updated channel and satellite
                            updatedChannels_BDS = [updatedChannels_BDS, i];
                            newSatellites_BDS = [newSatellites_BDS, almanacReadyList_BDS(1)];
                            % Set the acquisition's initial central search position
                            receiver.channels(i).CH_B1I.LO2_fd = dopFreq_BDS(1);
                            receiver.channels(i).CH_B1I.LO_Fcode_fd = receiver.channels(i).CH_B1I.LO2_fd / GSAR_CONSTANTS.STR_B1I.L0Fc0_R;
                            almanacReadyList_BDS(1) = []; % This satellite has been used
                            dopFreq_BDS(1) = [];
                        elseif ~isempty(waitList_BDS)
                            receiver.channels(i) = BdsCH_ColdInitialize(receiver.channels(i), receiver.syst, 'COLD_ACQ', waitList_BDS(1), receiver.config.recvConfig.configPage, GSAR_CONSTANTS);
                            receiver.satelliteTable(1).processState(waitList_BDS(1)) = {'COLD_ACQ'};
                            % Record the updated channel and satellite
                            updatedChannels_BDS = [updatedChannels_BDS, i];
                            newSatellites_BDS = [newSatellites_BDS, waitList_BDS(1)];
                            waitList_BDS(1) = [];
                        end
                    end
                    
                    % In fact, there is another situation, 'IDLE' satellite in this 'IDLE' channel, its table process state is also 'IDLE'.
                    % It may happen, but too rare, ignore it temporarily.
                    
                case 'PULLIN'
                    receiver.satelliteTable(1).processState(prn) = {'PULLIN'};
                case 'TRACK'
                    receiver.satelliteTable(1).processState(prn) = {'TRACK'};
                    % Recheck satellite table, visible is yes, block is no
                    receiver.satelliteTable(1).satVisible(prn) = 1;
                    receiver.satelliteTable(1).satBlock(prn) = 0;
                case 'SUBFRAME_SYNCED'
                    receiver.satelliteTable(1).processState(prn) = {'SUBFRAME_SYNCED'};
                case 'LOSS_OF_LOCK'
                    % Loss of lock happened in tracking part, need reaquire signal, check almanac first
                    if (receiver.satelliteTable(1).almanacReady(prn) == 1) && (receiver.satelliteTable(1).satVisible(prn) == 0)
                        % Almanac shows satellite is invisible, process as 'IDLE'
                        receiver.satelliteTable(1).processState(prn) = {'IDLE'};
                        
                        % Replace with other satellites
                        if ~isempty(almanacReadyList_BDS)
                            receiver.channels(i) = BdsCH_ColdInitialize(receiver.channels(i), receiver.syst, 'WARM_ACQ', almanacReadyList_BDS(1), receiver.config.recvConfig.configPage, GSAR_CONSTANTS);
                            receiver.satelliteTable(1).processState(almanacReadyList_BDS(1)) = {'WARM_ACQ'};            
                            % Record the updated channel and satellite
                            updatedChannels_BDS = [updatedChannels_BDS, i];
                            newSatellites_BDS = [newSatellites_BDS, almanacReadyList_BDS(1)];
                            % Set the acquisition's initial central search position
                            receiver.channels(i).CH_B1I.LO2_fd = dopFreq_BDS(1);
                            receiver.channels(i).CH_B1I.LO_Fcode_fd = receiver.channels(i).CH_B1I.LO2_fd / GSAR_CONSTANTS.STR_B1I.L0Fc0_R;
                            almanacReadyList_BDS(1) = []; % This satellite has been used
                            dopFreq_BDS(1) = [];
                        elseif ~isempty(waitList_BDS)
                            receiver.channels(i) = BdsCH_ColdInitialize(receiver.channels(i), receiver.syst, 'COLD_ACQ', waitList_BDS(1), receiver.config.recvConfig.configPage, GSAR_CONSTANTS);
                            receiver.satelliteTable(1).processState(waitList_BDS(1)) = {'COLD_ACQ'};
                            % Record the updated channel and satellite
                            updatedChannels_BDS = [updatedChannels_BDS, i];
                            newSatellites_BDS = [newSatellites_BDS, waitList_BDS(1)];
                            waitList_BDS(1) = [];
                        end
                    else
                        % Otherwise excute acquisition again, delete previous track results
                        receiver.satelliteTable(1).processState(prn) = {'RE_ACQ'};
                        receiver.channels(i) = BdsCH_ColdInitialize(receiver.channels(i), receiver.syst, 'COLD_ACQ', prn, receiver.config.recvConfig.configPage, GSAR_CONSTANTS);
                    end
                % case 'bitsync' & 'pullin_ini', these statuses are all limbo status, so there is no need to adjust.
            end
                % Second, adjustment of recorder struct, if newSatellites is empty, no need to update recorder
        
        
        case 'GPS_L1CA'
            prn = receiver.channels(i).CH_L1CA.PRNID;
            % Check idle channel, means no satellite in this channel
            if isnan(prn)
                if ~isempty(almanacReadyList_GPS)
                    receiver.channels(i) = GpsCH_ColdInitialize(receiver.channels(i), receiver.syst, 'WARM_ACQ', almanacReadyList_GPS(1), receiver.config.recvConfig.configPage, GSAR_CONSTANTS);
                    receiver.satelliteTable(2).processState(almanacReadyList_GPS(1)) = {'WARM_ACQ'};            
                    % Record the updated channel and satellite
                    updatedChannels_GPS = [updatedChannels_GPS, i];
                    newSatellites_GPS = [newSatellites_GPS, almanacReadyList_GPS(1)];
                    % Set the acquisition's initial central search position
                    receiver.channels(i).CH_L1CA.LO2_fd = dopFreq_GPS(1);
                    receiver.channels(i).CH_L1CA.LO_Fcode_fd = receiver.channels(i).CH_L1CA.LO2_fd / GSAR_CONSTANTS.STR_L1CA.L0Fc0_R;
                    almanacReadyList_GPS(1) = []; % This satellite has been used
                    dopFreq_GPS(1) = [];
                elseif ~isempty(waitList_GPS)
                    receiver.channels(i) = GpsCH_ColdInitialize(receiver.channels(i), receiver.syst, 'COLD_ACQ', waitList_GPS(1), receiver.config.recvConfig.configPage, GSAR_CONSTANTS);
                    receiver.satelliteTable(2).processState(waitList_GPS(1)) = {'COLD_ACQ'};
                    % Record the updated channel and satellite
                    updatedChannels_GPS = [updatedChannels_GPS, i];
                    newSatellites_GPS = [newSatellites_GPS, waitList_GPS(1)];
                    waitList_GPS(1) = [];
                end
                continue; % Skip this channel
            end
            switch receiver.channels(i).STATUS 
                case 'IDLE'
                    if strcmp(receiver.satelliteTable(2).processState(prn), 'WARM_ACQ') 
                        % Warm acquisition is failed, try cold acquisition
                        receiver.satelliteTable(2).processState(prn) = {'COLD_ACQ'};
                        receiver.channels(i).STATUS = 'COLD_ACQ';
                        receiver.channels(i).CH_L1CA.CH_STATUS = receiver.channels(i).STATUS;
                        % Set central frequency of acquisition
                        receiver.channels(i).CH_L1CA.LO2_fd = 0;
                        receiver.channels(i).CH_L1CA.LO_Fcode_fd = 0;
                    elseif strcmp(receiver.satelliteTable(2).processState(prn), 'COLD_ACQ')
                        % Cold acquisition is failed
                        if (receiver.satelliteTable(2).almanacReady(prn) == 1) && (receiver.satelliteTable(2).satVisible(prn) == 1)
                            % Almanac shows the satellite is visible, so it should be blocked
                            receiver.satelliteTable(2).satBlock(prn) = 1;
                            receiver.satelliteTable(2).processState(prn) = {'WAIT_FOR_PROCESS'}; % Maybe next time
                        else
                            % No almanac info, consider it is invisible, or truely invisible
                            receiver.satelliteTable(2).satVisible(prn) = 0;
                            receiver.satelliteTable(2).processState(prn) = {'IDLE'};
                        end
                        
                        if ~isempty(almanacReadyList_GPS)
                            receiver.channels(i) = GpsCH_ColdInitialize(receiver.channels(i), receiver.syst, 'WARM_ACQ', almanacReadyList_GPS(1), receiver.config.recvConfig.configPage, GSAR_CONSTANTS);
                            receiver.satelliteTable(2).processState(almanacReadyList_GPS(1)) = {'WARM_ACQ'};            
                            % Record the updated channel and satellite
                            updatedChannels_GPS = [updatedChannels_GPS, i];
                            newSatellites_GPS = [newSatellites_GPS, almanacReadyList_GPS(1)];
                            % Set the acquisition's initial central search position
                            receiver.channels(i).CH_L1CA.LO2_fd = dopFreq_GPS(1);
                            receiver.channels(i).CH_L1CA.LO_Fcode_fd = receiver.channels(i).CH_L1CA.LO2_fd / GSAR_CONSTANTS.STR_L1CA.L0Fc0_R;
                            almanacReadyList_GPS(1) = []; % This satellite has been used
                            dopFreq_GPS(1) = [];
                        elseif ~isempty(waitList_GPS)
                            receiver.channels(i) = GpsCH_ColdInitialize(receiver.channels(i), receiver.syst, 'COLD_ACQ', waitList_GPS(1), receiver.config.recvConfig.configPage, GSAR_CONSTANTS);
                            receiver.satelliteTable(2).processState(waitList_GPS(1)) = {'COLD_ACQ'};
                            % Record the updated channel and satellite
                            updatedChannels_GPS = [updatedChannels_GPS, i];
                            newSatellites_GPS = [newSatellites_GPS, waitList_GPS(1)];
                            waitList_GPS(1) = [];
                        end
                    elseif strcmp(receiver.satelliteTable(2).processState(prn), 'RE_ACQ')
                        if strcmp(receiver.config.recvConfig.reacquireMode, 'HEAVY')
                            % The satellite has been acquired before, then lost of lock, reacquire it until succeed
                            receiver.channels(i).STATUS = 'COLD_ACQ';
                            receiver.channels(i).CH_L1CA.CH_STATUS = receiver.channels(i).STATUS;
                        elseif strcmp(receiver.config.recvConfig.reacquireMode, 'LIGHT')
                            % Treat the satellite which has been acquired before like normal satellite after one more time acquisition
                            receiver.satelliteTable(2).processState(prn) = {'COLD_ACQ'};
                            receiver.channels(i).STATUS = 'COLD_ACQ';
                            receiver.channels(i).CH_L1CA.CH_STATUS = receiver.channels(i).STATUS;
                        elseif strcmp(receiver.config.recvConfig.reacquireMode, 'MEDIUM')
                            error('MEDIUM mode isn''t supported yet!');
                        end
                    elseif strcmp(receiver.satelliteTable(2).processState(prn), 'IDLE')
                        % This state copes with the following situation:
                        %   the channel is in 'IDLE' for a couple of seconds,  
                        %   means the satellite in this idle channel is also
                        %   idle, pick a idle sv into waitlist then process it.
                        if ~isempty(almanacReadyList_GPS)
                            receiver.channels(i) = GpsCH_ColdInitialize(receiver.channels(i), receiver.syst, 'WARM_ACQ', almanacReadyList_GPS(1), receiver.config.recvConfig.configPage, GSAR_CONSTANTS);
                            receiver.satelliteTable(2).processState(almanacReadyList_GPS(1)) = {'WARM_ACQ'};            
                            % Record the updated channel and satellite
                            updatedChannels_GPS = [updatedChannels_GPS, i];
                            newSatellites_GPS = [newSatellites_GPS, almanacReadyList_GPS(1)];
                            % Set the acquisition's initial central search position
                            receiver.channels(i).CH_L1CA.LO2_fd = dopFreq_GPS(1);
                            receiver.channels(i).CH_L1CA.LO_Fcode_fd = receiver.channels(i).CH_L1CA.LO2_fd / GSAR_CONSTANTS.STR_B1I.L0Fc0_R;
                            almanacReadyList_GPS(1) = []; % This satellite has been used
                            dopFreq_GPS(1) = [];
                        elseif ~isempty(waitList_GPS)
                            receiver.channels(i) = GpsCH_ColdInitialize(receiver.channels(i), receiver.syst, 'COLD_ACQ', waitList_GPS(1), receiver.config.recvConfig.configPage, GSAR_CONSTANTS);
                            receiver.satelliteTable(2).processState(waitList_GPS(1)) = {'COLD_ACQ'};
                            % Record the updated channel and satellite
                            updatedChannels_GPS = [updatedChannels_GPS, i];
                            newSatellites_GPS = [newSatellites_GPS, waitList_GPS(1)];
                            waitList_GPS(1) = [];
                        end
                    end
                    
                    % In fact, there is another situation, 'IDLE' satellite in this 'IDLE' channel, its table process state is also 'IDLE'.
                    % It may happen, but too rare, ignore it temporarily.
                    
                case 'PULLIN'
                    receiver.satelliteTable(2).processState(prn) = {'PULLIN'};
                case 'TRACK'
                    receiver.satelliteTable(2).processState(prn) = {'TRACK'};
                    % Recheck satellite table, visible is yes, block is no
                    receiver.satelliteTable(2).satVisible(prn) = 1;
                    receiver.satelliteTable(2).satBlock(prn) = 0;
                case 'SUBFRAME_SYNCED'
                    receiver.satelliteTable(2).processState(prn) = {'SUBFRAME_SYNCED'};
                case 'LOSS_OF_LOCK'
                    % Loss of lock happened in tracking part, need reaquire signal, check almanac first
                    if (receiver.satelliteTable(2).almanacReady(prn) == 1) && (receiver.satelliteTable(2).satVisible(prn) == 0)
                        % Almanac shows satellite is invisible, process as 'IDLE'
                        receiver.satelliteTable(2).processState(prn) = {'IDLE'};
                        
                        % Replace with other satellites
                        if ~isempty(almanacReadyList_GPS)
                            receiver.channels(i) = GpsCH_ColdInitialize(receiver.channels(i), receiver.syst, 'WARM_ACQ', almanacReadyList_GPS(1), receiver.config.recvConfig.configPage, GSAR_CONSTANTS);
                            receiver.satelliteTable(2).processState(almanacReadyList_GPS(1)) = {'WARM_ACQ'};            
                            % Record the updated channel and satellite
                            updatedChannels_GPS = [updatedChannels_GPS, i];
                            newSatellites_GPS = [newSatellites_GPS, almanacReadyList_GPS(1)];
                            % Set the acquisition's initial central search position
                            receiver.channels(i).CH_L1CA.LO2_fd = dopFreq_GPS(1);
                            receiver.channels(i).CH_L1CA.LO_Fcode_fd = receiver.channels(i).CH_L1CA.LO2_fd / GSAR_CONSTANTS.STR_L1CA.L0Fc0_R;
                            almanacReadyList_GPS(1) = []; % This satellite has been used
                            dopFreq_GPS(1) = [];
                        elseif ~isempty(waitList_GPS)
                            receiver.channels(i) = GpsCH_ColdInitialize(receiver.channels(i), receiver.syst, 'COLD_ACQ', waitList_GPS(1), receiver.config.recvConfig.configPage, GSAR_CONSTANTS);
                            receiver.satelliteTable(2).processState(waitList_GPS(1)) = {'COLD_ACQ'};
                            % Record the updated channel and satellite
                            updatedChannels_GPS = [updatedChannels_GPS, i];
                            newSatellites_GPS = [newSatellites_GPS, waitList_GPS(1)];
                            waitList_GPS(1) = [];
                        end
                    else
                        % Otherwise excute acquisition again, delete previous track results
                        receiver.satelliteTable(2).processState(prn) = {'RE_ACQ'};
                        receiver.channels(i) = GpsCH_ColdInitialize(receiver.channels(i), receiver.syst, 'COLD_ACQ', prn, receiver.config.recvConfig.configPage, GSAR_CONSTANTS);
                    end
                % case 'bitsync' & 'pullin_ini', these statuses are all limbo status, so there is no need to adjust.
            end
    end
end
if ~isempty(newSatellites_BDS)
    receiver.recorder = UpdateRecorder(newSatellites_BDS, updatedChannels_BDS, receiver.recorder, receiver);
end
if ~isempty(newSatellites_GPS)
    receiver.recorder = UpdateRecorder(newSatellites_GPS, updatedChannels_GPS, receiver.recorder, receiver);
end

end