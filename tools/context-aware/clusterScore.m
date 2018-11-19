function [ValiIndex, dist_cluster] = clusterScore(feature, cluster_No, cluster_Std_No, class_Num)
N = length(cluster_No);
ValiIndex = struct(...
    'JC',      0,...    % Jaccard 系数
    'FMI',     0,...    % FM 指数
    'RI',      0,...    % Rand 指数
    'DBI',     0,...    % DB 指数
    'DI',      0 ...    % Dunn 指数
    );
dist_cluster = struct(...
    'dmin',     [],...    % 簇间最小间距
    'dcen',     [],...    % 簇间中心间距
    'dmax',     [] ...    % 簇间最大间距
    );
%% 外部性能指标计算
a = 0;
b = 0;
c = 0;
d = 0;
for i = 1 : (N-1)
    for j = (i+1) : N
        if cluster_No(i)==cluster_No(j) && cluster_Std_No(i)==cluster_Std_No(j)
            a = a + 1;
        end
        if cluster_No(i)==cluster_No(j) && cluster_Std_No(i)~=cluster_Std_No(j)
            b = b + 1;
        end
        if cluster_No(i)~=cluster_No(j) && cluster_Std_No(i)==cluster_Std_No(j)
            c = c + 1;
        end
        if cluster_No(i)~=cluster_No(j) && cluster_Std_No(i)~=cluster_Std_No(j)
            d = d + 1;
        end
    end
end
% 计算Jaccard系数
JC = a / (a + b + c);
% 计算FM指数
FMI = sqrt(a^2 / ((a+b)*(a+c)));
% 计算Rand指数
RI = 2 * (a + d) / (N*(N-1));

%% 内部性能指标
avg_C = zeros(1, class_Num);
diam_C = zeros(1, class_Num);
for i = 1 : class_Num
    row_No = cluster_No == i;
    avg_C(i) = mean(pdist(feature(row_No, :))); % 计算簇内平均距离
    diam_C(i) = max(pdist(feature(row_No, :))); % 计算簇内最大距离
end

dmin = zeros(class_Num, class_Num);
dcen = zeros(class_Num, class_Num);
dmax = zeros(class_Num, class_Num);
for i = 1 : class_Num-1
    for j = i+1 : class_Num
        row_No = cluster_No == i;
        feature_i = feature(row_No, :);
        row_No = cluster_No == j;
        feature_j = feature(row_No, :);
        dmin(i, j) = min(min(pdist2(feature_i, feature_j, 'euclidean'))); % 计算簇间的最小距离
        dmin(j, i) = dmin(i, j);
        dmax(i, j) = max(max(pdist2(feature_i, feature_j, 'euclidean'))); % 计算簇间的最小距离
        dmax(j, i) = dmax(i, j);
        feature_i_mean = mean(feature_i, 1);
        feature_j_mean = mean(feature_j, 1);
        dcen(i, j) = pdist2(feature_i_mean, feature_j_mean, 'euclidean'); % 计算簇间的平均距离
        dcen(j, i) = dcen(i, j);
    end
end

% 计算DB指数和Dunn指数
DBI_part = nan(1, class_Num);
DI_part = nan(1, class_Num);
for i = 1 : class_Num
    for j = 1 : class_Num
        if i ~= j 
            % 计算DB指数
            DBI_temp = (avg_C(i) + avg_C(j)) / dcen(i, j);
            if isnan(DBI_part(i))
                DBI_part(i) = DBI_temp;
            else
                if DBI_part(i) < DBI_temp
                    DBI_part(i) = DBI_temp;
                end
            end
            % 计算Dunn指数
            DI_temp = dmin(i, j) / (max(diam_C));
            if isnan(DI_part(i))
                DI_part(i) = DI_temp;
            else
                if DI_part(i) > DI_temp
                    DI_part(i) = DI_temp;
                end
            end 
        end % if i ~= j 
    end % for j = 1 : class_Num
end % for i = 1 : class_Num          
DBI = mean(DBI_part);
DI = min(DI_part);
% 性能指标赋值
ValiIndex.JC = JC;
ValiIndex.FMI = FMI;
ValiIndex.RI = RI;
ValiIndex.DBI = DBI;
ValiIndex.DI = DI;
% 各个簇之间的距离赋值
dist_cluster.dmin = dmin;
dist_cluster.dcen = dcen;
dist_cluster.dmax = dmax;
