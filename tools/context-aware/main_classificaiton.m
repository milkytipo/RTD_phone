clc; 
close all;
isRead = 0;
if isRead
    clear; 
    load CNR_std_ublox.mat;
    isInt = 0;  % 仅读取整秒处数据，因为标定数据仅在整秒处
    class_name_all = categorical({'canyon', 'urban', 'surburb', 'viaduct_up', 'viaduct_down', 'boulevard'});
    fileNum = 6;
    fileNo = [1:6];
    fileType = [1, 1, 1, 3, 1, 1, 3];% [1, 1, 1, 2, 1, 1];% [1, 1, 1, 1, 3, 1, 1];  % 标定数据类型
    [filename, fileCalib, fileEphBds, fileEphGps, YYMMDD, TYPE] = fileNameInitial();
    [parameter, calibration] = paraInitial(fileNum);
    for k = 1 : fileNum
        i = fileNo(k);
        [parameter(i)] = readNMEA(parameter(i), filename{i}, YYMMDD{i}, fileEphBds{i}, fileEphGps{i}, isInt, TYPE{i});
        [calibration(i)] = readCalib(calibration(i), fileCalib{i}, YYMMDD{i}, fileType(i));
        [parameter(i)] = ephStateCal(parameter(i), fileEphBds{i}, fileEphGps{i});
        [parameter(i)] = posENU_error(parameter(i), calibration(i), fileType(i));
    end
    % —————————— 初始化验证数据参数 ————————————%
    i = i + 1; % 第7个文件名用以验证识别算法
    [parameter_NewData, calibration_NewData] = paraInitial(1);
    [parameter_NewData] = readNMEA(parameter_NewData, filename{i}, YYMMDD{i}, fileEphBds{i}, fileEphGps{i}, isInt, TYPE{i});
    [calibration_NewData] = readCalib(calibration_NewData, fileCalib{i}, YYMMDD{i}, fileType(i));
    [parameter_NewData] = ephStateCal(parameter_NewData, fileEphBds{i}, fileEphGps{i});
    [parameter_NewData] = posENU_error(parameter_NewData, calibration_NewData, fileType(i));
end

isTrain = 1; % 训练数据
isPredict = 1; % 预测新数据
isSVM = 1;
class_name = categorical();
processMode = 3; % 特征预处理模式: 基于里程平滑（1）  /   基于时间平滑（2） /  不处理（3）
valueMode = 1; % 归一化且经过atan变换（1）  /  归一化后数据 （2）  /  原始数据 （3）
isSmooth = 0; % 预测结果滤波平滑
feaChoose = 2; % 本文提取的五特征（1）  /   传统四特征（2）  /  测试（3）

%% %%%%%%%%%%  特征计算  %%%%%%%%%%%%%%%%%%
if isTrain %  3 4 5 7 8
%     CNR_std_modi = [0, 0, 1, 2, 0, 0]; % 不同文件的标准载噪比不同，需要进一步修正
    CNR_std_modi = [4, -3, 1, 2, 0, 0]; % 不同文件的标准载噪比不同，需要进一步修正
    [feaCluster, feaFile, clusterLen, timeLen] = featureCluster(parameter, fileNum, CNR_std_ublox, CNR_std_modi, isInt);
    % 对各个数据贴上场景类别标签
    for i = 1 : fileNum
        class_name_part = categorical();
        class_name_part(1:timeLen(i), 1) = class_name_all(i);
        class_name = [class_name; class_name_part];
    end
    % 特征参数预处理  paraRaw_Norm_atan / paraRaw_Norm
    switch valueMode
        case 1
            feaUsed = feaCluster.paraRaw_Norm_atan;
        case 2
            feaUsed = feaCluster.paraRaw_Norm;
        case 3
            feaUsed = feaCluster.paraRaw;
    end
    [feature_Modify] = featureModify(feaUsed, timeLen, fileNum, parameter, processMode); 
    N = sum(timeLen);
    % 各特征参数提取
    svNum = feature_Modify(:, 1); % 可见卫星数
    GDOP = feature_Modify(:, 2); % DOP值
    cnrMean = feature_Modify(:, 3); % 载噪比均值 
    cnrVar = feature_Modify(:, 4); % 载噪比方差 
    cnrFluc = feature_Modify(:, 5); % 载噪比波动均值 
    blockNum = feature_Modify(:, 6); % 卫星遮挡数
    blockProp = feature_Modify(:, 7); % 遮挡比例
    GDOP_ratio = feature_Modify(:, 8); % DOP值增大比例
    % 组合用以聚类和分类的特征
    if feaChoose == 1
        feature_class = table(cnrMean, cnrVar, cnrFluc, blockProp, GDOP_ratio, class_name);
        predictorNames = {'cnrMean', 'cnrVar', 'cnrFluc', 'blockProp', 'GDOP_ratio'};
    elseif feaChoose == 2
        feature_class = table(cnrMean, cnrVar, svNum, GDOP, class_name);
        predictorNames = {'cnrMean', 'cnrVar', 'svNum', 'GDOP'};
    elseif feaChoose == 3
        feature_class = table(cnrMean, cnrVar, cnrFluc, class_name);
        predictorNames = {'cnrMean', 'cnrVar', 'cnrFluc'};
    end
   %%%%%%%%%%%%  特征训练  %%%%%%%%%%%%%%%%%%%
    % ——————————  SVM  ————————————%
    if isSVM
        [trClass_SVM, valAccu_SVM, valPredi_SVM, valScores_SVM] = trainClassifier_SVM(feature_class, predictorNames);
        [ScoreSVMModel,ScoreTransform] = fitPosterior(trClass_SVM);
        [valPredi_SVM_Num, standard_Num] = plotClassResult(valPredi_SVM, class_name, N, class_name_all);
        if isSmooth
            [valPredi_SVM_Num] = predictSmooth(valPredi_SVM_Num, feaFile, timeLen, fileNum);
        end
        [predictResult, Predi_SVM_bin] = resultAnalysis(valPredi_SVM_Num, standard_Num, fileNum, timeLen);
    end
end % if isTrain




%% ——————————  新数据预测  ————————————%
if isPredict
     % 验证数据
    CNR_std_modi_NewData = 0;
    [feaCluster_NewData, feaFile_NewData, clusterLen_NewData, timeLen_NewData] = featureCluster(parameter_NewData, 1, CNR_std_ublox, CNR_std_modi_NewData, isInt);
    switch valueMode
        case 1
            feaUsed = feaCluster_NewData.paraRaw_Norm_atan;
        case 2
            feaUsed = feaCluster_NewData.paraRaw_Norm;
        case 3
            feaUsed = feaCluster_NewData.paraRaw;
    end
    [feature_Modify_NewData] = featureModify(feaUsed, timeLen_NewData, 1, parameter_NewData, processMode);
    N_NewData = sum(timeLen_NewData);

     % 验证数据参数
    svNum = feature_Modify_NewData(:, 1); % 可见卫星数
    GDOP = feature_Modify_NewData(:, 2); % DOP值
    cnrMean = feature_Modify_NewData(:, 3); % 载噪比均值 
    cnrVar = feature_Modify_NewData(:, 4); % 载噪比方差 
    cnrFluc = feature_Modify_NewData(:, 5); % 载噪比波动均值 
    blockNum = feature_Modify_NewData(:, 6); % 卫星遮挡数
    blockProp = feature_Modify_NewData(:, 7); % 遮挡比例
    GDOP_ratio = feature_Modify_NewData(:, 8); % DOP值增大比例
     % 组合用以聚类和分类的特征
    if feaChoose == 1
        feature_class_NewData = table(cnrMean, cnrVar, cnrFluc, blockProp, GDOP_ratio);   
    elseif feaChoose == 2
        feature_class_NewData = table(cnrMean, cnrVar, svNum, GDOP);
    elseif feaChoose == 3
        feature_class_NewData = table(cnrMean, cnrVar, cnrFluc);
    end
    % 新数据预测
    [yfit, valScores_SVM_NewData] = trClass_SVM.predictFcn(feature_class_NewData);
    yfit_Num = zeros(N_NewData, 1);
    for j = 1 : fileNum
        index_1 = yfit == class_name_all(j);
        yfit_Num(index_1) = j;
    end
    if isSmooth
        [yfit_Num] = predictSmooth(yfit_Num, feaFile_NewData, timeLen_NewData, 1);
    end
    figure();
    scatter(feaCluster_NewData.pos_enu(:, 1), feaCluster_NewData.pos_enu(:, 2), fileNum, yfit_Num, 'filled');
    title('NewDataPrediction');
    colormap(hsv(fileNum));
    colorbar;
end


% yfit_Num_temple = yfit_Num(3660 : 4270);
% predictResult_temp = zeros(6,1);
% for i = 1 : 6
%     predictResult_temp(i) = sum(yfit_Num_temple==i)/length(yfit_Num_temple);
% end






















% clc; 
% close all;
% isRead = 1;
% if isRead
%     clear; 
%     load CNR_std_ublox.mat;
%     class_Num = 6;
%     isInt = 1;  % 仅读取整秒处数据，因为标定数据仅在整秒处
%     class_name_all = categorical({'canyon', 'urban', 'surburb', 'viaduct_up', 'viaduct_down', 'boulevard'});
%     fileNum = 6;
%     fileType = [1, 2, 1, 2, 1, 1];  % 标定数据类型
%     [filename, fileCalib, fileEphBds, fileEphGps, YYMMDD, TYPE] = fileNameInitial();
%     [parameter, calibration] = paraInitial(fileNum);
%     for i = 1 : fileNum
%         [parameter(i)] = readNMEA(parameter(i), filename{i}, YYMMDD{i}, fileEphBds{i}, fileEphGps{i}, isInt, TYPE{i});
%         [calibration(i)] = readCalib(calibration(i), fileCalib{i}, YYMMDD{i}, fileType(i));
%         [parameter(i)] = ephStateCal(parameter(i), fileEphBds{i}, fileEphGps{i});
%         [parameter(i)] = posENU_error(parameter(i), calibration(i), fileType(i));
%     end
% end
% isKNN = 0;
% isSVM = 1;
% isKMEAN = 0;
% isGMM = 0;
% isHCLU = 0;
% class_name = categorical();
% mode = 3; % 特征预处理模式: 基于里程平滑（1）  /   基于时间平滑（2） /  不处理（3）
% %% %%%%%%%%%%  特征计算  %%%%%%%%%%%%%%%%%%
% [feature_Norm, feature, timeLen, pos_xyz, vel, enuMap] = featureGet(parameter, fileNum, CNR_std_ublox);
% N = sum(timeLen);
% % 对各个数据贴上场景类别标签
% for i = 1 : fileNum
%     class_name_part = categorical();
%     class_name_part(1:timeLen(i), 1) = class_name_all(i);
%     class_name = [class_name; class_name_part];
% end
% 
% % 特征参数预处理
% [feature_Modify] = featureModify(feature_Norm, timeLen, fileNum, parameter, mode);
% % 各特征参数提取
% svNum = feature_Modify(:, 1); % 可见卫星数
% GDOP = feature_Modify(:, 2); % DOP值
% cnrMean = feature_Modify(:, 3); % 载噪比均值
% cnrVar = feature_Modify(:, 4); % 载噪比方差
% cnrFluc = feature_Modify(:, 5); % 载噪比波动均值
% blockNum = feature_Modify(:, 6); % 卫星遮挡数
% blockProp = feature_Modify(:, 7); % 遮挡比例
% GDOP_ratio = feature_Modify(:, 8); % DOP值增大比例
% % 组合用以聚类和分类的特征
% feature_class = table(svNum, GDOP, cnrMean, cnrVar, cnrFluc, blockNum, blockProp, GDOP_ratio, class_name);
% 
% %% %%%%%%%%%%%%  特征训练  %%%%%%%%%%%%%%%%%%%
% predictorNames = {'svNum', 'GDOP', 'cnrMean', 'cnrVar'};
% % ——————————  KNN  ————————————%
% if isKNN
%     [trClass_KNN, valAccu_KNN, valPredi_KNN, valScores_KNN] = trainClassifier_KNN(feature_class, predictorNames);
%     [valPredi_KNN_Num, standard_Num] = plotClassResult(valPredi_KNN, class_name, enuMap, N, class_name_all, 'KNN');
% end
% 
% % ——————————  SVM  ————————————%
% if isSVM
%     [trClass_SVM, valAccu_SVM, valPredi_SVM, valScores_SVM] = trainClassifier_SVM(feature_class, predictorNames);
%     [valPredi_SVM_Num, standard_Num] = plotClassResult(valPredi_SVM, class_name, enuMap, N, class_name_all, 'SVM');
% %     [valPredi_SVM_Num] = predictSmooth(valPredi_SVM_Num, parameter, timeLen, fileNum);
%     [predictResult, Predi_SVM_bin] = resultAnalysis(valPredi_SVM_Num, standard_Num, fileNum, timeLen);
% end




