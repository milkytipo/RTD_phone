function [feature_Modify] = featureModify(feature, timeLen, fileNum, parameter, mode)
%%%%%%%%%  特征参数预处理  %%%%%%%%%%%
fNum = size(feature, 2); % 总特征数量
tNum = size(feature, 1); % 总历元数量
feature_Modify = zeros(tNum, fNum);

switch mode
    case 1
    %% —————————— 基于行驶里程数的平滑处理 —————————————— %
        winLen = 100; % 平滑窗口长度 /m
        index = 0; % 
        for i = 1 : fileNum
            movLen = zeros(1, timeLen(i));
            smoothIndex = ones(timeLen(i), 2);
            for j = 2 : timeLen(i)
                lenEpoch = (parameter(i).SOW(1,j)-parameter(i).SOW(1,j-1)) * (parameter(i).vel(j)+parameter(i).vel(j-1))/2;
                movLen(j) = movLen(j-1) + lenEpoch;
            end
            stratLen = movLen - winLen;
            for j = 2 : timeLen(i)
                [~, pos] = min(abs(movLen - stratLen(j)));
                smoothIndex(j, 1) = pos;
                smoothIndex(j, 2) = j;
            end
            for j = 1 : timeLen(i)
                index = index + 1;
                if j == 1
                    feature_file = feature(index:(index+timeLen(i)-1), :);
                end
                start_p = smoothIndex(j, 1);
                end_p = smoothIndex(j, 2);
                feature_Modify(index, :) = mean(feature_file(start_p:end_p,:), 1);
            end % for j = 1 : timeLen(i)
        end % for i = 1 : fileNum
    
  
    case 2
    %% ————————————  基于时间的平滑处理  ——————————————%
        winLen = 60; % 平滑窗口长度 /s
        index = 0; % 
        for i = 1 : fileNum
            movLen = zeros(1, timeLen(i));
            smoothIndex = ones(timeLen(i), 2);
            for j = 2 : timeLen(i)
                lenEpoch = parameter(i).SOW(1,j)-parameter(i).SOW(1,j-1);
                movLen(j) = movLen(j-1) + lenEpoch;
            end
            stratLen = movLen - winLen;
            for j = 2 : timeLen(i)
                [~, pos] = min(abs(movLen - stratLen(j)));
                smoothIndex(j, 1) = pos;
                smoothIndex(j, 2) = j;
            end
            for j = 1 : timeLen(i)
                index = index + 1;
                if j == 1
                    feature_file = feature(index:(index+timeLen(i)-1), :);
                end
                start_p = smoothIndex(j, 1);
                end_p = smoothIndex(j, 2);
                feature_Modify(index, :) = mean(feature_file(start_p:end_p,:), 1);
            end % for j = 1 : timeLen(i)
        end % for i = 1 : fileNum
    case 3
      %% ————————————  不做任何预处理  ——————————————%
        feature_Modify = feature;
end


    