%% Three_Tower_Data PVT test based on SatObs and Rinex Obs
close all; fclose all; clear all; clc; 
%% Reading the GPFPD positioning results from logfiles
[XYZ, TOWSEC] = readGPFPD('D:\Work\mp_research\sv_cadll\trunk\m\logfile\The_Three_Towers_GPFPD.txt');
N = length(TOWSEC);
Refpos = [-2852104.75; 4654050.36; 3288351.12];
ttd_enu_gpfpd_mt = zeros(3,N);
for i=1:N
    ttd_enu_gpfpd_mt(:,i) = xyz2enu(XYZ(i,:)', Refpos);
end
figure, plot(ttd_enu_gpfpd_mt(1,:),ttd_enu_gpfpd_mt(2,:),'o')

%% Testing the positioning results with log results
global GSAR_CONSTANTS;
GSAR_CONSTANTS = GlobalConstants();      % Define some global constants
receiver = ReceiverConstruct();    % Construct the receiver structure

receiver.syst                     = 'B1I_L1CA';         % Navigation signal system: GPS_L1CA / BDS_B1I / B1I_L1CA
receiver.config.recvConfig.startMode         = 'COLD_START';      % COLD_START / WARM_START
% receiver time type
receiver.config.recvConfig.timeType = 'BDST';   % NULL / GPST / BDST
configOpt   = 'DEFAULT';                 % Default configuration ('DEFAULT') / External file configuration ('EXTERN') / Advanced config ('ADVANCED')
configFile  = '.\GSARx_v0.2_SJTU.conf';  % Ignore when using default settings 
receiver.config.recvConfig.configPage        = ConfigLoad(configOpt, GSAR_CONSTANTS, configFile);
receiver.config.recvConfig.positionType      = 00;
receiver.config.recvConfig.targetSatellites(1).syst        = 'BDS_B1I';
receiver.config.recvConfig.targetSatellites(2).syst        = 'GPS_L1CA';
receiver.config.recvConfig.numberOfChannels(1).syst        = 'BDS_B1I';
receiver.config.recvConfig.numberOfChannels(1).channelNum  = 10;            % Number of channels in BDS
receiver.config.recvConfig.numberOfChannels(2).syst        = 'GPS_L1CA';
receiver.config.recvConfig.numberOfChannels(2).channelNum  = 10;            % Number of channels in GPS
receiver.config.recvConfig.elevationMask      = 10;
receiver.pvtCalculator.pvtT                 = 1;  % PVT frequency 1/receiver.pvtCalculator.pvtT [Hz]

receiver = ConfigReceiver(receiver);
recvSyst        = receiver.syst;
config          = receiver.config;
actvPvtChannels = receiver.actvPvtChannels;
ephemeris       = receiver.ephemeris;
pvtCalculator   = receiver.pvtCalculator;
satelliteTable  = receiver.satelliteTable;
recv_timer      = receiver.timer;
recv_timer.timeType = 'BDST';
channels        = receiver.channels;

Refpos = [-2852104.75; 4654050.36; 3288351.12];
C = 299792458;      % 光速
%% Load LogFiles
% load BDS Rinex Navigation Data file
[ ephemeris_C, satNum_C, updateTimes_C, isNorm_C ] = loadEphFromRINEX_C( 'D:\Work\mp_research\sv_cadll\trunk\m\logfile\The_Three_Towers.15R' );
for j=1:satNum_C
    prnj = ephemeris_C(j).prn;
    ephemeris(1).para(prnj).eph.deltan = ephemeris_C(j).deltan;
    ephemeris(1).para(prnj).eph.Cuc    = ephemeris_C(j).cuc;
    ephemeris(1).para(prnj).eph.M0     = ephemeris_C(j).m0;
    ephemeris(1).para(prnj).eph.e      = ephemeris_C(j).ecc;
    ephemeris(1).para(prnj).eph.Cus    = ephemeris_C(j).cus;
    ephemeris(1).para(prnj).eph.Crc    = ephemeris_C(j).crc;
    ephemeris(1).para(prnj).eph.Crs    = ephemeris_C(j).crs;
    ephemeris(1).para(prnj).eph.sqrtA  = ephemeris_C(j).sqrta;
    ephemeris(1).para(prnj).eph.i0     = ephemeris_C(j).i0;
    ephemeris(1).para(prnj).eph.Cic    = ephemeris_C(j).cic;
    ephemeris(1).para(prnj).eph.omegaDot = ephemeris_C(j).omegadot;
    ephemeris(1).para(prnj).eph.Cis    = ephemeris_C(j).cis;
    ephemeris(1).para(prnj).eph.iDot   = ephemeris_C(j).idot;
    ephemeris(1).para(prnj).eph.omega0 = ephemeris_C(j).omega0;
    ephemeris(1).para(prnj).eph.omega  = ephemeris_C(j).omega;
    ephemeris(1).para(prnj).eph.weekNumber = ephemeris_C(j).week;
    ephemeris(1).para(prnj).eph.health = 0;
%     ephemeris(1).para(prnj).eph.TGD1   = ???
%     ephemeris(1).para(prnj).eph.IODC   = ???
%     ephemeris(1).para(prnj).eph.toc    = ???
    ephemeris(1).para(prnj).eph.a2     = ephemeris_C(j).af2;
    ephemeris(1).para(prnj).eph.a1     = ephemeris_C(j).af1;
    ephemeris(1).para(prnj).eph.a0     = ephemeris_C(j).af0;
    ephemeris(1).para(prnj).eph.IODE   = ephemeris_C(j).iode;
    ephemeris(1).para(prnj).eph.Alpha0 = 1.769512891769E-08;
    ephemeris(1).para(prnj).eph.Alpha1 = 2.682209014893E-07;
    ephemeris(1).para(prnj).eph.Alpha2 = -2.324581146240E-06;
    ephemeris(1).para(prnj).eph.Alpha3 = 4.291534423828E-06;
    ephemeris(1).para(prnj).eph.Beta0  = 1.495040000000E+05;
    ephemeris(1).para(prnj).eph.Beta1  = -9.011200000000E+05;
    ephemeris(1).para(prnj).eph.Beta2  = 6.946816000000E+06;
    ephemeris(1).para(prnj).eph.Beta3  = -6.029312000000E+06;
%     ephemeris(1).para(prnj).eph.A0utc  = 
%     ephemeris(1).para(prnj).eph.A1utc  = 
%     ephemeris(1).para(prnj).eph.deltaTls = 
%     ephemeris(1).para(prnj).eph.deltaTlsf= 
%     ephemeris(1).para(prnj).eph.WNlsf  = 
%     ephemeris(1).para(prnj).eph.DN     = 
%     ephemeris(1).para(prnj).eph.A0gps  = 
%     ephemeris(1).para(prnj).eph.A1gps  = 
    ephemeris(1).para(prnj).eph.toe    = ephemeris_C(j).toe;
    
    ephemeris(1).para(prnj).ephReady   = 1;
end

% load GPS Rinex Navigation Data file
% ???
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

% % load RINEX observation information
[parameter, SOW] = readObs('D:\Work\mp_research\sv_cadll\trunk\m\logfile\The_Three_Towers_allObs.txt');


% [C1_obs, L1_obs, S1_obs, D1_obs, ch_obs, TOWSEC_obs] = read_rinex('D:\Work\mp_research\sv_cadll\trunk\m\logfile\The_Three_Towers.15O', 1);
% 
% % load SatObs information
% % BDS satobs 
% [el_C, az_C, SNR_C, CNR_C, carriVar_C, satPos_x_C, satPos_y_C, satPos_z_C, satVel_x_C, satVel_y_C, satVel_z_C, ...
%     satClcErr_C, satClcErrDot_C, TOWSEC_C] = readSatobs('D:\Work\mp_research\sv_cadll\trunk\m\logfile\The_Three_Towers_SateObs_BDS.txt');
% % GPS satobs 
% [el_G, az_G, SNR_G, CNR_G, carriVar_G, satPos_x_G, satPos_y_G, satPos_z_G, satVel_x_G, satVel_y_G, satVel_z_G, ...
%     satClcErr_G, satClcErrDot_G, TOWSEC_G] = readSatobs('D:\Work\mp_research\sv_cadll\trunk\m\logfile\The_Three_Towers_SateObs_GPS.txt');
% 
% % load BDS Mp parameters
% [Mparameter_C, MprnNum_C, MpTOWSEC_C] = readMP('D:\Work\mp_research\sv_cadll\trunk\m\logfile\The_Three_Towers.15BMP');
% % load GPS Mp parameters
% [Mparameter_G, MprnNum_G, MpTOWSEC_G] = readMP('D:\Work\mp_research\sv_cadll\trunk\m\logfile\The_Three_Towers.15GMP');


%% Organize observation for pvt
BDS_maxPrnNo = config.recvConfig.configPage.systConfig.BDS_B1I.maxPrnNo;
GPS_maxPrnNo = config.recvConfig.configPage.systConfig.GPS_L1CA.maxPrnNo;

satpos_bds       = zeros(6, BDS_maxPrnNo);
obs_bds          = zeros(1,BDS_maxPrnNo);
transmitTime_bds = zeros(1,BDS_maxPrnNo);
satClkCorr_bds   = zeros(2,BDS_maxPrnNo);
el_bds           = zeros(1,BDS_maxPrnNo);
az_bds           = zeros(1,BDS_maxPrnNo);
iono_bds         = zeros(1,BDS_maxPrnNo);
trop_bds         = zeros(1,BDS_maxPrnNo);
psr_bds          = zeros(1,BDS_maxPrnNo);
cn0_bds          = zeros(2,BDS_maxPrnNo);

satpos_gps       = zeros(6, GPS_maxPrnNo);
obs_gps          = zeros(1, GPS_maxPrnNo);
transmitTime_gps = zeros(1, GPS_maxPrnNo);
satClkCorr_gps   = zeros(2, GPS_maxPrnNo);
el_gps           = zeros(1,GPS_maxPrnNo);
az_gps           = zeros(1,GPS_maxPrnNo);
iono_gps         = zeros(1,GPS_maxPrnNo);
trop_gps         = zeros(1,GPS_maxPrnNo);
psr_gps          = zeros(1,GPS_maxPrnNo);
cn0_gps          = zeros(2,GPS_maxPrnNo);

% secN = length(TOWSEC_obs);
secN = length(SOW);
pvtForecast_Succ = 0;
pos_xyz_mt = zeros(3, secN);
pos_xyz_checked_mt = zeros(3, secN);
vel_xyz_mt = zeros(3, secN);
vel_xyz_checked_mt = zeros(3, secN);

rankBreak_vt = zeros(1, secN);
ttd_enu_mt = zeros(3, secN);
ttd_enu_checked_mt = zeros(3, secN);

for i=1:secN
    %----------- 1st, find the active channels of BDS -------------
    actvBds_List = ~isnan(parameter(1).Pseudorange(:,i));
    activeChBds_Ni = sum(actvBds_List);
    activeChannel_BDS = zeros(2, activeChBds_Ni);
    activeChannel_BDS(2,1:activeChBds_Ni) = find(actvBds_List)';
    % 2nd, construct the measurements of active channels of BDS
    for n=1:activeChBds_Ni
        bdsprn_in = activeChannel_BDS(2,n);
        satpos_bds(:, bdsprn_in) = [parameter(1).satPos(bdsprn_in).position(:,i);  ...
                                    parameter(1).satPos(bdsprn_in).velocity(:,i)];
        obs_bds(bdsprn_in) = parameter(1).Pseudorange(bdsprn_in, i);
        transmitTime_bds(bdsprn_in) = parameter(1).TransTime(bdsprn_in, i);
        satClkCorr_bds(:, bdsprn_in) = [parameter(1).satClkErr(bdsprn_in,i)/C; parameter(1).satClkDrift(bdsprn_in,i)/C];
        pvtCalculator.BDS.doppSmooth(bdsprn_in, 2) = pvtCalculator.BDS.doppSmooth(bdsprn_in, 1);
        pvtCalculator.BDS.doppSmooth(bdsprn_in, 1) = parameter(1).InteDopp(bdsprn_in, i);
        pvtCalculator.BDS.doppSmooth(bdsprn_in, 3) = parameter(1).carriFreq(bdsprn_in, i) - GSAR_CONSTANTS.STR_B1I.B0;
%         pvtCalculator.BDS.doppSmooth(bdsprn_in, 4) =  pvtCalculator.BDS.doppSmooth(bdsprn_in, 4) + 1;
        cn0_bds(1:2,bdsprn_in) = zeros(2,1);
        cn0_bds(1,bdsprn_in)   = parameter(1).pathPara(bdsprn_in).CNR(1, i); % DLOS CNR
        if parameter(1).pathNum(bdsprn_in, i) % MP CNR
            cn0_bds(2,bdsprn_in)   = parameter(1).pathPara(bdsprn_in).CNR(2, i);
        end
    end
    for j=1:BDS_maxPrnNo
        if sum(j==activeChannel_BDS(2,1:activeChBds_Ni))==0
            pvtCalculator.BDS.doppSmooth(j, 1:4) = 0;
        end
    end
    
    %----------- 3rd, find the active channels of GPS -------------
    actvGps_List = ~isnan(parameter(2).Pseudorange(:,i));
    activeChGps_Ni = sum(actvGps_List);
    activeChannel_GPS = zeros(2, activeChGps_Ni);
    activeChannel_GPS(2,1:activeChGps_Ni) = find(actvGps_List)';
    % 4th, construct the measurements of active channels of GPS
    for n=1:activeChGps_Ni
        gpsprn_in = activeChannel_GPS(2,n);
        satpos_gps(:, gpsprn_in) = [parameter(2).satPos(gpsprn_in).position(:,i);  ...
                                    parameter(2).satPos(gpsprn_in).velocity(:,i)];
        obs_gps(gpsprn_in) = parameter(2).Pseudorange(gpsprn_in, i);
        transmitTime_gps(gpsprn_in) = parameter(2).TransTime(gpsprn_in, i);
        satClkCorr_gps(:,gpsprn_in) = [parameter(2).satClkErr(gpsprn_in,i)/C; parameter(2).satClkDrift(gpsprn_in,i)/C];
        pvtCalculator.GPS.doppSmooth(gpsprn_in, 2) = pvtCalculator.GPS.doppSmooth(gpsprn_in, 1);
        pvtCalculator.GPS.doppSmooth(gpsprn_in, 1) = parameter(2).InteDopp(gpsprn_in, i);
        pvtCalculator.GPS.doppSmooth(gpsprn_in, 3) = parameter(2).carriFreq(gpsprn_in, i) - GSAR_CONSTANTS.STR_L1CA.L0;
%         pvtCalculator.GPS.doppSmooth(gpsprn_in, 4) =  pvtCalculator.GPS.doppSmooth(gpsprn_in, 4) + 1;
        cn0_gps(1:2,gpsprn_in) = zeros(2,1);
        cn0_gps(1:2,gpsprn_in) = parameter(2).pathPara(gpsprn_in).CNR(1, i); % DLOS CNR
        if parameter(2).pathNum(gpsprn_in, i) % MP CNR
            cn0_gps(2,gpsprn_in)   = parameter(2).pathPara(gpsprn_in).CNR(2, i);
        end
    end
    for j=1:GPS_maxPrnNo
        if sum(j==activeChannel_GPS(2,1:activeChGps_Ni))==0
            pvtCalculator.GPS.doppSmooth(j, 1:4) = 0;
        end
    end
    
    recv_timer.recvSOW = SOW(i);
    recv_timer.recvSOW_BDS = SOW(i);
    recv_timer.recvSOW_GPS = SOW(i);
    
%     pvtForecast_Succ = 0;
%     % 计算当前接收机时间和上次定位时刻的时间差值，执行该步骤的前提是接收机本地时间已经
%     if (recv_timer.recvSOW ~= -1) && (pvtCalculator.timeLast ~= -1) && (pvtCalculator.posiCheck > 0)
%     timeDiff = recv_timer.recvSOW - pvtCalculator.timeLast;
    
%     if timeDiff > pvtCalculator.maxInterval %距离上次定位时刻已经超过预设值，则认为通过预测获得的位置信息已经无效
%         pvtCalculator.positionValid = -1;
%         pvtCalculator.posiCheck = -1;
%         pvtCalculator.kalman.preTag = 0; %如果长时间无法获得足够数量的观测信息，则预测的位置结果将发散允许阈值之外，因此将重置Kalman滤波器标志
%     end
%     end
%     if (pvtCalculator.positionValid == 1) && (pvtCalculator.posiCheck >0)
%         pvtCalculator.posForecast = pvtCalculator.positionXYZ + pvtCalculator.positionVelocity(1:3) * timeDiff;
%         pvtForecast_Succ = 1;
%     end
    [pvtCalculator, pvtForecast_Succ] = pvt_forecast_filt(pvtCalculator, recv_timer, config);
    
    if i == 217
        stop=1;
    end
    
    if strcmp(receiver.syst,'BDS_B1I') || (strcmp(receiver.syst,'B1I_L1CA') && activeChGps_Ni==0)
        switch config.recvConfig.positionType
            case 00 % least-square single point positioning
                [pvtCalculator, recv_timer, satelliteTable(1)] = ...
                    lsPVT_resiraim_BDS(satpos_bds, ...
                                obs_bds, ...
                                transmitTime_bds, ...
                                satClkCorr_bds, ...
                                cn0_bds, ...
                                config, ...
                                activeChannel_BDS, ...
                                satelliteTable(1), ...
                                ephemeris(1).para, ...
                                recv_timer, ...
                                pvtCalculator, ...
                                pvtForecast_Succ);
            case 01 % kalman single point positioning
        end
    elseif strcmp(receiver.syst,'GPS_L1CA') || ( strcmp(receiver.syst,'B1I_L1CA') && activeChBds_Ni==0 )
        switch config.recvConfig.positionType
            case 00 % least-square single point positioning
                [pvtCalculator, recv_timer, satelliteTable(2)] = ...
                    lsPVT_resiraim_GPS(satpos_gps, ...% matrix[6x32], each column for a sat [x;y;z;vx;vy;vz]
                               obs_gps, ...% vector[1x32], each for a sat pseudorange [meter]
                               transmitTime_gps, ...% vector[1x32], each for a sat transmit time [sec]
                               satClkCorr_gps, ...% matrix[2x32], each colum for a sat [clk_dt; clk_df]
                               config, ...% receiver config struct
                               channels, ...% receiver channel list, [nx1:channel]
                               activeChannel_GPS, ...% matrix[2xNum], row1 for channel ID list; row2 for prn list; Num for number of active channels
                               satelliteTable(2), ...
                               ephemeris(2).para, ...% ephemeris para struct for GPS, [1x32 struct]
                               recv_timer, ...
                               pvtCalculator, ...
                               pvtForecast_Succ);
            case 01 % kalman single point positioning
                [pvtCalculator, recv_timer, satelliteTable(2)] = ...
                    kalmanPVT_resiraim_GPS(satpos_gps, ...% matrix[6x32], each column for a sat [x;y;z;vx;vy;vz]
                               obs_gps, ...% vector[1x32], each for a sat pseudorange [meter]
                               transmitTime_gps, ...% vector[1x32], each for a sat transmit time [sec]
                               satClkCorr_gps, ...% matrix[2x32], each colum for a sat [clk_dt; clk_df]
                               config, ...% receiver config struct
                               channels, ...% receiver channel list, [nx1:channel]
                               activeChannel_GPS, ...% matrix[2xNum], row1 for channel ID list; row2 for prn list; Num for number of active channels
                               satelliteTable(2), ...
                               ephemeris(2).para, ...% ephemeris para struct for GPS, [1x32 struct]
                               recv_timer, ...
                               pvtCalculator, ...
                               pvtForecast_Succ);
        end
    elseif strcmp(receiver.syst,'B1I_L1CA')
        switch config.recvConfig.positionType
            case 00 % least-square single point positioning
                [pvtCalculator, recv_timer, satelliteTable(1), satelliteTable(2)] = ...
                    lsPVT_resiraim_JointBdsGps(satpos_bds, satpos_gps, ...% matrix[6x32], each column for a sat [x;y;z;vx;vy;vz];
                               obs_bds, obs_gps, ...
                               transmitTime_bds, transmitTime_gps, ...
                               satClkCorr_bds, satClkCorr_gps, ...
                               cn0_bds, cn0_gps, ...
                               config, ...
                               activeChannel_BDS, activeChannel_GPS, ...
                               satelliteTable(1), satelliteTable(2), ...
                               ephemeris(1).para, ephemeris(2).para, ...
                               recv_timer, ...
                               pvtCalculator, ...
                               pvtForecast_Succ);
                    
            case 01 % kalman single point positioning
                
        end
    end

    
      if pvtCalculator.positionValid == 1
          pos_xyz_mt(:,i)   = pvtCalculator.positionXYZ;
          vel_xyz_mt(:,i)   = pvtCalculator.positionVelocity;
      else
          pos_xyz_mt(:,i)   = NaN(3,1);
          vel_xyz_mt(:,i)   = NaN(3,1);
      end
      
      if pvtCalculator.posiCheck == 1
          pos_xyz_checked_mt(:,i)   = pvtCalculator.positionXYZ;
          vel_xyz_checked_mt(:,i)   = pvtCalculator.positionVelocity;
      else
          pos_xyz_checked_mt(:,i)   = NaN(3,1);
          vel_xyz_checked_mt(:,i)   = NaN(3,1);
      end
    
      if ~isnan(pos_xyz_mt(1,i))
          ttd_enu_mt(:,i) = xyz2enu(pvtCalculator.positionXYZ, Refpos);
      else
          ttd_enu_mt(:,i) = NaN(3,1);
      end
      
      if ~isnan(pos_xyz_checked_mt(1,i))
        ttd_enu_checked_mt(:,i) = xyz2enu(pvtCalculator.positionXYZ, Refpos);
      else
          ttd_enu_checked_mt(:,i) = NaN(3,1);
      end
%     activChn_raim_bds = activeChannel_BDS;
%     activChn_raim_gps = activeChannel_GPS;
    
    % Start PVT solution
%     [pos_xyz, vel_xyz, cdtu, ...
%         az_actv_bds, az_actv_gps, el_actv_bds, el_actv_gps, iono_actv_bds, iono_actv_gps, trop_actv_bds, trop_actv_gps, ...
%         bEsti, psrCorr, DOP, rankBreak] = ...
%             leastSquarePos_JointBdsGps1(satpos_bds, satpos_gps, ...
%                                     obs_bds, obs_gps, ...
%                                     transmitTime_bds, transmitTime_gps, ...
%                                     ephemeris(1).para, ephemeris(2).para, ...
%                                     activChn_raim_bds, activChn_raim_gps, ...
%                                     satClkCorr_bds, satClkCorr_gps, ...
%                                     pvtCalculator, ...
%                                     pvtForecast_Succ, ...
%                                     el_bds, el_gps, ...
%                                     az_bds, az_gps, ...
%                                     iono_bds, iono_gps, ...
%                                     trop_bds, trop_gps);
%      pos_xyz_mt(:,i)   = pos_xyz;
%      rankBreak_vt(:,i) = rankBreak;
%      if rankBreak
%         ttd_enu_mt(:,i) = 0; 
%      else
%         ttd_enu_mt(:,i) = xyz2enu(pos_xyz, Refpos);
%      end
end

% epos = pos_xyz_mt - Refpos;
subplot(3,1,1); plot(ttd_enu_mt(1,:))
subplot(3,1,2); plot(ttd_enu_mt(2,:))
subplot(3,1,3); plot(ttd_enu_mt(3,:))















