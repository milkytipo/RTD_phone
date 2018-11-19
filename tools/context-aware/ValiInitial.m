function [ValiIndex, dist_cluster] = ValiInitial(cluTimes_N)
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
ValiIndex(1:cluTimes_N) = ValiIndex;
dist_cluster(1:cluTimes_N) = dist_cluster;