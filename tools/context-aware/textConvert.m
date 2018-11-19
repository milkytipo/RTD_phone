clc; clear; close all; fclose all;
fileNameRead = 'H:\20180326_NanjingEastRoad.ubx';
fileNameWrite = 'H:\20180326_NanjingEastRoad_GGA.txt';
fid_0 = fopen(fileNameRead);
if fid_0 == -1
    error('message data file not found or permission denied');
end
frewind(fid_0);
fid_1 = fopen(fileNameWrite, 'at');
lineNum = 0; % 行数
blankLineNum = 0; % 连续出现空行的数量
modiType = 5; % 文本修改模式
logFlag = 0; % 判断是否重复
preInfo = 'start'; % 
while 1
    line = fgetl(fid_0);
    if ~ischar(line)
        break;
    end
    if ~ischar(line)
        blankLineNum = blankLineNum + 1;
        if blankLineNum > 5
            break;
        end
    else
        blankLineNum = 0;
    end
    lineNum = lineNum + 1;
    len = length(line);
    
    % —————— 去除符号$前面的无用字符———————— %
    if modiType == 1
        for i = 1 : len
            if strcmp(line(i), '$')
                fprintf(fid_1, line(i:len));
                fprintf(fid_1, '\n');
                break;
            end
        end  
    end
    
    % —————— 修改时间系统 ———————— %
    if modiType == 2 
        if strcmp(line(4:6), 'RMC') || strcmp(line(4:6), 'GGA')
            Hour_UTC = str2double(line(8:9));
            Min_UTC = str2double(line(10:11));
            Sec_UTC = str2double(line(12:13));
            Sec_UTC = Sec_UTC - 1;   % 时间系统修改
            if Sec_UTC < 0
                Sec_UTC = Sec_UTC + 60;
                Min_UTC = Min_UTC - 1;
                if Min_UTC < 0
                    Min_UTC = Min_UTC + 60;
                    Hour_UTC = Hour_UTC - 1;
                end
            end
            line(8:9) = num2str(Hour_UTC,'%2.2d');
            line(10:11) = num2str(Min_UTC,'%2.2d');
            line(12:13) = num2str(Sec_UTC,'%2.2d');
            fprintf(fid_1, line(1:len));
            fprintf(fid_1, '\n');
        else
            fprintf(fid_1, line(1:len));
            fprintf(fid_1, '\n');
        end
        
    end
    
    % —————— 去除符号$前面的无用字符———————— %
    if modiType == 3
        for i = 1 : len - 4
            if strcmp(line(i:i+4), 'GPRMC') || strcmp(line(i:i+4), 'GPVTG') ...
                    || strcmp(line(i:i+4), 'GPGGA') || strcmp(line(i:i+4), 'GPGSA')...
                    || strcmp(line(i:i+4), 'GPGSV') || strcmp(line(i:i+4), 'GPGLL')...
                    || strcmp(line(i:i+4), 'GPZDA')
                fprintf(fid_1, strcat('$', line(i:len)));
                fprintf(fid_1, '\n');
                break;
            end
        end  
    end
    
    % —————— 去重复的历元———————— %
    if modiType == 4
        if strcmp(line(1), '>')
            if strcmp(preInfo, 'start')
                preInfo = line(1:35);
                logFlag = 1;
            elseif strcmp(preInfo, line(1:35))
                logFlag = 0;
            else
                preInfo = line(1:35);
                logFlag = 1;
            end
        end
        if logFlag == 1
            fprintf(fid_1, strcat(line(1:end), '\n'));
        end
    end
    
    % —————— 提取GGA数据 ———————— %
    if modiType == 5
        for i = 1 : len - 4
            if strcmp(line(i:i+4), 'GNGGA')
                fprintf(fid_1, strcat('$', line(i:len)));
                fprintf(fid_1, '\n');
                break;
            end
        end  
    end
    
end
fclose(fid_0);
fclose(fid_1);