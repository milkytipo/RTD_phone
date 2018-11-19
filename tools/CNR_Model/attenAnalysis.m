clear; clc; close all;
%%%%%%%%%%%%%%  系统参数  %%%%%%%%%%%%%
load CNR_std_novAtel.mat;
isReadMat = 1;
matName = 'attenAnaly_Urban.mat';  % attenAnaly_FengXian / attenAnaly_ViaductDown / attenAnaly_ViaductUp / attenAnaly_Urban
isWriteXls = 0;
xlsName = 'D:\个人论文材料\2017ION\Power Model\RawData\各场景数据统计参数.xlsx';
sheetName = 'Xuhui';   %  FengXian / NeihuanGaojiaxia / UrbanElevatedRoad / Xuhui
xlsLine = '22';  % 2 / 16 / 22

%%%%%%%%%%%%%% 配置参数 %%%%%%%%%%%%%%
El_range = [30, 60, 90;...
                    10, 30, 60];
El_range = [90;...
                  30];
hist_step = 1;
hist_values = -60 : hist_step : 5;
x_fit = -60 : 0.05 : 5;
sys = 'BDS_GEO';   % GPS / BDS_GEO / BDS_IGSO / BDS_MEO / BDS_NGEO
status = 4;

%%%%%%%%%%%%%% 读取原始数据 %%%%%%%%%%%%
if isReadMat
    load(matName);
    attenAnaly = attenAnaly_Urban;
else
    fileRinex = 'D:\个人论文材料\2017ION\Power Model\RawData\UrbanElevatedRoad\ViaductUp.16O';
    fileGGA = 'D:\个人论文材料\2017ION\Power Model\RawData\UrbanElevatedRoad\ViaductUp_GPGGA.txt';
    YYMMDD = '20160316';
    fileEphBds = 'D:\个人论文材料\2017ION\Power Model\RawData\UrbanElevatedRoad\BDS_EPH.txt';
    fileEphGps = 'D:\个人论文材料\2017ION\Power Model\RawData\UrbanElevatedRoad\GPS_EPH.txt';
    [XYZ, ~] = readGPGGA(fileGGA, YYMMDD);
    XYZ(isnan(XYZ(:,1)), :)=[];
    refPos = (median(XYZ))';
    attenAnaly = struct(...
        'CNR',   [],...
        'Doppler',   [],...
        'ch',       [],...
        'satPara',       [],...
        'TOWSEC',       []...
        );
    % refPos = [-2853445.384; 4667464.989; 3268291.058];    %   [ 3 × 1 ]
    [psedoRange, inteDopp, attenAnaly.CNR, attenAnaly.Doppler, attenAnaly.ch, attenAnaly.TOWSEC] = read_rinex(fileRinex, 1);
    [attenAnaly.satPara, PrnList] = satellite_status_cal(attenAnaly.TOWSEC, fileEphBds, fileEphGps, refPos);
end

%%%%%%%%%%%%%%%  系统卫星选取  %%%%%%%%%%%%%%%%%%%%
switch sys
    case 'GPS'
        prnRange = 1 : 32;
        CNR_Proc = attenAnaly.CNR.GPS;
        sarPara_Proc = attenAnaly.satPara.GPS;
        CNR_std_Proc = CNR_std.GPS;
        chList_Proc_temp = intersect(attenAnaly.ch.GPS, attenAnaly.ch.GPS);
        chList_Proc = intersect(chList_Proc_temp, prnRange);
    case 'BDS_GEO'
        prnRange = 5;
        CNR_Proc = attenAnaly.CNR.BDS;
        sarPara_Proc = attenAnaly.satPara.BDS;
        CNR_std_Proc = CNR_std.BDS_GEO;
        chList_Proc_temp = intersect(attenAnaly.ch.BDS, attenAnaly.ch.BDS);
        chList_Proc = intersect(chList_Proc_temp, prnRange);
        El_range = [90; 0];  % 仰角区间
    case 'BDS_IGSO'
        prnRange = 6 : 10;
        CNR_Proc = attenAnaly.CNR.BDS;
        sarPara_Proc = attenAnaly.satPara.BDS;
        CNR_std_Proc = CNR_std.BDS_IGSO;
        chList_Proc_temp = intersect(attenAnaly.ch.BDS, attenAnaly.ch.BDS);
        chList_Proc = intersect(chList_Proc_temp, prnRange);
    case 'BDS_MEO'
        prnRange = 11 : 15;
        CNR_Proc = attenAnaly.CNR.BDS;
        sarPara_Proc = attenAnaly.satPara.BDS;
        CNR_std_Proc = CNR_std.BDS_MEO;
        chList_Proc_temp = intersect(attenAnaly.ch.BDS, attenAnaly.ch.BDS);
        chList_Proc = intersect(chList_Proc_temp, prnRange);
    case 'BDS_NGEO'
        prnRange = 6 : 15;
        CNR_Proc = attenAnaly.CNR.BDS;
        sarPara_Proc = attenAnaly.satPara.BDS;
        CNR_std_Proc(1, :) = CNR_std.BDS_IGSO;
        CNR_std_Proc(2, :) = CNR_std.BDS_MEO;
        chList_Proc_temp = intersect(attenAnaly.ch.BDS, attenAnaly.ch.BDS);
        chList_Proc = intersect(chList_Proc_temp, prnRange);
end

%%%%%%%%%%%%%%%   仰角区间循环  %%%%%%%%%%%%%%%%%%%%
for k = 1 :  size(El_range, 2)
    El_MAX = El_range(1, k);
    El_MIN = El_range(2, k);
    %% %%%%%%%%%%%%%  筛选需要处理的数据 %%%%%%%%%%%%%%%
    index = 0;
    atten_El = NaN(1, 100000);
    for i = 1 : length(chList_Proc)
        prn = chList_Proc(i);
        line = find(sarPara_Proc(prn).El>El_MIN & sarPara_Proc(prn).El<El_MAX);
        if ~isempty(line)
            for j = 1 : length(line)
                index = index + 1;
                El = ceil(sarPara_Proc(prn).El(line(j)));
                if strcmp(sys, 'BDS_GEO')
                    atten_El(index) = CNR_Proc(prn, line(j)) - CNR_std_Proc(prn);
                elseif strcmp(sys, 'BDS_NGEO')
                    if prn <= 10
                        atten_El(index) = CNR_Proc(prn, line(j)) - CNR_std_Proc(1, El);
                    else
                        atten_El(index) = CNR_Proc(prn, line(j)) - CNR_std_Proc(2, El);
                    end
                else
                    atten_El(index) = CNR_Proc(prn, line(j)) - CNR_std_Proc(El);
                end % if strcmp(sys, 'BDS_GEO')
            end %  j = 1 : length(line)
        end % if ~isempty(line)
    end % for i = 1 : length(chList_Proc)
    atten_El = (atten_El(1:index))';
    
    Age1 = find(atten_El==0);
    Age1_value = normrnd(-1, 0.4, [length(Age1), 1]);
    Age2 = find(atten_El==1);
    Age2_value = normrnd(-2, 0.4, [length(Age2), 1]);
    Age3 = find(atten_El==2);
    Age3_value = normrnd(-3, 0.4, [length(Age3), 1]);
    atten_El(Age1) = Age1_value;
    atten_El(Age2) = Age2_value;
    atten_El(Age3) = Age3_value;
    
    
    visibleAge = find(atten_El>-30);
    blockAge = find(atten_El<=-30);
    blockValue = normrnd(-50, 2, [length(blockAge), 1]);
    atten_El_vis = atten_El(visibleAge);
    atten_El_Modi = atten_El;
    atten_El_Modi(blockAge) = blockValue;
    Per = length(visibleAge) / length(atten_El);
    figure();
    [pool_norm_all, x_all] = barPlot(hist_values, hist_step, atten_El_Modi);
    
    

    %% %%%%%%%%%%%%%% HMM-MG 参数估计 %%%%%%%%%%%%%%
    
    %%%%%——————  MVGM  ————————%%%%%
%     P0 = cat(3 , [0.33] , [0.33], [0.34]);
%     [logl , Mest , Sest , Pest] = em_mvgm(atten_El_vis , M0 , S0 , P0 , nbite);
%     PIest = [Pest(1,1,1); Pest(1,1,2); Pest(1,1,3)];
%     y_fit_test = PIest(1) * normpdf(x_fit, Mest(1,1,1), sqrt(Sest(1,1,1))) + PIest(2) * normpdf(x_fit, Mest(1,1,2), sqrt(Sest(1,1,2))) + ...
%             PIest(3) * normpdf(x_fit, Mest(1,1,3), sqrt(Sest(1,1,3)));
        
    %%%%%%%%%———————— k-means + EM Algorithms
    options = statset('MaxIter', 2000);
    Mu = [-0.134; -5.402; -4.38];
    Sigma(:,:,1) = [0.7];
    Sigma(:,:,2) = [13.21];
    Sigma(:,:,3) = [1.7];
    PComponents = [0.33, 0.33, 0.34];
    S = struct('mu',Mu,'Sigma',Sigma,'ComponentProportion',PComponents);
    GMModel = fitgmdist(atten_El_vis, 3, 'Options', options, 'RegularizationValue', 0.01);  % 'Start', S
    [idx, logl, P_matrix, ~] = cluster(GMModel, atten_El_vis);
    y_fit = Per * GMModel.ComponentProportion(1) * normpdf(x_fit, GMModel.mu(1), sqrt(GMModel.Sigma(1,1,1))) + Per * GMModel.ComponentProportion(2) * normpdf(x_fit, GMModel.mu(2), sqrt(GMModel.Sigma(1,1,2))) + ...
        Per * GMModel.ComponentProportion(3) * normpdf(x_fit, GMModel.mu(3), sqrt(GMModel.Sigma(1,1,3)));
    transiMat = [0, 0, 0;...
                     0, 0, 0;...
                     0, 0, 0];
     for i = 2 : length(idx)
         state1 = idx(i-1);
         state2 = idx(i);
         transiMat(state1, state2) = transiMat(state1, state2) + 1;
     end
     sumA = sum(transiMat, 2);
     transiMat = transiMat./sumA(:, ones(1,3));
     
     mu_sigma_mat = [GMModel.mu(1), GMModel.Sigma(1,1,1), GMModel.ComponentProportion(1); ...
                                 GMModel.mu(2), GMModel.Sigma(1,1,2), GMModel.ComponentProportion(2);...
                                 GMModel.mu(3), GMModel.Sigma(1,1,3), GMModel.ComponentProportion(3)];
     mu_sigma_mat = sort(mu_sigma_mat, 1, 'descend');
     
    %%%%%%%%%%  计算HMM-GMM矩阵参数  %%%%%%%%%
    PI0 = [Per * mu_sigma_mat(1, 3); Per * mu_sigma_mat(2, 3); Per * mu_sigma_mat(3, 3); 1-Per];  % 状态初始概率

    A0 = [0.85, 0.05, 0.05, 0.5;...
              0.05, 0.85, 0.05, 0.5;...
              0.05, 0.05, 0.85, 0.5;...
              0.05, 0.05, 0.05, 0.85;];  % 状态转移概率矩阵

    Mu = cat(3 , [mu_sigma_mat(1, 1)], [mu_sigma_mat(2, 1)], [mu_sigma_mat(3, 1)], [-50]); % 均值向量
    Sigma = cat(3 , [mu_sigma_mat(1, 2)], [mu_sigma_mat(2, 2)], [mu_sigma_mat(3, 2)], [4]);    % 协方差矩阵
    options.nb_ite = 2000;      % 迭代次数
    nbite = options.nb_ite;
    %%%%% EM algorithm %%%%
    [HM_GMM.logl , HM_GMM.PIest , HM_GMM.Aest , HM_GMM.Mu , HM_GMM.Sigma] = em_ghmm(atten_El_Modi', PI0 , A0 , Mu , Sigma , options);
    y_fit_test = HM_GMM.PIest(1) * normpdf(x_fit, HM_GMM.Mu(1,1,1), sqrt(HM_GMM.Sigma(1,1,1))) + HM_GMM.PIest(2) * normpdf(x_fit, HM_GMM.Mu(1,1,2), sqrt(HM_GMM.Sigma(1,1,2))) + ...
            HM_GMM.PIest(3) * normpdf(x_fit, HM_GMM.Mu(1,1,3), sqrt(HM_GMM.Sigma(1,1,3))) + HM_GMM.PIest(4) * normpdf(x_fit, HM_GMM.Mu(1,1,4), sqrt(HM_GMM.Sigma(1,1,4)));
   
        %%%%% 拟合曲线 %%%% 
    hold on;
    plot(x_fit, y_fit, '--r', 'LineWidth', 2);
    hold on;
    plot(x_fit, y_fit_test, '--c', 'LineWidth', 2);
    hold off;
%     figure();
%     state1_x = find(idx == 1);
%     state1 = atten_El_vis(state1_x);
%     state2_x = find(idx == 2);
%     state2 = atten_El_vis(state2_x);
%     state3_x = find(idx == 3);
%     state3 = atten_El_vis(state3_x);
%     plot(state1_x, state1, 'k.');
%     hold on;
%     plot(state2_x, state2, 'b.');
%     hold on;
%     plot(state3_x, state3, 'r.');
%     hold off;
%     figure();
%     plot(atten_El_vis, 'r.');
%     hold on;
%     plot(x_fit, y_fit_test, '--c', 'LineWidth', 2);
    %———————— 利用拟合参数绘图 ————————%
    

    %% %%%%%%%%%%%%%%自动记录到xls表格中 %%%%%%%%%%%%%%
    if isWriteXls
        xlswrite(xlsName, {strcat(sys,'_',num2str(El_MAX))}, sheetName,strcat('A',xlsLine));
        xlsLine_end = num2str(str2double(xlsLine) + status - 1);
        column_1 = strcat('B',xlsLine, ':', 'H', xlsLine_end);
        column_2 = strcat('I',xlsLine);
        matrixWrite = [HM_GMM.Aest', HM_GMM.PIest, [mu_sigma_mat(:,1); -50],[mu_sigma_mat(:,2); 0]];
        xlswrite(xlsName, matrixWrite, sheetName, column_1);
        xlswrite(xlsName, logl, sheetName, column_2);
        xlsLine = num2str(str2double(xlsLine) + status);
    end
    
end % for k = 1 : length(El_MAX)
