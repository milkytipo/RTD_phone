clear ; clc; fclose all;

fileName_1 = 'D:\Test database\Town\IMU_HuaweiP10_cellPhone.txt'; % 加速度计
fileName_2 = 'D:\20180415\2018-4-15{市区 SBG-手机IMU数据）\2018-4-15{市区 SBG-手机IMU数据）\gyro2.txt'; % 陀螺仪
fileName_3 = 'D:\20180415\2018-4-15{市区 SBG-手机IMU数据）\2018-4-15{市区 SBG-手机IMU数据）\mag2.txt'; % 磁力计
fileName_wirte = 'D:\Test database\Town\rawData_IMU_HuaweiP10_cellPhone.txt';
fid_1 = fopen(fileName_1);
fid_2 = fopen(fileName_2);
fid_3 = fopen(fileName_3);
fid_4 = fopen(fileName_wirte,'at');
N_ini = 30000;
para_acc = zeros(N_ini, 3); % 共有3个参数
time_acc = zeros(N_ini, 4);
para_gyro = zeros(N_ini, 3); % 共有3个参数
time_gyro = zeros(N_ini, 4);
para_mag = zeros(N_ini, 3); % 共有3个参数
time_mag = zeros(N_ini, 4);
time = zeros(N_ini, 3); % HHMMSS
type = 3;

lineNum = 0; % 读取文件的行数
N_log = 0; % 文件记录的历元数

while 1
    
    if type == 1
        %%
        line_1 = fgetl(fid_1);
        if ~ischar(line_1)
            break;
        end
        line_2 = fgetl(fid_2);
        if ~ischar(line_2)
            break;
        end
        line_3 = fgetl(fid_3);
        if ~ischar(line_3)
            break;
        end
        lineNum = lineNum + 1;
        N_log = ceil(lineNum/2);
        if (lineNum/2 - floor(lineNum/2)) == 0
            %—————————— 加速度计——————————————%
            comma = zeros(1, 50);  % [逗号坐标]
            comma_N = 0;
            len = length(line_1);
            for i = 1 : len
                if strcmp(line_1(i), ',')
                    comma_N = comma_N + 1;
                    comma(comma_N) = i;
                end % if strcmp(line(i), ',')
            end  % for i = 1 : len
            acc_x = str2double(line_1(1:comma(1)-1));
            acc_y = str2double(line_1(comma(1)+1:comma(2)-1));
            acc_z = str2double(line_1(comma(2)+1:end));

            %—————————— 陀螺仪 ——————————————%
            comma = zeros(1, 50);  % [逗号坐标]
            comma_N = 0;
            len = length(line_2);
            for i = 1 : len
                if strcmp(line_2(i), ',')
                    comma_N = comma_N + 1;
                    comma(comma_N) = i;
                end % if strcmp(line(i), ',')
            end  % for i = 1 : len
            gyro_x = str2double(line_2(1:comma(1)-1));
            gyro_y = str2double(line_2(comma(1)+1:comma(2)-1));
            gyro_z = str2double(line_2(comma(2)+1:end));

            %—————————— 磁力计 ——————————————%
            comma = zeros(1, 50);  % [逗号坐标]
            comma_N = 0;
            len = length(line_3);
            for i = 1 : len
                if strcmp(line_3(i), ',')
                    comma_N = comma_N + 1;
                    comma(comma_N) = i;
                end % if strcmp(line(i), ',')
            end  % for i = 1 : len
            mag_x = str2double(line_3(1:comma(1)-1));
            mag_y = str2double(line_3(comma(1)+1:comma(2)-1));
            mag_z = str2double(line_3(comma(2)+1:end));
            
        else
             %—————————— 加速度计——————————————%
            year = str2double(line_1(1:4));
            month = str2double(line_1(6:7));
            day = str2double(line_1(9:10));
            hour = str2double(line_1(13:14));
            minite = str2double(line_1(16:17));
            sec = str2double(line_1(19:20));
            daynum = dayofweek(year, month, day);
            todsec = 3600 * hour + 60 * minite + sec;
            acc_Time = todsec + 86400 * daynum;     % 当前条数的周内秒
            
            
            %—————————— 陀螺仪 ——————————————%
            year = str2double(line_2(1:4));
            month = str2double(line_2(6:7));
            day = str2double(line_2(9:10));
            hour = str2double(line_2(13:14));
            minite = str2double(line_2(16:17));
            sec = str2double(line_2(19:20));
            daynum = dayofweek(year, month, day);
            todsec = 3600 * hour + 60 * minite + sec;
            gyro_Time = todsec + 86400 * daynum;     % 当前条数的周内秒


            %—————————— 磁力计 ——————————————%
            year = str2double(line_3(1:4));
            month = str2double(line_3(6:7));
            day = str2double(line_3(9:10));
            hour = str2double(line_3(13:14));
            minite = str2double(line_3(16:17));
            sec = str2double(line_3(19:20));
            daynum = dayofweek(year, month, day);
            todsec = 3600 * hour + 60 * minite + sec;
            mag_Time = todsec + 86400 * daynum;     % 当前条数的周内秒

            if ~(acc_Time==gyro_Time && gyro_Time==mag_Time)
                error('time is wrong');
            end
            hour = mod(hour-8, 24); % 减去北京时间东八区的+8小时
            time(N_log, 1:3) = [hour, minite, sec];
        end 
        %%Z
    elseif type == 2
        %%
        line_1 = fgetl(fid_1);
        if ~ischar(line_1)
            break;
        end
        line_2 = fgetl(fid_2);
        if ~ischar(line_2)
            break;
        end
        line_3 = fgetl(fid_3);
        if ~ischar(line_3)
            break;
        end
        lineNum = lineNum + 1;
        N_log = lineNum;
        %—————————— 加速度计——————————————%
        year = str2double(line_1(1:4));
        month = str2double(line_1(6:7));
        day = str2double(line_1(9:10));
        time_acc(N_log, 1) = str2double(line_1(20:21)) - 8;
        time_acc(N_log, 2) = str2double(line_1(23:24));
        time_acc(N_log, 3) = str2double(line_1(26:27));
        daynum = dayofweek(year, month, day);
        todsec = 3600 * time_acc(N_log, 1) + 60 * time_acc(N_log, 2) + time_acc(N_log, 3);
        time_acc(N_log, 4) = todsec + 86400 * daynum;     % 当前条数的周内秒
        acc_x = str2double(line_1(36:45));
        acc_y = str2double(line_1(46:55));
        acc_z = str2double(line_1(56:end));
        para_acc(N_log, :) = [acc_x, acc_y, acc_z];
        
        %—————————— 陀螺仪 ——————————————%
        year = str2double(line_2(1:4));
        month = str2double(line_2(6:7));
        day = str2double(line_2(9:10));
        time_gyro(N_log, 1) = str2double(line_2(29:30)) - 8;
        time_gyro(N_log, 2) = str2double(line_2(32:33));
        time_gyro(N_log, 3) = str2double(line_2(35:36));
        daynum = dayofweek(year, month, day);
        todsec= 3600 * time_gyro(N_log, 1) + 60 * time_gyro(N_log, 2) + time_gyro(N_log, 3);
        time_gyro(N_log, 4) = todsec + 86400 * daynum;     % 当前条数的周内秒
        gyro_x = str2double(line_2(40:50));
        gyro_y = str2double(line_2(60:75));
        gyro_z = str2double(line_2(77:end));
        para_gyro(N_log, :) = [gyro_x, gyro_y, gyro_z];
        
        %—————————— 磁力计 ——————————————%
        year = str2double(line_3(1:4));
        month = str2double(line_3(6:7));
        day = str2double(line_3(9:10));
        time_mag(N_log, 1) = str2double(line_3(20:21)) - 8;
        time_mag(N_log, 2) = str2double(line_3(23:24));
        time_mag(N_log, 3) = str2double(line_3(26:27));
        daynum = dayofweek(year, month, day);
        todsec = 3600 * time_mag(N_log, 1) + 60 * time_mag(N_log, 2) + time_mag(N_log, 3);
        time_mag(N_log, 4) = todsec + 86400 * daynum;     % 当前条数的周内秒
        mag_x = str2double(line_3(37:50));
        mag_y = str2double(line_3(52:65));
        mag_z = str2double(line_3(66:end));
        para_mag(N_log, :) = [mag_x, mag_y, mag_z];   
        
    elseif type == 3
        %%
        line_1 = fgetl(fid_1);
        if ~ischar(line_1)
            break;
        end
        lineNum = lineNum + 1;
        N_log = lineNum;
        
        year = 2018;
        month = 03;
        day = 24;
        time_acc(N_log, 1) = str2double(line_1(1:2)) - 8;
        time_acc(N_log, 2) = str2double(line_1(3:4));
        time_acc(N_log, 3) = str2double(line_1(5:6));
        daynum = dayofweek(year, month, day);
        todsec = 3600 * time_acc(N_log, 1) + 60 * time_acc(N_log, 2) + time_acc(N_log, 3);
        time_acc(N_log, 4) = todsec + 86400 * daynum;     % 当前条数的周内秒
        time_gyro(N_log, :) = time_acc(N_log, :);
        time_mag(N_log, :) = time_acc(N_log, :);
        para_acc(N_log, :) = [str2double(line_1(8:14)), str2double(line_1(16:22)), str2double(line_1(24:30))];
        para_gyro(N_log, :) = [str2double(line_1(32:38)), str2double(line_1(40:46)), str2double(line_1(48:54))];
        para_mag(N_log, :) = [str2double(line_1(56:62)), str2double(line_1(64:70)), str2double(line_1(72:78))];

    end % elseif type == 3
end

%% 数据处理

para_acc = para_acc(1:N_log, :); % 共有3个参数
time_acc = time_acc(1:N_log, :);
para_gyro = para_gyro(1:N_log, :); % 共有3个参数
time_gyro = time_gyro(1:N_log, :);
para_mag = para_mag(1:N_log, :); % 共有3个参数
time_mag = time_mag(1:N_log, :);

time_mag_modi = modifyText(time_mag, N_log);
time_gyro_modi = modifyText(time_gyro, N_log);
time_acc_modi = modifyText(time_acc, N_log);


%% —————————— 写入新文件 ——————————————%
writeMobileSensor(year, month, day, time_acc_modi, time_gyro_modi, time_mag_modi, para_acc, para_gyro, para_mag, fid_4);

fclose(fid_1);
fclose(fid_2);
fclose(fid_3);
fclose(fid_4);
