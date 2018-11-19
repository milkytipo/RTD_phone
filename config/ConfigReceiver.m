%% Adjustment for receiver according to config
function receiver = ConfigReceiver(receiver)

global GSAR_CONSTANTS;

%% Initialize the signal stream Config Struct parameters
switch GSAR_CONSTANTS.STR_RECV.dataType
    case {'int4','bit4'}
        bytesPerData = 0.5;
    case {'int8','bit8'}
        bytesPerData = 1;
    case {'int12','bit12'}
        bytesPerData = 1.5;
    case {'int16','bit16'}
        bytesPerData = 2;
end
if strcmp(GSAR_CONSTANTS.STR_RECV.IQForm, 'Complex')
	bytesPerData = bytesPerData * 2; % If the format is complex, every two data points present one sampled points
end
%----- Read filesize --------
D = dir( GSAR_CONSTANTS.STR_RECV.datafilename{1} );
receiver.fileSize = D.bytes / bytesPerData / GSAR_CONSTANTS.STR_RECV.RECV_fs0;

receiver.config.sisConfig.skipNumberOfBytes = bytesPerData * round(GSAR_CONSTANTS.STR_RECV.RECV_fs0 * receiver.config.sisConfig.skipTime);
receiver.config.sisConfig.skipNumberOfSamples = receiver.config.sisConfig.skipNumberOfBytes / bytesPerData;

receiver.config.sisConfig.codePeriod.B1I = GSAR_CONSTANTS.STR_B1I.ChipNum / GSAR_CONSTANTS.STR_B1I.Fcode0;
receiver.config.sisConfig.samplesPerCode.B1I = ceil(GSAR_CONSTANTS.STR_RECV.fs * receiver.config.sisConfig.codePeriod.B1I);
receiver.config.sisConfig.codePeriod.L1CA = GSAR_CONSTANTS.STR_L1CA.ChipNum / GSAR_CONSTANTS.STR_L1CA.Fcode0;
receiver.config.sisConfig.samplesPerCode.L1CA = ceil(GSAR_CONSTANTS.STR_RECV.fs * receiver.config.sisConfig.codePeriod.L1CA);

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

%% Config the acquire wait_list channels
switch receiver.syst
    case {'BDS_B1I','B1I_B2I'}
%         receiver.acqCHTable(1).acqCHWaitList = zeros(1,receiver.config.recvConfig.numberOfChannels(1).channelNum);
%         receiver.acqCHTable(1).acqCHWaitNum  = 0;
% 针对冷、热捕获分别初始化通道列表
        receiver.acqCHTable(1).coldAcqCHWaitList = zeros(1,receiver.config.recvConfig.numberOfChannels(1).channelNum);
        receiver.acqCHTable(1).coldAcqCHWaitNum  = 0;
        receiver.acqCHTable(1).hotAcqCHWaitList = zeros(1,receiver.config.recvConfig.numberOfChannels(1).channelNum);
        receiver.acqCHTable(1).hotAcqCHWaitNum  = 0;
        
%         receiver.acqCHTable(2).acqCHWaitList = [];
%         receiver.acqCHTable(2).acqCHWaitNum  = 0;
        receiver.acqCHTable(2).coldAcqCHWaitList = [];
        receiver.acqCHTable(2).coldAcqCHWaitNum  = 0;
        receiver.acqCHTable(2).hotAcqCHWaitList = [];
        receiver.acqCHTable(2).hotAcqCHWaitNum  = 0;
        
    case {'GPS_L1CA','L1CA_L2C'}
%         receiver.acqCHTable(2).acqCHWaitList = zeros(1, receiver.config.recvConfig.numberOfChannels(2).channelNum);
%         receiver.acqCHTable(2).acqCHWaitNum  = 0;
        receiver.acqCHTable(2).coldAcqCHWaitList = zeros(1,receiver.config.recvConfig.numberOfChannels(2).channelNum);
        receiver.acqCHTable(2).coldAcqCHWaitNum  = 0;
        receiver.acqCHTable(2).hotAcqCHWaitList = zeros(1,receiver.config.recvConfig.numberOfChannels(2).channelNum);
        receiver.acqCHTable(2).hotAcqCHWaitNum  = 0;
        
%         receiver.acqCHTable(1).acqCHWaitList = [];
%         receiver.acqCHTable(1).acqCHWaitNum  = 0;
        receiver.acqCHTable(1).coldAcqCHWaitList = [];
        receiver.acqCHTable(1).coldAcqCHWaitNum  = 0;
        receiver.acqCHTable(1).hotAcqCHWaitList = [];
        receiver.acqCHTable(1).hotAcqCHWaitNum  = 0;
        
    case {'B1I_L1CA','B1I_B2I_L1CA_L2C'}
%         receiver.acqCHTable(1).acqCHWaitList = zeros(1,receiver.config.recvConfig.numberOfChannels(1).channelNum);
%         receiver.acqCHTable(1).acqCHWaitNum  = 0;
%         receiver.acqCHTable(2).acqCHWaitList = zeros(1, receiver.config.recvConfig.numberOfChannels(2).channelNum);
%         receiver.acqCHTable(2).acqCHWaitNum  = 0;
        receiver.acqCHTable(1).coldAcqCHWaitList = zeros(1,receiver.config.recvConfig.numberOfChannels(1).channelNum);
        receiver.acqCHTable(1).coldAcqCHWaitNum  = 0;
        receiver.acqCHTable(1).hotAcqCHWaitList = zeros(1,receiver.config.recvConfig.numberOfChannels(1).channelNum);
        receiver.acqCHTable(1).hotAcqCHWaitNum  = 0;
        
        receiver.acqCHTable(2).coldAcqCHWaitList = zeros(1,receiver.config.recvConfig.numberOfChannels(2).channelNum);
        receiver.acqCHTable(2).coldAcqCHWaitNum  = 0;
        receiver.acqCHTable(2).hotAcqCHWaitList = zeros(1,receiver.config.recvConfig.numberOfChannels(2).channelNum);
        receiver.acqCHTable(2).hotAcqCHWaitNum  = 0;
          
end

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