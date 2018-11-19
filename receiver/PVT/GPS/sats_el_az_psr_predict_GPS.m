function [el, az, iono, trop, psr, satelliteTable] = sats_el_az_psr_predict_GPS(satpos, activeChannel_GPS, posForecast, satelliteTable, eph_para, recv_timer)

el = zeros(1,32);
az = zeros(1,32);
iono = zeros(1,32);
trop = zeros(1,32);
psr =  zeros(1,32);

nmbOfSatellites = size(activeChannel_GPS, 2);

alpha_default = [2.186179e-008, -9.73869e-008, 7.03774e-008, 3.031505e-008]';
beta_default = [ 129643.8, -64245.75, -866336.2, 1612913]';
T_amb = 20;%20
P_amb = 101.325; %KPa
P_vap = .849179;%.86; 0.61078*(H/100)*exp(T/(T+238.3)*17.2694) KPa

% compute the LLH coordinates
[ Lat, Lon, ~ ] = cart2geo( posForecast(1), posForecast(2), posForecast(3), 5 );

for n = 1:nmbOfSatellites
    prn = activeChannel_GPS(2, n);
    satpos_n = satpos(1:3, prn);
    satvel_n = satpos(4:6, prn);
    psr1_sat2usr = satpos_n - posForecast;
    rho_predict = norm(psr1_sat2usr, 2);
    traveltime = rho_predict / 299792458;
    
    % earth rotation correction
    satpos_n_rotcorr = e_r_corr(traveltime, satpos_n);
    psr2_sat2usr = satpos_n_rotcorr - posForecast;
    
    psr(prn) = norm(psr2_sat2usr, 2);
    
    % Compute each sat el and az
    [az(prn), el(prn), ~] = topocent(posForecast, psr2_sat2usr);
    
    % Update these el and az into satelliteTable
    satelliteTable.satPosxyz(1:6, prn) = [satpos_n; satvel_n];
    satelliteTable.satElevation(prn) = el(prn);
    satelliteTable.satAzimuth(prn) = az(prn);
    
    % Compute the iono&trop correction
    if eph_para(prn).eph.Alpha0 == 'N'
        alpha_n = alpha_default;
        beta_n  = beta_default;
    else
        alpha_n = [eph_para(prn).eph.Alpha0; eph_para(prn).eph.Alpha1; eph_para(prn).eph.Alpha2; eph_para(prn).eph.Alpha3];
        beta_n  = [eph_para(prn).eph.Beta0;  eph_para(prn).eph.Beta1;  eph_para(prn).eph.Beta2;  eph_para(prn).eph.Beta3];
    end
    iono(prn) = Ionospheric_GPS(Lat, Lon, el(prn), az(prn), alpha_n', beta_n', recv_timer.recvSOW_GPS);
    trop(prn) = Tropospheric(T_amb,P_amb,P_vap,el(prn));
end
