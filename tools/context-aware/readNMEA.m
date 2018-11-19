%%
function [parameter] = readNMEA(parameter, filename, YYMMDD, fileNameBds, fileNameGps, isInt, TYPE)

CNR_bound = 25;  % 最低判别的载噪比功率
el_bound = 5; % 最低判别的仰角
% [ephemeris_BDS, prn_list_BDS, updateTimes_BDS, isNorm_BDS, toe_matrix_BDS] = loadEphFromRINEX_C(fileNameBds);
[ephemeris_GPS, prn_list_GPS, ~, ~, toe_matrix_GPS] = loadEphFromRINEX_C(fileNameGps);

fid = fopen(filename);
if fid == -1
    error('message data file not found or permission denied');
end
frewind(fid);

year = str2double(YYMMDD(1:4));
month = str2double(YYMMDD(5:6));
day = str2double(YYMMDD(7:8));

%—————————— 读取总共记录时刻次数 ————————%
logCountAll = 0; % 数据记录历元数目
maxPrnNo = 32;      % 系统PRN号最大值
firstEpoch = 1;     % 记录参数的开始时刻
endEpoch = 100000000;  % 记录参数的结束时刻
while 1
    line = fgetl(fid);
    if ~ischar(line)
        break;
    end
    if strcmp(line(4:6), 'RMC')
        logCountAll = logCountAll + 1;
    end
end
fclose(fid);
if endEpoch > logCountAll
    endEpoch = logCountAll;
end
logCount = endEpoch - firstEpoch + 1;
%% 初始化
%———————————— 参数初始化 ————————————%
parameter.SYST = 'GPS_L1CA';     % 目前仅记录GPS L1CA信号参数
parameter.TYPE = TYPE;     % 目前仅记录GPS L1CA信号参数
parameter.SOW = nan(5, logCount); 
parameter.pos_llh = nan(3, logCount);
parameter.pos_xyz = nan(3, logCount);
parameter.pos_enu = nan(3, logCount);
parameter.ENU_error = nan(7, logCount);
parameter.posValid = nan(1, logCount);
parameter.vel = nan(1, logCount);
parameter.vel_angle = nan(1, logCount);
parameter.satNum = nan(1, logCount);
parameter.prnNo = nan(maxPrnNo,logCount);
parameter.GDOP = nan(1,logCount);
parameter.GDOP_ratio = nan(1,logCount);

parameter.Elevation = nan(maxPrnNo,logCount);
parameter.Azimuth = nan(maxPrnNo,logCount);
parameter.CNR = nan(maxPrnNo,logCount);
parameter.CNR_Var = nan(maxPrnNo,logCount);
parameter.movLength = nan(1,logCount);
parameter.length = logCount;

%% 读取参数
fid = fopen(filename);
if fid == -1
    error('message data file not found or permission denied');
end
k = 0;  % 历元数
lineNum = 0; % 行数
lineValid = 0;
while 1
    line = fgetl(fid);
    if ~ischar(line)
        break;
    end
    lineNum = lineNum + 1;
 %%   %%%%%%%%%%%%%%    读取RMC参数信息    %%%%%%%%%%%%%%
    if strcmp(line(4:6), 'RMC')
        comma = zeros(1, 50);  % [逗号坐标]
        comma_N = 0; % 逗号数
        k = k + 1;
        len = length(line);
        for i = 1 : len
            if strcmp(line(i), ',')
                comma_N = comma_N + 1;
                comma(comma_N) = i;
                if comma_N == 2
                    if (comma(2)-comma(1)-1) >= 9
                        lineValid = 1;
                    else
                        lineValid = 0;
                        k = k - 1;
                        logCount = logCount - 1;
                    end
                    break;   % for i = 1 : len
                end
            end % if strcmp(line(i), ',')
        end  % for i = 1 : len
        if lineValid == 1
            daynum = dayofweek(year, month, day);
            hour = str2double(line(comma(1)+1 : comma(1)+2));
            minite = str2double(line(comma(1)+3 : comma(1)+4));
            sec = str2double(line(comma(1)+5 : comma(1)+10));
            todsec = 3600 * hour + 60 * minite + sec;
            towsec = todsec + 86400 * daynum;     % 当前条数的周内秒
            parameter.SOW(1, k) = towsec;
            parameter.SOW(2, k) = hour;
            parameter.SOW(3, k) = minite;
            parameter.SOW(4, k) = sec;
            if k == 1
                parameter.SOW(5, k) = 0;
            else
                parameter.SOW(5, k) = towsec - parameter.SOW(1, k-1);
            end
            if isInt
                if abs(sec - round(sec))>0.02
                    lineValid = 0;
                    k = k - 1;
                    logCount = logCount - 1;
                end
            end
        end % if lineValid == 1
    end % if strcmp(line(4:6), 'RMC')
    
%%    %%%%%%%%%%%%%%    读取VTG参数信息    %%%%%%%%%%%%%%
    if strcmp(line(4:6), 'VTG') && lineValid==1
        comma = zeros(1, 50);  % [逗号坐标]
        comma_N = 0;
        len = length(line);
        for i = 1 : len
            if strcmp(line(i), ',')
                comma_N = comma_N + 1;
                comma(comma_N) = i;
                if comma_N == 8
                    if (comma(8)-comma(7)-1) >= 4
                        velValid = 1;
                    else
                        velValid = 0;
                    end
                    break;   % for i = 1 : len
                end % if comma_N == 8
            end % if strcmp(line(i), ',')
        end  % for i = 1 : len
        if velValid == 1
            parameter.vel_angle(k) = str2double(line(comma(1)+1 : comma(2)-1));
            parameter.vel(k) = str2double(line(comma(7)+1 : comma(8)-1)) / 3.6;
        else
            parameter.vel_angle(k) = parameter.vel_angle(k-1);
            parameter.vel(k) = parameter.vel(k-1);
        end
        if k == 1
            parameter.movLength(k) = 0;
        else
            lenEpoch = (parameter.SOW(1,k)-parameter.SOW(1,k-1)) * (parameter.vel(k)+parameter.vel(k-1))/2;
            parameter.movLength(k) = parameter.movLength(k-1) + lenEpoch;
        end
    end % if strcmp(line(4:6), 'VTG') && lineValid==1
    
%%    %%%%%%%%%%%%%%    读取GGA参数信息    %%%%%%%%%%%%%%
    if strcmp(line(4:6), 'GGA') && lineValid==1
        comma = zeros(1, 50);  % [逗号坐标]
        comma_N = 0;
        len = length(line);
        for i = 1 : len
            if strcmp(line(i), ',')
                comma_N = comma_N + 1;
                comma(comma_N) = i;
                if comma_N == 10
                    if (comma(3)-comma(2)-1) >= 8
                        parameter.posValid(k) = 1;
                    else
                        parameter.posValid(k) = 0;
                    end
                    break;   % for i = 1 : len
                end
            end % if strcmp(line(i), ',')
        end  % for i = 1 : len
        if parameter.posValid(k) == 1
            LLH(1) = str2double(line(comma(2)+1 : comma(2)+2)) + str2double(line(comma(2)+3 : comma(3)-1)) / 60;
            LLH(2) = str2double(line(comma(4)+1 : comma(4)+3)) + str2double(line(comma(4)+4 : comma(5)-1)) / 60;
            LLH(3) = str2double(line(comma(9)+1 : comma(10)-1));
            XYZ = llh2xyz(LLH);
            parameter.pos_llh(:, k) = [LLH(1); LLH(2); LLH(3)];
            parameter.pos_xyz(:, k) = [XYZ(1); XYZ(2); XYZ(3)];
            parameter.pos_enu(:, k) = xyz2enu(parameter.pos_xyz(:, k), parameter.pos_xyz(:, 1));
        else
            parameter.pos_llh(:, k) = parameter.pos_llh(:, k-1);
            parameter.pos_xyz(:, k) = parameter.pos_xyz(:, k-1);
            parameter.pos_enu(:, k) = parameter.pos_enu(:, k-1);
        end
    end % if strcmp(line(4:6), 'GGA') && lineValid==1
    
%%    %%%%%%%%%%%%%%    读取GSV参数信息    %%%%%%%%%%%%%%
    if strcmp(line(2:6), 'GPGSV') && lineValid==1
        if str2double(line(10)) == 1
            G_mat = zeros(32, 4);
            prnVaildNum = 0;
        end
        comma = zeros(1, 50);  % [逗号坐标]
        comma_N = 0;
        len = length(line);
        for i = 1 : len
            if strcmp(line(i), ',')
                comma_N = comma_N + 1;
                comma(comma_N) = i;
            end   % if strcmp(line(i), ',')
        end  % for i = 1 : len
        svNum = str2double(line(comma(3)+1 : comma(3)+2));
        if svNum > 0
            gsvValid = 1;
        else
            gsvValid = 0;
        end
        if gsvValid == 1
            svNum_line = (comma_N + 1 - 4) / 4;
            for j = 1 : svNum_line
                index = 4 * j;
                prn = str2double(line(comma(index)+1 : comma(index+1)-1));
                if prn <= 32
                    % 由于可能存在接收到卫星信号但无仰角、方位角信息，所以此处不保存仰角、方位角，后续由星历计算得到
                    if (~strcmp(line(comma(index+3)+1), '*')) && (~strcmp(line(comma(index+3)+1), ','))
%                         el = str2double(line(comma(index+1)+1 : comma(index+2)-1));
%                         az = str2double(line(comma(index+2)+1 : comma(index+3)-1));
                        [el, az] = sat_El_Az(ephemeris_GPS, prn_list_GPS, toe_matrix_GPS, prn, parameter.SOW(1, k), parameter.pos_xyz(:, k), 'GPS');
                        cnr = str2double(line(comma(index+3)+1 : comma(index+3)+2));
                        if el>=el_bound && cnr>=CNR_bound
                            prnVaildNum = prnVaildNum + 1;
                            parameter.prnNo(prnVaildNum, k) = prn;
                            parameter.Elevation(prn, k) = round(el);
                            parameter.Azimuth(prn, k) = round(az);
                            parameter.CNR(prn, k) = cnr;
                            G_mat(prnVaildNum, :) = [-cos(el)*sin(az), ...
                                -cos(el)*cos(az), ...
                                -sin(el), 1];
                        end
                    end
                end % if prn <= 32
            end % for j = 1 : svNum_line
        end % if gsvValid == 1
        if str2double(line(8)) == str2double(line(10))
            parameter.satNum(k) = prnVaildNum;
            if prnVaildNum >=4
                G_mat_valid = G_mat(1:prnVaildNum, :);
                H_mat =  inv(G_mat_valid' * G_mat_valid);
                parameter.GDOP(k) = sqrt(H_mat(1,1)+H_mat(2,2)+H_mat(3,3)+H_mat(4,4));
                if parameter.GDOP(k) > 10
                    parameter.GDOP(k) = 10;
                end
            else
                parameter.GDOP(k) = 10;
            end
        end
    end %  if strcmp(line(4:6), 'GSV') && lineValid==1
    
end   % while 1
fclose(fid);

%% —————————————— 去除无效参数 —————————————————%
parameter.SOW = parameter.SOW(:, 1:logCount); 
parameter.pos_llh = parameter.pos_llh(:, 1:logCount);
parameter.pos_xyz = parameter.pos_xyz(:, 1:logCount);
parameter.pos_enu = parameter.pos_enu(:, 1:logCount);
parameter.posValid = parameter.posValid(:, 1:logCount);
parameter.ENU_error = parameter.ENU_error(:, logCount);
parameter.vel = parameter.vel(:, 1:logCount);
parameter.vel_angle = parameter.vel_angle(:, 1:logCount);
parameter.satNum = parameter.satNum(:, 1:logCount);
parameter.prnNo = parameter.prnNo(:, 1:logCount);
parameter.GDOP = parameter.GDOP(:, 1:logCount);
parameter.Elevation = parameter.Elevation(:, 1:logCount);
parameter.Azimuth = parameter.Azimuth(:, 1:logCount);
parameter.CNR = parameter.CNR(:, 1:logCount);
parameter.CNR_Var = parameter.CNR_Var(:, 1:logCount);
parameter.movLength = parameter.movLength(:, 1:logCount);
parameter.length = logCount;


%% ———————————— 计算卫星波动系数 ————————————————
prnNum = intersect(parameter.prnNo, parameter.prnNo);
smoothIndex = ones(logCount, 2);
isFix = 1;  % 是否固定计算的历元数目
if isFix
    winLen = 5;
    for j = 1 : logCount
        pos_st = j - winLen + 1;
        if pos_st < 1
            pos_st = 1;
            pos_ed = winLen;
        else
            pos_ed = j;
        end
        smoothIndex(j, 1) = pos_st;
        smoothIndex(j, 2) = pos_ed;
    end
    
else
    winLen = 100; % 平滑窗口长度 /m
    minEpoch = 7; % 平滑窗口的最小历元数目
    movLen = parameter.movLength;
    startLen = movLen - winLen;
    [~, pos_ed] = min(abs(startLen)); % 前100m的所有值相同
    for j = 1 : logCount
        [~, pos_st] = min(abs(movLen - startLen(j)));
        smoothIndex(j, 1) = pos_st;
        if j < pos_ed
            smoothIndex(j, 2) = pos_ed;
        else
            smoothIndex(j, 2) = j;
        end
        % 定义计算波动系数的最小历元数目
        if ((smoothIndex(j, 2)-smoothIndex(j, 1)) < minEpoch) && smoothIndex(j, 1)>minEpoch
            smoothIndex(j, 1) = smoothIndex(j, 2) - minEpoch;
        end
    end
end


for i = 1 : length(prnNum)
    prn = prnNum(i);
    CNR_temp = parameter.CNR(prn, :);
    nan_index = isnan(CNR_temp);
    CNR_temp(nan_index) = CNR_bound; % 将nan（即被阻塞的信号）的点赋值为15dB
     %% —————————— 基于行驶里程数的平滑处理 —————————————— %   
    for j = 1 : logCount
        start_p = smoothIndex(j, 1);
        end_p = smoothIndex(j, 2);
        parameter.CNR_Var(prn, j) = sqrt(var(CNR_temp(start_p:end_p)));
    end % for j = 1 : timeLen(i)        
end


end % function