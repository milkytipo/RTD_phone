function [posvel, el, az, dop, raimG, raimB,prError,pvtCalculator] = ...
    leastSquarePos_GPS(satpos, obs, Beijing_Time,ephemeris,activeChannel, elevationMask,satClkCorr,pvtCalculator,posiChannel,recv_time)%freqforcal, settings)
%Function calculates the Least Square Solution.
%
%[pos, el, az, dop] = leastSquarePos(satpos, obs, settings);
%
%   Inputs:
%       satpos      - Satellites positions (in ECEF system: [X; Y; Z;] -
%                   one column per satellite)
%       obs         - Observations - the pseudorange measurements to each
%                   satellite:
%                   (e.g. [20000000 21000000 .... .... .... .... ....])
%       settings    - receiver settings
%        time        -transmit time
%       channelList   -activechannel
%   Outputs:
%       pos         - receiver position and receiver clock error
%                   (in ECEF system: [X, Y, Z, dt])
%       el          - Satellites elevation angles (degrees)
%       az          - Satellites azimuth angles (degrees)
%       dop         - Dilutions Of Precision ([GDOP PDOP HDOP VDOP TDOP])

%--------------------------------------------------------------------------
%                           SoftGNSS v3.0
%--------------------------------------------------------------------------
%Based on Kai Borre
%Copyright (c) by Kai Borre
%Updated by Darius Plausinaitis, Peter Rinder and Nicolaj Bertelsen
%
% CVS record:
% $Id: leastSquarePos.m,v 1.1.2.12 2006/08/22 13:45:59 dpl Exp $
%==========================================================================

%=== Initialization =======================================================
nmbOfIterations = 11;
dop     = zeros(1, 5);
dtr     = pi/180;
pos     = zeros(4, 1);
% pos = [-2605249.211205  4743124.060174  3364584.183359 -2.098158367372609e+06]'; %for test
vel = zeros(4,1); %calculate velocity and ddt
sat_xyz = satpos(1:3,:);
satVel = satpos(4:6,:);
nmbOfSatellites = size(activeChannel, 2);
Rot_X   = zeros(3,35);%%经过地球自转修正后的卫星位置
A       = zeros(size(posiChannel,2), 4);
raimG = zeros(size(posiChannel,2), 4);  % raim 算法中使用
omc     = zeros(size(posiChannel,2), 1);
raimB = zeros(size(posiChannel,2), 1);    % raim 算法中使用
az.GPS      = zeros(3, nmbOfSatellites);
el.GPS      = az.GPS;
az.GPS(2,:)=activeChannel(2,:);    %令计算后的数值与卫星的prn号相对应
el.GPS(2,:)=activeChannel(2,:);
az.GPS(3,:)=activeChannel(1,:);    
el.GPS(3,:)=activeChannel(1,:);
az.BDS = [];
el.BDS = [];
prError = [];
elUse = [];     % 使用卫星的仰角
%satUsed = activeChannel(2,:);  % 参与位置与速度解算的卫星号
%---
T_amb = 20;%20
P_amb = 101.325; %KPa
P_vap = .849179;%.86; 0.61078*(H/100)*exp(T/(T+238.3)*17.2694) KPa
posvel = zeros(1, 10);

%---
if length(activeChannel(1,:)) >= 4
    %=== Iteratively find receiver position ===================================
    for iter = 1:nmbOfIterations
        useNum = 0;     % 使用卫星的数目//每次迭代需要清零
        for i = 1:nmbOfSatellites
            if ephemeris(activeChannel(2,i)).eph.Alpha0 == 'N'
                Alpha_i = [2.186179e-008,-9.73869e-008,7.03774e-008,3.031505e-008];
                Beta_i = [ 129643.8, -64245.75, -866336.2,1612913];
            else
                Alpha_i =[ephemeris(activeChannel(2,i)).eph.Alpha0,ephemeris(activeChannel(2,i)).eph.Alpha1, ...
                   ephemeris(activeChannel(2,i)).eph.Alpha2,ephemeris(activeChannel(2,i)).eph.Alpha3];
                Beta_i =[ephemeris(activeChannel(2,i)).eph.Beta0,ephemeris(activeChannel(2,i)).eph.Beta1, ...
                    ephemeris(activeChannel(2,i)).eph.Beta2,ephemeris(activeChannel(2,i)).eph.Beta3];
            end        
            if iter == 1
                %--- Initialize variables at the first iteration --------------
                Rot_X(:, activeChannel(2,i)) = sat_xyz(:, activeChannel(2,i));%卫星i的位置
                trop = 2;%电离层与对流层的延时
            else
                %--- Update equations -----------------------------------------
                rho2 = (Rot_X(1, activeChannel(2,i)) - pos(1))^2 + (Rot_X(2, activeChannel(2,i)) - pos(2))^2 + ...
                    (Rot_X(3, activeChannel(2,i)) - pos(3))^2;%卫星i的伪距平方
                traveltime = sqrt(rho2) / 299792458;

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
                if iter>=4
%                 %--- Calculate tropospheric correction --------------------
                     trop1 = Tropospheric(T_amb,P_amb,P_vap,el.GPS(1,i));
                     trop2 =Ionospheric_GPS(Lat,Lon,el.GPS(1,i),az.GPS(1,i),Alpha_i,Beta_i,Beijing_Time(activeChannel(2,i)));

                     trop = trop1 + trop2;
                     wucha(i,1)=trop1;
                     wucha(i,2)=trop2;

                end % if iter >=6 , ... ... correct atmesphere
                %-
            end % if iter == 1 ... ... else
            if ismember(activeChannel(2,i), posiChannel(2,:))
                useNum = useNum + 1;
                elUse(useNum) = el.GPS(1,i);
                %--- Apply the corrections ----------------------------------------
                omc(useNum) = (obs(activeChannel(2,i)) - norm(Rot_X(:, activeChannel(2,i)) - pos(1:3), 'fro') - pos(4) - trop);
        %         accP(i)= (obs(activeChannel(2,i))- trop);

                %--- Construct the A matrix ---------------------------------------
                A(useNum, :) =  [ (-(Rot_X(1, activeChannel(2,i)) - pos(1))) / norm(Rot_X(:, activeChannel(2,i)) - pos(1:3), 'fro') ...
                    (-(Rot_X(2, activeChannel(2,i)) - pos(2))) / norm(Rot_X(:, activeChannel(2,i)) - pos(1:3), 'fro') ...
                    (-(Rot_X(3, activeChannel(2,i)) - pos(3))) / norm(Rot_X(:, activeChannel(2,i)) - pos(1:3), 'fro') ...
                    1 ];
            end
        end % for i = 1:nmbOfSatellites
        if iter == nmbOfIterations
            raimG = A;
            raimB = omc;
        end
        if iter >=6
            satUsed = posiChannel(2,:);  % 参与位置与速度解算的卫星号
            bEsti = omc - A/(A'*A)*A'*omc;    % 残余分量
            WSSE = (norm(bEsti))^2;         % 误差检测值
            if WSSE < chi2inv(0.99999, size(A,1)-4)     % 如果判断有错误卫星，则不经进行仰角判断
                for j= useNum:-1:1  %去除仰角低于elevationMask的卫星
                     if elUse(j) < elevationMask            
                         if size(A,1) >= 4
                             omc(j)=[];
                             A(j,:)=[];
                             satUsed(j)=[];
                         end
                     end
                end
            end
        end
        % These lines allow the code to exit gracefully in case of any errors
        if rank(A) ~= 4  
            posvel = zeros(1, 10);
            return
        end

        %--- Find position update ---------------------------------------------
        x   = A \ omc;

        %--- Apply position update --------------------------------------------
        pos = pos + x;

    end % for iter = 1:nmbOfIterations
    % fprintf('Satellite pos(自转矫正) -- %.6f \n', Rot_X);
    % fprintf('accP -- %.6f \n',accP);
    % fprintf('wucha -- %.6f \n',wucha);
    % fprintf('az -- %.6f \n',az);
    % fprintf('el -- %.6f \n',el);
    pos = pos';
    %calculate velocity from carrier frequency
    bVel = zeros(length(satUsed), 1);
    for k = 1:length(satUsed)
        if pvtCalculator.GPS.doppSmooth(satUsed(k), 2) ~= 0 
            deltaP = pvtCalculator.GPS.doppSmooth(satUsed(k),1) - pvtCalculator.GPS.doppSmooth(satUsed(k),2);   %积分多普勒一秒的变化量（m）
        else
            deltaP = -299792458/1575420000*pvtCalculator.GPS.doppSmooth(satUsed(k),4);    % 多普勒频移（m）
        end
        bVel(k) = [ (-(Rot_X(1, satUsed(k)) - pos(1))) / norm(Rot_X(:, satUsed(k)) - pos(1:3)', 'fro') ...
                (-(Rot_X(2, satUsed(k)) - pos(2))) / norm(Rot_X(:, satUsed(k)) - pos(1:3)', 'fro') ...
                (-(Rot_X(3, satUsed(k)) - pos(3))) / norm(Rot_X(:, satUsed(k)) - pos(1:3)', 'fro')]*satVel(:,satUsed(k))...
                + deltaP + 299792458*satClkCorr(satUsed(k));
    end
    vel = A \ bVel;     % 计算速度
    pos(4)=pos(4)/299792458;
    posvel=[pos,0,vel',0];
    
     %——————————————计算伪距与上次定位结果的残差——————————————%
    for k = 1 : size(posiChannel, 2)
        timeDiff = recv_time.recvSOW - pvtCalculator.timeLast;
        posiFore = pvtCalculator.posiLast(1:3);% + pvtCalculator.posiLast(6:8) * timeDiff;        % 假设为匀速运动，从而对当前位置作出估计
        rho2 = (sat_xyz(1, posiChannel(2,k)) - posiFore(1))^2 + (sat_xyz(2, posiChannel(2,k)) - posiFore(2))^2 + ...
                    (sat_xyz(3, posiChannel(2,k)) - posiFore(3))^2;%卫星i的伪距平方
        traveltime = sqrt(rho2) / 299792458 ;
        %--- Correct satellite position (do to earth rotation) --------
        Rot_X(:, posiChannel(2,k)) = e_r_corr(traveltime, sat_xyz(:, posiChannel(2,k)));%卫星i经过地球自转修正后的位置
        prError(k) = (obs(posiChannel(2,k)) - norm(Rot_X(:, posiChannel(2,k)) - posiFore(1:3), 'fro') - pvtCalculator.posiLast(4)*299792458 - trop);
    end 
    clcErrFore = median(prError);    % 预估出接收机的钟差值
    prError = prError - clcErrFore;   % 去除钟差值
    %——————————————若本次定位结果正确，则记录本次定位结果————————%
    bEsti = omc - A/(A'*A)*A'*omc;    % 残余分量
    WSSE = (norm(bEsti))^2;         % 误差检测值
    if size(A,1) > 4    % 则定位方程为超定方程
        if WSSE < chi2inv(0.99999, size(A,1)-4)     % 判断定位结果是否正确
            pvtCalculator.posiLast = posvel';    % 若正确，记录定位结果
            pvtCalculator.posiTag = 1;  % 位置信息已更新
            pvtCalculator.posiCheck = 1;    % 认为定位结果可信
        end
    else
        if pvtCalculator.posiLast(1)~=0 && pvtCalculator.posiCheck==1
            posiDistance = sqrt((pvtCalculator.posiLast(1) - posvel(1))^2+(pvtCalculator.posiLast(2) - posvel(2))^2+(pvtCalculator.posiLast(3) - posvel(3))^2);
            if posiDistance < 100   % 两次定位误差小于100m
                pvtCalculator.posiLast = posvel';    % 记录定位结果
                pvtCalculator.posiTag = 1;  % 位置信息已更新
                pvtCalculator.posiCheck = 1;    % 认为定位结果可信
            else
                pvtCalculator.posiLast = posvel';    % 记录定位结果
                pvtCalculator.posiTag = 1;  % 位置信息已更新
                pvtCalculator.posiCheck = 0;    % 认为定位结果不确定
            end
        else
            pvtCalculator.posiLast = posvel';    % 记录定位结果
            pvtCalculator.posiTag = 1;  % 位置信息已更新
            pvtCalculator.posiCheck = 0;    % 认为定位结果不确定
        end
    end
    %=== Calculate Dilution Of Precision ======================================
    % if nargout  == 4
        %--- Initialize output ------------------------------------------------


        %--- Calculate DOP ----------------------------------------------------
        Q       = inv(A'*A);

        dop(1)  = sqrt(trace(Q));                       % GDOP
        dop(2)  = sqrt(Q(1,1) + Q(2,2) + Q(3,3));       % PDOP
        dop(3)  = sqrt(Q(1,1) + Q(2,2));                % HDOP
        dop(4)  = sqrt(Q(3,3));                         % VDOP
        dop(5)  = sqrt(Q(4,4));                         % TDOP
    %     fprintf('dop -- %.6f \n',dop);
end
end
