% Single point PVT procedure
function [receiver] = pointPos_LOG(receiver,receiver_ref, pvtForecast_Succ, parameter,parameter_ref, Loop)
%% Initialization
global GSAR_CONSTANTS;  
BDS_maxPrnNo = receiver.config.recvConfig.configPage.systConfig.BDS_B1I.maxPrnNo;
GPS_maxPrnNo = receiver.config.recvConfig.configPage.systConfig.GPS_L1CA.maxPrnNo;
recvSYST = receiver.syst;
config = receiver.config;
channels = receiver.channels;
satelliteTable = receiver.satelliteTable;
BDS_eph = receiver.naviMsg.BDS_B1I.ephemeris;
GPS_eph = receiver.naviMsg.GPS_L1CA.ephemeris;
recv_timer = receiver.timer;
pvtCalculator = receiver.pvtCalculator;
pvtCalculator_ref = receiver_ref.pvtCalculator;
rawP.GPS = zeros(1, GPS_maxPrnNo);
rawP.BDS = zeros(1, BDS_maxPrnNo);
rawP_ref.GPS = zeros(1, GPS_maxPrnNo);
rawP_ref.BDS = zeros(1, BDS_maxPrnNo);
satClkCorr.BDS = zeros(2, BDS_maxPrnNo);
satClkCorr.GPS = zeros(2, GPS_maxPrnNo);
satClkCorr_ref.BDS = zeros(2, BDS_maxPrnNo);
satClkCorr_ref.GPS = zeros(2, GPS_maxPrnNo);
satPositions.BDS = zeros(6, BDS_maxPrnNo);
satPositions.GPS = zeros(6, GPS_maxPrnNo);
satPositions_ref.BDS = zeros(6, BDS_maxPrnNo);  
satPositions_ref.GPS = zeros(6, GPS_maxPrnNo);

EphAll.BDS = [];
EphAll.GPS = [];
transmitTime.BDS = zeros(1, BDS_maxPrnNo);
transmitTime.GPS = zeros(1, GPS_maxPrnNo);
transmitTime_ref.GPS = zeros(1, GPS_maxPrnNo);
CN0.BDS = zeros(2, BDS_maxPrnNo);
CN0.GPS = zeros(2, GPS_maxPrnNo);
CN0_ref.GPS = zeros(2, GPS_maxPrnNo);
% Active channel list
IMU_MEMS = zeros(3,1);

BDS_PRN = parameter(1).prnNo(:, Loop);
BDS_PRN = BDS_PRN(~isnan(BDS_PRN))';
% GPS_PRN = parameter_ref(2).prnNo(:, Loop);
% GPS_PRN = GPS_PRN(~isnan(GPS_PRN))';

GPS_PRN =intersect( parameter_ref(2).prnNo(:, Loop), parameter(2).prnNo(:, Loop));
for  i  = 1:32
   if parameter(2).Elevation(i,Loop) <15
        GPS_PRN( GPS_PRN == i) = [];
   end
end

svnum.BDS = length(BDS_PRN);% this flag is to find whether avaliable satellite is above 4
svnum.GPS = length(GPS_PRN);
activeChannel.BDS(2,:) = BDS_PRN;
activeChannel.GPS(2,:) = GPS_PRN;% avaliable channels

c = 2.99792458e8;


for prnj=1:32 % GPS
    GPS_eph(prnj).eph.Alpha0 = 2.186179e-008; 
    GPS_eph(prnj).eph.Alpha1 = -9.73869e-008;
    GPS_eph(prnj).eph.Alpha2 = 7.03774e-008;
    GPS_eph(prnj).eph.Alpha3 = 3.031505e-008;
    GPS_eph(prnj).eph.Beta0  = 129643.8; 
    GPS_eph(prnj).eph.Beta1  = -64245.75;
    GPS_eph(prnj).eph.Beta2  = -866336.2;
    GPS_eph(prnj).eph.Beta3  = 1612913;
end
for prnj=1:32 % BDS
    BDS_eph(prnj).eph.Alpha0 = 1.396983861923E-08;
    BDS_eph(prnj).eph.Alpha1 = 2.384185791016E-07;
    BDS_eph(prnj).eph.Alpha2 = -2.324581146240E-06;
    BDS_eph(prnj).eph.Alpha3 = 4.768371582031E-06;
    BDS_eph(prnj).eph.Beta0  = 1.515520000000E+05;
    BDS_eph(prnj).eph.Beta1  = -1.064960000000E+06;
    BDS_eph(prnj).eph.Beta2  = 7.798784000000E+06;
    BDS_eph(prnj).eph.Beta3  = -6.684672000000E+06;
end

%% Start PVT
if (svnum.BDS + svnum.GPS) >= 1
    %---------- ¼ÆËãGPS¹Û²âÁ¿ ----------
    if svnum.GPS >= 1
        for i = 1 : svnum.GPS
            transmitTime.GPS(1, GPS_PRN(i)) = parameter(2).TransTime(GPS_PRN(i), Loop);
            transmitTime_ref.GPS(1, GPS_PRN(i)) = parameter_ref(2).TransTime(GPS_PRN(i), Loop);
            satPositions.GPS(1:3, GPS_PRN(i)) = parameter(2).satPos(GPS_PRN(i)).position(1:3, Loop);
            satPositions.GPS(4:6, GPS_PRN(i)) = parameter(2).satPos(GPS_PRN(i)).velocity(1:3, Loop);
            satPositions_ref.GPS(1:3, GPS_PRN(i)) = parameter_ref(2).satPos(GPS_PRN(i)).position(1:3, Loop);
            satPositions_ref.GPS(4:6, GPS_PRN(i)) = parameter_ref(2).satPos(GPS_PRN(i)).velocity(1:3, Loop);
            IMU_MEMS =[ parameter(2).IMU_ax(Loop); parameter(2).IMU_ay(Loop) ;parameter(2).IMU_az(Loop)];

            satClkCorr.GPS(1, GPS_PRN(i)) = parameter(2).satClkErr(GPS_PRN(i), Loop)/c;
            satClkCorr.GPS(2, GPS_PRN(i)) = parameter(2).satClkDrift(GPS_PRN(i), Loop)/c;
            satClkCorr_ref.GPS(1, GPS_PRN(i)) = parameter_ref(2).satClkErr(GPS_PRN(i), Loop)/c;
            satClkCorr_ref.GPS(2, GPS_PRN(i)) = parameter_ref(2).satClkDrift(GPS_PRN(i), Loop)/c;
            
            rawP.GPS(1, GPS_PRN(i)) = parameter(2).Pseudorange(GPS_PRN(i), Loop);
            rawP_ref.GPS(1, GPS_PRN(i)) = parameter_ref(2).Pseudorange(GPS_PRN(i), Loop);
            CN0.GPS(1, GPS_PRN(i)) = parameter(2).pathPara(GPS_PRN(i)).CNR(1, Loop);
            CN0_ref.GPS(1, GPS_PRN(i)) = parameter_ref(2).pathPara(GPS_PRN(i)).CNR(1, Loop);
            pvtCalculator.GPS.doppSmooth(GPS_PRN(i), 3) = -parameter(2).doppFreq(GPS_PRN(i), Loop) * GSAR_CONSTANTS.C/GSAR_CONSTANTS.STR_L1CA.L0; 
            pvtCalculator_ref.GPS.doppSmooth(GPS_PRN(i), 3) = -parameter_ref(2).doppFreq(GPS_PRN(i), Loop) * GSAR_CONSTANTS.C/GSAR_CONSTANTS.STR_L1CA.L0;          
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
            pvtCalculator.BDS.doppSmooth(BDS_PRN(i), 3) = -parameter(1).doppFreq(BDS_PRN(i), Loop) * GSAR_CONSTANTS.C/GSAR_CONSTANTS.STR_B1I.B0;   
        end
    end
    
    if strcmp(recvSYST,'BDS_B1I')
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
                                BDS_eph, ...
                                recv_timer, ...
                                pvtCalculator, ...
                                pvtForecast_Succ);
            case 01 % kalman single point positioning
                [pvtCalculator, recv_timer, satelliteTable(1)] = ...
                    kalmanPVT_resiraim_BDS(satPositions.BDS, ...
                                rawP.BDS, ...
                                transmitTime.BDS, ...
                                satClkCorr.BDS, ...
                                CN0.BDS, ...
                                config, ...
                                activeChannel.BDS, ...
                                satelliteTable(1), ...
                                BDS_eph, ...
                                recv_timer, ...
                                pvtCalculator, ...
                                pvtForecast_Succ);
        end
        
    elseif strcmp(recvSYST,'GPS_L1CA')
        switch config.recvConfig.positionType
            case 00 % least-square single point positioning
                [pvtCalculator, recv_timer, satelliteTable(2)] = ...
                    lsPVT_resiraim_GPS(satPositions.GPS, ...% matrix[6x32], each column for a sat [x;y;z;vx;vy;vz]
                               satPositions_ref.GPS, ...
                               rawP.GPS, ...% vector[1x32], each for a sat pseudorange [meter]   ***
                               rawP_ref.GPS,...                        
                               transmitTime.GPS, ...% vector[1x32], each for a sat transmit time [sec]
                               transmitTime_ref.GPS, ...
                               satClkCorr.GPS, ...% matrix[2x32], each colum for a sat [clk_dt; clk_df]  ***
                               satClkCorr_ref.GPS,...
                               CN0.GPS, ...
                               CN0_ref.GPS, ...
                               config, ...% receiver config struct
                               channels, ...% receiver channel list, [nx1:channel]
                               activeChannel.GPS, ...% matrix[2xNum], row1 for channel ID list; row2 for prn list; Num for number of active channels
                               satelliteTable(2), ...
                               GPS_eph, ...% ephemeris para struct for GPS, [1x32 struct]
                               recv_timer, ...
                               pvtCalculator, ...
                               pvtCalculator_ref,...
                               parameter, ...
                               Loop,...
                               pvtForecast_Succ);
            case 01 % kalman single point positioning
                [pvtCalculator, recv_timer, satelliteTable(2)] = ...
                    kalmanPVT_resiraim_GPS(satPositions.GPS, ...% matrix[6x32], each column for a sat [x;y;z;vx;vy;vz]   ***
                               satPositions_ref.GPS, ...
                               rawP.GPS, ...% vector[1x32], each for a sat pseudorange [meter]   ***
                               rawP_ref.GPS,...                        
                               transmitTime.GPS, ...% vector[1x32], each for a sat transmit time [sec]
                               transmitTime_ref.GPS, ...
                               satClkCorr.GPS, ...% matrix[2x32], each colum for a sat [clk_dt; clk_df]  ***
                               satClkCorr_ref.GPS,...
                               CN0.GPS, ...
                               CN0_ref.GPS, ...
                               config, ...% receiver config struct
                               channels, ...% receiver channel list, [nx1:channel]
                               activeChannel.GPS, ...% matrix[2xNum], row1 for channel ID list; row2 for prn list; Num for number of active channels
                               satelliteTable(2), ...
                               GPS_eph, ...% ephemeris para struct for GPS, [1x32 struct]
                               recv_timer, ...
                               pvtCalculator, ...
                               pvtCalculator_ref,...
                               parameter, ...
                               Loop,...
                               pvtForecast_Succ,...
                               IMU_MEMS);
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
                               BDS_eph, GPS_eph, ...
                               recv_timer, ...
                               pvtCalculator, ...
                               pvtForecast_Succ);
                    
            case 01 % kalman single point positioning
                [pvtCalculator, recv_timer, satelliteTable(1), satelliteTable(2)] = ...
                    kalmanPVT_resiraim_JointBdsGps(satPositions.BDS, satPositions.GPS, ...% matrix[6x32], each column for a sat [x;y;z;vx;vy;vz];
                               rawP.BDS, rawP.GPS, ...
                               transmitTime.BDS, transmitTime.GPS, ...
                               satClkCorr.BDS, satClkCorr.GPS, ...
                               CN0.BDS, CN0.GPS, ...
                               config, ...
                               activeChannel.BDS, activeChannel.GPS, ...
                               satelliteTable(1), satelliteTable(2), ...
                               BDS_eph, GPS_eph, ...
                               recv_timer, ...
                               pvtCalculator, ...
                               pvtForecast_Succ);
        end
    end
    
    pvtCalculator.positionTime = [recv_timer.year, recv_timer.month, recv_timer.day, recv_timer.hour, recv_timer.min, recv_timer.sec];
end

receiver.pvtCalculator = pvtCalculator;
receiver.satelliteTable = satelliteTable;
receiver.timer = recv_timer;
end




