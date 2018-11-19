% the receiver's coldstart mode initialization operations
function [receiver] = ColdStartIni(receiver)

global GSAR_CONSTANTS;

% Empty reference position and  time
receiver.config.recvConfig.truePosition = [];
receiver.config.recvConfig.trueTime = -1;

% Assign visible satellites to channels, if exceed capacity, select former ones, if insufficient, use invisible satellites and set 'IDLE'.
switch receiver.syst
    case 'BDS_B1I'
        % 配置北斗B1信号参数
        bdsatInOperation = receiver.satelliteTable(1).satInOperation;
        L = bdsatInOperation>=2;
        receiver.satelliteTable(1).satCandiPrio = receiver.satelliteTable(1).PRN(L);
        receiver.satelliteTable(1).nCandiPrio = length(receiver.satelliteTable(1).satCandiPrio);
        
%         bdsCandidateSats = receiver.satelliteTable(1).PRN(L);
%         nBdsCandi = length(bdsCandidateSats);
        
        if receiver.config.recvConfig.numberOfChannels(1).channelNum > 0
            for n = 1:receiver.config.recvConfig.numberOfChannels(1).channelNum
                if receiver.satelliteTable(1).nCandiPrio > 0  
%                     prn = receiver.config.visibleSatellites(1).prnNum(n);
                    prn = receiver.satelliteTable(1).satCandiPrio(1);
                    receiver.channels(n).SYST = 'BDS_B1I';
                    receiver.channels(n).STATUS = 'COLD_ACQ';
                    receiver.satelliteTable(1).processState(prn) = {'COLD_ACQ'};
                    receiver.channels(n) = BdsCH_ColdInitialize(receiver.channels(n), receiver.syst, 'COLD_ACQ', prn, receiver.config.recvConfig.configPage, GSAR_CONSTANTS, receiver.device);
                    receiver.satelliteTable(1).satCandiPrio(1) = []; % 去除第一颗卫星
                    receiver.satelliteTable(1).nCandiPrio = receiver.satelliteTable(1).nCandiPrio - 1;
                else
                    receiver.channels(n).SYST = 'BDS_B1I';
                    receiver.channels(n).STATUS = 'IDLE';
                    receiver.channels(n).CH_B1I.CH_STATUS = receiver.channels(n).STATUS;
                    receiver.channels(n).CH_B1I.PRNID = 0;
                end
            end
        end
        
    case 'GPS_L1CA'
        % 配置GPS信号参数
        gpsatInOperation = receiver.satelliteTable(2).satInOperation;
        L = gpsatInOperation>=2;
        receiver.satelliteTable(2).satCandiPrio = receiver.satelliteTable(2).PRN(L);
        receiver.satelliteTable(2).nCandiPrio = length(receiver.satelliteTable(2).satCandiPrio);
        
%         gpsCandidateSats = receiver.satelliteTable(2).PRN(L);
%         nGpsCandi = length(gpsCandidateSats);      
        
        if receiver.config.recvConfig.numberOfChannels(2).channelNum > 0
            for n = 1:receiver.config.recvConfig.numberOfChannels(2).channelNum
                if receiver.satelliteTable(2).nCandiPrio > 0    % length(receiver.config.recvConfig.visibleSatellites(2).prnNum)
%                     prn = receiver.config.visibleSatellites(2).prnNum(n);
                    prn = receiver.satelliteTable(2).satCandiPrio(1);
                    receiver.channels(n).SYST = 'GPS_L1CA';
                    receiver.channels(n).STATUS = 'COLD_ACQ';
                    receiver.satelliteTable(2).processState(prn) = {'COLD_ACQ'};
                    receiver.channels(n) = GpsCH_ColdInitialize(receiver.channels(n), receiver.syst, 'COLD_ACQ', prn, receiver.config.recvConfig.configPage, GSAR_CONSTANTS, receiver.device);
                    receiver.satelliteTable(2).satCandiPrio(1) = []; % 去除第一颗卫星
                    receiver.satelliteTable(2).nCandiPrio = receiver.satelliteTable(2).nCandiPrio - 1;
                else
                    receiver.channels(n).SYST = 'GPS_L1CA';
                    receiver.channels(n).STATUS = 'IDLE';
                    receiver.channels(n).CH_L1CA.CH_STATUS = receiver.channels(n).STATUS;
                    receiver.channels(n).CH_L1CA.PRNID = 0;
                end
            end
        end
        
    case 'B1I_L1CA'
        % 配置北斗B1信号参数
        bdsatInOperation = receiver.satelliteTable(1).satInOperation;
        L = bdsatInOperation>=2;
        receiver.satelliteTable(1).satCandiPrio = receiver.satelliteTable(1).PRN(L);
        receiver.satelliteTable(1).nCandiPrio = length(receiver.satelliteTable(1).satCandiPrio);
        
        if receiver.config.recvConfig.numberOfChannels(1).channelNum > 0
            for n = 1:receiver.config.recvConfig.numberOfChannels(1).channelNum
                if receiver.satelliteTable(1).nCandiPrio > 0  % length(receiver.config.visibleSatellites(1).prnNum)
%                     prn = receiver.config.visibleSatellites(1).prnNum(n);
                    prn = receiver.satelliteTable(1).satCandiPrio(1);
                    receiver.channels(n).SYST = 'BDS_B1I';
                    receiver.channels(n).STATUS = 'COLD_ACQ';
                    receiver.satelliteTable(1).processState(prn) = {'COLD_ACQ'};
                    receiver.channels(n) = BdsCH_ColdInitialize(receiver.channels(n), receiver.syst, 'COLD_ACQ', prn, receiver.config.recvConfig.configPage, GSAR_CONSTANTS, receiver.device);
                    receiver.satelliteTable(1).satCandiPrio(1) = []; % 去除第一颗卫星
                    receiver.satelliteTable(1).nCandiPrio = receiver.satelliteTable(1).nCandiPrio - 1;
                else
                    receiver.channels(n).SYST = 'BDS_B1I';
                    receiver.channels(n).STATUS = 'IDLE';
                    receiver.channels(n).CH_B1I.CH_STATUS = receiver.channels(n).STATUS;
                    receiver.channels(n).CH_B1I.PRNID = 0;
                end
            end
        end
         % 配置GPS信号参数
        gpsatInOperation = receiver.satelliteTable(2).satInOperation;
        L = gpsatInOperation>=2;
        receiver.satelliteTable(2).satCandiPrio = receiver.satelliteTable(2).PRN(L);
        receiver.satelliteTable(2).nCandiPrio = length(receiver.satelliteTable(2).satCandiPrio);
         
        if receiver.config.recvConfig.numberOfChannels(2).channelNum > 0
            for n = 1:receiver.config.recvConfig.numberOfChannels(2).channelNum
                nGPS = n + receiver.config.recvConfig.numberOfChannels(1).channelNum;
                if receiver.satelliteTable(2).nCandiPrio > 0    % length(receiver.config.visibleSatellites(2).prnNum)
%                     prn = receiver.config.visibleSatellites(2).prnNum(n);
                    prn = receiver.satelliteTable(2).satCandiPrio(1);
                    receiver.channels(nGPS).SYST = 'GPS_L1CA';
                    receiver.channels(nGPS).STATUS = 'COLD_ACQ';
                    receiver.satelliteTable(2).processState(prn) = {'COLD_ACQ'};
                    receiver.channels(nGPS) = GpsCH_ColdInitialize(receiver.channels(nGPS), receiver.syst, 'COLD_ACQ', prn, receiver.config.recvConfig.configPage, GSAR_CONSTANTS, receiver.device);
                    receiver.satelliteTable(2).satCandiPrio(1) = []; % 去除第一颗卫星
                    receiver.satelliteTable(2).nCandiPrio = receiver.satelliteTable(2).nCandiPrio - 1;
                else
                    receiver.channels(nGPS).SYST = 'GPS_L1CA';
                    receiver.channels(nGPS).STATUS = 'IDLE';
                    receiver.channels(nGPS).CH_L1CA.CH_STATUS = receiver.channels(nGPS).STATUS;
                    receiver.channels(nGPS).CH_L1CA.PRNID = 0;
                end
            end
        end
        
     %GPS双频模式
    case 'L1CA_L2C'
        gpsatInOperation = receiver.satelliteTable(2).satInOperation;
        sat_L2 = receiver.config.recvConfig.configPage.systConfig.GPS_L2C.satsInOperation; %目前双频卫星列表
        L = gpsatInOperation>=2;
        receiver.satelliteTable(2).satCandiPrio = receiver.satelliteTable(2).PRN(L);
        receiver.satelliteTable(2).nCandiPrio = length(receiver.satelliteTable(2).satCandiPrio);
         
        if receiver.config.recvConfig.numberOfChannels(2).channelNum > 0
            for n = 1:receiver.config.recvConfig.numberOfChannels(2).channelNum
                if receiver.satelliteTable(2).nCandiPrio > 0 
                    prn = receiver.satelliteTable(2).satCandiPrio(1);
                    if (ismember(prn,sat_L2)) %双频
                        receiver.channels(n).SYST = 'GPS_L1CA_L2C';
                        receiver.channels(n).STATUS = 'COLD_ACQ';
                        receiver.satelliteTable(2).processState(prn) = {'COLD_ACQ'};
                        receiver.channels(n) = GpsCH_L1L2_ColdInitialize(receiver.channels(n), prn, receiver.config.recvConfig.configPage);
                        receiver.satelliteTable(2).satCandiPrio(1) = []; % 去除第一颗卫星
                        receiver.satelliteTable(2).nCandiPrio = receiver.satelliteTable(2).nCandiPrio - 1;
                    else %单频
                        receiver.channels(n).SYST = 'GPS_L1CA';
                        receiver.channels(n).STATUS = 'COLD_ACQ';
                        receiver.satelliteTable(2).processState(prn) = {'COLD_ACQ'};
                        receiver.channels(n) = GpsCH_ColdInitialize(receiver.channels(n), receiver.syst, 'COLD_ACQ', prn, receiver.config.recvConfig.configPage, GSAR_CONSTANTS, receiver.device);
                        receiver.satelliteTable(2).satCandiPrio(1) = []; % 去除第一颗卫星
                        receiver.satelliteTable(2).nCandiPrio = receiver.satelliteTable(2).nCandiPrio - 1;
                    end
                else    %闲置通道不对CH_INFO初始化
                    receiver.channels(n).SYST = 'GPS_L1CA_L2C';
                    receiver.channels(n).STATUS = 'IDLE';
                end
            end
        end
        
    otherwise
        error('Unable to start receiver: undefined working mode!');
        
end


