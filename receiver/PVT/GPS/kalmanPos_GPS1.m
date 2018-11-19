function [bur, vel, cdtu_delta, az, el, iono, trop, bEsti, psrCorr, DOP, KalFilt] = ...
    kalmanPos_GPS1(satpos, satpos_ref,obs,obs_ref, transmitTime, activeChannel, satClkCorr,satClkCorr_ref, pvtCalculator, pvtCalculator_ref,pvtForecast_Succ, elfore, azfore, ionofore, tropfore, cn0,IMU_MEMS)
%Function calculates the Kalman Solution.
%
% In the Kalman PVT solution, the predict pvt is always deemed as
% trustable, so the forecast elfore, azfore, ionofore and tropfore are
% thought of trustable.
%本函数为了方便起见，nxtState_pos值得都是bur；

%------------ Initialization ----------------
% if pvtForecast_Succ ~= 1
%     error('Calling kalmanPos_GPS1() fail! pvtForecast_Succ is not equal to 1');
% end

nmbOfSatellites = size(activeChannel, 2);
% reorganize the obs, satpos, satclk into a compact vectors or matrices
satpos_ref_actv = zeros(3, nmbOfSatellites);
satvel_ref_actv = zeros(3, nmbOfSatellites);
satpos_rot_corr = zeros(3, nmbOfSatellites);  %storing the sat positions after earth rotation corrections
obs_actv = zeros(1, nmbOfSatellites);
obs_ref_actv = zeros(1, nmbOfSatellites);

transmitTime_actv = zeros(1, nmbOfSatellites);
satClkCorr_actv = zeros(2, nmbOfSatellites);
satClkCorr_ref_actv = zeros(2, nmbOfSatellites);
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
    satpos_ref_actv(:,n) = satpos_ref(1:3, activeChannel(2,n));
    satvel_ref_actv(:,n) = satpos_ref(4:6, activeChannel(2,n));
    
    obs_actv(n) = obs(activeChannel(2,n));
    obs_ref_actv(n)=obs_ref(activeChannel(2,n));
    
    transmitTime_actv(n) = transmitTime(activeChannel(2,n));
    satClkCorr_actv(:,n) = satClkCorr(:, activeChannel(2,n));
    satClkCorr_ref_actv(:,n) = satClkCorr_ref(:, activeChannel(2,n));
    
    cn0_actv(:, n) = cn0(1:2, activeChannel(2,n));
    el(n)   = elfore(activeChannel(2,n));
    az(n)   = azfore(activeChannel(2,n));
    iono(n) = ionofore(activeChannel(2,n));
    trop(n) = tropfore(activeChannel(2,n));
end
max_el = find(el == max(el));
%-------- 1st of 1st, compute the Kalman predict procedure --------
KalFilt = pvtCalculator.kalman;
bias=KalFilt.stt_dtf(:, 2);
% nxtState = KalFilt.PHI * KalFilt.state; % This stage is unneccessary. Did already in the pvt_forecast_filt() function.
% nxtState = KalFilt.state;
nxtState_pos = [KalFilt.stt_x(1), KalFilt.stt_y(1), KalFilt.stt_z(1)]';
nxtState_vel = [KalFilt.stt_x(2), KalFilt.stt_y(2), KalFilt.stt_z(2)]';
nxtState_acc= [KalFilt.stt_x(3), KalFilt.stt_y(3), KalFilt.stt_z(3)]';
nxtState_dtf = KalFilt.stt_dtf(:, 2); % vector 2x1, GPS clk error state


%----------- 1st, correct the satellite clock error ---------
obs_corrsatclk_actv = psr_satclk_corr(obs_actv, satClkCorr_actv(1,:));
obs_corrsatclk_ref_actv= psr_satclk_corr(obs_ref_actv, satClkCorr_ref_actv(1,:));
%----------- 2nd, correct the eartbur = nxtState_pos;h rotation effects ----------
pos_ref_xyz=  [ -2853445.926; 4667466.476; 3268291.272];
bur = nxtState_pos ;
nxtState_pos = nxtState_pos + pos_ref_xyz;   
[ Lat, Lon, Hight ] = cart2geo( nxtState_pos(1), nxtState_pos(2), nxtState_pos(3), 5 );


sat2usr_mtrx = satpos_ref_actv - repmat(pos_ref_xyz, 1, nmbOfSatellites);
rho_predict = sqrt(sum(sat2usr_mtrx.*sat2usr_mtrx, 1));
traveltime = rho_predict / 299792458;
for n=1:nmbOfSatellites
    satpos_rot_corr(:, n) = e_r_corr(traveltime(n), satpos_ref_actv(:, n));
end

sat2usr_mtrx = satpos_rot_corr - repmat(pos_ref_xyz, 1, nmbOfSatellites);
rho_predict = sqrt(sum(sat2usr_mtrx.*sat2usr_mtrx, 1)); % row vector [1 x nmbOfSatellites]

%---------- 3rd, correct the iono and trop errors --------------
% correct the prected local clk error caused by drift as well as iono &
% trop
obs_corr_actv =obs_actv - obs_ref_actv;
obs_corr_actv_DD =zeros(1,nmbOfSatellites);
for i= 1 : (nmbOfSatellites)
    if i ~=max_el
         obs_corr_actv_DD(i)=obs_corr_actv(i) - obs_corr_actv(max_el);
    end
end
obs_corr_actv_DD(max_el) = [] ;
% obs_corr_actv = obs_corrsatclk_actv - iono - trop - cdtu; % row vector [1 x nmbOfSatellites]    

%---------- 4th, compute the observation matrix -------------
for n=1:nmbOfSatellites
    H(n,:) = [-sat2usr_mtrx(:,n)'/rho_predict(n), 1];      %Ir 即这个H(n)
end
H_DD = zeros(nmbOfSatellites,4);
for i= 1 : (nmbOfSatellites)
    if i ~=max_el
        H_DD(i,:)=H(i,:) - H(max_el,:);
    end
end
H_DD(max_el,:) = [];
%---------- 4th, compute velocity observations -------------
gpsDoppSmooth = pvtCalculator.GPS.doppSmooth;
gpsDoppSmooth_ref = pvtCalculator_ref.GPS.doppSmooth;
deltaP = zeros(1, nmbOfSatellites);
deltaP_ref = zeros(1, nmbOfSatellites);
obs_vel = zeros(1, nmbOfSatellites);
C = 299792458;
% L1= 1575420000;
% wavelengthL1 = C/L1;

for n=1:nmbOfSatellites
    if gpsDoppSmooth(activeChannel(2,n),4) > 5e10
        deltaP(n) = (gpsDoppSmooth(activeChannel(2,n),1) - gpsDoppSmooth(activeChannel(2,n),2)) / pvtCalculator.pvtT; %积分多普勒一秒的变化量（m）由于前面用的dopper，所以此行无效
    else
%         deltaP(n) = -wavelengthL1*gpsDoppSmooth(activeChannel(2,n),3);
        deltaP(n) = gpsDoppSmooth(activeChannel(2,n),3);
    end
    
    if gpsDoppSmooth_ref (activeChannel(2,n),4) > 5e10
        deltaP_ref(n) = (gpsDoppSmooth_ref (activeChannel(2,n),1) - gpsDoppSmooth_ref(activeChannel(2,n),2)) / pvtCalculator.pvtT; %积分多普勒一秒的变化量（m）
    else
%         deltaP(n) = -wavelengthL1*gpsDoppSmooth(activeChannel(2,n),3);
        deltaP_ref(n) = gpsDoppSmooth_ref(activeChannel(2,n),3);
    end
    deltaP_DD(n) = deltaP(n)-deltaP_ref(n);
    sat_vel_DD(n)=H(n, 1:3)*(satvel_actv(:,n)-satvel_ref_actv(:,n));
%     obs_vel(n) = deltaP(n) - deltaP_ref(n) +H(n, 1:3)*(satvel_actv(:,n)-satvel_ref_actv(:,n));%本次根据定位方程得到的多普勒值（在单位矢量方向上的多普值单位m/s)
end
obs_vel_DD  =zeros(1,nmbOfSatellites);
for i= 1 : nmbOfSatellites
    if i ~=max_el
        obs_vel_DD(i)  = deltaP_DD(i)-deltaP_DD(max_el) +sat_vel_DD(i) -sat_vel_DD(max_el);
    end
end
obs_vel_DD(max_el)= [];
%---------- 5th, compute the predict velocity obs ----------
% stt_vel = [nxtState(4:6); nxtState(8)]; % row vector, [4x1]
% Here, the local clk drift has been corrected in the tracking loop
stt_vel = [nxtState_vel; nxtState_dtf(2)]; % row vector, [4x1]
rhodot_predict = H_DD * stt_vel; % column vector, [nmbOfSatellites x 1] %将运动速度转换为多普勒方向的速度

%---------- 6th, compute the error measurements -----------
Rur =  H_DD(:,1:3) *bur;
omc_rho = (obs_corr_actv_DD - Rur')';
omc_rhodot = obs_vel_DD' - rhodot_predict;

omc_acc = IMU_MEMS - bias - nxtState_acc;

drho = zeros(5*(nmbOfSatellites -1), 1); % [2*nmbOfSatellites x 1]
nxtstate_ = [KalFilt.stt_x;bias(1); KalFilt.stt_y;bias(2); KalFilt.stt_z;bias(3)]; % vector [8x1]
HK = zeros(5*(nmbOfSatellites -1), 12);
Rdiag = zeros(5*(nmbOfSatellites -1), 1);
R = zeros(2*nmbOfSatellites,1);
R_DD = zeros(5*(nmbOfSatellites-1),1);
for n=1:nmbOfSatellites 
%    R(2*n-1:2*n)   = (EKF_R_Compute_new1('GPS_L1CA', Lat, el(n), cn0_actv(:,n), KalFilt.Rv));
      R(2*n-1:2*n)   = (EKF_R_Compute(activeChannel,'GPS_L1CA',cn0_actv(:,n),KalFilt.Rv));
end

for n = 1:nmbOfSatellites
    if n~=max_el
         R_DD(5*n-4) = sqrt(R(2*n-1).^2 +R(2*max_el-1).^2);
                  R_DD(5*n-3) = sqrt(R(2*n).^2 +R(2*max_el).^2);
    end
    R_DD(n*5-2:n*5)=pvtCalculator.kalman.Ra;
    
%     R_DD(8*n-2) =0.01;%加速度bias
%     R_DD(8*n-1) = 0.01;
%     R_DD(8*n) = 0.01;
end
    R_DD((5*max_el-4):(5*max_el) ) = [];

for n=1:(nmbOfSatellites-1)
    drho(n*5-4) = omc_rho(n);
    drho(n*5-3) = omc_rhodot(n);
    drho(n*5-2:n*5)   =  omc_acc;
%     drho(n*8-2:n*8)   =  0;
    HK(n*5-4:n*5-1, :) = [H_DD(n,1)*eye(4), H_DD(n,2)*eye(4), H_DD(n,3)*eye(4)];    %
    HK(n*5-2, :) = [0,0,1,1,0,0,0,0,0,0,0,0];
        HK(n*5-1, :) = [0,0,0,0,0,0,1,1,0,0,0,0];
            HK(n*5, :) =[0,0,0,0,0,0,0,0,0,0,1,1];
%                 HK(n*8-2, :) = [0,0,0,1,0,0,0,0,0,0,0,0];
%                         HK(n*8-1, :) = [0,0,0,0,0,0,0,1,0,0,0,0];
%                                 HK(n*8, :) = [0,0,0,0,0,0,0,0,0,0,0,1];
%     HK(n, :) = [ H_DD(n,1:3) , zeros(1,6)];    
%         HK((nmbOfSatellites -1)+n, :) = [zeros(1,3), H_DD(n,1:3), zeros(1,3)];  
%                 HK(2*(nmbOfSatellites -1)+1:2*(nmbOfSatellites -1)+3, :) = [zeros(3,6), eye(3)];  

%    Rdiag(n*5-4:n*5-3) =(EKF_R_Compute_new1('GPS_L1CA', Lat, el(n), cn0_actv(:,n), KalFilt.Rv));
%    Rdiag(n*5-4:n*5-3) =(EKF_R_Compute(activeChannel,'GPS_L1CA',cn0_actv(:,n),KalFilt.Rv));
%    Rdiag(n*5-2) =0.001;
%     Rdiag(n*5-1) = 10000000;
%     Rdiag(n*5) =10000000;
end
Pk_ = KalFilt.P; % Pk_ already computed in the function pvt_forecast_filt().
R = diag(R_DD);

%------- 8th, performing the Kalman updating -------
Kgain = Pk_ * HK.' / (HK * Pk_ * HK.' + R);
dx = Kgain * drho;
KalFilt.P = (eye(12) - Kgain * HK) * Pk_;
KalFilt.P = (KalFilt.P + (KalFilt.P).')/2;    %滤波数值计算
newState = nxtstate_ + dx;

KalFilt.stt_x = newState(1:3);
KalFilt.stt_y = newState(5:7);
KalFilt.stt_z = newState(9:11);
KalFilt.stt_dtf(:, 2) = [newState(4);newState(8);newState(12)];
bias =KalFilt.stt_dtf(:, 2) ;
pos_xyz = [newState(1),newState(5),newState(9)]'; 
bur = pos_xyz;
% vel = [newState(2),newState(4),newState(6),newState(8)];
vel = [newState(2),newState(6),newState(10)]';
cdtu_delta =0;


% Pk_nth = KalFilt.P; % Pk_ already computed in the function pvt_forecast_filt().
% dx = 0;
% dv = 0;
% dc = 0;
% for n=1:nmbOfSatellites
%     drho = [omc_rho(n); omc_rhodot(n)];
%     H_nth = [H(n,1)*eye(2), H(n,2)*eye(2), H(n,3)*eye(2), H(n,4)*eye(2)];
%     
%     Rvec_nth = EKF_R_Compute_new1('GPS_L1CA', Lat, el(n), cn0_actv(:,n), KalFilt.Rv);
%     R_nth = diag(Rvec_nth);
%     
%     K_nth = Pk_nth * H_nth.' / (H_nth * Pk_nth * H_nth.' + R_nth);
%     dstt_nth = K_nth * drho;
%     Pk_nth = (eye(8) - K_nth * H_nth) * Pk_nth;
%     Pk_nth = (Pk_nth + Pk_nth.')/2;
%     
%     dx = dx + [dstt_nth(1), dstt_nth(3), dstt_nth(5)]';
%     dv = dv + [dstt_nth(2), dstt_nth(4), dstt_nth(6)]';
%     dc = dc + [dstt_nth(7), dstt_nth(8)]';
%     
% end
% 
% nxtState_pos = nxtState_pos + dx;
% nxtState_vel = nxtState_vel + dv;
% nxtState_dtf = nxtState_dtf + dc;
% 
% %------ update the new estimates into the Kalman structure -------
% KalFilt.stt_x = [nxtState_pos(1), nxtState_vel(1)]';
% KalFilt.stt_y = [nxtState_pos(2), nxtState_vel(2)]';
% KalFilt.stt_z = [nxtState_pos(3), nxtState_vel(3)]';
% KalFilt.stt_dtf(:, 2) = nxtState_dtf;
% KalFilt.P     = Pk_nth;
% 
% pos_xyz = nxtState_pos;
% % vel = [nxtState_vel; nxtState_dtf(2)];
% vel = [nxtState_vel; dc(2)];
% cdtu = nxtState_dtf(1);

%------ last, compute the pseudorange residual erros -------
sat2usr_mtrx = satpos_ref_actv - repmat(pos_xyz, 1, nmbOfSatellites);
rho_predict = sqrt(sum(sat2usr_mtrx.*sat2usr_mtrx, 1));
traveltime = rho_predict / 299792458;
for n=1:nmbOfSatellites
    satpos_rot_corr(:, n) = e_r_corr(traveltime(n), satpos_ref_actv(:, n));
end
sat2usr_mtrx = satpos_rot_corr - repmat(pos_xyz, 1, nmbOfSatellites);
rho_predict = sqrt(sum(sat2usr_mtrx.*sat2usr_mtrx, 1)); % row vector [1 x nmbOfSatellites]

for n=1:nmbOfSatellites
    H(n,:) = [-sat2usr_mtrx(:,n)'/rho_predict(n), 1];
end
bEsti = (eye(nmbOfSatellites-1) - H_DD(:,1:3)/(H_DD(:,1:3)'*H_DD(:,1:3))*H_DD(:,1:3)') * omc_rho;
psrCorr = obs_corrsatclk_actv - iono - trop - cdtu_delta;

%------- last, compute the pseudorange residual erros -------
% bEsti = (eye(nmbOfSatellites) - H/(H'*H)*H') * omc_rho;
% psrCorr = obs_corr_actv;
% pos_xyz = KalFilt.state(1:3);
% vel = [KalFilt.state(4:6); KalFilt.state(8)];
% vel(4) = vel(4)/wavelengthL1;
% cdtu = KalFilt.state(7);

%=== Calculate Dilution Of Precision ======================================
Q = inv(H' * H);
DOP(1)  = sqrt(trace(Q));                       % GDOP
DOP(2)  = sqrt(Q(1,1) + Q(2,2) + Q(3,3));       % PDOP
DOP(3)  = sqrt(Q(1,1) + Q(2,2));                % HDOP
DOP(4)  = sqrt(Q(3,3));                         % VDOP
DOP(5)  = sqrt(Q(4,4));                         % TDOP





















