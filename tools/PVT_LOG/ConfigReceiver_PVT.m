%% Adjustment for receiver according to config
function receiver = ConfigReceiver_PVT(receiver)

global GSAR_CONSTANTS;


%% Construct the channels structure
receiver.channels = ChannelsInitializing(0); % 0 is a random prn ID, just for initialization.
switch receiver.syst
    case {'BDS_B1I','B1I_B2I'}
        [receiver.config.recvConfig.numberOfChannels(1:2).channelNumAll] = ...
            deal(receiver.config.recvConfig.numberOfChannels(1).channelNum);    % 总信道数目
        receiver.config.recvConfig.numberOfChannels(2).channelNum = 0;          % GPS通道数置0
    case {'GPS_L1CA','L1CA_L2C'}
        [receiver.config.recvConfig.numberOfChannels(1:2).channelNumAll] = ...
            deal(receiver.config.recvConfig.numberOfChannels(2).channelNum);    % 总信道数目
        receiver.config.recvConfig.numberOfChannels(1).channelNum = 0;          % 北斗通道数置0
    case {'B1I_L1CA','B1I_B2I_L1CA_L2C'}
        [receiver.config.recvConfig.numberOfChannels(1:2).channelNumAll] = ...
            deal(receiver.config.recvConfig.numberOfChannels(1).channelNum + receiver.config.recvConfig.numberOfChannels(2).channelNum);    % 总信道数目       
end
receiver.channels(1:receiver.config.recvConfig.numberOfChannels(1).channelNumAll, 1) = receiver.channels;



%% Config the active Pvt Channels list struct
receiver.actvPvtChannels.actChnsNum_BDS = 0;
receiver.actvPvtChannels.BDS = zeros(2, receiver.config.recvConfig.numberOfChannels(1).channelNum); % row1 - active CH ID; row2 - active CH's PRN
receiver.actvPvtChannels.actChnsNum_GPS = 0;
receiver.actvPvtChannels.GPS = zeros(2, receiver.config.recvConfig.numberOfChannels(2).channelNum); % row1 - active CH ID; row2 - active CH's PRN

%% Config the satellite table for controller module 
receiver.satelliteTable = satelliteTableInitializing(receiver.satelliteTable, receiver.config.recvConfig.targetSatellites, receiver.config.recvConfig.configPage.systConfig);

%% Initialize struct about navigation message
receiver.naviMsg = naviMsgInitializing(receiver.naviMsg, receiver.config.recvConfig.configPage.systConfig);

%% initialize PVT parameters
receiver.pvtCalculator = pvtCalculatorInitializing(receiver.pvtCalculator, receiver.config);

%% Config the receiver inner-time module
receiver.timer = TimerInitializing(receiver.timer, receiver.config);

receiver.elapseTime = 0;
receiver.Loop       = 0;
receiver.Trun       = 0;
end