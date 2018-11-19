%% Receiver's warm start mode initialization operations
function receiver = WarmStartIni(receiver)

global GSAR_CONSTANTS;

% invisible = []; % Create a list of satellites not visible
% 
% for i = 1:length(receiver.satelliteTable.processState)
%    if strcmp(receiver.satelliteTable.processState(i), 'IDLE')
%        invisible = [invisible, i];
%    end
% end

% Update 3 priori informations: position, time, almanac
if isempty(receiver.config.truePosition)
    error('Position info is wrong, can''t excute warm start!');
end
prePos = receiver.config.truePosition'; % True position

recvRefTime = receiver.config.skipTime + receiver.config.trueTime; % Reference time
almFilePath = 'E:\多径研究项目\sv_cadll\branches\branch_fangxr\fangxr\m\almanac.yuma.week0811.405504.txt'; % Load exsited almanac file
receiver.almanac = ReadYUMA(almFilePath, receiver.syst); % Read YUMA file to get almanac info

% Calculate satellites' position and velocity
[satPos, satEl] = calSatPos2(receiver.syst, prePos, recvRefTime, receiver.almanac); % 
receiver.config.visibleSatellites = find(satEl > receiver.config.elevationMask); % Get PRN ID of visible satellites

satPosVisible = satPos(receiver.config.visibleSatellites,:);
dopFreq = calcfrerange(receiver.syst, satPosVisible', prePos, receiver.config.visibleSatellites); % An array

% Reconfig the satellite table
receiver.satelliteTable = satelliteTableInitializing(receiver.syst, receiver.config.visibleSatellites);

% Assign visible satellites to channels, if exceed capacity, select former ones, if insufficient, use invisible satellites and set 'IDLE'.
for n = 1:receiver.config.numberOfChannels
    if n <= length(receiver.config.visibleSatellites)
        % First, set the status of each channel as 'WARM_ACQ'
        prn = receiver.config.visibleSatellites(n);
        
        receiver.channels(n).STATUS = 'WARM_ACQ';
        receiver.satelliteTable.processState(prn) = {'WARM_ACQ'};

        % Second, allocate the sv's PRN to each channel
        switch receiver.syst
            case 'BD_B1I'
                receiver.channels(n).CH_B1I.CH_STATUS = receiver.channels(n).STATUS;
                receiver.channels(n).CH_B1I.PRNID = prn;

                % Set the acquisition's initial central search position
                receiver.channels(n).CH_B1I.LO2_fd = dopFreq(n);
                receiver.channels(n).CH_B1I.LO_Fcode_fd = receiver.channels(n).CH_B1I.LO2_fd / GSAR_CONSTANTS.STR_B1I.L0Fc0_R;

                if receiver.channels(n).CH_B1I.PRNID>5
                    receiver.channels(n).CH_B1I.navType = 'B1I_D1';
                else
                    receiver.channels(n).CH_B1I.navType = 'B1I_D2';
                end

                if strcmp(receiver.channels(n).CH_B1I.navType,'B1I_D2') ...
                    && (receiver.channels(n).CH_B1I.Tcohn_N > GSAR_CONSTANTS.STR_B1I.NT1ms_in_D2)

                    receiver.channels(n).CH_B1I.Tcohn_N = GSAR_CONSTANTS.STR_B1I.NT1ms_in_D2;
                end
                
            case 'GPS_L1CA'
                receiver.channels(n).CH_L1CA.CH_STATUS = receiver.channels(n).STATUS;
                receiver.channels(n).CH_L1CA.PRNID = prn;
                
                % Set the coarse acquisition's initial central search position
                receiver.channels(n).CH_L1CA.LO2_fd = dopFreq(n);
                receiver.channels(n).CH_L1CA.LO_Fcode_fd = receiver.channels(n).CH_L1CA.LO2_fd / GSAR_CONSTANTS.STR_L1CA.L0Fc0_R;
            otherwise
                error('System type has not been defined yet!');
        end
    else
        % Channels' number is beyond visible satellites, set the rest channels to 'IDLE' status
        receiver.channels(n).STATUS = 'IDLE';

        % Set satellite in the channel is NaN
        switch receiver.syst
            case 'BD_B1I'
                receiver.channels(n).CH_B1I.CH_STATUS = receiver.channels(n).STATUS;
                receiver.channels(n).CH_B1I.PRNID = NaN;
            case 'GPS_L1CA'
                receiver.channels(n).CH_L1CA.CH_STATUS = receiver.channels(n).STATUS;
                receiver.channels(n).CH_L1CA.PRNID = NaN;
        end
    end
end

end
