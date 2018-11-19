%%%%%% Example of Training/Testing a 2d-mixture of 2 gaussians driven by
%%%%%% HMM
clear; clc;close all;


d                                   = 4;    % 状态数目
m                                   = 1;   %  高斯分布维度
L                                   = 1;    % 生成L组样本
R                                   = 1;    % 训练R组样本
Ntrain                              = 5000;    % 训练样本数
Ntest                               = 10000;    % 测试样本数
options.nb_ite                      = 2000;      % 迭代次数

PI                                  = [0.25; 0.25; 0.25; 0.25];  % 状态初始概率
A                                = [0.85, 0.05, 0.05, 0.05;...
                                      0.05, 0.85, 0.05, 0.05;...
                                      0.05, 0.05, 0.85, 0.05;...
                                      0.05, 0.05, 0.05, 0.85;];  % 状态转移概率矩阵
M                                   = cat(3 , [-49] , [-8], [-2], [0]); % 均值向量
S                                   = cat(3 , [3] , [4], [5], [6]);    % 协方差矩阵

[Ztrain , Xtrain]                   = sample_ghmm(Ntrain , PI , A , M , S , L);
Xtrain                              = Xtrain - 1;

%%%%% initial parameters %%%%
PI0 = [0.3 ; 0.3; 0.3; 0.1];  % 状态初始概率

A0                                   = [0.6, 0.1, 0.1, 0.1;...
                                      0.2, 0.5, 0.1, 0.2;...
                                      0.1, 0.3, 0.7, 0.2;...
                                      0.1, 0.1, 0.1, 0.5;];  % 状态转移概率矩阵

M0                                   = cat(3 , [-45] , [-10], [0], [2]); % 均值向量
S0                                   = cat(3 , [5] , [2], [6], [1]);    % 协方差矩阵

%%%%% EM algorithm %%%%

[logl , PIest , Aest , Mest , Sest] = em_ghmm(Ztrain , PI0 , A0 , M0 , S0 , options);


