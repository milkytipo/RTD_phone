function [bur, vel_delta, cdtu_delta, az, el, iono, trop, bEsti, psrCorr, DOP, rankBreak] = ...
    leastSquarePos_GPS1(satpos, satpos_ref,obs,obs_ref,  transmitTime, transmitTime_ref,ephemeris_para, activeChannel, satClkCorr, satClkCorr_ref,pvtCalculator, pvtCalculator_ref,recv_timer, ...
                        pvtForecast_Succ, elfore, azfore, ionofore, tropfore, cn0,cn0_ref)
%Function calculates the Least Square Solution
%
%[pos, el, az, dop] = leastSquarePos(satpos, obs, settings);
%
%   Inputs:
%       satpos      - Satellites positions (in ECEF system: [X; Y; Z;] -
%                   one column per satellite) [6 X 32]
%       obs         - Observations - the pseudorange measurements to each
%                   satellite:
%                   (e.g. [20000000 21000000 .... .... .... .... ....])
%       settings    - receiver settings
%        time        -transmit time
%       channelList   -activechannel
%   Outputs:
%       pos         - receiver position and receiver clock error
%                   (in ECEF system: [X, Y, Z, dt])
%       el          - Satellites elevation angles (degrees)
%       az          - Satellites azimuth angles (degrees)
%       dop         - Dilutions Of Precision ([GDOP PDOP HDOP VDOP TDOP])

%=== Initialization =======================================================
% Perform a normal Least Square Positioning Procedure
pos_ref_xyz= [ -2853445.926;4667466.476; 3268291.272];
nmbOfIterations = 11;
c = 299792458; 
Tc_L1 = 1/1.023e6;
nmbOfSatellites = size(activeChannel, 2);
% ionosphere and troposphere model initialization
alpha_default = [2.186179e-008, -9.73869e-008, 7.03774e-008, 3.031505e-008]';
beta_default = [ 129643.8, -64245.75, -866336.2, 1612913]';
Alpha_actv = zeros(4, nmbOfSatellites);
Beta_actv  = zeros(4, nmbOfSatellites);

% reorganize the obs, satpos, satclk into a compact vectors or matrices
satpos_actv = zeros(3, nmbOfSatellites);
satvel_actv = zeros(3, nmbOfSatellites);
satpos_rot_corr = zeros(3, nmbOfSatellites);  %storing the sat positions after earth rotation corrections
obs_actv = zeros(1, nmbOfSatellites);
transmitTime_actv = zeros(1, nmbOfSatellites);
satClkCorr_actv = zeros(2, nmbOfSatellites);
cn0_actv = zeros(2, nmbOfSatellites);
%basestation parameters
satpos_ref_actv = zeros(3, nmbOfSatellites);
satvel_ref_actv = zeros(3, nmbOfSatellites);
satpos_ref_rot_corr = zeros(3, nmbOfSatellites);  %storing the sat positions after earth rotation corrections
obs_ref_actv = zeros(1, nmbOfSatellites);
transmitTime_ref_actv = zeros(1, nmbOfSatellites);
satClkCorr_ref_actv = zeros(2, nmbOfSatellites);
cn0_ref_actv = zeros(2, nmbOfSatellites);

% output ini
DOP = zeros(5,1);
vel = zeros(4,1);
pos_xyz = [];
cdtu = 0;
DOP_ref = zeros(5,1);
vel_ref = zeros(4,1);
pos_xyz_ref = [];
cdtu_ref = 0;

az = zeros(1, nmbOfSatellites);
el = zeros(1, nmbOfSatellites);
iono = zeros(1, nmbOfSatellites);
trop = zeros(1, nmbOfSatellites);
psrCorr = zeros(1, nmbOfSatellites);
psrCorr_ref = zeros(1, nmbOfSatellites);
rankBreak = 0;

H = zeros(nmbOfSatellites,4);

H_ref = zeros(nmbOfSatellites,4);

for n=1:nmbOfSatellites
    satpos_actv(:,n) = satpos(1:3, activeChannel(2,n));
    satvel_actv(:,n) = satpos(4:6, activeChannel(2,n));
    obs_actv(n) = obs(activeChannel(2,n));
    transmitTime_actv(n) = transmitTime(activeChannel(2,n));
    satClkCorr_actv(:,n) = satClkCorr(:, activeChannel(2,n));
    cn0_actv(:, n) = cn0(1:2, activeChannel(2,n));
    psrCorr(n) = obs_actv(n) + c*satClkCorr_actv(1,n) - ionofore(activeChannel(2,n)) - tropfore(activeChannel(2,n));  
end
%basestation section
for n=1:nmbOfSatellites
    satpos_ref_actv(:,n) = satpos_ref(1:3, activeChannel(2,n));
    satvel_ref_actv(:,n) = satpos_ref(4:6, activeChannel(2,n));
    obs_ref_actv(n) = obs_ref(activeChannel(2,n));
    transmitTime_ref_actv(n) = transmitTime_ref(activeChannel(2,n));
    satClkCorr_ref_actv(:,n) = satClkCorr_ref(:, activeChannel(2,n));
    cn0_ref_actv(:, n) = cn0_ref(1:2, activeChannel(2,n));
    psrCorr_ref(n) = obs_ref_actv(n) + c*satClkCorr_ref_actv(1,n) - ionofore(activeChannel(2,n)) - tropfore(activeChannel(2,n));  
end


%----------- 1st, correct the satellite clock error ---------
obs_corr_actv = psr_satclk_corr(obs_actv, satClkCorr_actv(1,:));
obs_ref_corr_actv = psr_satclk_corr(obs_ref_actv, satClkCorr_ref_actv(1,:));

%----------- 2nd, get the a-prior user position -------------
% [pos_xyz, pos_llh, pos_vel] = get_user_pos(pvtCalculator);
if pvtForecast_Succ
    pos_xyz = pvtCalculator.posForecast;
    cdtu = pvtCalculator.clkErrForecast(2);    %校正后的接收机钟差
end


% For the first time PVT calculation, the user position is unknown, so we
% perform two more initial pre-iterations.
if isempty(pos_xyz)
    refPos =[ -2853445.926;4667466.476; 3268291.272];  % 上海市静态点
    pos_xyz = refPos;

    
    %------- 3rd, perform a few iters solution solving without atmosphere
    %correct under the condition that there is a-prior PVT solution ------
    for iter_pre = 1:11
        sat2usr_mtrx = satpos_actv - repmat(pos_xyz, 1, nmbOfSatellites);      %卫星相对用户的向量
        rho_predict = sqrt(sum(sat2usr_mtrx.*sat2usr_mtrx, 1));                       %k-1时刻用户到每一颗卫星的距离
    
        traveltime = rho_predict / 299792458;
    
        %------- 3.1rd, correct earth rotation correction ----------
        for n=1:nmbOfSatellites
            satpos_rot_corr(:, n) = e_r_corr(traveltime(n), satpos_actv(:, n));
        end
    
        sat2usr_mtrx = satpos_rot_corr - repmat(pos_xyz, 1, nmbOfSatellites);
        rho_predict = sqrt(sum(sat2usr_mtrx.*sat2usr_mtrx, 1));
    
        for n=1:nmbOfSatellites
            H(n,:) = [-sat2usr_mtrx(:,n)'/rho_predict(n), 1];           %H即G几何矩阵
        end
        omc = (obs_corr_actv - rho_predict - cdtu)';               %omc即b
        if rank(H) ~= 4
            bEsti = psrCorr'-median(psrCorr);
            rankBreak = 1;
            return;
        end
        dp = H \ omc;
        pos_xyz = pos_xyz + dp(1:3);
        cdtu = cdtu + dp(4);  %把ε_p算入接收机误差中
        
        if sum(abs(dp))<0.01
            break;
        end
    end %EOF "for iter_pre = 1:3"
end %EOF "if isempty(pos_xyz)"

%basestation section
if ~isempty(pos_xyz)
    refPos =[ -2853445.926;4667466.476; 3268291.272];  % 上海市静态点
    pos_xyz = refPos;
    
    for iter_pre = 1:11
        sat2usr_ref_mtrx = satpos_ref_actv - repmat(pos_ref_xyz, 1, nmbOfSatellites);      %卫星相对用户的向量
        rho_ref_predict = sqrt(sum(sat2usr_ref_mtrx.*sat2usr_ref_mtrx, 1));                       %k-1时刻用户到每一颗卫星的距离
    
        traveltime_ref = rho_ref_predict / 299792458;
    
        %------- 3.1rd, correct earth rotation correction ----------
        for n=1:nmbOfSatellites
            satpos_ref_rot_corr(:, n) = e_r_corr(traveltime_ref(n), satpos_ref_actv(:, n));
        end
    
        sat2usr_ref_mtrx = satpos_ref_rot_corr - repmat(pos_ref_xyz, 1, nmbOfSatellites);
        rho_ref_predict = sqrt(sum(sat2usr_ref_mtrx.*sat2usr_ref_mtrx, 1));
    
        for n=1:nmbOfSatellites
            H_ref(n,:) = [-sat2usr_ref_mtrx(:,n)'/rho_ref_predict(n), 1];           %H即G几何矩阵
        end
        omc_ref = (obs_ref_corr_actv - rho_ref_predict - cdtu_ref)';               %omc即b
        if rank(H_ref) ~= 4
            bEsti_ref = psrCorr_ref'-median(psrCorr_ref);
            rankBreak_ref = 1;
            return;
        end
        dp_ref = H_ref \ omc_ref;
        pos_ref_xyz = pos_ref_xyz + dp_ref(1:3);
        cdtu_ref = cdtu_ref + dp_ref(4);  %把ε_p算入接收机误差中
        
        if sum(abs(dp_ref))<0.01
            break;
        end
    end %EOF "for iter_pre = 1:3"
end %EOF "if isempty(pos_xyz)"


% The approximate user position is known, the user LLH coordinates
% ------ find the longtitude and latitude of position CGCS2000 -------
[ Lat, Lon, Hight ] = cart2geo( pos_xyz(1), pos_xyz(2), pos_xyz(3), 5 );
pos_llh = [Lat; Lon; Hight];

%-----4th, get the iono and trop parameters -----
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

%---- 5th, compute the elv and azi of each satellite -----
    for n=1:nmbOfSatellites
        [az(n), el(n), ~] = topocent(pos_xyz, sat2usr_mtrx(:, n));
        iono(n) = Ionospheric_GPS(pos_llh(1), pos_llh(2), el(n), az(n), Alpha_actv(:,n)', Beta_actv(:,n)', transmitTime_actv(n));
        trop(n) = Tropospheric(T_amb,P_amb,P_vap,el(n));
    end

%--------- pre-7.1, compute the weighting factors -------
w_gps = wightMtr_gen(Lat, el, cn0_actv, c*Tc_L1);
W_gps = diag(1./sqrt(w_gps));
W_gps = eye(nmbOfSatellites);

%---- 7th, Iteratively find receiver position with error corrections -----
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
    wH = H;
    wH(1:nmbOfSatellites, 1:3) = W_gps * wH(1:nmbOfSatellites, 1:3);
    
    omc = (obs_corr_actv - rho_predict - cdtu - iono - trop)';
    womc= W_gps * omc;
    
    if rank(H) ~= 4
        pos_xyz = zeros(3,1);
        cdtu = 0;
        bEsti = psrCorr'-median(psrCorr);
        rankBreak = 1;
        return;
    end
%     dp = H \ omc;
    dp = wH \ womc;
    pos_xyz = pos_xyz + dp(1:3);
    cdtu = cdtu + dp(4);
    
    if sum(abs(dp))<0.01
        break;
    end
end
pos_ref_xyz= [ -2853445.926;4667466.476; 3268291.272];
bur=  pos_xyz -  pos_ref_xyz;
cdtu_delta=cdtu -cdtu_ref;
% [ Lat, Lon, Hight ] = cart2geo( pos_xyz(1), pos_xyz(2), pos_xyz(3), 5 );
% pos_llh = [Lat; Lon; Hight];
oribEsti = omc - H/(H'*H)*H'*omc;    % 残余分量
bEsti = omc - H/(wH'*wH)*wH'*womc;
psrCorr = obs_corr_actv - iono - trop - cdtu(1);

%--------- compute the velocity -----------
gpsDoppSmooth = pvtCalculator.GPS.doppSmooth;
gpsDoppSmooth_ref = pvtCalculator_ref.GPS.doppSmooth;
deltaP = zeros(1, nmbOfSatellites);
bVel = zeros(1, nmbOfSatellites);
deltaP_ref = zeros(1, nmbOfSatellites);
bVel_ref  = zeros(1, nmbOfSatellites);
C = 299792458;
% L1= 1575420000;
% wavelengthL1 = C/L1;
for n=1:nmbOfSatellites
    if gpsDoppSmooth(activeChannel(2,n),4) > 5e10
        deltaP(n) = (gpsDoppSmooth(activeChannel(2,n),1) - gpsDoppSmooth(activeChannel(2,n),2)) / pvtCalculator.pvtT; %积分多普勒一秒的变化量（m）
    else
%         deltaP(n) = -wavelengthL1*gpsDoppSmooth(activeChannel(2,n),3);
        deltaP(n) = gpsDoppSmooth(activeChannel(2,n),3);
    end
    bVel(n) = deltaP(n) + H(n, 1:3)*satvel_actv(:,n) + C*satClkCorr_actv(2,n);
end
bVel = bVel';
vel = H \ bVel;

%basestation section
for n=1:nmbOfSatellites
    if gpsDoppSmooth_ref (activeChannel(2,n),4) > 5e10
        deltaP_ref (n) = (gpsDoppSmooth_ref (activeChannel(2,n),1) - gpsDoppSmooth_ref(activeChannel(2,n),2)) / pvtCalculator.pvtT; %积分多普勒一秒的变化量（m）
    else
%         deltaP(n) = -wavelengthL1*gpsDoppSmooth(activeChannel(2,n),3);
        deltaP_ref (n) = gpsDoppSmooth_ref(activeChannel(2,n),3);
    end
    bVel_ref (n) = deltaP_ref (n) + H_ref (n, 1:3)*satvel_ref_actv(:,n) + C*satClkCorr_ref_actv(2,n);
end
bVel_ref = bVel_ref';
vel_ref = H_ref \ bVel_ref;

vel_delta = vel -vel_ref;
% vel(4)'s unit is m/s.
% vel(4) = vel(4)/wavelengthL1;

%=== Calculate Dilution Of Precision ======================================
Q = inv(H' * H);
DOP(1)  = sqrt(trace(Q));                       % GDOP
DOP(2)  = sqrt(Q(1,1) + Q(2,2) + Q(3,3));       % PDOP
DOP(3)  = sqrt(Q(1,1) + Q(2,2));                % HDOP
DOP(4)  = sqrt(Q(3,3));                         % VDOP
DOP(5)  = sqrt(Q(4,4));                         % TDOP

