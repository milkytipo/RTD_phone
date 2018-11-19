clc; 
close all;
isRead = 0;
if isRead
    clear; 
    load CNR_std_ublox.mat;
    isInt = 1;  % 仅读取整秒处数据，因为标定数据仅在整秒处
    class_name_all = categorical({'canyon', 'urban', 'surburb', 'open', 'viaduct_down', 'boulevard'});
    fileNum = 6;
    fileNo = [1:6];
    fileType = [1, 1, 1, 1, 1, 1];% [1, 1, 1, 2, 1, 1];% [1, 1, 1, 1, 3, 1, 1];  % 标定数据类型
    [filename, fileCalib, fileEphBds, fileEphGps, YYMMDD, TYPE] = fileNameInitial();
    [parameter, calibration] = paraInitial(fileNum);
    for k = 1 : length(fileNo)
        i = fileNo(k);
        [parameter(i)] = readNMEA(parameter(i), filename{i}, YYMMDD{i}, fileEphBds{i}, fileEphGps{i}, isInt, TYPE{i});
        [calibration(i)] = readCalib(calibration(i), fileCalib{i}, YYMMDD{i}, fileType(i));
        [parameter(i)] = ephStateCal(parameter(i), fileEphBds{i}, fileEphGps{i});
        [parameter(i)] = posENU_error(parameter(i), calibration(i), fileType(i));
    end
end

isFeaCal = 0; % 重新计算信号特征参数
isKmean = 1;
isGMM = 0;
isPosErr = 0; % 根据定位误差进行聚类分析
isSmooth = 0; % 将特征参数平滑后再聚类
isMerge = 1; % 对聚类结果按照一定公里数合并
isPCA = 0; % 进行PCA分析
isPlot = 1; 
class_name = categorical();
mode = 3; % 特征预处理模式: 基于里程平滑（1）  /   基于时间平滑（2） /  不处理（3）
class_Num_all = 10; % 聚类的总类别数
cluster_Times = 1; % 由于初始值不同，总的聚类次数
%% %%%%%%%%%%  特征计算  %%%%%%%%%%%%%%%%%%
if isFeaCal %  3 4 5 7 8
    parameter(1).prnNo_useless = [18]; % 不计算载噪比的卫星号
    parameter(6).prnNo_useless = [5, 13]; % 不计算载噪比的卫星号
%     parameter(1).prnNo_useless = [7, 8]; % 不计算载噪比的卫星号
    CNR_std_modi = [0, 2, -1, 0, 0, 0, 0]; % 不同文件的标准载噪比不同，需要进一步修正
    [feaCluster, clusterLen, timeLen] = featureCluster(parameter, fileNum, CNR_std_ublox, CNR_std_modi, isInt);
    N_clu = sum(clusterLen);
    N_epoch = sum(timeLen);
    % 特征参数预处理
    [feature_Modify] = featureModify(feaCluster.paraRaw_Norm_atan, timeLen, fileNum, parameter, mode);
    % 各特征参数提取
    svNum = feature_Modify(:, 1); % 可见卫星数
    GDOP = feature_Modify(:, 2); % DOP值
    cnrMean = feature_Modify(:, 3); % 载噪比均值 
    cnrVar = feature_Modify(:, 4); % 载噪比方差 
    cnrFluc = feature_Modify(:, 5); % 载噪比波动均值 
    blockNum = feature_Modify(:, 6); % 卫星遮挡数
    blockProp = feature_Modify(:, 7); % 遮挡比例
    GDOP_ratio = feature_Modify(:, 8); % DOP值增大比例
    ENU_err = feature_Modify(:, 9); % 总误差 
    ENU_err_raw = feaCluster.paraRaw(:, 9); % 原始总误差 
end % if isFeaCal

%% 利用定位误差进行场景聚类
if isPosErr
    pos_clu = [1, 2, 3, 4, 5, 7, 9, 11, 15, 20, 30, 40, 50, 70, 100]; % 定义聚类间隔
    pos_clu_N = length(pos_clu) + 1;
    pos_err = feaCluster.paraRaw(:, 9); % 定位误差
    idx_posErr = zeros(N_epoch, 1);
    % —————————— 根据定位误差聚类 ——————————%
    for i = 1 : pos_clu_N
    if i == 1
        row = pos_err < pos_clu(i);
    elseif i == pos_clu_N
        row = pos_err>=pos_clu(i-1);
    else
        row = pos_err>=pos_clu(i-1) & pos_err<pos_clu(i);
    end
    idx_posErr(row) = i;    
    end
    
    if isMerge
        [idx_posErr] = clusterMerge(idx_posErr, feaCluster.smoothIndex);
    end
    
    % —————————— 画图 ————————————%
%     figure();
%     scatter(feaCluster.pos_enu(:, 1), feaCluster.pos_enu(:, 2), 6, idx_posErr, 'filled');
%     title('PosErr');
%     colormap(hsv(pos_clu_N));
%     colorbar;
end

%% %%%%%%%%%%%%  聚类分析  %%%%%%%%%%%%%%%%%%%
% class_Num = 8;
feature_cluster = [cnrMean, cnrVar, cnrFluc,blockProp, GDOP_ratio];
if isPCA
    [coeff,~,latent] = pca(feature_cluster);
    feature_cluster = feature_cluster * coeff(:, 1:3);
end
class_N = length(class_Num_all);
[ValiIndex, dist_cluster] = ValiInitial(class_N);
for i = 1 : class_N
    class_Num = class_Num_all(i); % 选择聚类的总类别数
    
    for j = 1 : cluster_Times
        if isSmooth
            % ————————————  k-means  ——————————————
            idxExp = zeros(N_epoch, 1);
            if isKmean
                clu_method = 'Kmeans';
                [idx, k_center] = kmeans(feature_cluster, class_Num);
                for k = 1 : N_clu
                    st = feaCluster.smoothIndex(k, 1);
                    ed = feaCluster.smoothIndex(k, 2);
                    idxExp(st:ed) = idx(k);
                end
            end

            % ————————————  GMM  ——————————————
            if isGMM
                clu_method = 'GMM';
                options = statset('MaxIter', 3000);
                GMModel = fitgmdist(feature_cluster, class_Num, 'Options', options, 'RegularizationValue', 0.01);  % 'Start', S
                [idx, logl, P_matrix, M_distance] = cluster(GMModel, feature_cluster);
                for k = 1 : N_clu
                    st = feaCluster.smoothIndex(k, 1);
                    ed = feaCluster.smoothIndex(k, 2);
                    idxExp(st:ed) = idx(k);
                end
            end

        % ———————— if isSmooth  —————————— 
        else % if isSmooth
            if isKmean
                clu_method = 'Kmeans';
                [idx, k_center] = kmeans(feature_cluster, class_Num, 'MaxIter', 200);
                idxExp = idx;
            end
            if isGMM
                clu_method = 'GMM';
                options = statset('MaxIter', 3000);
                GMModel = fitgmdist(feature_cluster, class_Num, 'Options', options, 'RegularizationValue', 0.01);  % 'Start', S
                [idx, logl, P_matrix, M_distance] = cluster(GMModel, feature_cluster);
                idxExp = idx;
            end
        end % if isSmooth
        
        % ————————————— 聚类结果按照里程数合并 ———————————————— %
        idxExpRaw = idxExp;
        if isMerge
            [idxExp] = clusterMerge(idxExp, feaCluster.smoothIndex);
        end
        [idxExp] = idxSort(idxExp, feaCluster.paraRaw(:, 3));  % 将类别标号重新排序
         % ———————————————— 聚类结果画图 ———————————————— %
        if isPlot
            figure();
            scatter(feaCluster.pos_enu(:, 1), feaCluster.pos_enu(:, 2), 7, idxExp, 'filled');
            title(clu_method);
            colormap(hsv(class_Num));
            colorbar;
            if isPCA
                figure();
                scatter3(feature_cluster(:, 1), feature_cluster(:, 2), feature_cluster(:, 3), 7, idxExp, 'filled');
                title('parameters——PCA');
                colormap(hsv(class_Num));
                colorbar;
            end
        end
        
        % ———————————————— 聚类误差分析 ———————————————— %
        [ValiIndex_temp, dist_cluster_temp] = clusterScore(feature_cluster, idxExp, idx_posErr, class_Num);
        dist_cluster(i) = dist_cluster_temp;
        [ValiIndex(i)] = scoreCal(ValiIndex(i), ValiIndex_temp, j);
    end % for j = 1 : cluster_Times
end % for i = 1 : class_N
[feaEachClu] = feaStatistic(feaCluster, idxExp, idxExpRaw, class_Num);  
% eva = evalclusters(feature_cluster, 'kmeans', 'DaviesBouldin', 'KList',[2:20]);  
figure()
boxplot(feaCluster.paraRaw(:, 3), idxExp);
figure()
boxplot(feaCluster.paraRaw(:, 5), idxExp);
figure()
boxplot(feaCluster.paraRaw(:, 7), idxExp);
figure()
boxplot(feaCluster.paraRaw(:, 9), idxExp);

