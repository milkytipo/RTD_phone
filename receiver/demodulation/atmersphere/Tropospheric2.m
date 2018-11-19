%This Function approximate Troposspheric Group Delay Base on 
%application . edited by B. Parkinson,J. Spilker, P.Enge, AIAA,1996
%CopyRight By Moein Mehrtash
%**************************************************************************
% Written by Moein Mehrtash, Concordia University, 3/21/2008              *
% Email: moeinmehrtash@yahoo.com                                          *
%**************************************************************************
% Reference:"GPS Theory and application",edited by B.Parkinson,J.Spilker, *
%**************************************************************************           
%Input
%        T_amb:'C =>At reciever antenna location
%        P_amb:kPa =>At reciever antenna location
%        P_vap:kPa =>Water vapore pressure at reciever antenna location
%        Pos_Rcv       : XYZ position of reciever               (Meter) 
%        Pos_SV        : XYZ matrix position of GPS satellites  (Meter) 

%Output:    
%        Delta_R_Trop: m =>Tropospheric Error Correction
%**************************************************************************           
function Delta_T=Tropospheric2(T0,P0,e0,el,h) % mbar
%Zenith Hydrostatic Delay
%c = 299792458;
T0 = T0 + 273.16;
Ndry0 = 77.64*P0/(T0)*10;
hdry = (40136+148.72*(T0-273.16));
mdry = 1/sind(sqrt(el^2+6.25));
Tdry = 1e-6/5*Ndry0*(hdry-h)^5/hdry^4*mdry;
%Zenith Wet Delay
Nwet0 = (-12.96*(T0)+3.718*1e+5)*e0/(T0)^2*10;
hwet = 11000;
mwet = 1/sind(sqrt(el^2+2.25));
Twet = 1e-6/5*Nwet0*(hwet-h)^5/hwet^4*mwet;
%Troposhpheric Delay Correctoion
Delta_T=Tdry+Twet;                        % Meter
end