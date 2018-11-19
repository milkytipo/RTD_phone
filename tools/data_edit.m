%% This file is used for edit signal data, change the format from complex to real.
clear all; clc;

N = 1000000;
filepath = '.\datasource\BD2B1_2014-6-5_11-35-57.dat';
fid1 = fopen(filepath, 'rb');
fseek(fid1, 0, 'bof');

fid2 = fopen('.\datasource\BD2B1_2014-6-5_11-35-57_realpart.dat', 'wb');

while 1
    [signal, cnt] = fread(fid1, N, 'int8');
    signal_real = signal(1:2:length(signal));
    
    if cnt < N
        fclose(fid1);
        break;
    end

    fwrite(fid2, signal_real, 'int8');
end

fwrite(fid2, signal_real, 'int8');
fclose(fid2);
