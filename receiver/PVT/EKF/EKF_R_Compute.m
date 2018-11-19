function [R] = EKF_R_Compute(activeChannel, syst,cn0_actv, Rv)
% Compute the EKF measurement covariance according to satellite signal
% informations. Currently, only the SNR/CNR are used to compute R. In the
% future, the multipath, elevation or others will be taken into account.
%-Input:
% activeChannel        - matrix [2 x nmbOfSatellites]
% satelliteTable       - struct vector [1 x GPS_maxPrnNo]
% Rv                   - default pseudorange and pseudorange rate measurement variance, vector [1 x 2]
%-Output
% R                    - measurement variance, including pseudorange and
%                        pseudorange rate variance, vector [1 x 2*nmbOfSatellites]
nmbOfSatellites = length(cn0_actv)-1;
% nmbOfSatellites = size(activeChannel, 2);
R = zeros(1, 2*nmbOfSatellites);
T = 0.02; % coherent tracking time, [s]
C = 299792458;
L1= 1575420000;
B1= 1561.098e6;
switch syst
    case 'GPS_L1CA'
        chip2rho = C/1.023e6;
        lambda2rhodot = C/L1;
    case 'BDS_B1I'
        chip2rho = C/2.046e6;
        lambda2rhodot = C/B1;
end

for n=1:nmbOfSatellites
%     satn_SNR = satelliteTable.SCNR(1,activeChannel(2,n));
    satn_SNR=cn0_actv(n);
    
    if isnan(satn_SNR) || isinf(satn_SNR)
        satn_SNR = 10; %dB
        printf('SYST: %s Sat%d SCNR is NaN or InF!\n', syst, activeChannel(2,n));
    end
%     CNR = satn_SNR + 27; %dB
    CNR = satn_SNR ; %dB 2018.9.5 modify
    cnr = 10^(CNR/20);
    R(n) = 10 * chip2rho * (1/2/cnr) * (1 + 2/T/cnr) + Rv(1); % Pseudorange measurement variance
    R(n+nmbOfSatellites) = (lambda2rhodot/2/pi)^2 * 10/cnr * (1 + 1/2/T/cnr) + Rv(2); % Pseudorange rate (inteDoppler) measurement variance
end

