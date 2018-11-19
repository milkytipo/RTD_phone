clc;
close all;
clear;
isRead = 0;
manual = 0;
isPDF = 0;
if isRead
    fileName = 'E:\work_Private\wangyz\Lujiazui_Static_Point_v2.0\Lujiazui_static_point_all_auto.xlsx';
    [xls.para_GPS,~,~] = xlsread(fileName, 'GPS');
    [xls.para_BDS_GEO,~,~] = xlsread(fileName, 'BDS_GEO');
    [xls.para_BDS_IGSO,~,~] = xlsread(fileName, 'BDS_IGSO');
    [xls.para_BDS_MEO,~,~] = xlsread(fileName, 'BDS_MEO');
    % [Occur,~,~] = xlsread(fileName, 'occurance');
else
    load('xls.mat');  %  xls    xls_manual
end
del_flag = [9,10]; % 根据数据flag去除相应数据

typeNum = 2;        % BDS_GEO:1           BDS_IGSO:2           BDS_MEO:3              GPS:4
% BDS_IGSO+BDS_MEO:5          GPS+BDS_MEO:6               GPS+BDS_IGSO+BDS_MEO:7
absFlag = 1; % 1 : 绝对值；       2：正数；         3：负数

angle_step = 15;
angle_xvalues = 0:angle_step:90;

doppBias_step = 0.01;
doppBias_xvalues = -0.2 : doppBias_step : 0.2;

 el_range = [0, 90];  %仰角的取值范围
 lamda = 0.000648471;  % 2.6028   2.70279  2.26068   2.55464   2.45221
% 衰落频率相关配置参数
value_time = 0; % 滤除短时多径的值
% doppBias_step = 0.01;
% doppBias_xvalues = -0.3:doppBias_step:0.3;




[multiPara] = mp_xls_read(xls.para_GPS, xls.para_BDS_GEO, xls.para_BDS_IGSO, xls.para_BDS_MEO, del_flag);

% 筛选出对应仰角的数据
if 1
    % 选择要处理的卫星类型
    line1_temp = bitand(multiPara(typeNum).elelvation>el_range(1), multiPara(typeNum).elelvation<el_range(2));
    codeDelay =multiPara(typeNum).codeDelay(line1_temp);
    attenuation = multiPara(typeNum).attenuation(line1_temp);
    doppBias = multiPara(typeNum).doppBias(line1_temp);
    elelvation = multiPara(typeNum).elelvation(line1_temp);
    lifeTime = multiPara(typeNum).lifeTime(line1_temp);
    flag = multiPara(typeNum).flag(line1_temp);
    
    % 取绝对值
    if absFlag == 1
        doppBias = abs(doppBias);  % 由于左右对称，所以取绝对值
    elseif absFlag == 2
        line4_temp = (doppBias>0);
        doppBias = doppBias(line4_temp); 
        elelvation = elelvation(line4_temp);
        codeDelay = codeDelay(line4_temp);
        attenuation = attenuation(line4_temp);
        lifeTime = lifeTime(line4_temp);
        flag = flag(line4_temp);
    elseif absFlag == 3
        line4_temp = (doppBias<0);
        doppBias = -doppBias(line4_temp); 
        elelvation = elelvation(line4_temp);
        codeDelay = codeDelay(line4_temp);
        attenuation = attenuation(line4_temp);
        lifeTime = lifeTime(line4_temp);
        flag = flag(line4_temp);
    end
    para_All = [codeDelay, attenuation, doppBias, elelvation, lifeTime, flag];
    para_All = [para_All; para_All];
end





if manual
%     [para_All] = fadFreq_manual(doppBias_xvalues, para_All);
    
    if typeNum == 1
        
        del_col = [];
        for j = 1 : 30
            add(j, :) = [360, 7.1, 0.0007, 70, 10, 1];
        end
        for j = 31 : 35
            add(j, :) = [360, 7.1, 0.0029, 70, 10, 1];
        end
        para_All(del_col, :) = [];
        para_All = [para_All; add;];
    else
        [para_All] = fadFreq_manual_IGSO(doppBias_xvalues, para_All);
    end
end




para_All = sortrows(para_All, 6);
codeDelay = para_All(:, 1);
doppBias = para_All(:, 3);
elelvation = para_All(:, 4);
lifeTime = para_All(:, 5);
flag = para_All(:, 6);



%% multipath dopp bias
%————————对数据做进一步筛检————————————%
line1_temp = (lifeTime>=value_time);
line2_temp = (doppBias~= 0);
line3_temp = bitand(line1_temp, line2_temp); % 去除时间小于value_time秒的数据
% 筛选出有效数据
doppBias_mod = doppBias(line3_temp); 
elelvation_mod = elelvation(line3_temp);
codeDelay_mod = codeDelay(line3_temp);
flag_mod = flag(line3_temp);

% 筛选出衰落频率小于某个数的数据
if 1
    doppBias_range = 0.2;
    line1_temp = doppBias_mod<=doppBias_range;
    doppBias_mod = doppBias_mod(line1_temp);
    elelvation_mod = elelvation_mod(line1_temp);
    codeDelay_mod = codeDelay_mod(line1_temp);
    flag_mod = flag_mod(line1_temp);
end

% 筛选出对应延时的数据
if 0
    delay_range = [0, 1000];
    line1_temp = bitand(codeDelay_mod>delay_range(1), codeDelay_mod<delay_range(2));
    doppBias_mod = doppBias_mod(line1_temp);
    elelvation_mod = elelvation_mod(line1_temp);
    codeDelay_mod = codeDelay_mod(line1_temp);
    flag_mod = flag_mod(line1_temp);
end

%——————————— 初始化分布直方图 ————————————%
if 1
    [pool_norm, fadFreq_x, pool_Num] = barPlot(doppBias_xvalues, doppBias_step, doppBias_mod);
    if isPDF
        x_pdf=0 : 0.00005 : 0.003;
        y_pdf = exppdf(x_pdf, lamda);
        hold on;
        plot(x_pdf, y_pdf, 'r-','LineWidth',3);
        %——————————— distribution Error ————————————% 
        dataNum = length(doppBias_mod);
        k_Square_mid = zeros(1,length(fadFreq_x));
        for j = 1 : length(fadFreq_x)
            if pool_Num(j) >= 5 
                pi = y_pdf(abs(x_pdf-fadFreq_x(j))<0.00001)*doppBias_step;
                 k_Square_mid(j) = ((pool_Num(j) - pi*dataNum)^2)/(pi*dataNum);
            end
        end
        k_Square = sum(k_Square_mid);
    end
end

%————————多径衰落频率和卫星仰角的关系————————————%
if 0
    el_statistic = ceil(elelvation_delay/angle_step) * angle_step;
    
    figure();
    boxplot(doppBias_delay, flag_delay);
end

%————————多径衰落频率和多径延时的关系————————————%
if 0
    delay_statistic = ceil(codeDelay_el/delay_hist_step) * delay_hist_step;
    figure();
    boxplot(doppBias_el, delay_statistic);
end

%————————筛检出对应仰角的数值————————————%
if 0
    figure();
    xlin = linspace(min(elelvation_mod),max(elelvation_mod),200);
    ylin = linspace(min(codeDelay_mod),max(codeDelay_mod),200);
    [X,Y]=meshgrid(xlin,ylin);
    Z = griddata(elelvation_mod,codeDelay_mod,doppBias_mod,X,Y,'cubic');
    mesh(X,Y,Z)
end





