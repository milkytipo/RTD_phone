%% This script is used to read 514 data.
close all; fclose all; clear; clc;
fid = fopen('J:\ION数据\sjtu_l1b1_metadata_test_20151105.dat', 'rb');
fid2 = fopen('J:\ION数据\sjtu_l1b1_metadata_test_20151105_1min_1.dat', 'ab');
fid3 = fopen('J:\ION数据\sjtu_l1b1_metadata_test_20151105_1min_2.dat', 'ab');
fid4 = fopen('J:\ION数据\sjtu_l1b1_metadata_test_20151105_1min_3.dat', 'ab');
fid5 = fopen('J:\ION数据\sjtu_l1b1_metadata_test_20151105_1min_4.dat', 'ab');
% skipBytes = 0;
% ripeData = [];
sec = 0;  
fs = 62000000;
if fseek(fid, 0, 'bof') ~= 0
    break;
end
while 1
    % 读取4092个字节的数据，即8184个采样点的数据
    [rawData, cnt] = fread(fid, fs*2*0.5, 'int8');
    if sec <= 15
        fwrite(fid2, rawData, 'int8');
    end
    if sec<= 30 && sec>15
        fwrite(fid3, rawData, 'int8');
    end
    if sec<=45 && sec>30
        fwrite(fid4, rawData, 'int8');
    end
    if sec<=60 && sec>45
        fwrite(fid5, rawData, 'int8');
    end
    sec = sec + 0.5;
    if sec == 60
        break;
    end
end

fclose(fid);
fclose(fid2);
fclose(fid3);
fclose(fid4);
fclose(fid5);