clc;
close all;
isRead = 1;

if isRead
    clear all; fclose all; 
    fileName = 'D:\数据处理结果\Lujiazui_Static_Point_v2.0\Lujiazui_static_point_all_auto.xlsx';
    [parameter_GPS,~,~] = xlsread(fileName, 'GPS');
    [parameter_BDS_GEO,~,~] = xlsread(fileName, 'BDS_GEO');
    [parameter_BDS_IGSO,~,~] = xlsread(fileName, 'BDS_IGSO');
    [parameter_BDS_MEO,~,~] = xlsread(fileName, 'BDS_MEO');
    [Occur,~,~] = xlsread(fileName, 'occurance');
end
del_flag = [2]; % 根据数据flag去除相应数据
typeNum = 2;  % BDS_GEO:1         BDS_IGSO:2          BDS_MEO:3           GPS:4  
              % BDS_IGSO+BDS_MEO:5            GPS+BDS_MEO:6           GPS+BDS_IGSO+BDS_MEO:7

angle_step = 15;
angle_xvalues = 0:angle_step:90;            
             
             
plot_codeDelay = 1; % 码相位延时柱状图
plot_powerAtten = 0; % 能量衰减
plot_lifeTime = 0; % 生命周期
plot_proba = 0; % 出现概率




delay_hist_step = 10;
delay_xvalues = 0:delay_hist_step:900;

lifetime_step = 2;
lifetime_xvalues = 1:lifetime_step:80;
% 衰落频率相关配置参数
plot_doppBias = 0; % 多普勒频移
value_time = 0; % 滤除短时多径的值
doppBias_step = 0.01;
doppBias_xvalues = 0:doppBias_step:0.4;


% D:\个人论文材料\IAG\LuJiazui_Data_Analysis_original.xlsx
% D:\数据处理结果\统计结果\处理后数据\Lujiazui_static_point_all_v1.xlsx
% 



 
paraLog = zeros(1, 4); % 判断上述四个变量是否全部赋值



%————————参数初始化——————————%
Occur_BDS = Occur(:,1:4);
Occur_GPS = Occur(:,8:11);
Occur_BDS(isnan(Occur_BDS(:,1)),:) = [];
Occur_GPS(isnan(Occur_GPS(:,1)),:) = [];
multiPara = struct(...
    'sateType',     '',...
    'codeDelay',    [],...
    'attenuation',  [],...
    'power',  [],...
    'doppBias',     [],...
    'lifeTime',     [],...
    'elelvation',   [],...
    'flag',         [],...
    'lifeTimeflag',         [],...
    'Occur_proba',  []...
    );
multiPara(1:7) = multiPara;
multiPara(1).sateType = 'BDS_GEO';
multiPara(2).sateType = 'BDS_IGSO';
multiPara(3).sateType = 'BDS_MEO';
multiPara(4).sateType = 'GPS';
multiPara(5).sateType = 'BDS_IGSO+BDS_MEO';
multiPara(6).sateType = 'GPS+BDS_MEO';
multiPara(7).sateType = 'GPS+BDS_IGSO+BDS_MEO';
%%
%—————————————— 参数赋值 ——————————————%
% ————————BDS_GEO—————————%
if ~isempty(parameter_BDS_GEO)
    multiNum = size(parameter_BDS_GEO, 1);
    path_N = size(parameter_BDS_GEO, 2);
    if path_N <= 11
        multipath = 1;
    elseif path_N <= 23
        multipath = 2;
    else
        multipath = 3;
    end
    line = 1 : multiNum;
    column_N = 3;
    for i = 1 : multipath
        multiPara(1).codeDelay = [multiPara(1).codeDelay; parameter_BDS_GEO(line, column_N)];
        multiPara(1).attenuation = [multiPara(1).attenuation; parameter_BDS_GEO(line, column_N+1)];
        multiPara(1).doppBias = [multiPara(1).doppBias; parameter_BDS_GEO(line, column_N+2)];
        multiPara(1).lifeTime = [multiPara(1).lifeTime; parameter_BDS_GEO(line, column_N+3)];
        multiPara(1).elelvation = [multiPara(1).elelvation; parameter_BDS_GEO(line, column_N+4)];
        multiPara(1).flag = [multiPara(1).flag; parameter_BDS_GEO(line, column_N+5)];
        multiPara(1).lifeTimeflag = [multiPara(1).lifeTimeflag; parameter_BDS_GEO(line, column_N+6)];
        multiPara(1).power = [multiPara(1).power; parameter_BDS_GEO(line, column_N+7)];
        column_N = column_N + 12;
    end
    multiPara(1).Occur_proba = Occur_BDS(Occur_BDS(:,1)<=5&Occur_BDS(:,1)>0,:);
    paraLog(1) = 1;
end
% ————————BDS_IGSO—————————%
if ~isempty(parameter_BDS_IGSO)
    multiNum = size(parameter_BDS_IGSO, 1);
    path_N = size(parameter_BDS_IGSO, 2);
    if path_N <= 11
        multipath = 1;
    elseif path_N <= 23
        multipath = 2;
    else
        multipath = 3;
    end
    line = 1 : multiNum;
    column_N = 3;
    for i = 1 : multipath
        multiPara(2).codeDelay = [multiPara(2).codeDelay; parameter_BDS_IGSO(line, column_N)];
        multiPara(2).attenuation = [multiPara(2).attenuation; parameter_BDS_IGSO(line, column_N+1)];
        multiPara(2).doppBias = [multiPara(2).doppBias; parameter_BDS_IGSO(line, column_N+2)];
        multiPara(2).lifeTime = [multiPara(2).lifeTime; parameter_BDS_IGSO(line, column_N+3)];
        multiPara(2).elelvation = [multiPara(2).elelvation; parameter_BDS_IGSO(line, column_N+4)];
        multiPara(2).flag = [multiPara(2).flag; parameter_BDS_IGSO(line, column_N+5)];
        multiPara(2).lifeTimeflag = [multiPara(2).lifeTimeflag; parameter_BDS_IGSO(line, column_N+6)];
        multiPara(2).power = [multiPara(2).power; parameter_BDS_IGSO(line, column_N+7)];
        column_N = column_N + 12;
    end
    multiPara(2).Occur_proba = Occur_BDS(Occur_BDS(:,1)<=10&Occur_BDS(:,1)>5,:);
    paraLog(2) = 1;
end
% ————————BDS_MEO—————————%
if ~isempty(parameter_BDS_MEO)
    multiNum = size(parameter_BDS_MEO, 1);
    path_N = size(parameter_BDS_MEO, 2);
    if path_N <= 11
        multipath = 1;
    elseif path_N <= 23
        multipath = 2;
    else
        multipath = 3;
    end
    line = 1 : multiNum;
    column_N = 3;
    for i = 1 : multipath
        multiPara(3).codeDelay = [multiPara(3).codeDelay; parameter_BDS_MEO(line, column_N)];
        multiPara(3).attenuation = [multiPara(3).attenuation; parameter_BDS_MEO(line, column_N+1)];
        multiPara(3).doppBias = [multiPara(3).doppBias; parameter_BDS_MEO(line, column_N+2)];
        multiPara(3).lifeTime = [multiPara(3).lifeTime; parameter_BDS_MEO(line, column_N+3)];
        multiPara(3).elelvation = [multiPara(3).elelvation; parameter_BDS_MEO(line, column_N+4)];
        multiPara(3).flag = [multiPara(3).flag; parameter_BDS_MEO(line, column_N+5)];
        multiPara(3).lifeTimeflag = [multiPara(3).lifeTimeflag; parameter_BDS_MEO(line, column_N+6)];
        multiPara(3).power = [multiPara(3).power; parameter_BDS_MEO(line, column_N+7)];
        column_N = column_N + 12;
    end
    multiPara(3).Occur_proba = Occur_BDS(Occur_BDS(:,1)>10,:);
    paraLog(3) = 1;
end
% ————————GPS—————————%
if ~isempty(parameter_GPS)
    multiNum = size(parameter_GPS, 1);
    path_N = size(parameter_GPS, 2);
    if path_N <= 11
        multipath = 1;
    elseif path_N <= 23
        multipath = 2;
    else
        multipath = 3;
    end
    line = 1 : multiNum;
    column_N = 3;
    for i = 1 : multipath
        multiPara(4).codeDelay = [multiPara(4).codeDelay; parameter_GPS(line, column_N)];
        multiPara(4).attenuation = [multiPara(4).attenuation; parameter_GPS(line, column_N+1)];
        multiPara(4).doppBias = [multiPara(4).doppBias; parameter_GPS(line, column_N+2)];
        multiPara(4).lifeTime = [multiPara(4).lifeTime; parameter_GPS(line, column_N+3)];
        multiPara(4).elelvation = [multiPara(4).elelvation; parameter_GPS(line, column_N+4)];
        multiPara(4).flag = [multiPara(4).flag; parameter_GPS(line, column_N+5)];
        multiPara(4).lifeTimeflag = [multiPara(4).lifeTimeflag; parameter_GPS(line, column_N+6)];
        multiPara(4).power = [multiPara(4).power; parameter_GPS(line, column_N+7)];
        column_N = column_N + 12;
    end
    multiPara(4).Occur_proba = Occur_GPS;
    paraLog(4) = 1;
end

%%
%—————————————— 数据进一步处理 ————————————————%
for i = 1 : 4
    if paraLog(i)
        for j = 1 : length(del_flag) 
            removeLine = multiPara(i).flag==del_flag(j);  % 选择去除的数据
            multiPara(i).codeDelay(removeLine) = [];
            multiPara(i).attenuation(removeLine) = [];
            multiPara(i).doppBias(removeLine) = [];
            multiPara(i).lifeTime(removeLine) = [];
            multiPara(i).elelvation(removeLine) = [];
            multiPara(i).flag(removeLine) = [];
            multiPara(i).lifeTimeflag(removeLine) = [];
            multiPara(i).power(removeLine) = [];
        end
    end
end



%—————————— BDS_IGSO + BDS_MEO ————————————%
multiPara(5).codeDelay = [multiPara(2).codeDelay; multiPara(3).codeDelay];
multiPara(5).attenuation = [multiPara(2).attenuation; multiPara(3).attenuation];
multiPara(5).doppBias = [multiPara(2).doppBias; multiPara(3).doppBias];
multiPara(5).lifeTime = [multiPara(2).lifeTime; multiPara(3).lifeTime];
multiPara(5).elelvation = [multiPara(2).elelvation; multiPara(3).elelvation];
multiPara(5).flag = [multiPara(2).flag; multiPara(3).flag];
multiPara(5).lifeTimeflag = [multiPara(2).lifeTimeflag; multiPara(3).lifeTimeflag];
multiPara(5).power = [multiPara(2).power; multiPara(3).power];
multiPara(5).Occur_proba = [multiPara(2).Occur_proba; multiPara(3).Occur_proba];

%—————————— GPS + BDS_MEO ————————————%
multiPara(6).codeDelay = [multiPara(3).codeDelay; multiPara(4).codeDelay];
multiPara(6).attenuation = [multiPara(3).attenuation; multiPara(4).attenuation];
multiPara(6).doppBias = [multiPara(3).doppBias; multiPara(4).doppBias];
multiPara(6).lifeTime = [multiPara(3).lifeTime; multiPara(4).lifeTime];
multiPara(6).elelvation = [multiPara(3).elelvation; multiPara(4).elelvation];
multiPara(6).flag = [multiPara(3).flag; multiPara(4).flag];
multiPara(6).lifeTimeflag = [multiPara(3).lifeTimeflag; multiPara(4).lifeTimeflag];
multiPara(6).power = [multiPara(3).power; multiPara(4).power];
multiPara(6).Occur_proba = [multiPara(3).Occur_proba; multiPara(4).Occur_proba];

%—————————— GPS + BDS_IGSO + BDS_MEO ————————————%
multiPara(7).codeDelay = [multiPara(2).codeDelay; multiPara(3).codeDelay; multiPara(4).codeDelay];
multiPara(7).attenuation = [multiPara(2).attenuation; multiPara(3).attenuation; multiPara(4).attenuation];
multiPara(7).doppBias = [multiPara(2).doppBias; multiPara(3).doppBias; multiPara(4).doppBias];
multiPara(7).lifeTime = [multiPara(2).lifeTime; multiPara(3).lifeTime; multiPara(4).lifeTime];
multiPara(7).elelvation = [multiPara(2).elelvation; multiPara(3).elelvation; multiPara(4).elelvation];
multiPara(7).flag = [multiPara(2).flag; multiPara(3).flag; multiPara(4).flag];
multiPara(7).lifeTimeflag = [multiPara(2).lifeTimeflag; multiPara(3).lifeTimeflag; multiPara(4).lifeTimeflag];
multiPara(7).power = [multiPara(2).power; multiPara(3).power; multiPara(4).power];
multiPara(7).Occur_proba = [multiPara(2).Occur_proba; multiPara(3).Occur_proba; multiPara(4).Occur_proba];

% 选择要处理的卫星类型
codeDelay = multiPara(typeNum).codeDelay;
lifeTime = multiPara(typeNum).lifeTime;
attenuation = multiPara(typeNum).attenuation;
doppBias = multiPara(typeNum).doppBias;
elelvation = multiPara(typeNum).elelvation;
power = multiPara(typeNum).power;
Occur_proba = multiPara(typeNum).Occur_proba;
%% multipath delay distribution model
% —————————— 直方图 ——————————%


%————————码相位延时画图————————————%
if plot_codeDelay
    %——————自编写直方图代码————————%
    pool_index_pre = 0;
    pool_Num = zeros(1, length(delay_xvalues)-1); % 直方图总统计个数
    for j = 1 : length(codeDelay)
        pool_index = ceil(codeDelay(j)/delay_hist_step);
        if pool_index<=length(pool_Num) && pool_index~=pool_index_pre
            pool_Num(pool_index) = pool_Num(pool_index) + 1;  % 统计值加1
        end
        pool_index_pre = pool_index;
    end
    figure();
    pool_norm = pool_Num / sum(pool_Num);
    delay_x = (delay_xvalues(2:end)+delay_xvalues(1:end-1)) / 2;
    bar(delay_x, pool_norm);
    
    el_statistic = ceil(elelvation/angle_step) * angle_step;
    for j = 2 : length(angle_xvalues)
        Delay_angle(j-1).value = codeDelay(el_statistic==angle_xvalues(j));
        codeDelay_Mean(j-1) = mean(Delay_angle(j-1).value);
    end
    figure();
    boxplot(codeDelay, el_statistic); 
 
    figure();
    plot(angle_xvalues(2:end), codeDelay_Mean, '-r');
end



% h = histogram(codeDelay, delay_xvalues);



%—————————— 函数拟合 ————————————%
% delay_pd = fitdist(delaycenters','Gamma','Frequency',delaynelements');
% x = (1:5:1000);
% a1 = delay_pd.a-0.1;
% b1 = delay_pd.b;
% c1 = 20.5;
% f1 = c1/(b1^a1 * gamma(a1)) * x.^(a1-1).*exp(-x/b1);
% hold on
% % plot(x*delay_hist_step,f1,'r')
% plot(x,f1,'r')
% delay_pd_ex = fitdist(delaycenters','Exponential','Frequency',delaynelements');
% lamda = 0.003;%delay_pd_ex.mu;
% f2 = 28*lamda*exp(-lamda*x);
% hold on
% plot(x,f2,'m')
% real_data = delaynelements(2:end)/MpNum;
% model_data_Ga = c1/(b1^a1 * gamma(a1)) * delay_xvalues(2:end).^(a1-1).*exp(-delay_xvalues(2:end)/b1);
% model_data_Ex = 28*lamda*exp(-lamda * delay_xvalues(2:end));
% MSE_Ga = sum((model_data_Ga - real_data).^2);
% MSE_Ex = sum((model_data_Ex - real_data).^2);

%% multipath power-delay profile model

if plot_powerAtten
    power_values = NaN(length(delay_xvalues)-1,1);
    for i=1:length(delay_xvalues)-1
        L1 = codeDelay >= delay_xvalues(i);
        L2 = codeDelay < delay_xvalues(i+1);
        L3 = L1&L2;
        att = attenuation(L3);
        if ~isempty(att)
            L = isnan(att);
            power_values(i) = mean(10.^(att(~L)/20));
        end
    end

    powerdelay_profile = 20*log10(power_values);
    delayx = delay_xvalues(2:end)-delay_hist_step/2;
    figure() 
    plot(delayx, powerdelay_profile,'o');
    
    figure()
    atten_hist_step = 1;
    atten_xvalues = -11:atten_hist_step:26; 
    pool_Num_power = zeros(1, length(atten_xvalues)-1); % 直方图总统计个数
    for j = 1 : length(attenuation)
        if ~isnan(attenuation(j))
            pool_index = ceil((attenuation(j)+11)/atten_hist_step);
            if pool_index<=length(pool_Num_power)
                if codeDelay(j)>=100 && codeDelay(j)<250
                    pool_Num_power(pool_index) = pool_Num_power(pool_index) + 1;  % 统计值加1
                end
            end
        end
    end
    pool_power_norm = pool_Num_power / sum(pool_Num_power);
    attenu_x = atten_xvalues(2:end) - atten_hist_step/2;
    bar(attenu_x, pool_power_norm);
    
%     atten_values = histogram(attenuation, atten_xvalues);
end

%—————— 函数拟合 ————————%
% S0db = -11.7;
% d = -0.0085;
% x = 10:5:1000;
% avg_mp_power = S0db + d*x;





%% multipath life-time model
if plot_lifeTime
    pool_Num_lifetime = zeros(1, length(lifetime_xvalues)-1); % 直方图总统计个数
    for j = 1 : length(lifeTime)
        if lifeTime(j)>= 1 % 去除小于1s的数据
            lifetime_index = ceil((lifeTime(j)-1)/lifetime_step);
            if lifetime_index == 0
                lifetime_index = 1;
            end
        else
            continue;
        end
        if lifetime_index <= length(pool_Num_lifetime)
            pool_Num_lifetime(lifetime_index) = pool_Num_lifetime(lifetime_index) + 1;
        end
    end
    pool_lifetime_norm = pool_Num_lifetime / sum(pool_Num_lifetime);
    lifetime_x = lifetime_xvalues(2:end) - lifetime_step/2;
    figure();
    bar(lifetime_x, pool_lifetime_norm); 
    % 函数拟合
%     a = 0.3388;
%     b = -0.1748;
%     c = 0.009927;
%     d = -0.02002;
%     a = 0.2503;
%     b = -0.04263;
%     c = 0.07168;
%     d = -0.004768;
%     lifetime_x_fit = 1:1:800;
%     for j = 1 : length(lifetime_x_fit)
%         lifetime_y_fit(j) =  a*exp(b*lifetime_x_fit(j)) + c*exp(d*lifetime_x_fit(j));
%     end
%     hold on 
%     plot(lifetime_x_fit, lifetime_y_fit);
%     figure();
%     histogram(lifeTime, lifetime_xvalues);
end

%% multipath dopp bias
if plot_doppBias
    pool_Num_doppBias = zeros(1, length(doppBias_xvalues)-1); % 直方图总统计个数
    addNum = abs(doppBias_xvalues(1))/doppBias_step; % 将负数移位到1处
    for j = 1 : length(doppBias)
        if doppBias(j)~= 0 && lifeTime(j)>value_time % 去除小于5秒的数据
            if elelvation(j)>0 && elelvation(j)<90
                doppBias_index = ceil((abs(doppBias(j)))/doppBias_step) + addNum; % 此处取绝对值
                if doppBias_index > 0 && doppBias_index < length(pool_Num_doppBias)
                    pool_Num_doppBias(doppBias_index) = pool_Num_doppBias(doppBias_index) + 1;
                end
            end
        end
    end
    pool_doppBias_norm = pool_Num_doppBias / sum(pool_Num_doppBias);
    doppbias_x = doppBias_xvalues(2:end) - doppBias_step/2;
    figure();
    bar(doppbias_x, pool_doppBias_norm); 
    doppbias_x_1 = doppbias_x(addNum+1:end);
    pool_doppBias_norm_1 = pool_doppBias_norm(addNum+1:end);
    
    
    el_statistic = ceil(elelvation/angle_step) * angle_step;
    for j = 2 : length(angle_xvalues)
        doppBias_angle(j-1).value = doppbias_x(el_statistic==angle_xvalues(j));
        codeDelay_Mean(j-1) = mean(doppBias_angle(j-1).value);
    end
    figure();
    boxplot(codeDelay, el_statistic); 

end


%% 画出多径发生概率随卫星仰角的变化曲线图
if plot_proba
    figure();
    Occur_proba(Occur_proba(:,4)<0, :) = [];
    proba_values = NaN(length(angle_xvalues)-1,1);
    for i=1:length(angle_xvalues)-1
        L1 = Occur_proba(:,3) >= angle_xvalues(i);
        L2 = Occur_proba(:,3) < angle_xvalues(i+1);
        L3 = L1&L2;
        proba = Occur_proba(L3, 2);
        lastTime = Occur_proba(L3, 4);
        if ~isempty(proba)
            proba_values(i) = mean(proba);
            %sum(proba.*lastTime)/sum(lastTime);
        end
    end
    %—————————— 画散点图 ——————————%
    angle_x = angle_xvalues(2:end) - angle_step/2;
    plot(angle_x, proba_values,'o');
    %—————————— 函数公式拟合 ——————————%
end


%%
%
%----- scatter multipath ----=
% x_liftime_scatter = 1:1:100;
% figure();
% [mpltnelements, mpltcenters] = hist(lifeTime,x_liftime_scatter);
% bar(mpltcenters, mpltnelements/length(lifeTime))

%—————— 函数拟合 ————————%
% mplt_pd_gamma = fitdist(mpltcenters','Gamma','Frequency',mpltnelements');
% mplt_a_gamma = mplt_pd_gamma.a;
% mplt_b_gamma= mplt_pd_gamma.b;
% mplt_c =1;
% mplt_f_gamma = mplt_c/(mplt_b_gamma^mplt_a_gamma * gamma(mplt_a_gamma)) * x_liftime_scatter.^(mplt_a_gamma-1).*exp(-x_liftime_scatter/mplt_b_gamma);
% hold on
% plot(x_liftime_scatter,mplt_f_gamma,'m')
% 
% % calculate MSE
% real_data = mpltnelements/length(mp_lifetime_list_Scatters);
% rmse_gamma = sum((mplt_f_gamma - real_data).^2);
% 
% 
% mplt_pd_rayleigh = fitdist(mpltcenters','Rayleigh','Frequency',mpltnelements');
% mplt_b_rayleigh = mplt_pd_rayleigh.b;
% mplt_f_rayleigh = (x_liftime_scatter/mplt_b_rayleigh^2).*exp(-x_liftime_scatter.^2/2/mplt_b_rayleigh^2);
% plot(x_liftime_scatter,mplt_f_rayleigh,'g')
% 
% % calculate MSE
% rmse_rayleigh = sum((mplt_f_rayleigh - real_data).^2);
% 
% 
% mplt_pd_normal = fitdist(mpltcenters','Normal','Frequency',mpltnelements');
% mplt_mu_normal = 6; %mplt_pd_normal.mu;  6
% mplt_sigma_normal = 5.8; %mplt_pd_normal.sigma;  5.8
% mplt_f_normal = exp(-(x_liftime_scatter-mplt_mu_normal).^2/2/mplt_sigma_normal^2)/mplt_sigma_normal/sqrt(2*pi);
% plot(x_liftime_scatter,mplt_f_normal,'r')
% 
% % calculate MSE
% rmse_normal = sum((mplt_f_normal - real_data).^2);
% % chi square test
% sumUse = sum(mpltnelements(1:29));
% chi_normal = sum(((mplt_f_normal(1:29)*sumUse - mpltnelements(1:29)).^2)./mpltnelements(1:29));



% %----- IgsoMeoSpecular multipath lift time -----
% x_liftime_IgsoMeoSpecular = 10:20:1000;
% figure;
% [mpltnelements, mpltcenters] = hist(mp_lifetime_list_IgsoMeoSpecular,x_liftime_IgsoMeoSpecular);
% bar(mpltcenters, mpltnelements/length(mp_lifetime_list_IgsoMeoSpecular))
% % bar(mpltcenters, mpltnelements/1000*length(mp_lifetime_list_IgsoMeoSpecular))
% 
% x = 0:1:1000;
% mplt_mu_normal = 90; %mplt_pd_normal.mu;
% mplt_sigma_normal = 55; %mplt_pd_normal.sigma;
% mplt_f_normal = 20*exp(-(x-mplt_mu_normal).^2/2/mplt_sigma_normal^2)/mplt_sigma_normal/sqrt(2*pi);
% hold on;
% plot(x,mplt_f_normal,'r')