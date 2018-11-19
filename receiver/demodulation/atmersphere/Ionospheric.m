%This Function approximate Ionospheric Group Delay 

%************************************************************************
%************************************************************************           
% ***********************************************************************           
%      Function for   computing an Ionospheric range correction for the *
%      GPS L1 frequency from the parameters broadcasted in the GPS      *
%      Navigation Message.                                              *
%      ==================================================================
%      References:                                                      *
%      Klobuchar, J.A., (1996) "Ionosphercic Effects on GPS", in        *
%        Parkinson, Spilker (ed), "Global Positioning System Theory and *
%        Applications, pp.513-514.                                      *
%      ICD-GPS-200, Rev. C, (1997), pp. 125-128                         *
%      NATO, (1991), "Technical Characteristics of the NAVSTAR GPS",    *
%        pp. A-6-31   -   A-6-33                                        *
%      ==================================================================
%    Input :                                                            *
%        Pos_Rcv       : XYZ position of reciever               (Meter) *
%        Pos_SV        : XYZ matrix position of GPS satellites  (Meter) *
%        GPS_Time      : Time of Week                           (sec)   *
%        Alfa(4)       : The coefficients of a cubic equation           *
%                        representing the amplitude of the vertical     *
%                        dalay (4 coefficients - 8 bits each)           *
%        Beta(4)       : The coefficients of a cubic equation           *
%                        representing the period of the model           *
%                        (4 coefficients - 8 bits each)                 *
%    Output:                                                            *
%       Delta_I        : Ionospheric slant range correction for         *
%                        the L1 frequency                       (Sec)   *
%     ==================================================================

function Delta_I=Ionospheric(Lat,Lon,El,A,Alpha,Beta,GPS_Time)

% Lat=GPS_Rcv(1)/pi;Lon=GPS_Rcv(2)/pi;   % semicircles unit Lattitdue and Longitude 
% S=size(Pos_SV);
% m=S(1);n=S(2);
c= 299792458;
E=El/180;                                          %SemiCircle Elevation
A=A/180;
Lat=Lat/180;
Lon=Lon/180;
% A=A0;                                               %SemiCircle Azimoth 
% 1.Calculate the Earth-Centered angle, Psi

Psi=0.0137/(E+.11)-0.022;                        %SemiCircle

%2.Compute the Subionospheric lattitude, Phi_L
Phi_L=Lat+Psi*cos(A*pi);                         %SemiCircle
if Phi_L>0.416
    Phi_L=0.416;
elseif Phi_L<-0.416
    Phi_L=-0.416;
end

%3.Compute the subionospheric longitude, Lambda_L
Lambda_L=Lon+(Psi*sin(A*pi)/cos(Phi_L*pi));  %SemiCircle

%4.Find the geomagnetic lattitude ,Phi_m, of the subionospheric location
%looking toward each GPS satellite:
Phi_m=Phi_L+0.064*cos((Lambda_L-1.617)*pi);

%5.Find the Local Time ,t, at the subionospheric point
t=4.32*10^4*Lambda_L+mod(GPS_Time,86400);                 %GPS_Time(Sec)
if t>86400
    t=t-86400;
elseif t<0
    t=t+86400;
end

%6.Convert Slant time delay, Compute the Slant Factor,F
F=1+16*(.53-E)^3;

%7.Compute the ionospheric time delay T_iono by first computing x
Per=Beta(1)+Beta(2)*Phi_m+Beta(3)*Phi_m^2+Beta(4)*Phi_m^3;
if Per <72000                                     %Period
    Per=72000;
end
x=2*pi*(t-50400)/Per;                       %Rad
AMP=Alpha(1)+Alpha(2)*Phi_m+Alpha(3)*Phi_m^2+Alpha(4)*Phi_m^3;
if AMP<0 
    AMP=0;
end
%step 8.
if abs(x)>1.57
    T_iono=F*5*10^(-9);
else
    T_iono=F*(5*10^(-9)+AMP*(1-x^2/2+x^4/4));
end
    Delta_I=T_iono*c;
end
