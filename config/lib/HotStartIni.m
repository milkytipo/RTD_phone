%% Receiver's hot start mode initialization operations
function receiver = hotstart_ini(receiver)

notVisible = []; % Create a list of satellites not visible

for i = 1:length(receiver.sat_table.process_state)
   if strcmp(receiver.sat_table.process_state(i), 'idle')
       notVisible = [notVisible, i];
   end
end

% Update priori informations
prePos = []'; % True position
recvAsTime = ; % Assisted receiver time

ephFilePath = ''; % Load exsited almanac file


% Reconfig receiver's parameters


for n = 1:receiver.recv_cfg.numberOfChannels
    if n <= length(receiver.acq_cfg.svVisible)
        % First, set the status of each channel as 'coarse_acq'
        receiver.channels(n).STATUS = 'coarse_acq';

        % Second, allocate the sv's PRN to each channel
        switch receiver.SYST
            case 'BD_B1I'
                receiver.channels(n).CH_B1I.CH_STATUS = receiver.channels(n).STATUS;

                receiver.channels(n).CH_B1I.PRNID = receiver.acq_cfg.svVisible(n);

                % Second, set the coarse acquisition's initial central search position
                % since coldstart and non-assist, there is not initial Doppler freq
    %             receiver.channels(n).CH_B1I.LO2_fd = 0;
    %             receiver.channels(n).CH_B1I.LO_Fcode_fd = receiver.channels(n).CH_B1I.LO2_fd / receiver.constants.STR_B1I.L0Fc0_R;

                if receiver.channels(n).CH_B1I.PRNID>5
                    receiver.channels(n).CH_B1I.navType = 'B1I_D1';
                else
                    receiver.channels(n).CH_B1I.navType = 'B1I_D2';
                end

                if strcmp(receiver.channels(n).CH_B1I.navType,'B1I_D2') ...
                    && (receiver.channels(n).CH_B1I.Tcohn_N > receiver.constants.STR_B1I.NT1ms_in_D2)

                    receiver.channels(n).CH_B1I.Tcohn_N = receiver.constants.STR_B1I.NT1ms_in_D2;
                end

                % ---------- added by fangxr ---------- %
                if strcmp(receiver.channels(n).CH_B1I.navType,'B1I_D2')
                    % These parameters are used for ephemeris demodulation of GEO
                    receiver.channels(n).CH_B1I.a1h = [];
                    receiver.channels(n).CH_B1I.a1m = [];
                    receiver.channels(n).CH_B1I.a1l = [];
                    receiver.channels(n).CH_B1I.Cuch = [];
                    receiver.channels(n).CH_B1I.Cucl = [];
                    receiver.channels(n).CH_B1I.eh = [];
                    receiver.channels(n).CH_B1I.em = [];
                    receiver.channels(n).CH_B1I.el = [];
                    receiver.channels(n).CH_B1I.Cich = [];
                    receiver.channels(n).CH_B1I.Cicm = [];
                    receiver.channels(n).CH_B1I.Cicl = [];
                    receiver.channels(n).CH_B1I.i0h = [];
                    receiver.channels(n).CH_B1I.i0m1 = [];
                    receiver.channels(n).CH_B1I.i0m2 = [];
                    receiver.channels(n).CH_B1I.i0l = [];
                    receiver.channels(n).CH_B1I.wh = [];
                    receiver.channels(n).CH_B1I.wm = [];
                    receiver.channels(n).CH_B1I.wl = [];
                    receiver.channels(n).CH_B1I.omegah = [];
                    receiver.channels(n).CH_B1I.omegam = [];
                    receiver.channels(n).CH_B1I.omegal = [];
                    receiver.channels(n).CH_B1I.subframeID = [1 2 3 4 5 6 7 8 9 10]; % Mark the subframe has been demodulated (just in MATLAB)
                end
                % ---------------------------------------- %
            case 'GPS_L1CA'
                receiver.channels(n).CH_L1CA.CH_STATUS = receiver.channels(n).STATUS;
                receiver.channels(n).CH_L1CA.PRNID = receiver.acq_cfg.svVisible(n);
            otherwise
                error('SYST type not defined yet!');
        end
    else
        % Channels for satellites not visible, set the status as 'idle'
        receiver.channels(n).STATUS = 'idle';

        % Allocate the sv's PRN to each channel
        switch receiver.SYST
            case 'BD_B1I'
                receiver.channels(n).CH_B1I.CH_STATUS = receiver.channels(n).STATUS;

                receiver.channels(n).CH_B1I.PRNID = notVisible(n-length(receiver.acq_cfg.svVisible));

                if receiver.channels(n).CH_B1I.PRNID>5
                    receiver.channels(n).CH_B1I.navType = 'B1I_D1';
                else
                    receiver.channels(n).CH_B1I.navType = 'B1I_D2';
                end

                if strcmp(receiver.channels(n).CH_B1I.navType,'B1I_D2') ...
                    && (receiver.channels(n).CH_B1I.Tcohn_N > receiver.constants.STR_B1I.NT1ms_in_D2)

                    receiver.channels(n).CH_B1I.Tcohn_N = receiver.constants.STR_B1I.NT1ms_in_D2;
                end

                % ---------- added by fangxr ---------- %
                if strcmp(receiver.channels(n).CH_B1I.navType,'B1I_D2')
                    % These parameters are used for ephemeris demodulation of GEO
                    receiver.channels(n).CH_B1I.a1h = [];
                    receiver.channels(n).CH_B1I.a1m = [];
                    receiver.channels(n).CH_B1I.a1l = [];
                    receiver.channels(n).CH_B1I.Cuch = [];
                    receiver.channels(n).CH_B1I.Cucl = [];
                    receiver.channels(n).CH_B1I.eh = [];
                    receiver.channels(n).CH_B1I.em = [];
                    receiver.channels(n).CH_B1I.el = [];
                    receiver.channels(n).CH_B1I.Cich = [];
                    receiver.channels(n).CH_B1I.Cicm = [];
                    receiver.channels(n).CH_B1I.Cicl = [];
                    receiver.channels(n).CH_B1I.i0h = [];
                    receiver.channels(n).CH_B1I.i0m1 = [];
                    receiver.channels(n).CH_B1I.i0m2 = [];
                    receiver.channels(n).CH_B1I.i0l = [];
                    receiver.channels(n).CH_B1I.wh = [];
                    receiver.channels(n).CH_B1I.wm = [];
                    receiver.channels(n).CH_B1I.wl = [];
                    receiver.channels(n).CH_B1I.omegah = [];
                    receiver.channels(n).CH_B1I.omegam = [];
                    receiver.channels(n).CH_B1I.omegal = [];
                    receiver.channels(n).CH_B1I.subframeID = [1 2 3 4 5 6 7 8 9 10]; % Mark the subframe has been demodulated (just in MATLAB)
                end
                % ---------------------------------------- %
            case 'GPS_L1CA'
                receiver.channels(n).CH_L1CA.CH_STATUS = receiver.channels(n).STATUS;
                receiver.channels(n).CH_L1CA.PRNID = notVisible(n-length(receiver.acq_cfg.svVisible));
            otherwise
                error('SYST type not defined yet!');
        end
    end
end

% receiver.recv_cfg.skipNumberOfBytes  = 0;
% receiver.recv_cfg.skipNumberOfSamples = receiver.recv_cfg.skipNumberOfBytes / receiver.recv_cfg.bytesPerData;