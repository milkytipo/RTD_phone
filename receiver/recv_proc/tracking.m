function channels = tracking(config, channels, recorder, sis, N, gpuExist, pvtCalculator, Trun)

global GSAR_CONSTANTS;
dfu_bds = pvtCalculator.clkErr(1,2)*GSAR_CONSTANTS.C/GSAR_CONSTANTS.STR_B1I.B0; % [Hz]
dfu_gps = pvtCalculator.clkErr(2,2)*GSAR_CONSTANTS.C/GSAR_CONSTANTS.STR_L1CA.L0; % [Hz]

% sis_int = sis;
for i=1:GSAR_CONSTANTS.STR_RECV.dataNum
    sis{i} = int8(sis{i});
end
%% ————————————————————并行实现北斗跟踪模块——————————————————————————%
% 跟踪模块变量初始化
listNumBDS = 0;
channelNum = [];
SYST = 'BDS_B1I';
for n = 1 : config.recvConfig.numberOfChannels(1).channelNum
    switch channels(n).STATUS
        case {'PULLIN','HOT_PULLIN', 'TRACK','SUBFRAME_SYNCED'}
            listNumBDS = listNumBDS + 1;
            channelList_BDS(listNumBDS,1) = channels(n);
            fileRecorderList_BDS(listNumBDS,1) = recorder(n);
            channelNum(listNumBDS) = n;
    end
end
% 跟踪模块
if listNumBDS > 0
    channelList_BDS = cumx_multiCH_Recv_Prc_track(SYST, sis, channelList_BDS,listNumBDS,...
        GSAR_CONSTANTS, N, config.recvConfig.Batch1msN, fileRecorderList_BDS, gpuExist, dfu_bds, Trun);   
end
% 变量返回赋值        
for n = 1:listNumBDS
    channels(channelNum(n)) = channelList_BDS(n);
end

%% ————————————————————并行实现GPS_L1CA跟踪模块——————————————————————————%
% 跟踪模块变量初始化
listNumGPS = 0;
channelNum = [];
for n = config.recvConfig.numberOfChannels(1).channelNum+1 : config.recvConfig.numberOfChannels(1).channelNumAll
    if (strcmp('GPS_L1CA',channels(n).SYST))
        switch channels(n).STATUS
            case {'PULLIN','HOT_PULLIN', 'TRACK','SUBFRAME_SYNCED'}
                listNumGPS = listNumGPS + 1;
                channelList_GPS(listNumGPS,1) = channels(n);
                fileRecorderList_GPS(listNumGPS,1) = recorder(n);
                channelNum(listNumGPS) = n;
        end
    end
end
% 跟踪模块
if listNumGPS > 0
    channelList_GPS = cumx_multiCH_Recv_Prc_track('GPS_L1CA', sis, channelList_GPS, ...
                                            listNumGPS, GSAR_CONSTANTS, N, config.recvConfig.Batch1msN, fileRecorderList_GPS, gpuExist, dfu_gps, Trun);         
end
% 变量返回赋值        
for n = 1:listNumGPS
    channels(channelNum(n)) = channelList_GPS(n);
end

%% ————————————————————并行实现GPS_L1CA_L2C跟踪模块——————————————————————————%
% 跟踪模块变量初始化
listNumGPS = 0;
clear channelList_GPS;
clear fileRecorderList_GPS;
channelNum = [];
for n = config.recvConfig.numberOfChannels(1).channelNum+1 : config.recvConfig.numberOfChannels(1).channelNumAll
    if (strcmp('GPS_L1CA_L2C',channels(n).SYST))
        switch channels(n).STATUS
            case {'PULLIN','HOT_PULLIN', 'TRACK','SUBFRAME_SYNCED'}
                listNumGPS = listNumGPS + 1;
                channelList_GPS(listNumGPS,1) = channels(n);
                fileRecorderList_GPS(listNumGPS,1) = recorder(n);
                channelNum(listNumGPS) = n;
        end
    end
end
% 跟踪模块
if listNumGPS > 0
    channelList_GPS = cumx_multiCH_Recv_Prc_track('GPS_L1CA_L2C', sis, channelList_GPS, ...
                      listNumGPS, GSAR_CONSTANTS, N, config.recvConfig.Batch1msN, fileRecorderList_GPS, gpuExist, dfu_gps, Trun);
end
% 变量返回赋值        
for n = 1:listNumGPS
    channels(channelNum(n)) = channelList_GPS(n);
end
