function [pos_xyz, vel, cdtu, az_bds, az_gps, el_bds, el_gps, iono_bds, iono_gps, trop_bds, trop_gps, bEsti, psrCorr, DOP, KalFilt] = ...
    kalmanPos_JointBdsGps1(satpos_bds, satpos_gps, obs_bds, obs_gps, transmitTime_bds, transmitTime_gps, ...
                                activeChannel_bds, activeChannel_gps, satClkCorr_bds, satClkCorr_gps, pvtCalculator, recv_timer, ...
                                pvtForecast_Succ, elfore_bds, elfore_gps, azfore_bds, azfore_gps, ionofore_bds, ionofore_gps, tropfore_bds, tropfore_gps, ...
                                cn0_bds, cn0_gps )
% Function calculates the Kalman Solution.
% recv_timer.rclkErr2Syst_UpCnt(1)=1;
% recv_timer.rclkErr2Syst_UpCnt(2)=3601;
% recv_timer.rclkErr2Syst_Thre = 3600;
if pvtForecast_Succ ~= 1
%     error('Calling kalmanPos_JointBdsGps1() fail! pvtForecast_Succ is not equal to 1');
end

%-------------- Initialization ----------------
%------- BDS -------
nmbOfSatellites_bds = size(activeChannel_bds, 2);
% re-organize the obs, satpos, satclk into a compact vectors or matrices
satpos_actv_bds = zeros(3, nmbOfSatellites_bds);
satvel_actv_bds = zeros(3, nmbOfSatellites_bds);
satpos_rot_corr_bds = zeros(3, nmbOfSatellites_bds);  %storing the sat positions after earth rotation corrections
obs_actv_bds = zeros(1, nmbOfSatellites_bds);
transmitTime_actv_bds = zeros(1, nmbOfSatellites_bds);
satClkCorr_actv_bds = zeros(2, nmbOfSatellites_bds);
az_bds   = zeros(1, nmbOfSatellites_bds);
el_bds   = zeros(1, nmbOfSatellites_bds);
iono_bds = zeros(1, nmbOfSatellites_bds);
trop_bds = zeros(1, nmbOfSatellites_bds);
cn0_actv_bds   = zeros(2, nmbOfSatellites_bds);

%------- GPS ---------
nmbOfSatellites_gps = size(activeChannel_gps, 2);
satpos_actv_gps = zeros(3, nmbOfSatellites_gps);
satvel_actv_gps = zeros(3, nmbOfSatellites_gps);
satpos_rot_corr_gps = zeros(3, nmbOfSatellites_gps);  %storing the sat positions after earth rotation corrections
obs_actv_gps = zeros(1, nmbOfSatellites_gps);
transmitTime_actv_gps = zeros(1, nmbOfSatellites_gps);
satClkCorr_actv_gps = zeros(2, nmbOfSatellites_gps);
az_gps   = zeros(1, nmbOfSatellites_gps);
el_gps   = zeros(1, nmbOfSatellites_gps);
iono_gps = zeros(1, nmbOfSatellites_gps);
trop_gps = zeros(1, nmbOfSatellites_gps);
cn0_actv_gps   = zeros(2, nmbOfSatellites_gps);

H_bds = zeros(nmbOfSatellites_bds,5);
H_gps = zeros(nmbOfSatellites_gps,5);

vel = zeros(5,1);
cdtu = zeros(2,1); % First element is clk error to BDS system; Second element is clk error to GPS system 
DOP = zeros(5,1);
psrCorr = zeros(1, nmbOfSatellites_bds+nmbOfSatellites_gps);
% rankBreak = 0;

% Sort-up BDS information
for n=1:nmbOfSatellites_bds
    satpos_actv_bds(:,n)     = satpos_bds(1:3, activeChannel_bds(2,n));
    satvel_actv_bds(:,n)     = satpos_bds(4:6, activeChannel_bds(2,n));
    obs_actv_bds(n)          = obs_bds(activeChannel_bds(2,n));
    transmitTime_actv_bds(n) = transmitTime_bds(activeChannel_bds(2,n));
    satClkCorr_actv_bds(:,n) = satClkCorr_bds(:, activeChannel_bds(2,n));
    el_bds(n)   = elfore_bds(activeChannel_bds(2,n));
    az_bds(n)   = azfore_bds(activeChannel_bds(2,n));
    iono_bds(n) = ionofore_bds(activeChannel_bds(2,n));
    trop_bds(n) = tropfore_bds(activeChannel_bds(2,n));
    cn0_actv_bds(:, n)       = cn0_bds(1:2, activeChannel_bds(2,n));
%     psrCorr(n) = obs_actv_bds(n) + c*satClkCorr_actv_bds(1,n) - ionofore_bds(activeChannel_bds(2,n)) - tropfore_bds(activeChannel_bds(2,n));
end

% Sort-up GPS information
for n=1:nmbOfSatellites_gps
    satpos_actv_gps(:,n) = satpos_gps(1:3, activeChannel_gps(2,n));
    satvel_actv_gps(:,n) = satpos_gps(4:6, activeChannel_gps(2,n));
    obs_actv_gps(n) = obs_gps(activeChannel_gps(2,n));
    transmitTime_actv_gps(n) = transmitTime_gps(activeChannel_gps(2,n));
    satClkCorr_actv_gps(:,n) = satClkCorr_gps(:, activeChannel_gps(2,n));
    el_gps(n)   = elfore_gps(activeChannel_gps(2,n));
    az_gps(n)   = azfore_gps(activeChannel_gps(2,n));
    iono_gps(n) = ionofore_gps(activeChannel_gps(2,n));
    trop_gps(n) = tropfore_gps(activeChannel_gps(2,n));
    cn0_actv_gps(:, n)       = cn0_gps(1:2, activeChannel_gps(2,n));
%     psrCorr(n+nmbOfSatellites_bds) = obs_actv_gps(n) + c*satClkCorr_actv_gps(1,n) - ionofore_gps(activeChannel_gps(2,n)) - tropfore_gps(activeChannel_gps(2,n));
end

%----------- 1.0st, compute the Kalman predict procedure ---------
KalFilt = pvtCalculator.kalman;
% nxtState = KalFilt.state;
nxtState_pos = [KalFilt.stt_x(1), KalFilt.stt_y(1), KalFilt.stt_z(1)]';
nxtState_vel = [KalFilt.stt_x(2), KalFilt.stt_y(2), KalFilt.stt_z(2)]';
nxtState_dtf_bds = KalFilt.stt_dtf(:, 1); % vector 2x1, BDS clk error state
nxtState_dtf_gps = KalFilt.stt_dtf(:, 2); % vector 2x1, BDS clk error state

%----------- 1.1st, correct the satellite clock error ---------
obs_corrsatclk_actv_bds = psr_satclk_corr(obs_actv_bds, satClkCorr_actv_bds(1,:));
obs_corrsatclk_actv_gps = psr_satclk_corr(obs_actv_gps, satClkCorr_actv_gps(1,:));

%----------- 2nd, correct the earth rotatoin effects ----------
pos_xyz = nxtState_pos;
[ Lat, Lon, Height ] = cart2geo( pos_xyz(1), pos_xyz(2), pos_xyz(3), 5 );

%----- 2.1, correct the BDS earth rotation correction -----
sat2usr_mtrx_bds = satpos_actv_bds - repmat(pos_xyz, 1, nmbOfSatellites_bds);
rho_predict_bds = sqrt(sum(sat2usr_mtrx_bds .* sat2usr_mtrx_bds, 1));
traveltime_bds = rho_predict_bds / 299792458;

for n=1:nmbOfSatellites_bds
    satpos_rot_corr_bds(:, n) = e_r_corr(traveltime_bds(n), satpos_actv_bds(:, n));
end
sat2usr_mtrx_bds = satpos_rot_corr_bds - repmat(pos_xyz, 1, nmbOfSatellites_bds);
rho_predict_bds = sqrt(sum(sat2usr_mtrx_bds .* sat2usr_mtrx_bds, 1));

%----- 2.2, correct the GPS earth rotation correction -----
sat2usr_mtrx_gps = satpos_actv_gps - repmat(pos_xyz, 1, nmbOfSatellites_gps);
rho_predict_gps = sqrt(sum(sat2usr_mtrx_gps .* sat2usr_mtrx_gps, 1));
traveltime_gps = rho_predict_gps / 299792458;

for n=1:nmbOfSatellites_gps
    satpos_rot_corr_gps(:, n) = e_r_corr(traveltime_gps(n), satpos_actv_gps(:, n));
end
sat2usr_mtrx_gps = satpos_rot_corr_gps - repmat(pos_xyz, 1, nmbOfSatellites_gps);
rho_predict_gps = sqrt(sum(sat2usr_mtrx_gps .* sat2usr_mtrx_gps, 1));

%------ 3rd, correct the iono and trop errors -------
cdtu(1) = nxtState_dtf_bds(1);
cdtu(2) = nxtState_dtf_gps(1);
obs_corr_actv_bds = obs_corrsatclk_actv_bds - iono_bds - trop_bds;
obs_corr_actv_gps = obs_corrsatclk_actv_gps - iono_gps - trop_gps;

%---------- 4th, compute the observation matrix -----------
for n=1:nmbOfSatellites_bds
    H_bds(n,:) = [-sat2usr_mtrx_bds(:,n)'/rho_predict_bds(n), 1, 0];
end

for n=1:nmbOfSatellites_gps
    H_gps(n,:) = [-sat2usr_mtrx_gps(:,n)'/rho_predict_gps(n), 0, 1];
end

%--------- 5th, estimate the rough initial local clkErr if necessary ------
% Check if clkErr to BDS has been corrected
if recv_timer.rclkErr2Syst_UpCnt(1) >= recv_timer.rclkErr2Syst_Thre
    % the estimated clkErr2BDS
    cdtu(1) = mean(obs_corr_actv_bds - rho_predict_bds);
end

% Check if clkErr to GPS has been corrected
if recv_timer.rclkErr2Syst_UpCnt(2) >= recv_timer.rclkErr2Syst_Thre
    % the estimated clkErr2GPS
    cdtu(2) = mean(obs_corr_actv_gps - rho_predict_gps);
end

%----- 6th, correct the predicted local clkErr -------
obs_corr_actv_bds = obs_corr_actv_bds - cdtu(1);
obs_corr_actv_gps = obs_corr_actv_gps - cdtu(2);

%------ 7th, compute velocity observations ---------
% BDS Doppler measurements
bdsDoppSmooth_bds = pvtCalculator.BDS.doppSmooth;
deltaP_bds = zeros(1, nmbOfSatellites_bds);
bVel_bds = zeros(1, nmbOfSatellites_bds);
C = 299792458;
% B1= 1561.098e6;
% wavelengthB1 = C/B1;

for n=1:nmbOfSatellites_bds
    if bdsDoppSmooth_bds(activeChannel_bds(2,n), 4) > 5e10
        deltaP_bds(n) = (bdsDoppSmooth_bds(activeChannel_bds(2,n), 1) - bdsDoppSmooth_bds(activeChannel_bds(2,n), 2)) / pvtCalculator.pvtT;
    else
%         deltaP_bds(n) = -wavelengthB1 * bdsDoppSmooth_bds(activeChannel_bds(2,n), 3);
        deltaP_bds(n) = bdsDoppSmooth_bds(activeChannel_bds(2,n), 3);
    end
%     deltaP(n) = -wavelengthB1 * bdsDoppSmooth(activeChannel(2,n), 3);%for debugging
    bVel_bds(n) = deltaP_bds(n) + H_bds(n, 1:3)*satvel_actv_bds(:,n) + C * satClkCorr_actv_bds(2,n);
end
% bVel_bds = bVel_bds';

% GPS Doppler measurements
gpsDoppSmooth_gps = pvtCalculator.GPS.doppSmooth;
deltaP_gps = zeros(1, nmbOfSatellites_gps);
bVel_gps = zeros(1, nmbOfSatellites_gps);
C = 299792458;
% L1= 1575420000;
% wavelengthL1 = C/L1;
for n=1:nmbOfSatellites_gps
    if gpsDoppSmooth_gps(activeChannel_gps(2,n),4) > 5e10
        deltaP_gps(n) = (gpsDoppSmooth_gps(activeChannel_gps(2,n),1) - gpsDoppSmooth_gps(activeChannel_gps(2,n),2)) / pvtCalculator.pvtT; %积分多普勒一秒的变化量（m）
    else
%         deltaP_gps(n) = -wavelengthL1 * gpsDoppSmooth_gps(activeChannel_gps(2,n),3);
        deltaP_gps(n) = gpsDoppSmooth_gps(activeChannel_gps(2,n),3);
    end
    bVel_gps(n) = deltaP_gps(n) + H_gps(n, 1:3)*satvel_actv_gps(:,n) + C * satClkCorr_actv_gps(2,n);
end
% bVel_gps = bVel_gps';

%-------- 8th, compute the predict velocity obs ---------
stt_vel = [nxtState_vel; nxtState_dtf_bds(2); nxtState_dtf_gps(2)];
rhodot_predict_bds = H_bds * stt_vel;
rhodot_predict_gps = H_gps * stt_vel;

%---------- 9th, compute the error measurements -----------
omc_rho_bds = (obs_corr_actv_bds - rho_predict_bds)';
omc_rhodot_bds = bVel_bds' - rhodot_predict_bds;

omc_rho_gps = (obs_corr_actv_gps - rho_predict_gps)';
omc_rhodot_gps = bVel_gps' - rhodot_predict_gps;

%--------- 10th, construct the Kalman matrix ----------
nmbOfSatellites = nmbOfSatellites_bds+nmbOfSatellites_gps;
drho = zeros(2*nmbOfSatellites, 1);
nxtstate_ = [KalFilt.stt_x; KalFilt.stt_y; KalFilt.stt_z; KalFilt.stt_dtf(:, 1); KalFilt.stt_dtf(:, 2)]; % vector [10x1]
HK = zeros(2*nmbOfSatellites, 10);
Rdiag = zeros(2*nmbOfSatellites, 1);

for n=1:nmbOfSatellites_bds
    drho(n*2 - 1) = omc_rho_bds(n);
    drho(n*2) = omc_rhodot_bds(n);
    
    HK(n*2-1 : n*2, 1:10) = [H_bds(n,1)*eye(2), H_bds(n,2)*eye(2), H_bds(n,3)*eye(2), H_bds(n,4)*eye(2), H_bds(n,5)*eye(2)];
    Rdiag(n*2-1 : n*2) = EKF_R_Compute_new1('BDS_B1I', Lat, el_bds(n), cn0_actv_bds(:,n), KalFilt.Rv);
end
for n=1:nmbOfSatellites_gps
    drho(n*2 - 1 + 2*nmbOfSatellites_bds) = omc_rho_gps(n);
    drho(n*2 + 2*nmbOfSatellites_bds) = omc_rhodot_gps(n);
    
    HK(n*2-1 + 2*nmbOfSatellites_bds : n*2 + 2*nmbOfSatellites_bds, 1:10) = [H_gps(n,1)*eye(2), H_gps(n,2)*eye(2), H_gps(n,3)*eye(2), H_gps(n,4)*eye(2), H_gps(n,5)*eye(2)];
    Rdiag(n*2-1 + 2*nmbOfSatellites_bds : n*2 + 2*nmbOfSatellites_bds) = EKF_R_Compute_new1('GPS_L1CA', Lat, el_gps(n), cn0_actv_gps(:,n), KalFilt.Rv);
end

Pk_ = KalFilt.P; % Pk_ already computed in the function pvt_forecast_filt().
R = diag(Rdiag);

%------- 11th, performing the Kalman updating -------
Kgain = Pk_ * HK.' / (HK * Pk_ * HK.' + R);
dx = Kgain * drho;
KalFilt.P = (eye(10) - Kgain * HK) * Pk_;
KalFilt.P = (KalFilt.P + (KalFilt.P).')/2;
newState = nxtstate_ + dx;

KalFilt.stt_x = newState(1:2);
KalFilt.stt_y = newState(3:4);
KalFilt.stt_z = newState(5:6);
KalFilt.stt_dtf(:, 1) = newState(7:8);
KalFilt.stt_dtf(:, 2) = newState(9:10);

pos_xyz = [newState(1),newState(3),newState(5)]';
vel = [newState(2),newState(4),newState(6),newState(8), newState(10)]';
cdtu = [newState(7), newState(9)]';

%------ last, compute the pseudorange residual erros -------
% compute the BDS the new H matrix and rho_predict
sat2usr_mtrx_bds = satpos_actv_bds - repmat(pos_xyz, 1, nmbOfSatellites_bds);
rho_predict_bds = sqrt(sum(sat2usr_mtrx_bds .* sat2usr_mtrx_bds, 1));
traveltime_bds = rho_predict_bds / 299792458;

for n=1:nmbOfSatellites_bds
    satpos_rot_corr_bds(:, n) = e_r_corr(traveltime_bds(n), satpos_actv_bds(:, n));
end
sat2usr_mtrx_bds = satpos_rot_corr_bds - repmat(pos_xyz, 1, nmbOfSatellites_bds);
rho_predict_bds = sqrt(sum(sat2usr_mtrx_bds .* sat2usr_mtrx_bds, 1));

for n=1:nmbOfSatellites_bds
    H_bds(n,:) = [-sat2usr_mtrx_bds(:,n)'/rho_predict_bds(n), 1, 0];
end

% compute the GPS the new H matrix and rho_predict
sat2usr_mtrx_gps = satpos_actv_gps - repmat(pos_xyz, 1, nmbOfSatellites_gps);
rho_predict_gps = sqrt(sum(sat2usr_mtrx_gps .* sat2usr_mtrx_gps, 1));
traveltime_gps = rho_predict_gps / 299792458;

for n=1:nmbOfSatellites_gps
    satpos_rot_corr_gps(:, n) = e_r_corr(traveltime_gps(n), satpos_actv_gps(:, n));
end
sat2usr_mtrx_gps = satpos_rot_corr_gps - repmat(pos_xyz, 1, nmbOfSatellites_gps);
rho_predict_gps = sqrt(sum(sat2usr_mtrx_gps .* sat2usr_mtrx_gps, 1));

for n=1:nmbOfSatellites_gps
    H_gps(n,:) = [-sat2usr_mtrx_gps(:,n)'/rho_predict_gps(n), 0, 1];
end

omc_rho = [omc_rho_bds; omc_rho_gps];
H = [H_bds; H_gps];
bEsti = (eye(nmbOfSatellites) - H/(H'*H)*H') * omc_rho;
psrCorr = [(obs_corrsatclk_actv_bds - cdtu(1)), (obs_corrsatclk_actv_gps - cdtu(2))] - [iono_bds, iono_gps] - [trop_bds, trop_gps];

%-------- Calculate Dilution Of Precision --------------
Q = inv(H' * H);
DOP(1)  = sqrt(trace(Q));                       % GDOP
DOP(2)  = sqrt(Q(1,1) + Q(2,2) + Q(3,3));       % PDOP
DOP(3)  = sqrt(Q(1,1) + Q(2,2));                % HDOP
DOP(4)  = sqrt(Q(3,3));                         % VDOP
DOP(5)  = sqrt(Q(4,4));                         % TDOP


