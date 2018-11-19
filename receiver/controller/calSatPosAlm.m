%% This function is used to calculate satellite's positions during warm start through almanac info.
function [sat_position] = calSatPosAlm(SYST, refTime, alm, prnNum)

% Initial
OMEGA_dot = 7.292115e-5; % CGS2000坐标系下的地球旋转速率(rad/s)
GM = 3.986004418e14; % CGS2000坐标系下的地球引力常数(m^3/s^2)
pi = 3.1415926535898;
% F = -4.442807633e-10; % Constant, [sec/(meter)^(1/2)]


sat_position = zeros(6, 1);

toa = alm.toa; % 星历参考时间
sqrtA = alm.sqrtA; % 长半轴的平方根
e = alm.e; % 偏心率
omega = alm.omega; % 近地点幅角
deltai = alm.deltai; % 参考时间的轨道参考倾角的改正量
M0 = alm.M0; % 参考时间的平近点角
omega0 = alm.omega0; % 按参考时间计算的升交点经度
omegaDot = alm.omegaDot; % OMEGA_DOT%升交点经度变化率
switch SYST
    case 'BDS_B1I'
        if prnNum > 5
            i0 = 0.3 * pi; % 参考时间的轨道倾角
        else
            i0 = 0;
        end
    case 'GPS_L1CA'
        i0 = 0.3 * pi;
end

% Find sat position
A = sqrtA ^ 2; % 计算半长轴
tk = check_t(refTime - toa); % 时间校正
n = (GM / A ^ 3) ^ 0.5; % 计算卫星平均角速度

M = M0 + n * tk;
M = rem(M + 2 * pi, 2 * pi);

E = M;
% Iteratively compute eccentric anomaly
for ii = 1:10
    Eold = E;
    E = M + e * sin(E);
    dE = rem(E - Eold, 2 * pi);

    if abs(dE) < 1.e-12
        % Necessary precision is reached, exit from the loop
        break;
    end
end

E = rem(E + 2 * pi, 2 * pi);

v_k = atan2(sqrt(1 - e ^ 2) * sin(E), cos(E) - e);
% 计算纬度幅角参数
phi_k = v_k + omega;
% Reduce phi to between 0 and 360 deg
phi_k = rem(phi_k, 2 * pi);


% 计算改正后的径向
r_k = A * (1 - e * cos(E));

% 计算卫星在轨道平面内的坐标
x_k = r_k .* cos(phi_k);
y_k = r_k .* sin(phi_k);

% 计算历元升交点的经度（地固系），计算MEO/IGSO卫星在CGS2000坐标系中的坐标
OMEGA_k = omega0 + (omegaDot - OMEGA_dot) * tk - OMEGA_dot * toa;
%     i_k = i0 + deltai;
i_k = deltai + i0;
X_k = x_k .* cos(OMEGA_k) - y_k .* cos(i_k) .* sin(OMEGA_k);
Y_k = x_k .* sin(OMEGA_k) + y_k .* cos(i_k) .* cos(OMEGA_k);
Z_k = y_k .* sin(i_k);
sat_position(1:3) = [X_k; Y_k; Z_k];

switch SYST
    case 'BDS_B1I'
        if prnNum > 5
            % Start calculate velocity
            % 1.计算E的倒数,倒数全采用下标1表示，E1
            E1 = n/(1-e*cos(E));
            % 2.计算phi_k的倒数phi_k1，phi_k1=v_k1
            phi_k1 = sqrt(1-e*e)*E1/(1-e*cos(E));
            % 3.计算delta_u_k1，delta_r_k1，delta_i_k1
            % delta_u_k1 = 2*phi_k1*(Cus*cos(2*phi_k)-Cuc*sin(2*phi_k));
            % delta_r_k1 = 2*phi_k1*(Crs*cos(2*phi_k)-Crc*sin(2*phi_k));
            % delta_i_k1 = 2*phi_k1*(Cis*cos(2*phi_k)-Cic*sin(2*phi_k));
            % 4.计算u_k1, r_k1, i_k1, OMEGA_k1
            u_k1 = phi_k1 ;
            r_k1 = A*e*E1*sin(E) ;
            i_k1 = 0;
            OMEGA_k1 = omegaDot-OMEGA_dot;
            % 5.计算x_k1, y_k1
            x_k1 = r_k1*cos(phi_k) - r_k*u_k1*sin(phi_k);
            y_k1 = r_k1*sin(phi_k) + r_k*u_k1*cos(phi_k);
            % 6.计算X_k1, Y_k1, Z_k1即vx, vy, vz
            X_k1 = -Y_k*OMEGA_k1-(y_k1*cos(i_k)-Z_k*i_k1)*sin(OMEGA_k)+x_k1*cos(OMEGA_k);
            Y_k1 = X_k*OMEGA_k1+(y_k1*cos(i_k)-Z_k*i_k1)*cos(OMEGA_k)+x_k1*sin(OMEGA_k);
            Z_k1 = y_k1*sin(i_k) + y_k*i_k1*cos(i_k);
            sat_position(4:6) = [X_k1; Y_k1; Z_k1];
%         [az, el, dist] = topocent(refPos, sat_position -refPos);
        else
            sat_position(4:6) = [0; 0; 0]; % GEO satellite
        end

    case 'GPS_L1CA'
        % Start calculate velocity
        % 1.计算E的倒数,倒数全采用下标1表示，E1
        E1 = n/(1-e*cos(E));
        % 2.计算phi_k的倒数phi_k1，phi_k1=v_k1
        phi_k1 = sqrt(1-e*e)*E1/(1-e*cos(E));
        % 3.计算delta_u_k1，delta_r_k1，delta_i_k1
        % delta_u_k1 = 2*phi_k1*(Cus*cos(2*phi_k)-Cuc*sin(2*phi_k));
        % delta_r_k1 = 2*phi_k1*(Crs*cos(2*phi_k)-Crc*sin(2*phi_k));
        % delta_i_k1 = 2*phi_k1*(Cis*cos(2*phi_k)-Cic*sin(2*phi_k));
        % 4.计算u_k1, r_k1, i_k1, OMEGA_k1
        u_k1 = phi_k1 ;
        r_k1 = A*e*E1*sin(E) ;
        i_k1 = 0;
        OMEGA_k1 = omegaDot-OMEGA_dot;
        % 5.计算x_k1, y_k1
        x_k1 = r_k1*cos(phi_k) - r_k*u_k1*sin(phi_k);
        y_k1 = r_k1*sin(phi_k) + r_k*u_k1*cos(phi_k);
        % 6.计算X_k1, Y_k1, Z_k1即vx, vy, vz
        X_k1 = -Y_k*OMEGA_k1-(y_k1*cos(i_k)-Z_k*i_k1)*sin(OMEGA_k)+x_k1*cos(OMEGA_k);
        Y_k1 = X_k*OMEGA_k1+(y_k1*cos(i_k)-Z_k*i_k1)*cos(OMEGA_k)+x_k1*sin(OMEGA_k);
        Z_k1 = y_k1*sin(i_k) + y_k*i_k1*cos(i_k);
        sat_position(4:6) = [X_k1; Y_k1; Z_k1];

%             [~, el(prnNum), ~] = topocent(refPos, sat_position -refPos);
end



end