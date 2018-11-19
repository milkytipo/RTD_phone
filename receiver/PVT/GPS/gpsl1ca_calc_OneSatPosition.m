function [satPositions, satClkCorr] = gpsl1ca_calc_OneSatPosition(transmitTime, eph)

satPositions = zeros(6,1);

% GPS sat orbit constants
F = -4.442807633e-10; % Constant, [sec/(meter)^(1/2)]
GM = 3.986005e14; % [m^3/sec^2] Earth's universal gravitational parameter
C = 2.99792458e8; % [m/sec] speed of light
OMEGA_dot=7.2921151467e-5;%WGS84坐标系下的地球旋转速率(rad/s)
% GM=3.986004418e14;%CGS2000坐标系下的地球引力常数(m^3/s^2)

% sat orbit parameters
toe=eph.toe;%星历参考时间
sqrtA=eph.sqrtA;%长半轴的平方根
e=eph.e;%偏心率
omega=eph.omega;%近地点幅角
deltan=eph.deltan;%卫星平均运动速率与计算值之差
M0=eph.M0;%参考时间的平近点角
omega0=eph.omega0;%按参考时间计算的升交点经度
omega_dot=eph.omegaDot;%OMEGA_DOT%升交点经度变化率
i0=eph.i0;%参考时间的轨道倾角
iDot=eph.iDot;%轨道倾角变化率
Cuc=eph.Cuc;%纬度幅角的余弦调和改正项的振幅
Cus=eph.Cus;%纬度幅角的正弦调和改正项的振幅
Crc=eph.Crc;%轨道半径的余弦调和改正项的振幅
Crs=eph.Crs;%轨道半径的正弦调和改正项的振幅
Cic=eph.Cic;%轨道倾角的余弦调和改正项的振幅
Cis=eph.Cis;%轨道倾角的正弦调和改正项的振幅
    
toc=eph.toc; %!!!!!!!!!!!!!!!!!causion
a0=eph.af0;
a1=eph.af1;
a2=eph.af2;
%transmitTime=eph.SOW;
TGD1=eph.TGD;

%% find initial satellite clock correction
%修正发射时间
dt = check_t(transmitTime-toc);
%计算卫星测距码相位时间偏差
satClkCorr = a0+(a1+a2*dt)*dt-TGD1;

%计算相对论校正项
%计算信号发射时刻系统时间
time = transmitTime - satClkCorr;

%% find sat position
%计算半长轴
A=sqrtA^2;
%计算观测历元到参考历元的时间差,并时间校正
tk  = check_t(time - toe);
%计算卫星平均角速度
n0=(GM/A^3)^0.5;
%改正平均角速度
n=n0+deltan;
%计算平近点角
M=M0+n*tk;
M   = rem(M + 2*pi, 2*pi);
    
%迭代计算偏近点角,超越方程
E=M;
%--- Iteratively compute eccentric anomaly ----------------------------
    for ii = 1:10
        Eold   = E;
        E       = M + e * sin(E);
        dE      = rem(E - Eold, 2*pi);
        
        if abs(dE) < 1.e-12
            % Necessary precision is reached, exit from the loop
            break;
        end
    end
    
E   = rem(E + 2*pi, 2*pi);
%时间修正
%相对论修正项
dtr = F*e*sqrtA * sin(E);

%总时间修正项
%%%%%%%%%%%进行一次反馈再次计算%%%%%%%%%%
satClkCorr=a0+(a1+a2*dt)*dt+dtr-TGD1;
time = transmitTime - satClkCorr;
%时间校正
tk  = check_t(time - toe);
M=M0+n*tk;
M   = rem(M + 2*pi, 2*pi);
    
E=M;
    %--- Iteratively compute eccentric anomaly ----------------------------
    for ii = 1:10
        Eold   = E;
        E       = M + e * sin(E);
        dE      = rem(E - Eold, 2*pi);
        
        if abs(dE) < 1.e-12
            % Necessary precision is reached, exit from the loop
            break;
        end
    end
    
E   = rem(E + 2*pi, 2*pi);

v_k   = atan2(sqrt(1 - e^2) * sin(E), cos(E)-e);
%计算纬度幅角参数
phi_k=v_k+omega;
%Reduce phi to between 0 and 360 deg
phi_k = rem(phi_k, 2*pi);
%计算周期改正项，纬度幅角改正项、径向改正项、轨道倾角改正项
delta_u_k=Cus*sin(2*phi_k)+Cuc*cos(2*phi_k);
delta_r_k=Crs*sin(2*phi_k)+Crc*cos(2*phi_k);
delta_i_k=Cis*sin(2*phi_k)+Cic*cos(2*phi_k);
%计算改正后的纬度参数
u_k=phi_k+delta_u_k;
%计算改正后的径向
r_k=A*(1-e*cos(E))+delta_r_k;
%计算改正后的倾角
i_k=i0+iDot*tk+delta_i_k;
%计算卫星在轨道平面内的坐标
x_k=r_k.*cos(u_k);
y_k=r_k.*sin(u_k);

%计算历元升交点的经度（地固系），计算MEO/IGSO卫星在CGS2000坐标系中的坐标
OMEGA_k=omega0+(omega_dot-OMEGA_dot)*tk-OMEGA_dot*toe;
X_k=x_k.*cos(OMEGA_k)-y_k.*cos(i_k).*sin(OMEGA_k);
Y_k=x_k.*sin(OMEGA_k)+y_k.*cos(i_k).*cos(OMEGA_k);
Z_k=y_k.*sin(i_k);
position = [X_k;Y_k;Z_k];

satPositions(1) = position(1);
satPositions(2) = position(2);
satPositions(3) = position(3);

%% calculate velocity of NGEO satellite
%==============start calculate velocity===========================
%1.计算E的倒数,倒数全采用下标1表示，E1
E1 = n/(1-e*cos(E));
%2.计算phi_k的倒数phi_k1，phi_k1=v_k1
phi_k1 = sqrt(1-e*e)*E1/(1-e*cos(E));
%3.计算delta_u_k1，delta_r_k1，delta_i_k1
delta_u_k1 = 2*phi_k1*(Cus*cos(2*phi_k)-Cuc*sin(2*phi_k));
delta_r_k1 = 2*phi_k1*(Crs*cos(2*phi_k)-Crc*sin(2*phi_k));
delta_i_k1 = 2*phi_k1*(Cis*cos(2*phi_k)-Cic*sin(2*phi_k));
%4.计算u_k1,r_k1,i_k1,OMEGA_k1
u_k1 = phi_k1 + delta_u_k1;
r_k1 = A*e*E1*sin(E) + delta_r_k1;
i_k1 = iDot + delta_i_k1;
OMEGA_k1 = omega_dot-OMEGA_dot;
%5.计算x_k1,y_k1
x_k1 = r_k1*cos(u_k) - r_k*u_k1*sin(u_k);
y_k1 = r_k1*sin(u_k) + r_k*u_k1*cos(u_k);
%6.计算X_k1,Y_k1,Z_k1即vx,vy,vz
X_k1 = -Y_k*OMEGA_k1-(y_k1*cos(i_k)-Z_k*i_k1)*sin(OMEGA_k)+x_k1*cos(OMEGA_k);
Y_k1 = X_k*OMEGA_k1+(y_k1*cos(i_k)-Z_k*i_k1)*cos(OMEGA_k)+x_k1*sin(OMEGA_k);
Z_k1 = y_k1*sin(i_k) + y_k*i_k1*cos(i_k);
%==============finish calculate velocity==========================
satPositions(4) = X_k1;
satPositions(5) = Y_k1;
satPositions(6) = Z_k1;

%%   
%表达式中，t是信号发射时刻的BD-2系统时间，也就是对传播时间修正后的BD-2系统接收时间（距离/光速）。
%因此，t_k就是BD-2系统时间t和星历参考时间toe之间的总时间差，并考虑了跨过一周开始或结束的时间，
%也就是：如果t_k>302400时，就从t_k中减去604800；而如果t_k<-302400时，就对t_k中加上604800
%satposition(satNr)=[X_GK;Y_GK;Z_GK];
satClkCorr = zeros(2,1);
dtr = F*e*sqrtA * sin(E);
satClkCorr(1)=a0+(a1+a2*dt)*dt+dtr-TGD1;
dtr_dot = F*e*sqrtA * E1 * cos(E);
satClkCorr(2) = a1 + 2*a2*dt + dtr_dot;
    
end