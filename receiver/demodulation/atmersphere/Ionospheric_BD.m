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
 %         Hight       sattle hight
%
%    Output:                                                              *
%       Delta_I        : Ionospheric slant range correction for         *
%                        the L1 frequency                       (Sec)   *
%     ==================================================================

function Delta_I = Ionospheric_BD(Lat, Lon, El, A, Alpha, Beta, BD_Time, Rot_X)

% Lat=GPS_Rcv(1)/pi;Lon=GPS_Rcv(2)/pi;   % semicircles unit Lattitdue and Longitude 
% S=size(Pos_SV);
% m=S(1);n=S(2);
BD_Time=BD_Time+8*3600;%%北京时间
pi=3.1415926535898;
c= 299792458;
E=El*pi/180;                                          %SemiCircle Elevation
A=A*pi/180;
Phi_u=Lat*pi/180;
Lambda_u=Lon*pi/180;
% A=A0;                                               %SemiCircle Azimoth 
% 1.Calculate the Earth-Centered angle, Psi

Psi=pi/2-E-asin(6378/(6378+375)*cos(E));                       %SemiCircle

%2.Compute the Subionospheric lattitude, Phi_L
Phi_M=asin(sin(Phi_u)*cos(Psi)+cos(Phi_u)*sin(Psi)*cos(A));

% % Phi_L=Phi_u+Psi*cos(A*pi);                         %SemiCircle
% % if Phi_L>0.416
% %     Phi_L=0.416;
% % elseif Phi_L<-0.416
% %     Phi_L=-0.416;
% % end

%3.Compute the subionospheric longitude, Lambda_L
Lambda_M=Lambda_u+asin((sin(Psi)*sin(A))/cos(Phi_M));  %SemiCircle

%4.Find the geomagnetic lattitude ,Phi_m, of the subionospheric location
%looking toward each GPS satellite:
%Phi_m=Phi_L+0.064*cos((Lambda_M-1.617)*pi);
dianli_llh=[Phi_M*180/pi,Lambda_M*180/pi,375000];
dianli_xyz=llh2xyz(dianli_llh);
delta_t=sqrt((Rot_X(1)-dianli_xyz(1))^2+(Rot_X(2)-dianli_xyz(2))^2+(Rot_X(3)-dianli_xyz(3))^2)/c;%计算传输到电离层的时间
%5.Find the Local Time ,t, at the subionospheric point
t=mod(delta_t+BD_Time,86400);
% % t=4.32*10^4*Lambda_M+mod(BD_Time,86400);                 %GPS_Time(Sec)
% % if t>86400
% %     t=t-86400;
% % elseif t<0
% %     t=t+86400;
% % end

%6.Convert Slant time delay, Compute the Slant Factor,F
%F=1+16*(.53-E)^3;

%7.Compute the ionospheric time delay T_iono by first computing x
A4=Beta(1)+Beta(2)*abs(Phi_M/pi)+Beta(3)*(Phi_M/pi)^2+Beta(4)*abs((Phi_M/pi)^3);
if A4 <72000                                     %Period
    A4=72000;
elseif A4>=172800
    A4=172800;
end
%Rad
A2=Alpha(1)+Alpha(2)*abs(Phi_M/pi)+Alpha(3)*(Phi_M/pi)^2+Alpha(4)*abs((Phi_M/pi)^3);
if A2<0 
    A2=0;
end
%step 8.
if abs(t-50400)<(A4/4)
    Izt=5*10^(-9)+A2*cos(2*pi*(t-50400)/A4);
else
    Izt=5*10^(-9);
end
IB1t=1/sqrt(1-(6378/(6378+375)*cos(E))^2)*Izt;

Delta_I=IB1t*c;

% % if abs(x)>1.57
% %     T_iono=F*5*10^(-9);
% % else
% %     T_iono=F*(5*10^(-9)+A2*(1-x^2/2+x^4/4));
% % end
% %     Delta_I=T_iono*c;
end
