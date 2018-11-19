% 功能 : 根据星历和接收机坐标信息，计算各颗卫星的各种状态
% Input :   SOW : 数据的周内秒计数    matrix : [ 1 × N ]
%           fileNameBds : 北斗星历文件名
%           fileNameGps : GPS星历文件名
%           refPos  :  计算仰角、方位角的参考位置坐标     matrix : [ 3 × N ]

function [satPara, prnList] = satellite_status_cal(SOW, fileNameBds, fileNameGps, refPosVec)

[ephemeris_BDS, prn_list_BDS, updateTimes_BDS, isNorm_BDS, toe_matrix_BDS] = loadEphFromRINEX_C(fileNameBds);
[ephemeris_GPS, prn_list_GPS, updateTimes_GPS, isNorm_GPS, toe_matrix_GPS] = loadEphFromRINEX_C(fileNameGps);
% refPos = [-2851929.696633; 4653835.860388; 3288814.789700];
el_bound = 5; % 最低判别的仰角
% ——————————  个颗卫星的状态参数  ————————————%
Para = struct(...
    'satPos',   zeros(3, length(SOW)),...
    'satVel',   zeros(3, length(SOW)),...
    'vel_tan',   zeros(1, length(SOW)),...
    'El',       zeros(1, length(SOW)),...
    'Az',       zeros(1, length(SOW)),...
    'V_El',       zeros(1, length(SOW)),...
    'V_Az',       zeros(1, length(SOW)),...
    'V_El_Az',       zeros(1, length(SOW)),...
    'SOW',      zeros(1, length(SOW)),...
    'SYS',      ''...
    );
% ——————————  系统总体状态参数  ————————————%
sys = struct(...
    'prnVisible', zeros(32, length(SOW)),...  % 可见卫星的PRN号
    'prnVisNum', zeros(1, length(SOW)),...    % 可见卫星的数量 
    'GDOP', zeros(1, length(SOW)),...         % GDOP值
    'SYS',      ''...
    );

prnList.BDS =  prn_list_BDS;
prnList.GPS =  prn_list_GPS;

satPara.GPS.para(1:32) = Para;
satPara.BDS.para(1:14) = Para;

satPara.GPS.sys = sys;
satPara.BDS.sys = sys;

for i = 1 : length(SOW)
    time = SOW(i);
    refPos = refPosVec(:, i);
    G_mat = zeros(32, 4);
    %————————————————  计算GPS卫星状态  ————————————————%
    for prn = 1 : 32
        if any(prn_list_GPS == prn)
            line = prn_list_GPS == prn;
            timeErr = abs(toe_matrix_GPS(line, :) - time);
            [~, index] = min(timeErr);
            [satPositions, satClkCorr] = GPS_calculateSatPosition_extra(time, ephemeris_GPS(line, index), prn);
            vector_norm = (satPositions(1:3)-refPos) / norm(satPositions(1:3)-refPos);
            Len = norm(satPositions(1:3)-refPos);
            vel_parallel = (vector_norm'*satPositions(4:6));
            vel_Orth = sqrt((norm(satPositions(4:6)))^2 - vel_parallel^2);
            satPara.GPS.para(prn).vel_tan(i) = vel_Orth / Len;
            [az, el, dist] = topocent(refPos, satPositions(1:3)-refPos);
            satPara.GPS.para(prn).satPos(:,i) = satPositions(1:3);
            satPara.GPS.para(prn).satVel(:,i) = satPositions(4:6);
            satPara.GPS.para(prn).El(i) = el;
            satPara.GPS.para(prn).Az(i) = az;
            % 以仰角大于10度的卫星视为可见卫星
            if el >= el_bound 
                satPara.GPS.sys.prnVisNum(i) = satPara.GPS.sys.prnVisNum(i) + 1;
                satPara.GPS.sys.prnVisible(satPara.GPS.sys.prnVisNum(i), i) = prn;
                G_mat(satPara.GPS.sys.prnVisNum(i), :) = [-cos(el)*sin(az), ...
                        -cos(el)*cos(az), ...
                        -sin(el), 1];
            end
            % 计算仰角、方位角的变化率
            if i > 1
                satPara.GPS.para(prn).V_El(i) = el - satPara.GPS.para(prn).El(i-1);
                satPara.GPS.para(prn).V_Az(i) = az - satPara.GPS.para(prn).Az(i-1);
                if satPara.GPS.para(prn).V_Az(i)>180
                    satPara.GPS.para(prn).V_Az(i) = satPara.GPS.para(prn).V_Az(i) - 360;
                elseif satPara.GPS.para(prn).V_Az(i)<-180
                    satPara.GPS.para(prn).V_Az(i) = satPara.GPS.para(prn).V_Az(i) + 360;
                end
            else
                satPara.GPS.para(prn).V_El(i) = 0;
                satPara.GPS.para(prn).V_Az(i) = 0;
            end
            satPara.GPS.para(prn).V_El_Az(i) = sqrt((satPara.GPS.para(prn).V_El(i))^2 + (satPara.GPS.para(prn).V_Az(i))^2);
            satPara.GPS.para(prn).SOW(i) = time;
        end % if any(prn_list_BDS == prn)
    end % for prn = 1 : 32
    % —————————— 计算DOP值 ——————————————%
    if satPara.GPS.sys.prnVisNum(i) >= 4
        G_mat_valid = G_mat(1:satPara.GPS.sys.prnVisNum(i), :);
        H_mat =  inv(G_mat_valid' * G_mat_valid);
        satPara.GPS.sys.GDOP(i) = sqrt(H_mat(1,1)+H_mat(2,2)+H_mat(3,3)+H_mat(4,4));
        if satPara.GPS.sys.GDOP(i) > 10
            satPara.GPS.sys.GDOP(i) = 10;
        end
    else
        satPara.GPS.sys.GDOP(i) = 10;
    end
            
    %% ————————————————  计算北斗卫星状态  ————————————————%
    G_mat = zeros(32, 4);
    for prn = 1 : 14
        if any(prn_list_BDS == prn)
            line = prn_list_BDS == prn;
            timeErr = abs(toe_matrix_BDS(line, :) - time);
            [~, index] = min(timeErr);
            [satPositions, satClkCorr] = BD_calculateSatPosition_extra(time, ephemeris_BDS(line, index), prn);
            vector_norm = (satPositions(1:3)-refPos) / norm(satPositions(1:3)-refPos);
            Len = norm(satPositions(1:3)-refPos);
            vel_parallel = (vector_norm'*satPositions(4:6));
            vel_Orth = sqrt((norm(satPositions(4:6)))^2 - vel_parallel^2);
            satPara.BDS.para(prn).vel_tan(i) = vel_Orth / Len;
            [az, el, dist] = topocent(refPos, satPositions(1:3)-refPos);
            satPara.BDS.para(prn).satPos(:,i) = satPositions(1:3);
            satPara.BDS.para(prn).satVel(:,i) = satPositions(4:6);
            satPara.BDS.para(prn).El(i) = el;
            satPara.BDS.para(prn).Az(i) = az;
            % 以仰角大于3度的卫星视为可见卫星
            if el >= el_bound 
                satPara.BDS.sys.prnVisNum(i) = satPara.BDS.sys.prnVisNum(i) + 1;
                satPara.BDS.sys.prnVisible(satPara.BDS.sys.prnVisNum(i), i) = prn;
                G_mat(satPara.BDS.sys.prnVisNum(i), :) = [-cos(el)*sin(az), ...
                        -cos(el)*cos(az), ...
                        -sin(el), 1];
            end
            % 计算仰角、方位角的变化率
            if i > 1
                satPara.BDS.para(prn).V_El(i) = el - satPara.BDS.para(prn).El(i-1);
                satPara.BDS.para(prn).V_Az(i) = az - satPara.BDS.para(prn).Az(i-1);
                if satPara.BDS.para(prn).V_Az(i)>180
                    satPara.BDS.para(prn).V_Az(i) = satPara.BDS.para(prn).V_Az(i) - 360;
                elseif satPara.BDS.para(prn).V_Az(i)<-180
                    satPara.BDS.para(prn).V_Az(i) = satPara.BDS.para(prn).V_Az(i) + 360;
                end
            else
                satPara.BDS.para(prn).V_El(i) = 0;
                satPara.BDS.para(prn).V_Az(i) = 0;
            end
            satPara.BDS.para(prn).V_El_Az(i) = sqrt((satPara.BDS.para(prn).V_El(i))^2 + (satPara.BDS.para(prn).V_Az(i))^2);
            satPara.BDS.para(prn).SOW(i) = time;
        end % for prn = 1 : 14
    end % if any(prn_list_BDS == prn)
    % —————————— 计算DOP值 ——————————————%
    if satPara.BDS.sys.prnVisNum(i) >= 4
        G_mat_valid = G_mat(1:satPara.BDS.sys.prnVisNum(i), :);
        H_mat =  inv(G_mat_valid' * G_mat_valid);
        satPara.BDS.sys.GDOP(i) = sqrt(H_mat(1,1)+H_mat(2,2)+H_mat(3,3)+H_mat(4,4));
        if satPara.BDS.sys.GDOP(i) > 10
            satPara.BDS.sys.GDOP(i) = 10;
        end
    else
        satPara.BDS.sys.GDOP(i) = 10;
    end
end % for i = 1 : length(SOW)



