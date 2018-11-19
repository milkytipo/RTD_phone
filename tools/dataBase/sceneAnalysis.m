clc; 
close all;
isRead = 0;
if isRead
    clear; 
    load CNR_std_ublox.mat;
    isInt = 0;  % 仅读取整秒处数据，因为标定数据仅在整秒处
    class_name_all = categorical({'canyon', 'urban', 'surburb', 'boulevard', 'viaduct_down'});
    fileNum = 5;
    fileNo = 1:5; 
    [filename, fileCalib, fileEphBds, fileEphGps, YYMMDD, TYPE] = fileNameInitial();
    [parameter, calibration] = paraInitial(fileNum);
    for k = 1 : length(fileNo)
        i = fileNo(k);
        [parameter(i)] = readNMEA(parameter(i), filename{i}, YYMMDD{i}, fileEphBds{i}, fileEphGps{i}, isInt, TYPE{i});
        [parameter(i)] = ephStateCal(parameter(i), fileEphBds{i}, fileEphGps{i});
    end
end

isFeaCal = 1; % 重新计算信号特征参数
isKmean = 1;

isPlot = 1; 
class_name = categorical();
mode = 3; % 特征预处理模式: 基于里程平滑（1）  /   基于时间平滑（2） /  不处理（3）

%% %%%%%%%%%%  特征计算  %%%%%%%%%%%%%%%%%%
if isFeaCal %  3 4 5 7 8
%     parameter(1).prnNo_useless = [18]; % 不计算载噪比的卫星号
%     parameter(6).prnNo_useless = [5, 13]; % 不计算载噪比的卫星号

    CNR_std_modi = [0, 0, 0, 0, 0, 0, 0]; % 不同文件的标准载噪比不同，需要进一步修正

    [feaCluster, feaFile, timeLen] = featrueDatabase(parameter, fileNum, CNR_std_ublox, CNR_std_modi, isInt);
    % 特征参数预处理
    [feature_Modify] = featureModify(feaCluster.paraRaw_Norm_atan, timeLen, fileNum, parameter, mode);
    % 各特征参数提取
    inSvRatio = feature_Modify(:, 1); % 不可见卫星比例
    attRatio = feature_Modify(:, 2); % 信号差卫星的比例
    attDegree = feature_Modify(:, 3); % 信号差卫星的均值
    cnrFluc = feature_Modify(:, 4); % 载噪比波动均值 
    GDOP_ratio = feature_Modify(:, 5); % DOP值增大比例
end % if isFeaCal

feaStatis = zeros(fileNum, 5);
for i = 1 : fileNum
    feaStatis(i, :) = mean(feaFile(i).para, 1);
end



