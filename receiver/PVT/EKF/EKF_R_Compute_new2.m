function [Rvec] = EKF_R_Compute_new2(Syst, lat, el_actv, cn0_actv, Rv0)
% Compute the EKF measurement covariance according to satellite signal
% informations. Currently, only the SNR/CNR are used to compute Rvec. In the
% future, the multipath, elevation or others will be taken into account.
%-Input:
% lat                  - latitude, scalar
% el_actv              - elevation list, vector [1 x num_of_sats]
% Rv0                  - default pseudorange and pseudorange rate measurement variance, vector [2x1]
% cTc                  - chip length of the signal, scalar; 
%-Output
% Rvec                 - measurement variance, including pseudorange and
%                        pseudorange rate variance, vector [2*nmbOfSatellites x 1]

nmbOfSatellites = length(el_actv);

Re = 6378.14; % earch radius, km
hI = 350;     % height of maximum electron density, km
d2r = pi/180;
Bn = 1;
BL = 10;
T  = 0.02;

C = 299792458;
L1= 1575420000;
B1= 1561.098e6;
switch Syst
    case 'GPS_L1CA'
        cTc = C/1.023e6;
        cf0 = C/L1;
    case 'BDS_B1I'
        cTc = C/2.046e6;
        cf0 = C/B1;
end

if lat<20
    sigma_v = 9;
elseif lat <55
    sigma_v = 4.5;
else
    sigma_v = 6;
end
sigma_t = 0.12;

Rvec = zeros(2*nmbOfSatellites, 1);

for n = 1:nmbOfSatellites
    sigma2_iono = sigma_v / (1 + ( Re*sin(d2r*el_actv(n)) / (Re+hI) )^2);
    sigma2_trop = sigma_t^2 * 1.001^2 / (0.002001 + (sin(d2r*el_actv(n)))^2);
    
    cn0_lin = 10^(cn0_actv(1,n)/10);
    sigma2_psr   = cTc^2 * (Bn/cn0_lin/2) * (1 + 2/T/cn0_lin) + Rv0(1);
%     sigma2_psr   = 10 * cTc * (Bn/2/cn0_lin) * (1 + 2/T/cn0_lin) + Rv0(1); % Pseudorange measurement variance
    sigma2_psrdot= (cf0/T/2/pi)^2 * (4*BL/cn0_lin * (1 + 1/T/cn0_lin)) + Rv0(2);
%     sigma2_psrdot= (cf0/2/pi)^2 * 10/cn0_lin * (1 + 1/2/T/cn0_lin) + Rv0(2);
    
    if cn0_actv(2,n)
        cn0_los2mp = cn0_actv(1,n) - cn0_actv(2,n);
        sigma2_mpratio = 10^(-1.1*(cn0_los2mp - 10)/10);
    else
        sigma2_mpratio = 0;
    end
    
%     Rvec(2*n-1) = sigma2_iono + sigma2_trop + sigma2_psr*(1+sigma2_mpratio);
    Rvec(2*n-1) = sigma2_psr;
    Rvec(2*n)   = sigma2_psrdot;
end




% 
% 
% 
% nmbOfSatellites = size(activeChannel, 2);
% R = zeros(1, 2*nmbOfSatellites);
% T = 0.02; % coherent tracking time, [s]
% C = 299792458;
% L1= 1575420000;
% B1= 1561.098e6;
% switch satelliteTable.syst
%     case 'GPS_L1CA'
%         chip2rho = C/1.023e6;
%         lambda2rhodot = C/L1;
%     case 'BDS_B1I'
%         chip2rho = C/2.046e6;
%         lambda2rhodot = C/B1;
% end
% 
% for n=1:nmbOfSatellites
%     satn_SNR = satelliteTable.SCNR(1,activeChannel(2,n));
%     if isnan(satn_SNR) || isinf(satn_SNR)
%         satn_SNR = 10; %dB
%         printf('SYST: %s Sat%d SCNR is NaN or InF!\n', satelliteTable.syst, activeChannel(2,n));
%     end
%     CNR = satn_SNR + 27; %dB
%     cnr = 10^(CNR/20);
%     R(n) = 10 * chip2rho * (1/2/cnr) * (1 + 2/T/cnr) + Rv(1); % Pseudorange measurement variance
%     R(n+nmbOfSatellites) = (lambda2rhodot/2/pi)^2 * 10/cnr * (1 + 1/2/T/cnr) + Rv(2); % Pseudorange rate (inteDoppler) measurement variance
% end

