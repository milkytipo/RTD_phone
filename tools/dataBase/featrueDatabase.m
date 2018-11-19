function [feaCluster, feaFile, timeLen] = featrueDatabase(parameter, fileNum, CNR_std_ublox, CNR_std_modi, isInt)

% ———————— [可见卫星数，DOP值，均值，方差，波动性，被遮挡卫星数，遮挡比例系数, 误差, 累积里程数] ————————————————
pNum = 5; % 总特征数量

%% %———————————— 特征参数初始化 ————————————%
timeLen = zeros(fileNum, 1);  % 各文件中提取特征的历元数
for i = 1 : fileNum
    timeLen(i) = size(parameter(i).SOW, 2);
end
% [可见卫星数，DOP值，均值，方差，被遮挡卫星数]
tNum = max(timeLen); % 总历元数量

% ———————————— 各文件的特征参数结构体初始化  ——————————————%
feaFile = struct(...
    'para',          [],...          % 原始特征参数
    'paraSmooth',    [],...          % 平滑后的特征参数
    'pos_xyz',       [],...          % 位置坐标
    'vel',           [],...          % 速度
    'pos_enu',       [],...          % 二维平面地图用
    'movLength',     [],...          % 移动距离
    'smoothIndex',   [], ...  % 分割段落起止坐标
    'time',           [] ...  % 时间节点
    );

para = zeros(tNum, pNum);  % 原始特征参数
paraSmooth = zeros(tNum, pNum);  % 平滑后的特征参数
pos_xyz = zeros(tNum, 3);  % 位置坐标
vel = zeros(tNum, 1);  % 速度
pos_enu = zeros(tNum, 3);  % 二维平面图
smoothIndex = zeros(tNum, 2); % 平滑的起止坐标
movLength = zeros(tNum, 1);  % 速度
time = zeros(tNum, 4); 
feaFile.para = para; % 每个文件的特征参数
feaFile.paraSmooth = paraSmooth; % 每个文件平滑后的特征参数
feaFile.pos_xyz = pos_xyz; % 每个文件的特征参数
feaFile.vel = vel; % 每个文件的特征参数
feaFile.pos_enu = pos_enu; % 二维平面图
feaFile.movLength = movLength;
feaFile.smoothIndex = smoothIndex; % 每个文件的特征参数
feaFile.time = time;
feaFile(1:fileNum) = feaFile;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ———————————— 总聚类特征初始化  ——————————————%
feaCluster = struct(...
    'paraRaw',               [],...  % 原始特征参数
    'paraRaw_Norm',          [],...  % 归一化
    'paraRaw_Norm_atan',     [],...  % 求反正切
    'pos_enu',               [],...  % 二维平面地图用
    'movLength',               [],...  % 距离
    'time',           [] ...  % 时间节点
    );

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %————————————  参数特征提取  ————————————————

for i = 1 : fileNum
    index = 0;
    paraFile = parameter(i);  
    for k = 7 : timeLen(i)
        if abs(paraFile.SOW(1,k)-round(paraFile.SOW(1,k))) < 0.01  % 只读取在整秒处的数据
            index = index + 1;
            feaFile(i).pos_xyz(index, :) = paraFile.pos_xyz(:, k)';
            feaFile(i).vel(index) = paraFile.vel(k);
            feaFile(i).pos_enu(index, :) = paraFile.pos_enu(:, k)';
            feaFile(i).movLength(index) = paraFile.movLength(k);
            feaFile(i).time(index,:) = paraFile.SOW(1:4, k)';
            % ———————— 1、不可见卫星数占比 —————————— %
            if isInt
                satNum = paraFile.satNum(k);
            else
                satNum = paraFile.satNum((k-4):k);
            end
            satNum(isnan(satNum)) = [];     
            
            if isInt
                blockNum = paraFile.blockNum(k);
            else
                blockNum = paraFile.blockNum((k-4):k);
            end
            blockNum(isnan(blockNum)) = [];       
           
            feaFile(i).para(index, 1) = mean(blockNum) / (mean(blockNum) + mean(satNum));

            % ——————— 2~4、弱信号比例，弱信号均值，信号波动值 ———————%
            satNum_temp = paraFile.satNum(k);
            prnNo_temp = paraFile.prnNo(1:satNum_temp, k);
            for j = 1 : length(paraFile.prnNo_useless)
                prnNo_temp(prnNo_temp == paraFile.prnNo_useless(j)) = [];  % 人工去除需要删除的卫星号
            end
            satNum_temp = length(prnNo_temp);
            attenuation = zeros(1, satNum_temp);   % 均值、方差
            atten_var = zeros(1, satNum_temp);   % 波动性
            if satNum_temp > 0
                for j = 1 : satNum_temp
                    prn = prnNo_temp(j);
                    el = paraFile.Elevation(prn, k);
                    if el == 0
                        el = 1;
                    end
                    CNR_std = CNR_std_ublox(el) + CNR_std_modi(i);
                    
                    if isInt
                        atten_temp = CNR_std - paraFile.CNR(prn, k);
                    else
                        atten_temp = CNR_std - paraFile.CNR(prn, (k-4):k);
                    end
                    atten_temp(isnan(atten_temp)) = [];
                    attenuation(j) = mean(atten_temp);
                    atten_var(j) = paraFile.CNR_Var(prn, k);
                end
                feaFile(i).para(index, 2) = length(find(attenuation>5)) / satNum_temp;
                if feaFile(i).para(index, 2) > 0
                    feaFile(i).para(index, 3) = mean(attenuation(attenuation>5));
                else
                    feaFile(i).para(index, 3) = 0;
                end
                feaFile(i).para(index, 4) = mean(atten_var);
            elseif  satNum_temp == 0
                feaFile(i).para(index, 2) = feaFile(i).para(index-1, 2);
                feaFile(i).para(index, 3) = feaFile(i).para(index-1, 3); % 由于只有0个数，所以默认设为5
                feaFile(i).para(index, 4) = feaFile(i).para(index-1, 4);
            end % if paraFile.satNum(k) > 1

            % —————————— 5、GDOP增大比例 ——————————%
            if isInt 
                GDOP_ratio = paraFile.GDOP_ratio(k);
            else
                GDOP_ratio = paraFile.GDOP_ratio((k-4):k);
            end
            GDOP_ratio(isnan(GDOP_ratio)) = [];            
            feaFile(i).para(index, 5) = mean(GDOP_ratio);
            
        end % if abs(paraFile.SOW-round(paraFile.SOW)) < 0.01
    end % for k = 1 : timeLen(i)
    
    % ————————  去除无效的点  ————————————%
    feaFile(i).para = feaFile(i).para(1:index, :); % 
    feaFile(i).pos_xyz = feaFile(i).pos_xyz(1:index, :);
    feaFile(i).vel = feaFile(i).vel(1:index, :);
    feaFile(i).pos_enu = feaFile(i).pos_enu(1:index, :);
    feaFile(i).movLength = feaFile(i).movLength(1:index, :);
    feaFile(i).time = feaFile(i).time(1:index, :);
    timeLen(i) = index;  % 更新feature数目

end % for i = 1 : fileNum

%% ———————— 将各个文件的聚类参数合并 ——————————————%
for i = 1 : fileNum
    feaCluster.paraRaw = [feaCluster.paraRaw; feaFile(i).para];
    feaCluster.time = [feaCluster.time; feaFile(i).time];
end



%% %%%%%%%%%%% 参数归一化 %%%%%%%%%%%%%%
for i = 1 : pNum    
%     Mu = median(feature(:, i));
%     sigma = sum(abs(feature(:, i) - Mu))/N;
    N_raw = sum(timeLen);
    Mu_raw = mean(feaCluster.paraRaw(:, i));
    sigma_raw = sqrt(sum((feaCluster.paraRaw(:, i) - Mu_raw).^2) /N_raw);   
    feaCluster.paraRaw_Norm(:, i) = (feaCluster.paraRaw(:, i) - Mu_raw) / sigma_raw;
    feaCluster.paraRaw_Norm_atan(:, i) = atan(feaCluster.paraRaw_Norm(:, i)); 
    
end

%% %%%%%%%%%%% 计算地图显示用的ENU坐标 %%%%%%%%%%%%%%
% index = 1;
% for i = 1 : fileNum
%     
%     ENU_temp = parameter(i).pos_enu;
%     enuMap(:,index:(index+timeLen(i)-1)) = ENU_temp + [(max(enuMap(1,:)) - min(ENU_temp(1,:)) + 500);0;0];
%     index = index + timeLen(i);
% end   

end % EOF : function