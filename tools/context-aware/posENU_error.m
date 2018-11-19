function [parameter] = posENU_error(parameter, calibration, fileType)

for i = 1 : parameter.length
    if fileType==1 || fileType==2
        [~, col] = ismember(parameter.SOW(1, i), calibration.SOW(1,:));
        parameter.ENU_error(1:3, i) = xyz2enu(parameter.pos_xyz(:, i), calibration.pos_xyz(:, col));
    else
        parameter.ENU_error(1:3, i) = xyz2enu(parameter.pos_xyz(:, i), calibration.pos_xyz(:, 1)); % 静态数据对比结果
    end
    theata = parameter.vel_angle(i) / 360 * 2 * pi;
    % ———————————— 总误差 ——————————————%
    parameter.ENU_error(4, i) = norm(parameter.ENU_error(1:3, i));
    % ———————————— 平行于航向上的误差 ——————————————%
    vect_1 = parameter.ENU_error(1:2, i);
    vect_2 = [sin(theata); cos(theata)];
    parameter.ENU_error(5, i) = abs(dot(vect_1, vect_2));
    % ———————————— 正交于航向上的误差 ——————————————%
    vect_1 = [parameter.ENU_error(1:2, i); 0]; % 向量积必须是三维的
    vect_2 = [sin(theata); cos(theata); 0];
    parameter.ENU_error(6, i) = norm(cross(vect_1, vect_2));
    % ———————————— 平行减正交 ——————————————%
    parameter.ENU_error(7, i) = parameter.ENU_error(5, i) - parameter.ENU_error(6, i);
end