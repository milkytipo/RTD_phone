function [satTable] = satelliteTableInitializing(satTable, svTarget, configPage_systConfig)
% satTable            - satellite table, storing all information about
%                       system satellites
% svTarget            - target satellites that receiver will process,
%                       normally svTarget include all satellite in operation
% configPage_systConfig - the configuration about systems

%--------- configure BDS satTable -----------------
BDS_maxPrnNo = configPage_systConfig.BDS_B1I.maxPrnNo;      % 最大卫星数目
satTable(1).syst                  = 'BDS_B1I';
satTable(1).PRN                   = 1:BDS_maxPrnNo;

satTable(1).satInOperation        = zeros(1, BDS_maxPrnNo);
satTable(1).satInOperation(configPage_systConfig.BDS_B1I.satsInOperation) = 1; % Only those satellites in operation will be considered to be processed

% Only those target-and-inOperation satellite will be processed, so the
% corresponding satInOperation value will be equal to 2. Normally, the
% target satellites will be the satellite in operation.
satTable(1).satInOperation(svTarget(1).prnNum) = satTable(1).satInOperation(svTarget(1).prnNum) + 1;   % 0: sat not in operation
                                                                                                       % 1: sats in operation
                                                                                                       % 2: sats in-operation & target 
% satVisible is constantly updated during the receiver processing
satTable(1).satVisible            = -ones(1, BDS_maxPrnNo);    % -1:   cold start, no eph or ala info, don't know if the target satellites are visible
                                                               % 0:    sat invisible
                                                               % 1:    sat visible

satTable(1).satHealth             = ones(1, BDS_maxPrnNo);     % 1: sat healthy (default) \ 0: sat unhealthy
satTable(1).satBlock              = -ones(1, BDS_maxPrnNo);    % -1: sat not yet processed \ 0: unblocked \ 1: blocked
satTable(1).satBlockAge           = zeros(1, BDS_maxPrnNo);
satTable(1).ephemerisReady        = zeros(1, BDS_maxPrnNo);
satTable(1).ephemerisAge          = zeros(1, BDS_maxPrnNo);
satTable(1).almanacReady          = zeros(1, BDS_maxPrnNo);
satTable(1).almanacAge            = zeros(1, BDS_maxPrnNo);

satTable(1).satPosxyz             = zeros(6, BDS_maxPrnNo);
satTable(1).satElevation          = zeros(1, BDS_maxPrnNo);
satTable(1).satAzimuth            = zeros(1, BDS_maxPrnNo);

satTable(1).SCNR                  = -100*ones(2, BDS_maxPrnNo);
satTable(1).MPStatus              = zeros(1, BDS_maxPrnNo);

satTable(1).processState = repmat({'IDLE'},1,BDS_maxPrnNo);
L = satTable(1).satInOperation==2;
satTable(1).processState(L) = {'WAIT_FOR_PROCESS'}; % 'WAIT_FOR_PROCESS' means the satellite has not been process (acquire/track) before.

satTable(1).satCandiPrio = [];
satTable(1).nCandiPrio = 0;
satTable(1).satCandi = [];
satTable(1).nCandi = 0;

%--------- configure GPS satTable -----------------
GPS_maxPrnNo = configPage_systConfig.GPS_L1CA.maxPrnNo;      % 最大卫星数目
satTable(2).syst                  = 'GPS_L1CA';
satTable(2).PRN                   = 1:GPS_maxPrnNo;

satTable(2).satInOperation        = zeros(1, GPS_maxPrnNo);
satTable(2).satInOperation(configPage_systConfig.GPS_L1CA.satsInOperation) = 1;
satTable(2).satInOperation(svTarget(2).prnNum) = satTable(2).satInOperation(svTarget(2).prnNum) + 1;   % 0: sat not in operation
                                                                                                       % 1: sats in operation
                                                                                                       % 2: sats in-operation & target 
satTable(2).satVisible            = -ones(1, GPS_maxPrnNo); 
satTable(2).satHealth             = ones(1, GPS_maxPrnNo);
satTable(2).satBlock              = -ones(1, GPS_maxPrnNo);
satTable(2).satBlockAge           = zeros(1, GPS_maxPrnNo);
satTable(2).ephemerisReady        = zeros(1, GPS_maxPrnNo);
satTable(2).ephemerisAge          = zeros(1, GPS_maxPrnNo);
satTable(2).almanacReady          = zeros(1, GPS_maxPrnNo);
satTable(2).almanacAge            = zeros(1, GPS_maxPrnNo);

satTable(2).satPosxyz             = zeros(6, GPS_maxPrnNo);
satTable(2).satElevation          = zeros(1, GPS_maxPrnNo);
satTable(2).satAzimuth            = zeros(1, GPS_maxPrnNo);

satTable(2).SCNR                  = -100*ones(2, GPS_maxPrnNo);
satTable(2).MPStatus              = zeros(1, GPS_maxPrnNo);

satTable(2).processState = repmat({'IDLE'},1,GPS_maxPrnNo);
L = satTable(2).satInOperation==2;
satTable(2).processState(L) = {'WAIT_FOR_PROCESS'};

satTable(2).satCandiPrio = [];
satTable(2).nCandiPrio = 0;
satTable(2).satCandi = [];
satTable(2).nCandi = 0;

end