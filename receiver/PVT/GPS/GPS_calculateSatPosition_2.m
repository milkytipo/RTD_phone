function [satPos, satClkCorr] = GPS_calculateSatPosition_2(transmitTime, ephemeris1, ephemeris2, chSyst)
% 在双频模式下，计算卫星位置、速度和钟差
% ephemeris1: NAV导航电文结构体， ephemeris2: CNAV星历参数结构体  clk: CNAV时钟参数
% SYST:  GPS_L1CA/GPS_L1CA_L2C 卫星类型（单频/双频）

naviType = 0; %计算时所用星历类型： 1：NAV， 2：CNAV
satPos = zeros(6,1);   % X,Y,Z,Vx,Vy,Vz
satClkCorr = zeros(2,1); % 1位钟差， 2为频飘

miu = 3.986005e14;           %CGS2000坐标系下的地球引力常数(m^3/s^2)，用于CNAV
GM = 3.986004418e14;         %CGS2000坐标系下的地球引力常数(m^3/s^2)
Omega_e_dot = 7.2921151467e-5; %地球旋转角速度(rad/s)
Omega_dot_ref = -2.6e-9;     %地球旋转角速度参考值(semi-circles/second) - 用于CNAV 
Pi = 3.1415926535898;
F = -4.442807633e-10;      % Constant, [sec/(meter)^(1/2)]
A_ref = 26559710;          %轨道半长轴基准值（meters)

%% 参数赋值
if strcmp('GPS_L1CA',chSyst)  %单频卫星处理
    eph = ephemeris1.eph;
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
    TGD1=eph.TGD;

    naviType = 1;
end

if strcmp('GPS_L1CA_L2C',chSyst)  %双频卫星处理
    %>>>>>>>>>>暂时屏蔽CNAV电文<<<<<<<<< 20170707   
    %注意： CNAV的参数在解调时采用了原始单位，此处semi-circle全部转换成rad
%     if (ephemeris2.ephReady)  %若CNAV可用，优先使用
%         eph = ephemeris2.eph;
%         t_oe = eph.t_oe_10;        %星历/时钟参考时间
%         Delta_A = eph.Delta_A;     %t_oe半长轴偏移量
%         A_dot = eph.A_dot;         %半长轴变化率        
%         Delta_n0 = eph.Delta_n0*Pi;   %t_oe平均运动角速度校正值
%         Delta_n0_dot = eph.Delta_n0_dot*Pi;  %t_oe平均运动角速度校正值变化率
%         M_0 = eph.M_0n*Pi;            %t_oe平近点角
%         e = eph.e_n;               %轨道离心率
%         omega_n = eph.omega_n*Pi;       %轨道近地角距
%         Omega_0 = eph.Omega_0n*Pi;    %SOW=0时的升交点赤经
%         Delta_Omega_dot = eph.Delta_Omega_dot*Pi; %轨道升交点赤经变化率偏移量
%         i_0 = eph.i_0n*Pi;            %t_oe轨道倾角
%         i_0_dot = eph.i_0n_dot*Pi;    %轨道倾角变化率
%         Cis = eph.Cis_n;
%         Cic = eph.Cic_n;
%         Crs = eph.Crs_n;
%         Crc = eph.Crc_n;
%         Cus = eph.Cus_n;
%         Cuc = eph.Cuc_n;
%         
%         t_oc = eph.t_oc;
%         a_f0 = eph.a_f0n;
%         a_f1 = eph.a_f1n;
%         a_f2 = eph.a_f2n;
%         
%         naviType = 2;
    %>>>>>>>>>>暂时屏蔽CNAV电文<<<<<<<<<^          
    if (ephemeris1.ephReady)
        eph = ephemeris1.eph;
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
        toc=eph.toc;
        a0=eph.af0;
        a1=eph.af1;
        a2=eph.af2;
        TGD1=0; %双频无此需校正项!
            
        naviType = 1;
    end
end

%% 利用NAV电文解算
if (naviType == 1)
    A=sqrtA^2; %计算半长轴
    %% find initial satellite clock correction
    %修正发射时间
    dt = check_t(transmitTime-toc);
    % dt = check_t(transmitTime-toc);
    %计算卫星测距码相位时间偏差
    satClkCorr(1) = a0+(a1+a2*dt)*dt-TGD1;
    %计算信号发射时刻系统时间
    time = transmitTime - satClkCorr(1);
    %% find sat position
    %时间校正
    tk  = check_t(time - toe);
    %计算卫星平均角速度
    n0=(GM/A^3)^0.5;
    %改正平均角速度
    n=n0+deltan;
    %计算平近点角
    M=M0+n*tk;
    M   = rem(M + 2*Pi, 2*Pi);
    
    %迭代计算偏近点角,超越方程
    E=M;
    %--- Iteratively compute eccentric anomaly ----------------------------
    for ii = 1:10
        Eold   = E;
        E       = M + e * sin(E);
        dE      = rem(E - Eold, 2*Pi);
        
        if abs(dE) < 1.e-12
            % Necessary precision is reached, exit from the loop
            break;
        end
    end
    
    E   = rem(E + 2*Pi, 2*Pi);
    %M_k=E-e*sin(E);
    %时间修正
    %相对论修正项
    dtr = F*e*sqrtA * sin(E);
    %总时间修正项
    %%%%%%%%%%%进行一次反馈再次计算%%%%%%%%%%
    satClkCorr(1)=a0+(a1+a2*dt)*dt+dtr-TGD1;
    time = transmitTime - satClkCorr(1);
    %时间校正
    tk  = check_t(time - toe);
    %计算卫星平均角速度
    n0=(GM/A^3)^0.5;
    %计算观测历元到参考历元的时间差
    %t_k=t-toe;%t?
    %改正平均角速度
    n=n0+deltan;
    %计算平近点角
    M=M0+n*tk;
    M   = rem(M + 2*Pi, 2*Pi);
    
    E=M;
    %--- Iteratively compute eccentric anomaly ----------------------------
    for ii = 1:10
        Eold   = E;
        E       = M + e * sin(E);
        dE      = rem(E - Eold, 2*Pi);
        
        if abs(dE) < 1.e-12
            % Necessary precision is reached, exit from the loop
            break;
        end
    end
    
    E   = rem(E + 2*Pi, 2*Pi);
    
    v_k   = atan2(sqrt(1 - e^2) * sin(E), cos(E)-e);
    %计算纬度幅角参数
    phi_k=v_k+omega;
    %Reduce phi to between 0 and 360 deg
    phi_k = rem(phi_k, 2*Pi);
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
    OMEGA_k=omega0+(omega_dot-Omega_e_dot)*tk-Omega_e_dot*toe;
    X_k=x_k.*cos(OMEGA_k)-y_k.*cos(i_k).*sin(OMEGA_k);
    Y_k=x_k.*sin(OMEGA_k)+y_k.*cos(i_k).*cos(OMEGA_k);
    Z_k=y_k.*sin(i_k);
    position = [X_k;Y_k;Z_k];
    % % end
    %%
    satPos(1) = position(1);
    satPos(2) = position(2);
    satPos(3) = position(3);
    
    %% calculate velocity of NGEO satellite
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
    OMEGA_k1 = omega_dot-Omega_e_dot;
    %5.计算x_k1,y_k1
    x_k1 = r_k1*cos(u_k) - r_k*u_k1*sin(u_k);
    y_k1 = r_k1*sin(u_k) + r_k*u_k1*cos(u_k);
    %6.计算X_k1,Y_k1,Z_k1即vx,vy,vz
    X_k1 = -Y_k*OMEGA_k1-(y_k1*cos(i_k)-Z_k*i_k1)*sin(OMEGA_k)+x_k1*cos(OMEGA_k);
    Y_k1 = X_k*OMEGA_k1+(y_k1*cos(i_k)-Z_k*i_k1)*cos(OMEGA_k)+x_k1*sin(OMEGA_k);
    Z_k1 = y_k1*sin(i_k) + y_k*i_k1*cos(i_k);
    %==============finish calculate velocity==========================
    satPos(4) = X_k1;
    satPos(5) = Y_k1;
    satPos(6) = Z_k1;
    
    %%
    %表达式中，t是信号发射时刻的BD-2系统时间，也就是对传播时间修正后的BD-2系统接收时间（距离/光速）。
    %因此，t_k就是BD-2系统时间t和星历参考时间toe之间的总时间差，并考虑了跨过一周开始或结束的时间，
    %也就是：如果t_k>302400时，就从t_k中减去604800；而如果t_k<-302400时，就对t_k中加上604800
    %satposition(satNr)=[X_GK;Y_GK;Z_GK];
    dtr = F*e*sqrtA * sin(E);
    satClkCorr(1)=a0+(a1+a2*dt)*dt+dtr-TGD1;
    dtr_dot = F*e*sqrtA * E1 * cos(E);
    satClkCorr(2) = a1 + 2*a2*dt + dtr_dot;
end %EOF: if (naviType == 1)

%% 利用CNAV电文解算
if (naviType == 2)
    %% 钟差预估
    dt = check_t(transmitTime - t_oc);  %时间差值估计
    satClkCorr(1) = a_f0 + a_f1*dt + a_f2*dt^2; %钟差估计（无相对论校正项）
    t_k = check_t(transmitTime - t_oe - satClkCorr(1)); %星历时间差值估计
    
    A_0 = A_ref + Delta_A;   %参考时间的半长轴
    A_k = A_0 + A_dot * t_k; %当前半长轴
    n0 = sqrt(miu/A_0^3);    %参考时间平均角速度
    n_A = n0 + Delta_n0 + 0.5*Delta_n0_dot*t_k;  %修正角速度
    
    M_k = M_0 + n_A*t_k;  %平近点角 
    %迭代计算偏近点角
    E_k=M_k;
    for ii = 1:10
        Eold    = E_k;
        E_k     = M_k + e * sin(E_k);
        dE      = rem(E_k - Eold, 2*Pi);       
        if abs(dE) < 1e-12
            % Necessary precision is reached, exit from the loop
            break;
        end
    end
    
    %% 计算相对论时钟校正项，根据相对论时钟校正值，重新给出相关参数
    dtr = F*e*sqrt(A_k) * sin(E_k);
    
    satClkCorr(1) = a_f0 + a_f1*dt + a_f2*dt^2 + dtr;
    t_k = check_t(transmitTime - t_oe - satClkCorr(1));
    A_k = A_0 + A_dot * t_k; %当前半长轴
    n_A = n0 + Delta_n0 + 0.5*Delta_n0_dot*t_k;  %修正角速度
    M_k = M_0 + n_A*t_k;  %平近点角 
    %迭代计算偏近点角
    for ii = 1:10
        Eold    = E_k;
        E_k     = M_k + e * sin(E_k);
        dE      = rem(E_k - Eold, 2*Pi);       
        if abs(dE) < 1e-12
            % Necessary precision is reached, exit from the loop
            break;
        end
    end
    
    %% 计算卫星位置
    %计算真近点角
    v_k = atan2( sqrt(1-e^2)*sin(E_k), cos(E_k)-e );
    
    Phi_k = v_k + omega_n;
    %计算二次谐波扰动项，包括纬度幅角改正项、径向改正项、轨道倾角改正项
    delta_u_k = Cus*sin(2*Phi_k) + Cuc*cos(2*Phi_k);
    delta_r_k = Crs*sin(2*Phi_k) + Crc*cos(2*Phi_k);
    delta_i_k = Cis*sin(2*Phi_k) + Cic*cos(2*Phi_k);
    %计算改正后的纬度参数、径向、倾角
    u_k = Phi_k+delta_u_k;
    r_k = A_k*(1-e*cos(E_k))+delta_r_k;
    i_k = i_0 + i_0_dot*t_k + delta_i_k;
    %计算卫星在轨道平面内的坐标
    x_k = r_k*cos(u_k);
    y_k = r_k*sin(u_k);
    %计算历元升交点的经度（地固系），计算MEO/IGSO卫星在CGS2000坐标系中的坐标
    Omega_k = Omega_0 + (Omega_dot_ref + Delta_Omega_dot - Omega_e_dot)*t_k - Omega_e_dot*t_oe;
    X_k = x_k*cos(Omega_k) - y_k*cos(i_k)*sin(Omega_k);
    Y_k = x_k*sin(Omega_k) + y_k*cos(i_k)*cos(Omega_k);
    Z_k = y_k*sin(i_k);
    
    satPos(1:3) = [X_k;Y_k;Z_k];
    
    %% 计算卫星速度
    %1. E_k一阶导数
    E_k1 = n_A/(1-e*cos(E_k));
    %2. Phi_k一阶导数
    Phi_k1 = sqrt(1-e^2)*E_k1/(1-e*cos(E_k));  
    %3. delta_u_k，delta_r_k，delta_i_k一阶导数
    delta_u_k1 = 2*Phi_k1*(Cus*cos(2*Phi_k1)-Cuc*sin(2*Phi_k1));
    delta_r_k1 = 2*Phi_k1*(Crs*cos(2*Phi_k1)-Crc*sin(2*Phi_k1));
    delta_i_k1 = 2*Phi_k1*(Cis*cos(2*Phi_k1)-Cic*sin(2*Phi_k1));
    %4. u_k,r_k,i_k,Omega_k 一阶导数
    u_k1 = Phi_k1 + delta_u_k1;
    r_k1 = A_k*e*E_k1*sin(E_k) + delta_r_k1;
    i_k1 = i_0_dot + delta_i_k1;
    Omega_k1 = Omega_dot_ref + Delta_Omega_dot - Omega_e_dot;
    %5. x_k, y_k的导数
    x_k1 = r_k1*cos(u_k) - r_k*u_k1*sin(u_k);
    y_k1 = r_k1*sin(u_k) + r_k*u_k1*cos(u_k);
    %6.计算X_k1,Y_k1,Z_k1即vx,vy,vz
    X_k1 = -Y_k*Omega_k1 - (y_k1*cos(i_k)-Z_k*i_k1)*sin(Omega_k) + x_k1*cos(Omega_k);
    Y_k1 = X_k*Omega_k1 + (y_k1*cos(i_k)-Z_k*i_k1)*cos(Omega_k) + x_k1*sin(Omega_k);
    Z_k1 = y_k1*sin(i_k) + y_k*i_k1*cos(i_k);
    
    satPos(4:6) = [X_k1;Y_k1;Z_k1];
    
    %% 计算频率漂移
    dtr_dot = F*e*sqrt(A_k)*E_k1*cos(E_k); %虽然CNAV中给出A的导数，但其相比第一项很小，可忽略
    satClkCorr(2) = a_f1 + 2*a_f2*dt + dtr_dot;  
    
end %EOF:  if (naviType == 2)