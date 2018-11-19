clc;clear;
close all;
fclose all;
isRead = 0;
manual = 1;
if isRead
    fileName = 'D:\数据处理结果\Lujiazui_Static_Point_v2.0\Lujiazui_Static_Point_all_auto_Point_1-27.xlsx';
    [xls.para_GPS,~,~] = xlsread(fileName, 'GPS');
    [xls.para_BDS_GEO,~,~] = xlsread(fileName, 'BDS_GEO');
    [xls.para_BDS_IGSO,~,~] = xlsread(fileName, 'BDS_IGSO');
    [xls.para_BDS_MEO,~,~] = xlsread(fileName, 'BDS_MEO');
    % [Occur,~,~] = xlsread(fileName, 'occurance');
else
    load('xls_1-27.mat');
end


del_flag = [-1]; % 根据数据flag去除相应数据
typeNum =6;  % BDS_GEO:1         BDS_IGSO:2          BDS_MEO:3           GPS:4
% BDS_IGSO+BDS_MEO:5            GPS+BDS_MEO:6           GPS+BDS_IGSO+BDS_MEO:7


angle_step = 15;
angle_xvalues = angle_step:angle_step:90;
delay_hist_step = 32;
delay_xvalues = 0:delay_hist_step:1000;

[multiPara] = mp_xls_read(xls.para_GPS, xls.para_BDS_GEO, xls.para_BDS_IGSO, xls.para_BDS_MEO, del_flag);




para_All = [multiPara(typeNum).codeDelay, multiPara(typeNum).attenuation, ...
    multiPara(typeNum).doppBias, multiPara(typeNum).elelvation, ...
    multiPara(typeNum).lifeTime, multiPara(typeNum).flag];


if manual
    [para_All] = codeDelay_manual(delay_xvalues, para_All);
end

% 选择要处理的卫星类型
codeDelay = para_All(:, 1);
% attenuation = para_All(:, 2);
% doppBias = para_All(:, 3);
elelvation = para_All(:, 4);




%% multipath delay distribution model
% —————————— 直方图 ——————————%

RGB = [0.2,0.6,1; 1,0.4,0; 0.47,0.67,0.19; 0.1,0.5,0.8; 0.7,0.4,0.19; 0.24,0.47,0.19; 0.27,0.14,0.89; 0.17,0.41,0.69;];
%————————码相位延时画图————————————%

%——————自编写直方图代码————————%
if 0
    figure();
    [pool_norm_all, delay_x_all] = barPlot(delay_xvalues, delay_hist_step, codeDelay);
end


%——————延时与仰角关系的箱线图————————%
if 0
    if typeNum == 1
        codeDelay_Mean = zeros(1,3);
        el_statistic = elelvation;
        el_statistic(el_statistic<25) = 15;
        el_statistic(el_statistic>25&el_statistic<41) = 35;
        el_statistic(el_statistic>43) = 50;
        codeDelay_Mean(1) = mean(codeDelay(el_statistic == 15 ));
        codeDelay_Mean(2) = mean(codeDelay(el_statistic == 35 ));
        codeDelay_Mean(3) = mean(codeDelay(el_statistic == 50 ));
        figure();
        boxplot(codeDelay, el_statistic);
        hold on;
        plot(codeDelay_Mean, '-r');
    else
        el_statistic = ceil(elelvation/angle_step) * angle_step;
        for j = 1 : length(angle_xvalues)
            codeDelay_Mean(j) = mean(codeDelay(el_statistic==angle_xvalues(j)));
        end
        figure();
        boxplot(codeDelay, el_statistic);
        hold on;
        plot(codeDelay_Mean, '-r');
    end
end

%——————各个仰角区间的分布模型————————%
if 1
    el_statistic = ceil(elelvation/angle_step) * angle_step;
    
    codeDelay_angle = codeDelay;
%     codeDelay_angle = codeDelay(el_statistic == angle_xvalues(3));
     
    figure();
    [pool_norm_angle, delay_x_angle, pool_Num] = barPlot(delay_xvalues, delay_hist_step, codeDelay_angle);
    x_pdf=1 : 1 : 1000;
%     a = 2.53498;  % 2.6028   2.70279  2.26068   2.55464   2.45221
%     b = 101.647;  %127.646   111.682  74.6206   64.7951   59.7951
%     y_pdf = gampdf(x_pdf, a, b);
    

    y_pdf = pdf('InverseGaussian', x_pdf, 257.672, 431.569);
    
    hold on;
%     plot(x_pdf, y_pdf, 'r-','LineWidth',3);
    
    %——————————— distribution Error ————————————% 
    dataNum = length(codeDelay_angle);
    k_Square_mid = zeros(1,length(delay_x_angle));
    for j = 1 : length(delay_x_angle)
        if pool_Num(j) >= 5 
            pi = y_pdf(delay_x_angle(j))*delay_hist_step;
             k_Square_mid(j) = ((pool_Num(j) - pi*dataNum)^2)/(pi*dataNum);
        end
    end
        k_Square = sum(k_Square_mid);
end

%——————各个仰角区间的累积分布模型————————%
if 0
    a(1) = 2.64448;  
    b(1) = 127.903;  
    a(2) = 2.76248; 
    b(2) = 108.017;  
    a(3) = 2.80302;
    b(3) = 78.9312; 
    a(4) = 2.55464;
    b(4) = 64.7951; 
    a(5) = 2.45221;
    b(5) = 56.7951; 
    a(6) = 2.43969;
    b(6) = 45.1834; 
    figure();
    x_cdf=1 : 1 : 1000;
    for i = 1 : 6
        y_cdf = gamcdf(x_cdf, a(i), b(i));
        hold on;
        plot(x_cdf, y_cdf, 'r-','LineWidth',3);
    end
end
