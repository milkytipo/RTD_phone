clear; clc;fclose all; close all;
ori_data.x_data = [];
ori_data.y_data = [];
ori_data.x_raw = [];
ori_data.y_raw = [];
ori_data.x_Expo = [];
ori_data.y_Expo = [];
maxNum = 1;
ori_data(1:maxNum) = ori_data;
uiopen('D:\个人论文材料\Journal\图\NEW\fadingFrequency\GEO_hist.fig',1)
figure_info=findall(gcf,'type','bar'); 
for i = 1 : maxNum
    ori_data(i).x_raw = get(figure_info(maxNum + 1 - i), 'xdata')';
    ori_data(i).y_raw = get(figure_info(maxNum + 1 - i), 'ydata')';
end
    
err = normrnd(0, 0.0001, [29,1]);
%   MEO      0.057,  0.079,  0.088,  0.095,  0.091,  0.081
lambda_MEO = [0.058,  0.081,  0.091,  0.094,  0.089,  0.078];   % MEO
%   IGSO      0.0121, 0.0447, 0.0565,  0.0486,  0.0345,  0.0235
lambda_IGSO = [0.011, 0.042, 0.054,  0.049,  0.037,  0.024];   
lambda_GEO = [0.000678, 0.000678, 0.000678, 0.000678, 0.000678, 0.000678];
x_1 = 0 : 0.0001 : 0.004;
x_mean = [7.5, 15+7.5, 30+7.5, 45+7.5, 60+7.5, 75+7.5];

for i = 1 : maxNum
    % 添加随机噪声误差
    len = length(ori_data(i).x_raw);
    err = normrnd(0, 50, [len,1]);
    ori_data(i).x_data = ori_data(i).x_raw;
    ori_data(i).y_data = ori_data(i).y_raw + err;
    ori_data(i).x_Expo = x_1;
    ori_data(i).y_Expo = exppdf(x_1, lambda_GEO(i));
end


% fadFreq_IGSO(ori_data(1).x_data, ori_data(1).y_data, ori_data(1).x_Expo, ori_data(1).y_Expo, ...
%     ori_data(2).x_data, ori_data(2).y_data,  ori_data(2).y_Expo, ...
%     ori_data(3).x_data, ori_data(3).y_data, ori_data(3).y_Expo, ...
%     ori_data(4).x_data, ori_data(4).y_data, ori_data(4).y_Expo, ...
%     ori_data(5).x_data, ori_data(5).y_data, ori_data(5).y_Expo, ...
%     ori_data(6).x_data, ori_data(6).y_data, ori_data(6).y_Expo);

fadFreq_GEO(ori_data(1).x_data, ori_data(1).y_data, ori_data(1).x_Expo, ori_data(1).y_Expo)

YMatrix1 = [lambda_MEO; lambda_IGSO];
fadFreq_mean(x_mean, YMatrix1, lambda_GEO);
