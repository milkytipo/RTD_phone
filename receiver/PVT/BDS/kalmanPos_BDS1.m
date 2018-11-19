function [pos_xyz, vel, cdtu, az, el, iono, trop, bEsti, psrCorr, DOP, KalFilt] = ...
    kalmanPos_BDS1(satpos, obs, transmitTime, activeChannel, satClkCorr, pvtCalculator, pvtForecast_Succ, elfore, azfore, ionofore, tropfore, cn0)

%------------ Initialization ----------------
if pvtForecast_Succ ~= 1
    error('Calling kalmanPos_BDS1() fail! pvtForecast_Succ is not equal to 1');
end

nmbOfSatellites = size(activeChannel, 2);
% reorganize the obs, satpos, satclk into a compact vectors or matrices
satpos_actv = zeros(3, nmbOfSatellites);
satvel_actv = zeros(3, nmbOfSatellites);
satpos_rot_corr = zeros(3, nmbOfSatellites);  %storing the sat positions after earth rotation corrections
obs_actv = zeros(1, nmbOfSatellites);
transmitTime_actv = zeros(1, nmbOfSatellites);
satClkCorr_actv = zeros(2, nmbOfSatellites);
cn0_actv = zeros(2, nmbOfSatellites);
az = zeros(1, nmbOfSatellites);
el = zeros(1, nmbOfSatellites);
iono = zeros(1, nmbOfSatellites);
trop = zeros(1, nmbOfSatellites);
DOP = zeros(5,1);

H = zeros(nmbOfSatellites,4);

for n=1:nmbOfSatellites
    satpos_actv(:,n) = satpos(1:3, activeChannel(2,n));
    satvel_actv(:,n) = satpos(4:6, activeChannel(2,n));
    obs_actv(n) = obs(activeChannel(2,n));
    transmitTime_actv(n) = transmitTime(activeChannel(2,n));
    satClkCorr_actv(:,n) = satClkCorr(:, activeChannel(2,n));
    cn0_actv(:, n) = cn0(1:2, activeChannel(2,n));
    el(n)   = elfore(activeChannel(2,n));
    az(n)   = azfore(activeChannel(2,n));
    iono(n) = ionofore(activeChannel(2,n));
    trop(n) = tropfore(activeChannel(2,n));
end

%-------- 1st of 1st, compute the Kalman predict procedure --------
KalFilt = pvtCalculator.kalman;
% nxtState = KalFilt.PHI * KalFilt.state; % This stage is unneccessary. Did already in the pvt_forecast_filt() function.
% nxtState = KalFilt.state;
nxtState_pos = [KalFilt.stt_x(1), KalFilt.stt_y(1), KalFilt.stt_z(1)]';
nxtState_vel = [KalFilt.stt_x(2), KalFilt.stt_y(2), KalFilt.stt_z(2)]';
nxtState_dtf = KalFilt.stt_dtf(:, 1); % vector 2x1, BDS clk error state

%----------- 1st, correct the satellite clock error ---------
obs_corrsatclk_actv = psr_satclk_corr(obs_actv, satClkCorr_actv(1,:));

%----------- 2nd, correct the earth rotation effects ----------
pos_xyz = nxtState_pos;
[ Lat, Lon, Hight ] = cart2geo( pos_xyz(1), pos_xyz(2), pos_xyz(3), 5 );

sat2usr_mtrx = satpos_actv - repmat(pos_xyz, 1, nmbOfSatellites);
rho_predict = sqrt(sum(sat2usr_mtrx.*sat2usr_mtrx, 1));
traveltime = rho_predict / 299792458;
for n=1:nmbOfSatellites
    satpos_rot_corr(:, n) = e_r_corr(traveltime(n), satpos_actv(:, n));
end

sat2usr_mtrx = satpos_rot_corr - repmat(pos_xyz, 1, nmbOfSatellites);
rho_predict = sqrt(sum(sat2usr_mtrx.*sat2usr_mtrx, 1)); % row vector [1 x nmbOfSatellites]

%---------- 3rd, correct the iono and trop errors --------------
% correct the prected local clk error caused by drift as well as iono &
% trop
cdtu = nxtState_dtf(1);
obs_corr_actv = obs_corrsatclk_actv - iono - trop - cdtu; % row vector [1 x nmbOfSatellites]

%---------- 4.1th, compute the observation matrix -------------
for n=1:nmbOfSatellites
    H(n,:) = [-sat2usr_mtrx(:,n)'/rho_predict(n), 1];
end

%---------- 4.2th, compute velocity observations -------------
bdsDoppSmooth = pvtCalculator.BDS.doppSmooth;
deltaP = zeros(1, nmbOfSatellites);
obs_vel = zeros(1, nmbOfSatellites);
C = 299792458;

for n=1:nmbOfSatellites
    if bdsDoppSmooth(activeChannel(2,n),4) > 5e10
        deltaP(n) = (bdsDoppSmooth(activeChannel(2,n),1) - bdsDoppSmooth(activeChannel(2,n),2)) / pvtCalculator.pvtT; %积分多普勒一秒的变化量（m）
    else
        deltaP(n) = bdsDoppSmooth(activeChannel(2,n),3);
    end
    obs_vel(n) = deltaP(n) + H(n, 1:3)*satvel_actv(:,n) + C*satClkCorr_actv(2,n);
end

%---------- 5th, compute the predict velocity obs ----------
stt_vel = [nxtState_vel; nxtState_dtf(2)]; % row vector, [4x1]
rhodot_predict = H * stt_vel; % column vector, [nmbOfSatellites x 1]

%---------- 6th, compute the error measurements -----------
omc_rho = (obs_corr_actv - rho_predict)';
omc_rhodot = obs_vel' - rhodot_predict;

%------- 7th, construct the Kalman matrix -------
drho = zeros(2*nmbOfSatellites, 1); % [2*nmbOfSatellites x 1]
nxtstate_ = [KalFilt.stt_x; KalFilt.stt_y; KalFilt.stt_z; KalFilt.stt_dtf(:, 1)]; % vector [8x1]
HK = zeros(2*nmbOfSatellites, 8);
Rdiag = zeros(2*nmbOfSatellites, 1);
for n=1:nmbOfSatellites
    drho(n*2-1) = omc_rho(n);
    drho(n*2) = omc_rhodot(n);
    
    HK(n*2-1:n*2, :) = [H(n,1)*eye(2), H(n,2)*eye(2), H(n,3)*eye(2), H(n,4)*eye(2)];
    Rdiag(n*2-1:n*2) = EKF_R_Compute_new1('BDS_B1I', Lat, el(n), cn0_actv(:,n), KalFilt.Rv);
end
Pk_ = KalFilt.P; % Pk_ already computed in the function pvt_forecast_filt().
R = diag(Rdiag);

%------- 8th, performing the Kalman updating -------
Kgain = Pk_ * HK.' / (HK * Pk_ * HK.' + R);
dx = Kgain * drho;
KalFilt.P = (eye(8) - Kgain * HK) * Pk_;
KalFilt.P = (KalFilt.P + (KalFilt.P).')/2;
newState = nxtstate_ + dx;

KalFilt.stt_x = newState(1:2);
KalFilt.stt_y = newState(3:4);
KalFilt.stt_z = newState(5:6);
KalFilt.stt_dtf(:, 1) = newState(7:8);

pos_xyz = [newState(1),newState(3),newState(5)]';
vel = [newState(2),newState(4),newState(6),newState(8)]';
cdtu = newState(7);

%------ last, compute the pseudorange residual erros -------
sat2usr_mtrx = satpos_actv - repmat(pos_xyz, 1, nmbOfSatellites);
rho_predict = sqrt(sum(sat2usr_mtrx.*sat2usr_mtrx, 1));
traveltime = rho_predict / 299792458;
for n=1:nmbOfSatellites
    satpos_rot_corr(:, n) = e_r_corr(traveltime(n), satpos_actv(:, n));
end
sat2usr_mtrx = satpos_rot_corr - repmat(pos_xyz, 1, nmbOfSatellites);
rho_predict = sqrt(sum(sat2usr_mtrx.*sat2usr_mtrx, 1)); % row vector [1 x nmbOfSatellites]

for n=1:nmbOfSatellites
    H(n,:) = [-sat2usr_mtrx(:,n)'/rho_predict(n), 1];
end

bEsti = (eye(nmbOfSatellites) - H/(H'*H)*H') * omc_rho;
psrCorr = obs_corrsatclk_actv - iono - trop - cdtu;

%=== Calculate Dilution Of Precision ======================================
Q = inv(H' * H);
DOP(1)  = sqrt(trace(Q));                       % GDOP
DOP(2)  = sqrt(Q(1,1) + Q(2,2) + Q(3,3));       % PDOP
DOP(3)  = sqrt(Q(1,1) + Q(2,2));                % HDOP
DOP(4)  = sqrt(Q(3,3));                         % VDOP
DOP(5)  = sqrt(Q(4,4));                         % TDOP






