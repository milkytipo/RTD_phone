function [valPredi_SVM_Num_smooth] = predictSmooth(valPredi_SVM_Num, feaFile, timeLen, fileNum)

winLen = 50; % 平滑窗口长度 /m
winSec = 20; % s // 本代码假设特征每1秒输出一次
valPredi_SVM_Num_smooth = zeros(length(valPredi_SVM_Num), 1);
%% ———————————— 计算卫星波动系数 ————————————————
file_index = zeros(fileNum, 2);
index_temp = 0;
for i = 1 : fileNum
    file_index(i, 1) = index_temp + 1;
    file_index(i, 2) = index_temp + timeLen(i);
    index_temp = index_temp + timeLen(i);
end


for i = 1 : fileNum
    valPredi_temp = valPredi_SVM_Num(file_index(i, 1):file_index(i, 2));
    valPredi_temp_smooth = zeros(length(valPredi_temp), 1);
    movLen = feaFile(i).movLength;
    logCount = timeLen(i);
    smoothIndex = ones(logCount, 2);
    startLen = movLen - winLen;
    [~, pos_end] = min(abs(startLen)); % 前100m的所有值相同
    for j = 1 : logCount
        [~, pos] = min(abs(movLen - startLen(j)));
        smoothIndex(j, 1) = pos;
        if j < pos_end
            smoothIndex(j, 2) = pos_end;
        else
            smoothIndex(j, 2) = j;
        end
        
        if ((smoothIndex(j, 2)-smoothIndex(j, 1)) > winSec) && smoothIndex(j, 1)>winSec
            smoothIndex(j, 1) = smoothIndex(j, 2) - winSec;
        end
        valPredi_temp_smooth(j) = mode(valPredi_temp(smoothIndex(j, 1):smoothIndex(j, 2)));
    end
    valPredi_SVM_Num_smooth(file_index(i, 1):file_index(i, 2)) = valPredi_temp_smooth;

end
