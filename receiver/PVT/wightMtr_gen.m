function [w] = wightMtr_gen(lat, el_actv, cn0_actv, cTc)
% lat         - latitude, scalar
% el_actv     - elevation list, vector [1 x num_of_sats]
% cn0_actv    - CN0 of LOS and MPs for each sat, mat [2 x num_of_sats]
% cTc         - chip length of the signal, scalar; 

nmbOfSatellites = length(el_actv);
Re = 6378.14; % earch radius, km
hI = 350;     % height of maximum electron density, km
d2r = pi/180;
Bn = 1;
T  = 0.02;

if lat<20
    sigma_v = 9;
elseif lat <55
    sigma_v = 4.5;
else
    sigma_v = 6;
end
sigma_t = 0.12;

w = zeros(1, nmbOfSatellites);

for n = 1:nmbOfSatellites
%     sigma2_iono = sigma_v^2 / (1 - ( Re*cos(d2r*el_actv(n)) / (Re+hI) )^2);
    sigma2_iono = sigma_v / (1 + ( Re*sin(d2r*el_actv(n)) / (Re+hI) )^2);
    
    sigma2_trop = sigma_t^2 * 1.001^2 / (0.002001 + (sin(d2r*el_actv(n)))^2);
    
    cn0_lin = 10^(cn0_actv(1,n)/10);
    sigma2_th   = cTc^2 * (Bn/cn0_lin/2) * (1 + 2/T/cn0_lin);
    
    if cn0_actv(2,n)
        cn0_los2mp = cn0_actv(1,n) - cn0_actv(2,n);
        sigma2_mpratio = 10^(-1.1*(cn0_los2mp - 10)/10);
    else
        sigma2_mpratio = 0;
    end
    
    w(n) = sigma2_iono + sigma2_trop + sigma2_th*(1+sigma2_mpratio);
end





