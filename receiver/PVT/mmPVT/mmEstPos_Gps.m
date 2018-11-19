function [pos_xyz, vel, cdtu, az, el, iono, trop, bRaim, psrCorr, DOP, rankBreak] = mmEstPos_Gps ...
                             (satpos, obs, transmitTime, ephemeris_para, activeChannel, satClkCorr, ...
                                  pvtCalculator, recv_timer, pvtForecast_Succ, elfore, azfore, ionofore, tropfore, CN0_gps)
                              
                              
% this fucntion computes the receiver position using only GPS satellites and it is a part of joint estimation process

% satpos              - matrix[6x32], each column for a sat [x;y;z;vx;vy;vz]
% obs                 - vector[1x32], each for a sat pseudorange [meter]
% transmitTime        - vector[1x32], each for a sat transmit time [sec]
% satClkCorr          - matrix[2x32], each colum for a sat [clk_dt; clk_df]
% config              - receiver config struct
% channels            - receiver channel list, [nx1:channel]
% activeChannel_GPS   - matrix[2xNum], row1 for channel ID list; row2 for
%                       prn list; Num for number of active channels
% satelliteTable      - 
% ephemeris_para      - ephemeris.para struct for GPS, [1x32 struct]
% recv_timer          - receiver local timer
% pvtCalculator       - PVT struct
% pvtForecast_Succ    - forcast PVT solution is avaible: 1 - valid; 0 - invalid

% ======= initialization =========================================
% elevationMask = config.recvConfig.elevationMask;
nmbOfSatellites = size(activeChannel, 2);
c = 2.99792458e8;
nmbOfIterations = 11;
% ionosphere and troposphere model initialization
alpha_default = [2.186179e-008, -9.73869e-008, 7.03774e-008, 3.031505e-008]';
beta_default = [ 129643.8, -64245.75, -866336.2, 1612913]';
Alpha_actv = zeros(4, nmbOfSatellites);
Beta_actv  = zeros(4, nmbOfSatellites);
bEsti = zeros(1,nmbOfSatellites);
% reorganize the obs, satpos, satclk into a compact vectors or matrices
satpos_actv = zeros(3, nmbOfSatellites);
satvel_actv = zeros(3, nmbOfSatellites);
satpos_rot_corr = zeros(3, nmbOfSatellites);  %storing the sat positions after earth rotation corrections
obs_actv = zeros(1, nmbOfSatellites);
transmitTime_actv = zeros(1, nmbOfSatellites);
satClkCorr_actv = zeros(2, nmbOfSatellites);
% output ini
DOP = zeros(5,1);
vel = zeros(4,1);
pos_xyz = [];
cdtu = 0;
az = zeros(1, nmbOfSatellites);
el = zeros(1, nmbOfSatellites);
iono = zeros(1, nmbOfSatellites);
trop = zeros(1, nmbOfSatellites);
psrCorr = zeros(1, nmbOfSatellites);
rankBreak = 0;

H = zeros(nmbOfSatellites,4);

for n=1:nmbOfSatellites
    satpos_actv(:,n) = satpos(1:3, activeChannel(2,n));
    satvel_actv(:,n) = satpos(4:6, activeChannel(2,n));
    obs_actv(n) = obs(activeChannel(2,n));
    transmitTime_actv(n) = transmitTime(activeChannel(2,n));
    satClkCorr_actv(:,n) = satClkCorr(:, activeChannel(2,n));
    psrCorr(n) = obs_actv(n) + c*satClkCorr_actv(1,n) - ionofore(activeChannel(2,n)) - tropfore(activeChannel(2,n));
   
end

%----------- 1st, correct the satellite clock error ---------
obs_corr_actv = psr_satclk_corr(obs_actv, satClkCorr_actv(1,:));

%----------- 2nd, get elv and axi for each satellite -------------
if pvtForecast_Succ
    pos_xyz = pvtCalculator.posForecast;
    for n=1:nmbOfSatellites
        el(n)   = elfore(activeChannel(2,n));
        az(n)   = azfore(activeChannel(2,n));
        iono(n) = ionofore(activeChannel(2,n));
        trop(n) = tropfore(activeChannel(2,n));
    end
    %------- =============================================================
    % this code is left for future use if a prior PVT estimation is
    % required in some cases. However in current implementation this part
    % is not considered. In this case ionospeheric corrections will be
    % applied after few iterations
else
%     for n=1:nmbOfSatellites
%         [az(n), el(n), ~] = topocent(pos_xyz, sat2usr_mtrx(:, n));
%         iono(n) = Ionospheric_GPS(pos_llh(1), pos_llh(2), el(n), az(n), Alpha_actv(:,n)', Beta_actv(:,n)', transmitTime_actv(n));
%         trop(n) = Tropospheric(T_amb,P_amb,P_vap,el(n));
%     end
%==========================================================================
    pos_xyz = zeros(3,1);
end

%-----3th, get the iono and trop parameters -----
T_amb = 20;%20
P_amb = 101.325; %KPa
P_vap = .849179;%.86; 0.61078*(H/100)*exp(T/(T+238.3)*17.2694) KPa
for n=1:nmbOfSatellites
    if ephemeris_para(activeChannel(2, n)).eph.Alpha0 == 'N'
        Alpha_actv(:,n) = alpha_default;
        Beta_actv(:,n)  = beta_default;
    else
        Alpha_actv(:,n) = [ephemeris_para(activeChannel(2, n)).eph.Alpha0;
            ephemeris_para(activeChannel(2, n)).eph.Alpha1;
            ephemeris_para(activeChannel(2, n)).eph.Alpha2;
            ephemeris_para(activeChannel(2, n)).eph.Alpha3];
        Beta_actv(:,n)  = [ephemeris_para(activeChannel(2, n)).eph.Beta0;
            ephemeris_para(activeChannel(2, n)).eph.Beta1;
            ephemeris_para(activeChannel(2, n)).eph.Beta2;
            ephemeris_para(activeChannel(2, n)).eph.Beta3;];
    end   
end

% --- 4, iterativly compute receiver position
for iter = 1:nmbOfIterations
   sat2usr_mtrx = satpos_actv - repmat(pos_xyz, 1, nmbOfSatellites);
   rho_predict = sqrt(sum(sat2usr_mtrx.*sat2usr_mtrx, 1));
   
   traveltime = rho_predict / 299792458;
   for n=1:nmbOfSatellites
       satpos_rot_corr(:, n) = e_r_corr(traveltime(n), satpos_actv(:, n));
   end
   
   sat2usr_mtrx = satpos_rot_corr - repmat(pos_xyz, 1, nmbOfSatellites);
   rho_predict = sqrt(sum(sat2usr_mtrx.*sat2usr_mtrx, 1));
   
   for n=1:nmbOfSatellites
       H(n,:) = [-sat2usr_mtrx(:,n)'/rho_predict(n), 1];
   end
   
   omc = (obs_corr_actv - rho_predict - cdtu - iono - trop)';
   bRaim.omc = omc;
   if rank(H) ~= 4
        pos_xyz = zeros(3,1);
        cdtu = 0;
        bRaim.bEsti = psrCorr'-median(psrCorr);
        rankBreak = 1;
        return;
   end
   
   % predict receiver position based on MM and S estimators
   
   % 1, ---- define the maximum size of subset
   % at this point, hard and fast rule is applied with some assumptions
   if length(omc)>=7   % number of actv satellites
       nOutlier = length(omc)-2;  % number of errorous observations
   else
       nOutlier = 5;   % minimum number of required satellites
   end
   
%    xx = H\omc;
%     cdtu = xx(4);
%     pos_xyz = pos_xyz + xx(1:3);
   dp = rsv_Sreg_03(omc,H(:,1:3),nOutlier);
   pos_xyz = pos_xyz + dp.beta(2:end);
   
   if (abs(dp.beta(1))>1e7) || (abs(dp.beta(3))>1e7) || (abs(dp.beta(2))>1e7) || ...
           sum(abs(dp.beta))<0.01 || sum(abs(dp.beta))<=0
       break;
   end
%    if sum(xx) <0.01
%        break
%    end
   % iono and tropo corrections
   if ~pvtForecast_Succ && (iter==5)
        [ Lat, Lon, Hight ] = cart2geo( pos_xyz(1), pos_xyz(2), pos_xyz(3), 5 );
        pos_llh = [ Lat, Lon, Hight ];
       for n=1:nmbOfSatellites
           [az(n), el(n), dist] = topocent(pos_xyz, sat2usr_mtrx(:, n));
           iono(n) = Ionospheric_GPS(pos_llh(1), pos_llh(2), el(n), az(n), Alpha_actv(:,n)', Beta_actv(:,n)', transmitTime_actv(n));
           trop(n) = Tropospheric(T_amb, P_amb, P_vap, el(n));
       end
   end
    
end
bRaim.bEsti = omc - H/(H'*H)*H'*omc;
bRaim.mmWghts = dp.weights;
xx = H\omc;
cdtu = xx(4);
psrCorr = [(obs_corr_actv-cdtu(1))] - [iono] - [trop];
%--------- compute the velocity -----------
gpsDoppSmooth = pvtCalculator.GPS.doppSmooth;
deltaP = zeros(1, nmbOfSatellites);
bVel = zeros(1, nmbOfSatellites);
C = 299792458;
L1= 1575420000;
wavelengthL1 = C/L1;

for n=1:nmbOfSatellites
    if gpsDoppSmooth(activeChannel(2,n),4) > 5
        deltaP(n) = (gpsDoppSmooth(activeChannel(2,n),1) - gpsDoppSmooth(activeChannel(2,n),2)) / pvtCalculator.pvtT; %积分多普勒一秒的变化量（m）
    else
        deltaP(n) = -wavelengthL1*gpsDoppSmooth(activeChannel(2,n),3);
    end
    bVel(n) = deltaP(n) + H(n, 1:3)*satvel_actv(:,n) + C*satClkCorr_actv(2,n);
end
bVel = bVel';
vel = H \ bVel;
vel(4) = vel(4)/wavelengthL1;

%=== Calculate Dilution Of Precision ======================================
Q = inv(H' * H);
DOP(1)  = sqrt(trace(Q));                       % GDOP
DOP(2)  = sqrt(Q(1,1) + Q(2,2) + Q(3,3));       % PDOP
DOP(3)  = sqrt(Q(1,1) + Q(2,2));                % HDOP
DOP(4)  = sqrt(Q(3,3));                         % VDOP
DOP(5)  = sqrt(Q(4,4));                         % TDOP

