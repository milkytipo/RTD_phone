function [posvel,el,az,dop,pvtCalculator] = kalmanPosi_GPS(satpos, obs,Beijing_Time,ephemeris,activeChannel, ...
    elevationMask,satClkCorr,pvtCalculator,posiChannel,recv_time)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%
%
%
%
%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T = 1;  % 观测间隔1s
%—————— Set Q————————%
Sf = 36;
Sg = 0.01;
sigma=5;         %state transition variance
Qb = [Sf*T+Sg*T*T*T/3, Sg*T*T/2; Sg*T*T/2, Sg*T];
Qxyz = sigma^2 * [T^3/3, T^2/2; T^2/2, T];
Q = blkdiag(Qxyz, Qxyz, Qxyz, Qb);
% ——————Set R————————%
Rhoerror = 36;                                               % variance of measurement error(pseudorange error)
R = eye(2*size(posiChannel,2)) * Rhoerror; 

X = pvtCalculator.kalman.state(1:8);     % 状态变量  N-by-1    单系统取前8位
P = pvtCalculator.kalman.P;         % 误差协方差矩阵
%———————————滤波更新————————%
%=== Initialization =======================================================
%nmbOfIterations = 11;
dop     = zeros(1, 5);
pos     = X([1,3,5,7]);
vel = zeros(4,1); %calculate velocity and ddt
sat_xyz = satpos(1:3,:);
satVel = satpos(4:6,:);
nmbOfSatellites = size(activeChannel, 2);
Rot_X   = zeros(3,30);%%经过地球自转修正后的卫星位置
%A       = zeros(size(posiChannel,2), 4);
%raimG = zeros(size(posiChannel,2), 4);  % raim 算法中使用
%omc     = zeros(size(posiChannel,2), 1);    
%raimB = zeros(size(posiChannel,2), 1);    % raim 算法中使用
az.GPS      = zeros(3, nmbOfSatellites);
el.GPS      = az.GPS;
az.GPS(2,:)=activeChannel(2,:);    %令计算后的数值与卫星的prn号相对应
el.GPS(2,:)=activeChannel(2,:);
az.GPS(3,:)=activeChannel(1,:);    %令计算后的数值与卫星的prn号相对应
el.GPS(3,:)=activeChannel(1,:);
az.BDS = [];
el.BDS = [];
%prError = [];   % 与上一时刻定位结果的伪距残差
elUse = [];     % 使用卫星的仰角
%---
T_amb = 20;%20
P_amb = 101.325; %KPa
P_vap = .849179;%.86; 0.61078*(H/100)*exp(T/(T+238.3)*17.2694) KPa
posvel = zeros(1, 10);

%if length(activeChannel(1,:))>=4 && checkNGEO==1
    %=== Iteratively find receiver position ===================================
%    for iter = 1:nmbOfIterations
useNum = 0;     % 使用卫星的数目//每次迭代需要清零
for i = 1:nmbOfSatellites         
    Alpha_i =[ephemeris(activeChannel(2,i)).eph.Alpha0,ephemeris(activeChannel(2,i)).eph.Alpha1, ...
            ephemeris(activeChannel(2,i)).eph.Alpha2,ephemeris(activeChannel(2,i)).eph.Alpha3];
    Beta_i =[ephemeris(activeChannel(2,i)).eph.Beta0,ephemeris(activeChannel(2,i)).eph.Beta1, ...
            ephemeris(activeChannel(2,i)).eph.Beta2,ephemeris(activeChannel(2,i)).eph.Beta3];        
    %--- Update equations -----------------------------------------
    rho2 = (sat_xyz(1, activeChannel(2,i)) - pos(1))^2 + (sat_xyz(2, activeChannel(2,i)) - pos(2))^2 + ...
        (sat_xyz(3, activeChannel(2,i)) - pos(3))^2;%卫星i的伪距平方
    traveltime = sqrt(rho2) / 299792458 ;

    %--- Correct satellite position (do to earth rotation) --------
    Rot_X(:, activeChannel(2,i)) = e_r_corr(traveltime, sat_xyz(:, activeChannel(2,i)));%卫星i经过地球自转修正后的位置

    %--- Find the elevation angle of the satellite ----------------
    [az.GPS(1,i), el.GPS(1,i), dist] = topocent(pos(1:3, :), Rot_X(:, activeChannel(2,i)) - pos(1:3, :));
    el.GPS(2,i) = activeChannel(2,i);
    az.GPS(2,i) = activeChannel(2,i);
    az.GPS(3,i) = activeChannel(1,i);   
    el.GPS(3,i) = activeChannel(1,i);
    %            ---find the longtitude and latitude of position CGCS2000---
    [ Lat, Lon, Hight ] = cart2geo( pos(1), pos(2), pos(3), 5 );
    %-
    trop1 = Tropospheric(T_amb,P_amb,P_vap,el.GPS(1,i));
    trop2 =Ionospheric_GPS(Lat,Lon,el.GPS(1,i),az.GPS(1,i),Alpha_i,Beta_i,Beijing_Time(activeChannel(2,i)));
    %trop2 =Ionospheric_GPS(Lat,Lon,el.GPS(1,i),az.GPS(1,i),Alpha_i,Beta_i,Beijing_Time(activeChannel(2,i)),Rot_X(:,activeChannel(2,i)));
    trop = trop1 + trop2;
    if ismember(activeChannel(2,i), posiChannel(2,:))
        if pvtCalculator.GPS.doppSmooth(activeChannel(2,i), 2) ~= 0 
            deltaP = pvtCalculator.GPS.doppSmooth(activeChannel(2,i),1) - pvtCalculator.GPS.doppSmooth(activeChannel(2,i),2);   %积分多普勒一秒的变化量（m）
        else
            deltaP = -299792458/1561098000*pvtCalculator.GPS.doppSmooth(activeChannel(2,i),4);    % 多普勒频移（m）
        end
        useNum = useNum + 1;
        obsKalman(2*useNum-1,1) = obs(activeChannel(2,i)) - trop;   % 卡尔曼滤波中的伪距观测值
        obsKalman(2*useNum,1) = [(-(Rot_X(1, activeChannel(2,i)) - pos(1))) / norm(Rot_X(:, activeChannel(2,i)) - pos(1:3), 'fro') ...
                                    (-(Rot_X(2, activeChannel(2,i)) - pos(2))) / norm(Rot_X(:, activeChannel(2,i)) - pos(1:3), 'fro') ...
                                    (-(Rot_X(3, activeChannel(2,i)) - pos(3))) / norm(Rot_X(:, activeChannel(2,i)) - pos(1:3), 'fro')]*satVel(:,activeChannel(2,i))...
                                    + deltaP + 299792458*satClkCorr(activeChannel(2,i)); % 卡尔曼滤波中的多普勒频移观测值
        satKalman(useNum,1:3) = Rot_X(:,activeChannel(2,i))';     % 卡尔曼滤波中的卫星位数     N-by-6
        satKalman(useNum,4:6) = satVel(:,activeChannel(2,i))';
        elUse(useNum) = el.GPS(1,i);
    end
end % for i = 1:nmbOfSatellites
        
       
% satUsed = posiChannel(2,:);  % 参与位置与速度解算的卫星号
% bEsti = omc - A/(A'*A)*A'*omc;    % 残余分量
% WSSE = (norm(bEsti))^2;         % 误差检测值
% if WSSE < chi2inv(0.99999, size(A,1)-4)     % 如果判断有错误卫星，则不经进行仰角判断
%     for j= useNum:-1:1  %去除仰角低于elevationMask的卫星
%          if elUse(j) < elevationMask            
%              if size(A,1) >= 4
%                  satUsed(j)=[];
%              end
%          end
%     end
% end
          
[X,P] = EKF(Q,R,obsKalman,X,P,satKalman,T,posiChannel);


%——————卡尔曼滤波结果状态赋值——————————%
pvtCalculator.kalman.state(1:8) = X;     % 状态变量  N-by-1
pvtCalculator.kalman.P = P;         % 协方差矩阵
pos = X([1,3,5,7]);
vel = X([2,4,6,8]);
posvel = [pos',0,vel',0];



