function [peak_nc_corr, peak_freq_idx, peak_code_idx, th] = find2DPeakWithThre( corr_mt, mode )


[peak_corr_set, peak_freq_set] = max(corr_mt,[],1); %找出每个相位的峰值，并给出峰值对应的频率
[peak_nc_corr, peak_code_idx] = max(peak_corr_set);  %进一步确定峰值中的峰值，给出峰值相位
peak_freq_idx = peak_freq_set(peak_code_idx);  %给出峰值频率

switch mode
    case 'CM'
        %找出CM捕获峰值，计算门限
        %corr_mt中每行是一个频率，每列是一个相位，共20列
        corr_mt(:,peak_code_idx) = []; %去掉峰值相位的一列
        th = peak_nc_corr/( mean(mean(corr_mt)) ); %计算峰值与非峰值均值的比例，作为门限参数
        
    case 'hotAcq'
        %热捕获进行二维搜索，寻找峰值
        %计算门限时扣除峰值附近的三行三列
        [freqN, codeN] = size(corr_mt);
        freqDelete =  mod( (peak_freq_idx-1:peak_freq_idx+1)-1,freqN )+1; %需要删除的行
        codeDelete =  mod( (peak_code_idx-1:peak_code_idx+1)-1,codeN )+1; %需要删除的列
        corr_mt(freqDelete,:) = [];
        corr_mt(:,codeDelete) = [];
        th = peak_nc_corr/( mean(mean(corr_mt)) );
end


