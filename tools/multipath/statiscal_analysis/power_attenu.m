clc;clear all; fclose all;
close all;
isRead = 0;

if isRead
    fileName = 'D:\数据处理结果\Lujiazui_Static_Point_v2.0\Lujiazui_static_point_all_auto.xlsx';
    [xls.para_GPS,~,~] = xlsread(fileName, 'GPS');
    [xls.para_BDS_GEO,~,~] = xlsread(fileName, 'BDS_GEO');
    [xls.para_BDS_IGSO,~,~] = xlsread(fileName, 'BDS_IGSO');
    [xls.para_BDS_MEO,~,~] = xlsread(fileName, 'BDS_MEO');
    % [Occur,~,~] = xlsread(fileName, 'occurance');
else
    load('xls.mat'); 
end
manual = 0;
del_flag = [-1]; % 根据数据flag去除相应数据
typeNum = 6;  % BDS_GEO:1         BDS_IGSO:2          BDS_MEO:3           GPS:4
% BDS_IGSO+BDS_MEO:5            GPS+BDS_MEO:6           GPS+BDS_IGSO+BDS_MEO:7



delay_hist_step = 30;
delay_xvalues = 0:delay_hist_step:900;

[multiPara] = mp_xls_read(xls.para_GPS, xls.para_BDS_GEO, xls.para_BDS_IGSO, xls.para_BDS_MEO, del_flag);




para_All = [multiPara(typeNum).codeDelay, multiPara(typeNum).attenuation, ...
    multiPara(typeNum).doppBias, multiPara(typeNum).elelvation, ...
    multiPara(typeNum).lifeTime, multiPara(typeNum).power];


if manual
    %—————再次去除不可靠的点——————————%
    del_num = 0;
    del_col = [];
    for i = 1 : size(para_All, 1)

    end   
    para_All(del_col, :) = [];
end

% 选择要处理的卫星类型
codeDelay = para_All(:, 1);
attenuation = -para_All(:, 2)-3;
doppBias = para_All(:, 3);
elelvation = para_All(:, 4);
power = para_All(:, 6);



%% multipath power-delay profile model


power_values_mean = NaN(length(delay_xvalues)-1,1);
power_values_var = NaN(length(delay_xvalues)-1,1);
power_values_max = NaN(length(delay_xvalues)-1,1);
attenuation_mean = NaN(length(delay_xvalues)-1,1);
for i = 1 : length(delay_xvalues) - 1
    L1 = codeDelay >= delay_xvalues(i);
    L2 = codeDelay < delay_xvalues(i+1);
    L3 = L1&L2;
    att = power(L3);
    att_2 = attenuation(L3);
    if ~isempty(att)
        L = isnan(att);
        power_values_mean(i) = mean(10.^(att(~L)/20));
        power_values_var(i) = var(10.^(att(~L)/20));
        power_values_max(i) = max(10.^(att(~L)/20));
        attenuation_mean(i) = mean(10.^(att_2(~L)/20));
        
    end
end

powerdelay_profile_var = 20*log10(power_values_var);
powerdelay_profile_mean = 20*log10(power_values_mean);
powerdelay_profile_max = 20*log10(power_values_max);
powerdelay_profile_atten = 20*log10(attenuation_mean);

delayx = delay_xvalues(2:end)-delay_hist_step/2;
figure()
plot(delayx(1:end), powerdelay_profile_mean(1:end),'o');
% figure()
% plot(delayx(1:end), power_values_var(1:end),'o');
hold on;
plot(delayx(1:end), powerdelay_profile_max(1:end),'*');



% fit curve
x_fit = 0 : 900;
y_fit_1 = -0.0081302 * x_fit + 32.696;
y_fit_2 = -0.018816 * x_fit + 45.655;
hold on;
plot(x_fit, y_fit_1, '-');
hold on;
plot(x_fit, y_fit_2, '-');

figure()
plot(delayx(1:end), powerdelay_profile_atten(1:end),'o');

% figure()
% plot(codeDelay, attenuation, '.');
% % 
% figure()
% plot(codeDelay, power, '.');


%——————— 热力图 ——————————%
if 0
    x_grid = 0 : 20 : 800;
    y_grid = -25 : 2 : 5;
    x_value = codeDelay;
    y_value = attenuation;
    gridNum = 2000;
    proba_image(x_grid, y_grid, x_value, y_value, gridNum);
end

%——————— 柱状图 ——————————%

% atten_hist_step = 1;
% atten_xvalues = -11:atten_hist_step:26;
% figure()
% barPlot(atten_xvalues, atten_hist_step, attenuation)













