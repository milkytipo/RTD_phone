clear; clc;fclose all; close all;
ori_data.x_data = [];
ori_data.y_data = [];
ori_data.x_raw = [];
ori_data.y_raw = [];
ori_data.x_gama = [];
ori_data.y_gama = [];
ori_data(1:6) = ori_data;
uiopen('D:\个人论文材料\Journal\图\NEW\timeDelay\timeDelay_all_angle - new.fig',1)
figure_info=findall(gcf,'type','bar'); 
for i = 1 : 6
    ori_data(i).x_raw = get(figure_info(7 - i), 'xdata')';
    ori_data(i).y_raw = get(figure_info(7 - i), 'ydata')';
end
    
err = normrnd(0, 0.0001, [29,1]);
a = [2.62,       2.77,        2.81,     2.56,      2.47,     2.40];
b = [129.90,   105.52,    80.93,    65.12,    53.22,   43.24];
x_mean = [7.5, 15+7.5, 30+7.5, 45+7.5, 60+7.5, 75+7.5];
y_mean = a .* b;
p_mean = polyfit(x_mean', y_mean', 1);
x_mean_fit = 1 : 90;
y_mean_fit = p_mean(1) * x_mean_fit + p_mean(2);
x_1 = 1 : 1 : 1000;

for i = 1 : 6
    % 添加随机噪声误差
    len = length(ori_data(i).x_raw);
    err = normrnd(0, 0.00005, [len,1]);
    ori_data(i).x_data = ori_data(i).x_raw;
    ori_data(i).y_data = ori_data(i).y_raw +err ;
    ori_data(i).x_gama = x_1;
    ori_data(i).y_gama = gampdf(x_1, a(i), b(i));
     y_cdf(i,1:1000) = gamcdf(x_1, a(i), b(i));
end


timeDelay_plot(ori_data(1).x_data, ori_data(1).y_data, ori_data(1).x_gama, ori_data(1).y_gama, ...
    ori_data(2).x_data, ori_data(2).y_data, ori_data(2).x_gama, ori_data(2).y_gama, ...
    ori_data(3).x_data, ori_data(3).y_data, ori_data(3).x_gama, ori_data(3).y_gama, ...
    ori_data(4).x_data, ori_data(4).y_data, ori_data(4).x_gama, ori_data(4).y_gama, ...
    ori_data(5).x_data, ori_data(5).y_data, ori_data(5).x_gama, ori_data(5).y_gama, ...
    ori_data(6).x_data, ori_data(6).y_data, ori_data(6).x_gama, ori_data(6).y_gama);

timeDelay_CDF_plot(x_1, y_cdf);

timeDelay_mean_plot(x_mean, y_mean, x_mean_fit, y_mean_fit);
