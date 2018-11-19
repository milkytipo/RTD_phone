function [feaCluster, feaFile, clusterLen, timeLen] = featureCluster(parameter, fileNum, CNR_std_ublox, CNR_std_modi, isInt)

% ———————— [可见卫星数，DOP值，均值，方差，波动性，被遮挡卫星数，遮挡比例系数, 误差, 累积里程数] ————————————————
pNum = 9; % 总特征数量
winLen = 50; % 平滑窗口长度 /m
minEpoch = 7; % 平滑窗口的最小历元数目
isSmooth = 1; % 是否进行数据平滑

%% %———————————— 特征参数初始化 ————————————%
timeLen = zeros(fileNum, 1);  % 各文件中提取特征的历元数
clusterLen = zeros(fileNum, 1);  % 各文件特征平滑后的历元数
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
    'paraSmooth',            [],...  % 按距离平滑后的特征参数
    'paraSmooth_Norm',       [],...  % 归一化
    'paraSmooth_Norm_atan',  [],...  % 求反正切
    'pos_enu',               [],...  % 二维平面地图用
    'movLength',               [],...  % 距离
    'smoothIndex',           [], ...  % 分割段落起止坐标
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
            % ———————— 1、可见卫星数特征 —————————— %
            if isInt
                satNum = paraFile.satNum(k);
            else
                satNum = paraFile.satNum((k-4):k);
            end
            satNum(isnan(satNum)) = [];            
            feaFile(i).para(index, 1) = mean(satNum);

            %  ———————— 2、GDOP值特征 —————————— %
            if isInt
                GDOP = paraFile.GDOP(k);
            else
                GDOP = paraFile.GDOP((k-4):k);
            end
            GDOP(isnan(GDOP)) = [];           
            feaFile(i).para(index, 2) = mean(GDOP);

            % ——————— 3~5、载噪比均值、方差和波动性 ———————%
            satNum_temp = paraFile.satNum(k);
            prnNo_temp = paraFile.prnNo(1:satNum_temp, k);
            for j = 1 : length(paraFile.prnNo_useless)
                prnNo_temp(prnNo_temp == paraFile.prnNo_useless(j)) = [];  % 人工去除需要删除的卫星号
            end
            satNum_temp = length(prnNo_temp);
            
            attenuation = zeros(1, satNum_temp);   % 均值、方差
            atten_var = zeros(1, satNum_temp);   % 波动性
            if satNum_temp > 1
                for j = 1 : satNum_temp
                    prn = prnNo_temp(j);
                    el = paraFile.Elevation(prn, k);
                    if el == 0
                        CNR_std = CNR_std_ublox(1) + CNR_std_modi(i);
                    else
                        CNR_std = CNR_std_ublox(el) + CNR_std_modi(i);
                    end
                    if isInt
                        atten_temp = paraFile.CNR(prn, k) - CNR_std;
                    else
                        atten_temp = paraFile.CNR(prn, (k-4):k) - CNR_std;
                    end
                    atten_temp(isnan(atten_temp)) = [];
                    attenuation(j) = mean(atten_temp);
                    atten_var(j) = paraFile.CNR_Var(prn, k);
                end
                feaFile(i).para(index, 3) = -mean(attenuation);
                if feaFile(i).para(index, 3) < 0
                    feaFile(i).para(index, 3) = 0;
                end
                feaFile(i).para(index, 4) = sqrt(var(attenuation));
                feaFile(i).para(index, 5) = mean(atten_var);
            elseif satNum_temp == 1
                prn = paraFile.prnNo(1, k);
                el = paraFile.Elevation(prn, k);
                if el == 0
                    CNR_std = CNR_std_ublox(1) + CNR_std_modi(i);
                else
                    CNR_std = CNR_std_ublox(el) + CNR_std_modi(i);
                end
                if isInt
                    atten_temp = paraFile.CNR(prn, k) - CNR_std;
                else
                    atten_temp = paraFile.CNR(prn, (k-4):k) - CNR_std;
                end
                atten_temp(isnan(atten_temp)) = [];
                attenuation(1) = mean(atten_temp);
                atten_var(1) = paraFile.CNR_Var(prn, k);
                feaFile(i).para(index, 3) = -attenuation;
                feaFile(i).para(index, 4) = feaFile(i).para(index-1, 4); % 由于只有1个数，所以默认设为5
                feaFile(i).para(index, 5) = mean(atten_var);
            elseif  satNum_temp == 0
                feaFile(i).para(index, 3) = 40;
                feaFile(i).para(index, 4) = feaFile(i).para(index-1, 4); % 由于只有0个数，所以默认设为5
                feaFile(i).para(index, 5) = feaFile(i).para(index-1, 5);
            end % if paraFile.satNum(k) > 1

            % —————————— 6、被遮挡卫星数 ——————————%
            if isInt
                blockNum = paraFile.blockNum(k);
            else
                blockNum = paraFile.blockNum((k-4):k);
            end
            blockNum(isnan(blockNum)) = [];            
            feaFile(i).para(index, 6) = mean(blockNum);

            % —————————— 7、卫星遮挡比例系数 ——————————%
            feaFile(i).para(index, 7) = feaFile(i).para(index, 6) / (feaFile(i).para(index, 6)+feaFile(i).para(index, 1));

            % —————————— 8、GDOP增大比例 ——————————%
            if isInt 
                GDOP_ratio = paraFile.GDOP_ratio(k);
            else
                GDOP_ratio = paraFile.GDOP_ratio((k-4):k);
            end
            GDOP_ratio(isnan(GDOP_ratio)) = [];            
            feaFile(i).para(index, 8) = mean(GDOP_ratio);

            % —————————— 9、定位误差 ——————————%
            feaFile(i).para(index, 9) = paraFile.ENU_error(4, k);
            
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


%% %%%%%%%%%%% 对各参数按里程平滑 %%%%%%%%%%%%%%
if isSmooth
    for i = 1 : fileNum
        % ————————按100米路段对数据进行分割，计算分割后路段的起止坐标 ——————————————%
        partN = 0;
        st = 1;
        while 1
            partN = partN + 1;
            feaFile(i).smoothIndex(partN, 1) = st;
            lenEnd = feaFile(i).movLength(st) + winLen;
            [~, ed] = min(abs(feaFile(i).movLength - lenEnd));
            if ed - st < minEpoch  % 路段间隔不小于minEpoch个历元
                ed = st + minEpoch;
            end
            if (ed > timeLen(i)) || (ed==timeLen(i)-1)   % 终止坐标不超过数据长度
                ed = timeLen(i);
            end
            feaFile(i).smoothIndex(partN, 2) = ed;
            st = ed + 1;
            if st > timeLen(i)
                break;
            end
        end
        feaFile(i).smoothIndex = feaFile(i).smoothIndex(1:partN, :);
        clusterLen(i) = partN;

         % ————————按100米路段对数据进行分割，计算分割后路段的特征值 ——————————————%
        for j = 1 : partN
           
            st = feaFile(i).smoothIndex(j, 1);
            ed = feaFile(i).smoothIndex(j, 2);
%             partIndexAll(index, 1) = st + indexAdd;
%             partIndexAll(index, 2) = ed + indexAdd;
            % ———————— 1、可见卫星数特征 —————————— %
            feaFile(i).paraSmooth(j, 1) = mean(feaFile(i).para(st:ed, 1));
            %  ———————— 2、GDOP值特征 —————————— %
            feaFile(i).paraSmooth(j, 2) = mean(feaFile(i).para(st:ed, 2));
            %  ———————— 3、载噪比均值 —————————— %
            feaFile(i).paraSmooth(j, 3) = mean(feaFile(i).para(st:ed, 3));
            %  ———————— 4、载噪比方差 —————————— %
            feaFile(i).paraSmooth(j, 4) = mean(feaFile(i).para(st:ed, 4));
            %  ———————— 5、载噪比波动性 —————————— %
            feaFile(i).paraSmooth(j, 5) = mean(feaFile(i).para(st:ed, 5));
            %  ———————— 6、被遮挡卫星数 —————————— %
            feaFile(i).paraSmooth(j, 6) = mean(feaFile(i).para(st:ed, 6));
            %  ———————— 7、卫星遮挡比例系数 —————————— %
            feaFile(i).paraSmooth(j, 7) = mean(feaFile(i).para(st:ed, 7));
            %  ———————— 8、GDOP增大比例 —————————— %
            feaFile(i).paraSmooth(j, 8) = mean(feaFile(i).para(st:ed, 8));
            %  ———————— 9、定位误差 —————————— %
            feaFile(i).paraSmooth(j, 9) = mean(feaFile(i).para(st:ed, 9));
        end % for j = 1 : partN
        feaFile(i).paraSmooth = feaFile(i).paraSmooth(1:partN, :);
    end % for i = 1 : fileNum
end % if isSmooth

%% ———————— 将各个文件的聚类参数合并 ——————————————%
for i = 1 : fileNum
    feaCluster.paraRaw = [feaCluster.paraRaw; feaFile(i).para];
    feaCluster.paraSmooth = [feaCluster.paraSmooth; feaFile(i).paraSmooth];
    feaCluster.movLength = [feaCluster.movLength; feaFile(i).movLength];
    feaCluster.time = [feaCluster.time; feaFile(i).time];
    if isempty(feaCluster.smoothIndex)
        smoothAdd = 0;
    else
        smoothAdd = max(feaCluster.smoothIndex(:,2));
    end
    feaCluster.smoothIndex = [feaCluster.smoothIndex; feaFile(i).smoothIndex + smoothAdd];
    
    ENU_temp = feaFile(i).pos_enu;
    if isempty(feaCluster.pos_enu)
        st_map = 0;
    else
        st_map = max(feaCluster.pos_enu(:,1));
    end
    ENU_temp(:, 1) = ENU_temp(:, 1) + (st_map - min(ENU_temp(:,1)) + 500);
    feaCluster.pos_enu = [feaCluster.pos_enu; ENU_temp];
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
    
    N_Smo = sum(clusterLen);
    Mu_Smo = mean(feaCluster.paraSmooth(:, i));
    sigma_Smo = sqrt(sum((feaCluster.paraSmooth(:, i) - Mu_Smo).^2) /N_Smo);   
    feaCluster.paraSmooth_Norm(:, i) = (feaCluster.paraSmooth(:, i) - Mu_Smo) / sigma_Smo;
    feaCluster.paraSmooth_Norm_atan(:, i) = atan(feaCluster.paraSmooth_Norm(:, i));
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