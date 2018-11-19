function [iono, pvtCalculator] = Ionospheric_GPS_L1L2( ... 
    pvtCalculator, iono, el, L2toL1_delay, ISC, chN, prnList_L1L2)
%校正公式 ： rho0 = rho1 - iono;
%iono = ( L2toL1_delay - L2toL1_devDelay + c*(ISC_L2C - gamma*ISC_L1CA) )/(gamma-1) + c*T_GD;
%或者 iono = c*(T_GD-ISC_L1CA) + M(theta)*VTEC_L1;

%输出 iono: 电离层延时、卫星和接收机设备延时总校正值（相对与L1伪距）
%    pvtCalculator: 给出L1频点的垂直电离层延时和设备频间延时的估计值

%输入：
%    pvtCalculator： 用到接收机设备时延的历史值以平滑
%    el:卫星仰角 1*32 (degree)
%    L2toL1_delay: 跟踪环路得到的频间总延时 1*32
%    ISC： 包含计算卫星设备时延所需的导航电文 1*32 struct
%    chN： 双频通道数量
%    prnList_L1L2: 双频卫星prn列表 1*32，chN

c = 299792458;
gamma = (77/60)^2;

if (chN==1)
    prn = prnList_L1L2(1);
    iono(prn) = ( L2toL1_delay(prn) - pvtCalculator.L2toL1_devDelay + c*ISC(prn).ISC_L2C - ...
        c*gamma*ISC(prn).ISC_L1CA )/(gamma-1) + c*ISC(prn).T_GD;
elseif (chN>1) %计算最小二乘解
    A = zeros(chN,2);
    b = zeros(chN,1);
    M = zeros(chN,1);
    A(:,1) = 1;
    for i=1:chN
        prn = prnList_L1L2(i);
        theta = el(prn)/180;
        M(i) = 1+16*(0.53-theta)^3;
        A(i,2) = (gamma-1)*M(i);
        b(i) = L2toL1_delay(prn) + c*( ISC(prn).ISC_L2C-ISC(prn).ISC_L1CA );     
    end
    x=(A.'*A)\A.'*b;
    
    %对设备延时和电离层估计量进行滤波平滑
    if (pvtCalculator.L2toL1_devDelay~=0)
        pvtCalculator.L2toL1_devDelay = 0.5*pvtCalculator.L2toL1_devDelay + 0.5*x(1);
    else
        pvtCalculator.L2toL1_devDelay = x(1);
    end
    
    if (pvtCalculator.VTEC_L1~=0)
        pvtCalculator.VTEC_L1 = 0.5*pvtCalculator.VTEC_L1 + 0.5*x(2);
    else
        pvtCalculator.VTEC_L1 = x(2);
    end
    
    %计算校正量
    for i=1:chN
        prn = prnList_L1L2(i);
        iono(prn) = c*(ISC(prn).T_GD-ISC(prn).ISC_L1CA) + M(i)*pvtCalculator.VTEC_L1;
    end

end
    