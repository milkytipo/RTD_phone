function [peak_nc_corr, peak_freq_idx, peak_code_idx, snr] = find2DPeak(array) 
% find peak of 2-D array and caculate SNR
% 1st dimention is frequency dimention
% 2nd dimention is codephase dimention

freqSearch = size(array, 1);  %返回列的数目
[peak_corr_freq, peak_freq_set] = max(array,[],1); %取每列最大值
[peak_nc_corr, peak_code_idx] = max(peak_corr_freq,[],2); %取每行最大值
peak_freq_idx = peak_freq_set(peak_code_idx); % find the peak frequency index
% non_peak_freq_idx = mod(peak_freq_idx + 3,freqSearch) + 1;
% mean_corr = mean(array(non_peak_freq_idx,:)); %取平均
% abs_corr =  mean(abs(array(non_peak_freq_idx,:)-mean_corr));
%--------------------------------------------
non_peak_freq_idx = ((peak_freq_idx - 3):1:(peak_freq_idx + 3)) - 1;
non_peak_freq_idx = mod(non_peak_freq_idx, freqSearch) + 1;
n = ((peak_code_idx - 15):1:(peak_code_idx + 15)) - 1;
non = mod(n,size(array,2)) + 1;
array(non_peak_freq_idx, non) = 0;
s = sum(sum(array, 2),1);
mean_corr = s/((size(array,2))*size(array, 1) - 31*7);
array1 = abs(array-mean_corr);
array1(non_peak_freq_idx, non) = 0;
s1 = sum(sum(array1, 2),1);
abs_corr = s1/((size(array,2))*size(array, 1) - 31*7);
%--------------------------------------------
snr= (peak_nc_corr - mean_corr)/abs_corr;