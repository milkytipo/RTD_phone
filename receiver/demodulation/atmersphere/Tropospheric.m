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
function Delta_T=Tropospheric(T_amb,P_amb,P_vap,El)
El = El/180*pi;
%Zenith Hydrostatic Delay
Kd=1.55208*10^(-4)*P_amb*(40136+148.72*T_amb)/(T_amb+273.16);

%Zenith Wet Delay
Kw=-.282*P_vap/(T_amb+273.16)+8307.2*P_vap/(T_amb+273.16)^2;

Denom1=sin(sqrt(El^2+1.904*10^-3));
Denom2=sin(sqrt(El^2+.6854*10^-3));
%Troposhpheric Delay Correctoion
Delta_T=Kd/Denom1+Kw/Denom2;                        % Meter
end