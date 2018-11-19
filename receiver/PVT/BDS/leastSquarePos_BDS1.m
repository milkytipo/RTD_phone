function [pos_xyz, vel, cdtu, az, el, iono, trop, bEsti, psrCorr, DOP, rankBreak] = ...
    leastSquarePos_BDS1(satpos, obs, transmitTime, ephemeris_para, activeChannel, satClkCorr, ...
                        pvtCalculator, recv_timer, pvtForecast_Succ, elfore, azfore, ionofore, tropfore, CN0_bds)
%Function calculates the Least Square Solution.
%
%[pos, el, az, dop] = leastSquarePos(satpos, obs, settings);
%
%   Inputs:
%       satpos      - Satellites positions (in ECEF system: [X; Y; Z;] -
%                   one column per satellite)
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

%--------------------------------------------------------------------------

%-------------- Initialization ----------------
nmbOfIterations = 11;
c = 299792458;
Tc_B1 = 1/2.046e6;
nmbOfSatellites = size(activeChannel, 2);
% re-organize the obs, satpos, satclk into a compact vectors or matrices
satpos_actv = zeros(3, nmbOfSatellites);
satvel_actv = zeros(3, nmbOfSatellites);
satpos_rot_corr = zeros(3, nmbOfSatellites);  %storing the sat positions after earth rotation corrections
obs_actv = zeros(1, nmbOfSatellites);
transmitTime_actv = zeros(1, nmbOfSatellites);
satClkCorr_actv = zeros(2, nmbOfSatellites);
Alpha_actv = zeros(4, nmbOfSatellites);
Beta_actv  = zeros(4, nmbOfSatellites);
cn0_actv   = zeros(2, nmbOfSatellites);
DOP = zeros(5,1);
H = zeros(nmbOfSatellites,4);

vel = zeros(4,1);
pos_xyz = [];
cdtu = 0;
az = zeros(1, nmbOfSatellites);
el = zeros(1, nmbOfSatellites);
iono = zeros(1, nmbOfSatellites);
trop = zeros(1, nmbOfSatellites);
psrCorr = zeros(1, nmbOfSatellites);
rankBreak = 0;

T_amb = 20;%20
P_amb = 101.325; %KPa
P_vap = .849179;%.86; 0.61078*(H/100)*exp(T/(T+238.3)*17.2694) KPa

for n=1:nmbOfSatellites
    satpos_actv(:,n)     = satpos(1:3, activeChannel(2,n));
    satvel_actv(:,n)     = satpos(4:6, activeChannel(2,n));
    obs_actv(n)          = obs(activeChannel(2,n));
    transmitTime_actv(n) = transmitTime(activeChannel(2,n));
    satClkCorr_actv(:,n) = satClkCorr(:, activeChannel(2,n));
    Alpha_actv(:, n)     = [ephemeris_para(activeChannel(2, n)).eph.Alpha0;
                            ephemeris_para(activeChannel(2, n)).eph.Alpha1;
                            ephemeris_para(activeChannel(2, n)).eph.Alpha2;
                            ephemeris_para(activeChannel(2, n)).eph.Alpha3];
    Beta_actv(:,n)       = [ephemeris_para(activeChannel(2, n)).eph.Beta0;
                            ephemeris_para(activeChannel(2, n)).eph.Beta1;
                            ephemeris_para(activeChannel(2, n)).eph.Beta2;
                            ephemeris_para(activeChannel(2, n)).eph.Beta3;];
    cn0_actv(:,n)        = CN0_bds(:, activeChannel(2, n));
    psrCorr(n) = obs_actv(n) + c*satClkCorr_actv(1,n) - ionofore(activeChannel(2,n)) - tropfore(activeChannel(2,n));
end

%----------- 1st, correct the satellite clock error ---------
obs_corr_actv = psr_satclk_corr(obs_actv, satClkCorr_actv(1,:));
%----------- 2nd, get the a-prior user position -------------
if pvtForecast_Succ
    pos_xyz = pvtCalculator.posForecast;
    cdtu = pvtCalculator.clkErrForecast(1);
end

% For the first time PVT calculation, the user position is unknown, so we
% perform two more initial pre-iterations.
if isempty(pos_xyz)
    pos_xyz = zeros(3,1);
    %------- 3rd, perform a few iters solution solving without atmosphere
    % correct under the condition that there is a-prior PVT solution ------
    for iter_pre = 1:11
        sat2usr_mtrx = satpos_actv - repmat(pos_xyz, 1, nmbOfSatellites);
        rho_predict = sqrt(sum(sat2usr_mtrx.*sat2usr_mtrx, 1));
        
        traveltime = rho_predict / 299792458;
        
        %------- 3.1rd, correct earth rotation correction ----------
        for n=1:nmbOfSatellites
            satpos_rot_corr(:, n) = e_r_corr(traveltime(n), satpos_actv(:, n));
        end
        
        sat2usr_mtrx = satpos_rot_corr - repmat(pos_xyz, 1, nmbOfSatellites);
        rho_predict = sqrt(sum(sat2usr_mtrx.*sat2usr_mtrx, 1));
        
        for n=1:nmbOfSatellites
            H(n,:) = [-sat2usr_mtrx(:,n)'/rho_predict(n), 1];
        end
        omc = (obs_corr_actv - rho_predict - cdtu)';
        if rank(H) ~= 4
            bEsti = psrCorr'-median(psrCorr);
            rankBreak = 1;
            return;
        end
        dp = H \ omc;
        pos_xyz = pos_xyz + dp(1:3);
        cdtu = cdtu + dp(4);
        
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
    for n=1:nmbOfSatellites
        el(n)   = elfore(activeChannel(2,n));
        az(n)   = azfore(activeChannel(2,n));
        iono(n) = ionofore(activeChannel(2,n));
        trop(n) = tropfore(activeChannel(2,n));
    end
    % Check if clkErr to BDS has been corrected
    if recv_timer.rclkErr2Syst_UpCnt(1) >= recv_timer.rclkErr2Syst_Thre
        sat2usr_mtrx = satpos_actv - repmat(pos_xyz, 1, nmbOfSatellites);
        rho_predict = sqrt(sum(sat2usr_mtrx.*sat2usr_mtrx, 1));
        
        traveltime = rho_predict / 299792458;
        
        %------- 5.1rd, correct earth rotation correction ----------
        for n=1:nmbOfSatellites
            satpos_rot_corr(:, n) = e_r_corr(traveltime(n), satpos_actv(:, n));
        end
        
        sat2usr_mtrx = satpos_rot_corr - repmat(pos_xyz, 1, nmbOfSatellites);
        rho_predict = sqrt(sum(sat2usr_mtrx.*sat2usr_mtrx, 1));
        
        cdtu = mean(obs_corr_actv - rho_predict - iono - trop);
    end
else
    for n=1:nmbOfSatellites
        [az(n), el(n), dist] = topocent(pos_xyz, sat2usr_mtrx(:, n));
        iono(n) = Ionospheric_BD(pos_llh(1), pos_llh(2), el(n), az(n), Alpha_actv(:,n), Beta_actv(:,n), transmitTime_actv(n), satpos_rot_corr(:, n));
        trop(n) = Tropospheric(T_amb, P_amb, P_vap, el(n));
    end
end

%--------- pre-7.1, compute the weighting factors -------
SIGMAmt = wightMtr_gen(Lat, el, cn0_actv, c*Tc_B1);
SIGMAmt_inv = diag(1./sqrt(SIGMAmt));

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
    omc = (obs_corr_actv - rho_predict - cdtu - iono - trop)';
    
    wH = H;
    wH(1:nmbOfSatellites, 1:3) = SIGMAmt_inv * wH(1:nmbOfSatellites, 1:3);
    womc = SIGMAmt_inv * omc;
    
    if rank(H) ~= 4
        pos_xyz = zeros(3,1);
        cdtu = 0;
        bEsti = psrCorr'-median(psrCorr);
        rankBreak = 1;
        return;
    end
%     dp = H \ omc;
%     dp = (H'*SIGMAmt_inv*H) \ (H'*SIGMAmt_inv*omc);
    dp = wH \ womc;
    
    pos_xyz = pos_xyz + dp(1:3);
    cdtu = cdtu + dp(4);
    
    if sum(abs(dp))<0.01
        break;
    end
end

orgbEsti = omc - H/(H'*H)*H'*omc;    % ²ÐÓà·ÖÁ¿
% bEsti = omc - H/(H'*SIGMAmt_inv*H)*H'*SIGMAmt_inv*omc;
bEsti = omc - H/(wH'*wH)*wH'*womc;
psrCorr = obs_corr_actv - iono - trop - cdtu;

%--------- compute the velocity -----------
bdsDoppSmooth = pvtCalculator.BDS.doppSmooth;
deltaP = zeros(1, nmbOfSatellites);
bVel = zeros(1, nmbOfSatellites);
C = 299792458;
% B1= 1561.098e6;
% wavelengthB1 = C/B1;

for n=1:nmbOfSatellites
    if bdsDoppSmooth(activeChannel(2,n), 4) > 5e10
        deltaP(n) = (bdsDoppSmooth(activeChannel(2,n),1)-bdsDoppSmooth(activeChannel(2,n),2)) / pvtCalculator.pvtT;
    else
%         deltaP(n) = -wavelengthB1 * bdsDoppSmooth(activeChannel(2,n), 3);
        deltaP(n) = bdsDoppSmooth(activeChannel(2,n), 3);
    end
%     deltaP(n) = -wavelengthB1 * bdsDoppSmooth(activeChannel(2,n), 3);%for debugging
    bVel(n) = deltaP(n) + H(n, 1:3)*satvel_actv(:,n) + C*satClkCorr_actv(2,n);
end
bVel = bVel';
vel = H \ bVel;
% vel(4) = vel(4)/wavelengthB1;

%-------- Calculate Dilution Of Precision --------------
Q = inv(H' * H);
DOP(1)  = sqrt(trace(Q));                       % GDOP
DOP(2)  = sqrt(Q(1,1) + Q(2,2) + Q(3,3));       % PDOP
DOP(3)  = sqrt(Q(1,1) + Q(2,2));                % HDOP
DOP(4)  = sqrt(Q(3,3));                         % VDOP
DOP(5)  = sqrt(Q(4,4));                         % TDOP

