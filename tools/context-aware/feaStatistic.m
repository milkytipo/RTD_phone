function [feaEachClu] = feaStatistic(feaCluster, idxExp, idxExpRaw, class_Num)
feaEachClu = struct(...
    'paraRaw',               [],...  % 原始特征参数
    'paraRaw_Norm',          [],...  % 归一化
    'paraRaw_Norm_atan',     [],...  % 求反正切
    'idxExpRaw',             []...  % 求反正切
    );
feaEachClu(1:class_Num) = feaEachClu;
for i = 1 : class_Num
    row_No = idxExp == i;
    feaEachClu(i).paraRaw = feaCluster.paraRaw(row_No, :);
    feaEachClu(i).paraRaw_Norm = feaCluster.paraRaw_Norm(row_No, :);
    feaEachClu(i).paraRaw_Norm_atan = feaCluster.paraRaw_Norm_atan(row_No, :);
    feaEachClu(i).idxExpRaw = idxExpRaw(row_No);
end