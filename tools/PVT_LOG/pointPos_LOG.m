% Single point PVT procedure
function [receiver] = pointPos_LOG(receiver, pvtForecast_Succ, parameter, Loop)
%% Initialization
global GSAR_CONSTANTS;  
BDS_maxPrnNo = receiver.config.recvConfig.configPage.systConfig.BDS_B1I.maxPrnNo;
GPS_maxPrnNo = receiver.config.recvConfig.configPage.systConfig.GPS_L1CA.maxPrnNo;
recvSYST = receiver.syst;
config = receiver.config;
channels = receiver.channels;
actvPvtChannels = receiver.actvPvtChannels;
satelliteTable = receiver.satelliteTable;
ephemeris = receiver.ephemeris;
almanac = receiver.almanac;
recv_timer = receiver.timer;
pvtCalculator = receiver.pvtCalculator;
rawP.GPS = zeros(1, GPS_maxPrnNo);
rawP.BDS = zeros(1, BDS_maxPrnNo);
satClkCorr.BDS = zeros(2, BDS_maxPrnNo);
satClkCorr.GPS = zeros(2, GPS_maxPrnNo);
satPositions.BDS = zeros(6, BDS_maxPrnNo);
satPositions.GPS = zeros(6, GPS_maxPrnNo);
EphAll.BDS = [];
EphAll.GPS = [];
transmitTime.BDS = zeros(1, BDS_maxPrnNo);
transmitTime.GPS = zeros(1, GPS_maxPrnNo);
CN0.BDS = zeros(2, BDS_maxPrnNo);
CN0.GPS = zeros(2, GPS_maxPrnNo);
% Active channel list


BDS_PRN = parameter(1).prnNo(:, Loop);
BDS_PRN = BDS_PRN(~isnan(BDS_PRN))';
GPS_PRN = parameter(2).prnNo(:, Loop);
GPS_PRN = GPS_PRN(~isnan(GPS_PRN))';


svnum.BDS = length(BDS_PRN);% this flag is to find whether avaliable satellite is above 4
svnum.GPS = length(GPS_PRN);
activeChannel.BDS(2,:) = BDS_PRN;
activeChannel.GPS(2,:) = GPS_PRN;% avaliable channels

c = 2.99792458e8;


for prnj=1:32
    ephemeris(2).para(prnj).eph.Alpha0 = 1.024454832077E-08;
    ephemeris(2).para(prnj).eph.Alpha1 = 2.235174179077E-08;
    ephemeris(2).para(prnj).eph.Alpha2 = -5.960464477539E-08;
    ephemeris(2).para(prnj).eph.Alpha3 = -1.192092895508E-07;
    ephemeris(2).para(prnj).eph.Beta0  = 9.625600000000E+04;
    ephemeris(2).para(prnj).eph.Beta1  = 1.310720000000E+05;
    ephemeris(2).para(prnj).eph.Beta2  = -6.553600000000E+04;
    ephemeris(2).para(prnj).eph.Beta3  = -5.898240000000E+05;
end
for prnj=1:32
    ephemeris(1).para(prnj).eph.Alpha0 = 1.769512891769E-08;
    ephemeris(1).para(prnj).eph.Alpha1 = 2.682209014893E-07;
    ephemeris(1).para(prnj).eph.Alpha2 = -2.324581146240E-06;
    ephemeris(1).para(prnj).eph.Alpha3 = 4.291534423828E-06;
    ephemeris(1).para(prnj).eph.Beta0  = 1.495040000000E+05;
    ephemeris(1).para(prnj).eph.Beta1  = -9.011200000000E+05;
    ephemeris(1).para(prnj).eph.Beta2  = 6.946816000000E+06;
    ephemeris(1).para(prnj).eph.Beta3  = -6.029312000000E+06;
end

%% Start PVT
if (svnum.BDS + svnum.GPS) >= 1
    %---------- ¼ÆËãGPS¹Û²âÁ¿ ----------
    if svnum.GPS >= 1
        for i = 1 : svnum.GPS
            transmitTime.GPS(1, GPS_PRN(i)) = parameter(2).TransTime(GPS_PRN(i), Loop);
            satPositions.GPS(1:3, GPS_PRN(i)) = parameter(2).satPos(GPS_PRN(i)).position(1:3, Loop);
            satPositions.GPS(4:6, GPS_PRN(i)) = parameter(2).satPos(GPS_PRN(i)).velocity(1:3, Loop);
            satClkCorr.GPS(1, GPS_PRN(i)) = parameter(2).satClkErr(GPS_PRN(i), Loop)/c;
            satClkCorr.GPS(2, GPS_PRN(i)) = parameter(2).satClkDrift(GPS_PRN(i), Loop)/c;
            rawP.GPS(1, GPS_PRN(i)) = parameter(2).Pseudorange(GPS_PRN(i), Loop);
            CN0.GPS(1, GPS_PRN(i)) = parameter(2).pathPara(GPS_PRN(i)).CNR(1, Loop);     
            pvtCalculator.GPS.doppSmooth(GPS_PRN(i), 3) = parameter(2).carriFreq(GPS_PRN(i), Loop) - GSAR_CONSTANTS.STR_L1CA.L0;   
        end
    end
    %---------- Compute BDS observables ----------
    if svnum.BDS >= 1
        for i = 1 : svnum.BDS
            transmitTime.BDS(1, BDS_PRN(i)) = parameter(1).TransTime(BDS_PRN(i), Loop);
            satPositions.BDS(1:3, BDS_PRN(i)) = parameter(1).satPos(BDS_PRN(i)).position(1:3, Loop);
            satPositions.BDS(4:6, BDS_PRN(i)) = parameter(1).satPos(BDS_PRN(i)).velocity(1:3, Loop);
            satClkCorr.BDS(1, BDS_PRN(i)) = parameter(1).satClkErr(BDS_PRN(i), Loop)/c;
            satClkCorr.BDS(2, BDS_PRN(i)) = parameter(1).satClkDrift(BDS_PRN(i), Loop)/c;
            rawP.BDS(1, BDS_PRN(i)) = parameter(1).Pseudorange(BDS_PRN(i), Loop);
            CN0.BDS(1, BDS_PRN(i)) = parameter(1).pathPara(BDS_PRN(i)).CNR(1, Loop);
            pvtCalculator.BDS.doppSmooth(BDS_PRN(i), 3) = parameter(1).carriFreq(BDS_PRN(i), Loop) - GSAR_CONSTANTS.STR_B1I.B0;   
        end
    end
    
    if strcmp(recvSYST,'BDS_B1I') || (strcmp(recvSYST,'B1I_L1CA') && svnum.GPS==0)
%         [xyzdt,el,az,dop, raimG, raimB,prError,pvtCalculator] = leastSquarePos_BDS(satPositions.BDS, rawP.BDS+satClkCorr.BDS(1,:)*299792458, ...
%                     transmitTime.BDS,ephemeris(1).para,activeChannel.BDS, config.recvConfig.elevationMask, checkNGEO,satClkCorr.BDS(2,:),pvtCalculator, posiChannel.BDS,recv_time);
        switch config.recvConfig.positionType
            case 00 % least-square single point positioning
                [pvtCalculator, recv_timer, satelliteTable(1)] = ...
                    lsPVT_resiraim_BDS(satPositions.BDS, ...
                                rawP.BDS, ...
                                transmitTime.BDS, ...
                                satClkCorr.BDS, ...
                                CN0.BDS, ...
                                config, ...
                                activeChannel.BDS, ...
                                satelliteTable(1), ...
                                ephemeris(1).para, ...
                                recv_timer, ...
                                pvtCalculator, ...
                                pvtForecast_Succ);
            case 01 % kalman single point positioning
                
        end
        
    elseif strcmp(recvSYST,'GPS_L1CA') || ( strcmp(recvSYST,'B1I_L1CA') && svnum.BDS==0 )
        switch config.recvConfig.positionType
            case 00 % least-square single point positioning
                [pvtCalculator, recv_timer, satelliteTable(2)] = ...
                    lsPVT_resiraim_GPS(satPositions.GPS, ...% matrix[6x32], each column for a sat [x;y;z;vx;vy;vz]
                               rawP.GPS, ...% vector[1x32], each for a sat pseudorange [meter]
                               transmitTime.GPS, ...% vector[1x32], each for a sat transmit time [sec]
                               satClkCorr.GPS, ...% matrix[2x32], each colum for a sat [clk_dt; clk_df]
                               config, ...% receiver config struct
                               channels, ...% receiver channel list, [nx1:channel]
                               activeChannel.GPS, ...% matrix[2xNum], row1 for channel ID list; row2 for prn list; Num for number of active channels
                               satelliteTable(2), ...
                               ephemeris(2).para, ...% ephemeris para struct for GPS, [1x32 struct]
                               recv_timer, ...
                               pvtCalculator, ...
                               pvtForecast_Succ);
            case 01 % kalman single point positioning
                [pvtCalculator, recv_timer, satelliteTable(2)] = ...
                    kalmanPVT_resiraim_GPS(satPositions.GPS, ...% matrix[6x32], each column for a sat [x;y;z;vx;vy;vz]
                               rawP.GPS, ...% vector[1x32], each for a sat pseudorange [meter]
                               transmitTime.GPS, ...% vector[1x32], each for a sat transmit time [sec]
                               satClkCorr.GPS, ...% matrix[2x32], each colum for a sat [clk_dt; clk_df]
                               config, ...% receiver config struct
                               channels, ...% receiver channel list, [nx1:channel]
                               activeChannel.GPS, ...% matrix[2xNum], row1 for channel ID list; row2 for prn list; Num for number of active channels
                               satelliteTable(2), ...
                               ephemeris(2).para, ...% ephemeris para struct for GPS, [1x32 struct]
                               recv_timer, ...
                               pvtCalculator, ...
                               pvtForecast_Succ);
        end

    elseif  strcmp(recvSYST,'B1I_L1CA')
        switch config.recvConfig.positionType
            case 00 % least-square single point positioning
                [pvtCalculator, recv_timer, satelliteTable(1), satelliteTable(2)] = ...
                    lsPVT_resiraim_JointBdsGps(satPositions.BDS, satPositions.GPS, ...% matrix[6x32], each column for a sat [x;y;z;vx;vy;vz];
                               rawP.BDS, rawP.GPS, ...
                               transmitTime.BDS, transmitTime.GPS, ...
                               satClkCorr.BDS, satClkCorr.GPS, ...
                               CN0.BDS, CN0.GPS, ...
                               config, ...
                               activeChannel.BDS, activeChannel.GPS, ...
                               satelliteTable(1), satelliteTable(2), ...
                               ephemeris(1).para, ephemeris(2).para, ...
                               recv_timer, ...
                               pvtCalculator, ...
                               pvtForecast_Succ);
                    
            case 01 % kalman single point positioning
                
        end
    end
    
    pvtCalculator.positionTime = [recv_timer.year, recv_timer.month, recv_timer.day, recv_timer.hour, recv_timer.min, recv_timer.sec];
end

receiver.pvtCalculator = pvtCalculator;
receiver.satelliteTable = satelliteTable;
end




