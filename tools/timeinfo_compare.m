% clear all; clc;
clear STR_time_1 STR_time_2 time1 time2 time1_m time2_m time time1_up time2_up time_diff cod_diff;

load('time.mat');
STR_time_1 = STR_time;

load('timeinfo_xqj_133_16.mat');
STR_time_2 = time;

clear STR_time;

for i = 1:6
    if i == 1 % GEO
        T1cnt = 2;
        time1(i,:) = STR_time_1(i).SOW + STR_time_1(i).SubFrame_N * 0.6 + STR_time_1(i).Word_N * 0.06 + (STR_time_1(i).Bit_N) * 0.06/30 + ...
            STR_time_1(i).T1ms_N * 0.001 + STR_time_1(i).CodPhs * 0.001/2046;
    else
        T1cnt = 20;
        time1(i,:) = STR_time_1(i).SOW + STR_time_1(i).Word_N * 0.6 + (STR_time_1(i).Bit_N) * 0.6/30 + ...
            STR_time_1(i).T1ms_N * 0.001 + STR_time_1(i).CodPhs * 0.001/2046;
    end
    
    time1_m(i,:) = time1(i,1:123);
    time2(i,:) = STR_time_2(i).SOW + STR_time_2(i).Bit_N * (0.03*T1cnt)/30 + ...
        mod(STR_time_2(i).T1ms_N, T1cnt) * 0.001 + STR_time_2(i).CodPhs * 0.001/2046;
    time2_m(i,:) = time2(i,:);
    time_diff(i,:) = time1_m(i,:) - time2_m(i,:);
    cod_diff(i,:) = time_diff(i,:) * 1000 * 2046;
end

for j = 1:122
    time1_up(:,j) = time1_m(:,j+1) - time1_m(:,j);
    time2_up(:,j) = time2_m(:,j+1) - time2_m(:,j);
end
