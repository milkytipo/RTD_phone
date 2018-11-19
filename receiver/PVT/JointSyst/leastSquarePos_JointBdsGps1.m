function [pos_xyz, vel, cdtu, az_bds, az_gps, el_bds, el_gps, iono_bds, iono_gps, trop_bds, trop_gps, bEsti, psrCorr, DOP,rankBreak] = ...
    leastSquarePos_JointBdsGps1(satpos_bds, satpos_gps, obs_bds, obs_gps, transmitTime_bds, transmitTime_gps, ephemeris_para_bds, ephemeris_para_gps, ...
                                activeChannel_bds, activeChannel_gps, satClkCorr_bds, satClkCorr_gps, pvtCalculator, recv_timer, ...
                                pvtForecast_Succ, elfore_bds, elfore_gps, azfore_bds, azfore_gps, ionofore_bds, ionofore_gps, tropfore_bds, tropfore_gps, ...
                                cn0_bds, cn0_gps )
%Function calculates the Least Square Solution.
% recv_timer.rclkErr2Syst_UpCnt(1)=1;
% recv_timer.rclkErr2Syst_UpCnt(2)=3601;
% recv_timer.rclkErr2Syst_Thre = 3600;
%--------------------------------------------------------------------------
nmbOfIterations = 11;
c = 299792458; 
Tc_B1 = 1/2.046e6;
Tc_L1 = 1/1.023e6;
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
Alpha_actv_bds = zeros(4, nmbOfSatellites_bds);
Beta_actv_bds  = zeros(4, nmbOfSatellites_bds);
cn0_actv_bds   = zeros(2, nmbOfSatellites_bds);

%------- GPS ---------
nmbOfSatellites_gps = size(activeChannel_gps, 2);
satpos_actv_gps = zeros(3, nmbOfSatellites_gps);
satvel_actv_gps = zeros(3, nmbOfSatellites_gps);
satpos_rot_corr_gps = zeros(3, nmbOfSatellites_gps);  %storing the sat positions after earth rotation corrections
obs_actv_gps = zeros(1, nmbOfSatellites_gps);
transmitTime_actv_gps = zeros(1, nmbOfSatellites_gps);
satClkCorr_actv_gps = zeros(2, nmbOfSatellites_gps);
Alpha_actv_gps = zeros(4, nmbOfSatellites_gps);
Beta_actv_gps  = zeros(4, nmbOfSatellites_gps);
cn0_actv_gps   = zeros(2, nmbOfSatellites_gps);
% gps ionosphere and troposphere model default
alpha_default_gps = [2.186179e-008, -9.73869e-008, 7.03774e-008, 3.031505e-008]';
beta_default_gps  = [ 129643.8, -64245.75, -866336.2, 1612913]';


T_amb = 20;%20
P_amb = 101.325; %KPa
P_vap = .849179;%.86; 0.61078*(H/100)*exp(T/(T+238.3)*17.2694) KPa


H_bds = zeros(nmbOfSatellites_bds,5);
H_gps = zeros(nmbOfSatellites_gps,5);

az_bds   = zeros(1, nmbOfSatellites_bds);
el_bds   = zeros(1, nmbOfSatellites_bds);
iono_bds = zeros(1, nmbOfSatellites_bds);
trop_bds = zeros(1, nmbOfSatellites_bds);
az_gps   = zeros(1, nmbOfSatellites_gps);
el_gps   = zeros(1, nmbOfSatellites_gps);
iono_gps = zeros(1, nmbOfSatellites_gps);
trop_gps = zeros(1, nmbOfSatellites_gps);
pos_xyz = [];
vel = zeros(5,1);
cdtu = zeros(2,1); % First element is clk error to BDS system; Second element is clk error to GPS system 
DOP = zeros(5,1);
psrCorr = zeros(1, nmbOfSatellites_bds+nmbOfSatellites_gps);
rankBreak = 0;

% Sort-up BDS information
for n=1:nmbOfSatellites_bds
    satpos_actv_bds(:,n)     = satpos_bds(1:3, activeChannel_bds(2,n));
    satvel_actv_bds(:,n)     = satpos_bds(4:6, activeChannel_bds(2,n));
    obs_actv_bds(n)          = obs_bds(activeChannel_bds(2,n));
    transmitTime_actv_bds(n) = transmitTime_bds(activeChannel_bds(2,n));
    satClkCorr_actv_bds(:,n) = satClkCorr_bds(:, activeChannel_bds(2,n));
    Alpha_actv_bds(:, n)     = [ephemeris_para_bds(activeChannel_bds(2, n)).eph.Alpha0;
                            ephemeris_para_bds(activeChannel_bds(2, n)).eph.Alpha1;
                            ephemeris_para_bds(activeChannel_bds(2, n)).eph.Alpha2;
                            ephemeris_para_bds(activeChannel_bds(2, n)).eph.Alpha3];
    Beta_actv_bds(:,n)       = [ephemeris_para_bds(activeChannel_bds(2, n)).eph.Beta0;
                            ephemeris_para_bds(activeChannel_bds(2, n)).eph.Beta1;
                            ephemeris_para_bds(activeChannel_bds(2, n)).eph.Beta2;
                            ephemeris_para_bds(activeChannel_bds(2, n)).eph.Beta3;];
    cn0_actv_bds(:, n)       = cn0_bds(1:2, activeChannel_bds(2,n));
    psrCorr(n) = obs_actv_bds(n) + c*satClkCorr_actv_bds(1,n) - ionofore_bds(activeChannel_bds(2,n)) - tropfore_bds(activeChannel_bds(2,n));
end

% Sort-up GPS information
for n=1:nmbOfSatellites_gps
    satpos_actv_gps(:,n) = satpos_gps(1:3, activeChannel_gps(2,n));
    satvel_actv_gps(:,n) = satpos_gps(4:6, activeChannel_gps(2,n));
    obs_actv_gps(n) = obs_gps(activeChannel_gps(2,n));
    transmitTime_actv_gps(n) = transmitTime_gps(activeChannel_gps(2,n));
    satClkCorr_actv_gps(:,n) = satClkCorr_gps(:, activeChannel_gps(2,n));
    
    if ephemeris_para_gps(activeChannel_gps(2, n)).eph.Alpha0 == 'N'
        Alpha_actv_gps(:,n) = alpha_default_gps;
        Beta_actv_gps(:,n)  = beta_default_gps;
    else
        Alpha_actv_gps(:,n) = [ephemeris_para_gps(activeChannel_gps(2, n)).eph.Alpha0;
            ephemeris_para_gps(activeChannel_gps(2, n)).eph.Alpha1;
            ephemeris_para_gps(activeChannel_gps(2, n)).eph.Alpha2;
            ephemeris_para_gps(activeChannel_gps(2, n)).eph.Alpha3];
        Beta_actv_gps(:,n)  = [ephemeris_para_gps(activeChannel_gps(2, n)).eph.Beta0;
            ephemeris_para_gps(activeChannel_gps(2, n)).eph.Beta1;
            ephemeris_para_gps(activeChannel_gps(2, n)).eph.Beta2;
            ephemeris_para_gps(activeChannel_gps(2, n)).eph.Beta3;];
    end
    cn0_actv_gps(:, n)       = cn0_gps(1:2, activeChannel_gps(2,n));
    psrCorr(n+nmbOfSatellites_bds) = obs_actv_gps(n) + c*satClkCorr_actv_gps(1,n) - ionofore_gps(activeChannel_gps(2,n)) - tropfore_gps(activeChannel_gps(2,n));
end

%----------- 1st, correct the satellite clock error ---------
obs_corr_actv_bds = psr_satclk_corr(obs_actv_bds, satClkCorr_actv_bds(1,:));
obs_corr_actv_gps = psr_satclk_corr(obs_actv_gps, satClkCorr_actv_gps(1,:));

%----------- 2nd, get the a-prior user position -------------
if pvtForecast_Succ
    pos_xyz = pvtCalculator.posForecast;
    cdtu = pvtCalculator.clkErrForecast(1:2);
end

% For the first time PVT calculation, the user position is unknown, so we
% perform two more initial pre-iterations.
if isempty(pos_xyz)
    pos_xyz = zeros(3,1);
    %------- 3rd, perform a few iters solution solving without atmosphere
    % correct under the condition that there is a-prior PVT solution ------
    for iter_pre = 1:11
        %---------- Compute the BDS observation info -------------
        sat2usr_mtrx_bds = satpos_actv_bds - repmat(pos_xyz, 1, nmbOfSatellites_bds);
        rho_predict_bds = sqrt(sum(sat2usr_mtrx_bds .* sat2usr_mtrx_bds, 1));
        
        traveltime_bds = rho_predict_bds / 299792458;
        
        %------- 3.1rd, correct earth rotation correction ----------
        for n=1:nmbOfSatellites_bds
            satpos_rot_corr_bds(:, n) = e_r_corr(traveltime_bds(n), satpos_actv_bds(:, n));
        end
        
        sat2usr_mtrx_bds = satpos_rot_corr_bds - repmat(pos_xyz, 1, nmbOfSatellites_bds);
        rho_predict_bds = sqrt(sum(sat2usr_mtrx_bds .* sat2usr_mtrx_bds, 1));
        
        for n=1:nmbOfSatellites_bds
            H_bds(n,:) = [-sat2usr_mtrx_bds(:,n)'/rho_predict_bds(n), 1, 0];
        end
        omc_bds = (obs_corr_actv_bds - rho_predict_bds - cdtu(1))';
        
        %---------- Compute the GPS observation info -----------
        sat2usr_mtrx_gps = satpos_actv_gps - repmat(pos_xyz, 1, nmbOfSatellites_gps);
        rho_predict_gps = sqrt(sum(sat2usr_mtrx_gps .* sat2usr_mtrx_gps, 1));
    
        traveltime_gps = rho_predict_gps / 299792458;
    
        %------- 3.1rd, correct earth rotation correction ----------
        for n=1:nmbOfSatellites_gps
            satpos_rot_corr_gps(:, n) = e_r_corr(traveltime_gps(n), satpos_actv_gps(:, n));
        end
    
        sat2usr_mtrx_gps = satpos_rot_corr_gps - repmat(pos_xyz, 1, nmbOfSatellites_gps);
        rho_predict_gps = sqrt(sum(sat2usr_mtrx_gps .* sat2usr_mtrx_gps, 1));
    
        for n=1:nmbOfSatellites_gps
            H_gps(n,:) = [-sat2usr_mtrx_gps(:,n)'/rho_predict_gps(n), 0, 1];
        end
        omc_gps = (obs_corr_actv_gps - rho_predict_gps - cdtu(2))';
        
        % Combine the observation matrix and measurement error vector of
        % separate BDS and GPS into one
        H = [H_bds; H_gps];
        omc = [omc_bds; omc_gps];
        if rank(H) ~= 5
            bEsti = [psrCorr(1:nmbOfSatellites_bds)'-median(psrCorr(1:nmbOfSatellites_bds));...
                psrCorr(nmbOfSatellites_bds+1:nmbOfSatellites_bds+nmbOfSatellites_gps)'-median(psrCorr(nmbOfSatellites_bds+1:nmbOfSatellites_bds+nmbOfSatellites_gps))];
            rankBreak = 1;
            return;
        end   
        dp = H \ omc;
        pos_xyz = pos_xyz + dp(1:3);
        cdtu = cdtu + dp(4:5);
        
        if sum(abs(dp))<0.01
            break;
        end
    end %EOF "for iter_pre = 1:11"
end
% The approximate user position is known, the user LLH coordinates
% ------ find the longtitude and latitude of position CGCS2000 -------
[ Lat, Lon, Hight ] = cart2geo( pos_xyz(1), pos_xyz(2), pos_xyz(3), 5 );
pos_llh = [Lat; Lon; Hight];
    
%---- 5th, compute the elv and azi of each satellite -----
if pvtForecast_Succ
    for n=1:nmbOfSatellites_bds % for bds' el, az, iono, trop
        el_bds(n)   = elfore_bds(activeChannel_bds(2,n));
        az_bds(n)   = azfore_bds(activeChannel_bds(2,n));
        iono_bds(n) = ionofore_bds(activeChannel_bds(2,n));
        trop_bds(n) = tropfore_bds(activeChannel_bds(2,n));
    end
    for n=1:nmbOfSatellites_gps % for gps' el, az, iono, trop
        el_gps(n)   = elfore_gps(activeChannel_gps(2,n));
        az_gps(n)   = azfore_gps(activeChannel_gps(2,n));
        iono_gps(n) = ionofore_gps(activeChannel_gps(2,n));
        trop_gps(n) = tropfore_gps(activeChannel_gps(2,n));
    end
    
    % Check if clkErr to BDS has been corrected
    if recv_timer.rclkErr2Syst_UpCnt(1) >= recv_timer.rclkErr2Syst_Thre
        %---------- 5.1 Compute the BDS observation info -------------
        sat2usr_mtrx_bds = satpos_actv_bds - repmat(pos_xyz, 1, nmbOfSatellites_bds);
        rho_predict_bds = sqrt(sum(sat2usr_mtrx_bds .* sat2usr_mtrx_bds, 1));
        
        traveltime_bds = rho_predict_bds / 299792458;
        
        %------- 5.1rd, correct earth rotation correction ----------
        for n=1:nmbOfSatellites_bds
            satpos_rot_corr_bds(:, n) = e_r_corr(traveltime_bds(n), satpos_actv_bds(:, n));
        end
        
        sat2usr_mtrx_bds = satpos_rot_corr_bds - repmat(pos_xyz, 1, nmbOfSatellites_bds);
        rho_predict_bds = sqrt(sum(sat2usr_mtrx_bds .* sat2usr_mtrx_bds, 1));
        
        % the estimated clkErr2BDS
        cdtu(1) = mean(obs_corr_actv_bds - rho_predict_bds - iono_bds - trop_bds);
    end
    
    % Check if clkErr to GPS has been corrected
    if recv_timer.rclkErr2Syst_UpCnt(2) >= recv_timer.rclkErr2Syst_Thre
        %---------- 5.2 Compute the GPS observation info -----------
        sat2usr_mtrx_gps = satpos_actv_gps - repmat(pos_xyz, 1, nmbOfSatellites_gps);
        rho_predict_gps = sqrt(sum(sat2usr_mtrx_gps .* sat2usr_mtrx_gps, 1));
    
        traveltime_gps = rho_predict_gps / 299792458;
    
        %------- 5.2rd, correct earth rotation correction ----------
        for n=1:nmbOfSatellites_gps
            satpos_rot_corr_gps(:, n) = e_r_corr(traveltime_gps(n), satpos_actv_gps(:, n));
        end
    
        sat2usr_mtrx_gps = satpos_rot_corr_gps - repmat(pos_xyz, 1, nmbOfSatellites_gps);
        rho_predict_gps = sqrt(sum(sat2usr_mtrx_gps .* sat2usr_mtrx_gps, 1));
        
        % the estimated clkErr2GPS
        cdtu(2) = mean(obs_corr_actv_gps - rho_predict_gps - iono_gps - trop_gps);
    end
else
    for n=1:nmbOfSatellites_bds
        [az_bds(n), el_bds(n), dist] = topocent(pos_xyz, sat2usr_mtrx_bds(:, n));
        iono_bds(n) = Ionospheric_BD(pos_llh(1), pos_llh(2), el_bds(n), az_bds(n), Alpha_actv_bds(:,n), Beta_actv_bds(:,n), transmitTime_actv_bds(n), satpos_rot_corr_bds(:, n));
        trop_bds(n) = Tropospheric(T_amb, P_amb, P_vap, el_bds(n));
    end
    for n=1:nmbOfSatellites_gps
        [az_gps(n), el_gps(n), dist] = topocent(pos_xyz, sat2usr_mtrx_gps(:, n));
        iono_gps(n) = Ionospheric_GPS(pos_llh(1), pos_llh(2), el_gps(n), az_gps(n), Alpha_actv_gps(:,n)', Beta_actv_gps(:,n)', transmitTime_actv_gps(n));
        trop_gps(n) = Tropospheric(T_amb, P_amb, P_vap, el_gps(n));
    end
end

%--------- pre-7.1, compute the weighting factors -------
w_bds = wightMtr_gen(Lat, el_bds, cn0_actv_bds, c*Tc_B1);
W_bds = diag(1./sqrt(w_bds));

w_gps = wightMtr_gen(Lat, el_gps, cn0_actv_gps, c*Tc_L1);
W_gps = diag(1./sqrt(w_gps));

%---- 7th, Iteratively find receiver position with error corrections -----
for iter = 1:nmbOfIterations
    %---------- Compute the BDS observation matrix and error vector -------------
    sat2usr_mtrx_bds = satpos_actv_bds - repmat(pos_xyz, 1, nmbOfSatellites_bds);
    rho_predict_bds = sqrt(sum(sat2usr_mtrx_bds .* sat2usr_mtrx_bds, 1));
    
    traveltime_bds = rho_predict_bds / 299792458;
    for n=1:nmbOfSatellites_bds
        satpos_rot_corr_bds(:, n) = e_r_corr(traveltime_bds(n), satpos_actv_bds(:, n));
    end
    
    sat2usr_mtrx_bds = satpos_rot_corr_bds - repmat(pos_xyz, 1, nmbOfSatellites_bds);
    rho_predict_bds = sqrt(sum(sat2usr_mtrx_bds .* sat2usr_mtrx_bds, 1));
    
    for n=1:nmbOfSatellites_bds
        H_bds(n,:) = [-sat2usr_mtrx_bds(:,n)' / rho_predict_bds(n), 1, 0];
    end
    wH_bds = H_bds;
    wH_bds(1:nmbOfSatellites_bds,1:3) = W_bds * wH_bds(1:nmbOfSatellites_bds,1:3);
    
    omc_bds = (obs_corr_actv_bds - rho_predict_bds - cdtu(1) - iono_bds - trop_bds)';
    womc_bds = W_bds * omc_bds;
    
    %---------- Compute the GPS observation matrix and error vector -------------
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
    wH_gps = H_gps;
    wH_gps(1:nmbOfSatellites_gps, 1:3) = W_gps * wH_gps(1:nmbOfSatellites_gps, 1:3);
    
    omc_gps = (obs_corr_actv_gps - rho_predict_gps - cdtu(2) - iono_gps - trop_gps)';
    womc_gps = W_gps * omc_gps;
    
    H = [H_bds; H_gps];
    omc = [omc_bds; omc_gps];
    wH = [wH_bds; wH_gps];
    womc = [womc_bds; womc_gps];
    
    if rank(H) ~= 5
        pos_xyz = zeros(3,1);
        cdtu = zeros(2,1);
        bEsti = [psrCorr(1:nmbOfSatellites_bds)'-median(psrCorr(1:nmbOfSatellites_bds));...
                psrCorr(nmbOfSatellites_bds+1:nmbOfSatellites_bds+nmbOfSatellites_gps)'-median(psrCorr(nmbOfSatellites_bds+1:nmbOfSatellites_bds+nmbOfSatellites_gps))];
        rankBreak = 1;
        return;
    end
%     dp = H \ omc;
    dp = wH \ womc;
    
    pos_xyz = pos_xyz + dp(1:3);
    cdtu = cdtu + dp(4:5);
    
    if sum(abs(dp))<0.01
        break;
    end
end

oribEsti = omc - H/(H'*H)*H'*omc;    % 残余分量
bEsti = omc - H/(wH'*wH)*wH'*womc;    % 残余分量
psrCorr = [(obs_corr_actv_bds-cdtu(1)), (obs_corr_actv_gps-cdtu(2))] - [iono_bds, iono_gps] - [trop_bds, trop_gps];

%--------- compute the velocity -----------
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
bVel_bds = bVel_bds';

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
bVel_gps = bVel_gps';

bVel = [bVel_bds; bVel_gps];
vel = H \ bVel;
% vel(4) = vel(4)/wavelengthB1;
% vel(5) = vel(5)/wavelengthL1;

%-------- Calculate Dilution Of Precision --------------
Q = inv(H' * H);
DOP(1)  = sqrt(trace(Q));                       % GDOP
DOP(2)  = sqrt(Q(1,1) + Q(2,2) + Q(3,3));       % PDOP
DOP(3)  = sqrt(Q(1,1) + Q(2,2));                % HDOP
DOP(4)  = sqrt(Q(3,3));                         % VDOP
DOP(5)  = sqrt(Q(4,4));                         % TDOP


