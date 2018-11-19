 % 是否重新读取文件
isRead = 1; clc;
close all;
if isRead
    clear;clc;fclose all;
    filename = 'K:\multipath_simulator_15_2017-3-25_10-25-07_allObs.txt';
    %fileName_O = 'D:\数据处理结果\Lujiazui_static_2_2016-5-18_18-55-19\Lujiazui_static_2_2016-5-18_18-55-19.15O';
    % filename_Sateobs_BDS = 'C:\Users\wyz\Desktop\logfile+m\logfile\The_Three_Towers_SateObs_BDS.txt';
    % [el_BDS,az_BDS,SNR_BDS,CNR_BDS,carriVar_BDS,satPos_x_BDS,satPos_y_BDS,satPos_z_BDS,satVel_x_BDS,satVel_y_BDS,satVel_z_BDS,satClcErr_BDS,satClcErrDot_BDS,TOWSEC_BDS]...
    %      = readSatobs(filename_Sateobs_BDS);
    %     [parameter,prnNum,prnMax,TOWSEC_1] = readMP(fileName_MP);
    [parameter, SOW] = readObs(filename);
    prnBDS = parameter(1).prnMax;
    prnGPS = parameter(2).prnMax;
end
timeIndex = SOW(1,:) - SOW(1,1);
% [C1, L1,S1,D1,satnum,TOWSEC_2] = read_rinex(fileName_O,1);
xlsName = 'D:\数据处理结果\Lujiazui_Static_Point_v2.0\Lujiazui_Static_Point_12_ed\Lujiazui_static_point_12_auto.xlsx';
sheetName = 'GPS';  % BDS_GEO / BDS_IGSO / BDS_MEO / GPS / occurance
prn = 2;
xlsLine = '3';
sys = 'GPS'; % BDS / GPS
isWriteXls = 0;
window = 200000; %求多普勒频移的窗口大小
timeInterval = 0.1; % second

loopPhase = 170; %跳过整周的相位差

lifeTime_ALL = [1, length(timeIndex)]; % 判断数据是否可以计算生命周期
skipN = 0; % 载波跳过的周期数
multiPara = struct(...
    'pathNum',      0,...
    'codeDelay',    nan(1,length(timeIndex)),...
    'attenu',       nan(1,length(timeIndex)),...
    'carriPhase',   nan(1,length(timeIndex)),...
    'contiPhase',   nan(1,length(timeIndex)),...
    'doppRate',     nan(1,length(timeIndex)),...
    'I_amp',        nan(1,length(timeIndex)),...
    'Q_amp',        nan(1,length(timeIndex)),...
    'elevation',    nan(1,length(timeIndex)),...
    'CNR',          nan(1,length(timeIndex)),...
    'pathIndex',    [],...
    'delay_sect',   [],...    
    'atten_sect',   [],...
    'dopp_sect',    [],...
    'el_sect',      [],...
    'timeLen',      [],...
    'lifeTime_Flag',[]... % 判断数据是否可以计算生命周期
    );
multiPara(1:5) = multiPara;

if strcmp(sys,'GPS')
    codeMeters = 299792458/1023000;
elseif strcmp(sys,'BDS')
    codeMeters = 299792458/2046000;
end
% column = cell{3,5};
column{1} = {strcat('B',xlsLine),strcat('C',xlsLine),strcat('D',xlsLine),strcat('E',xlsLine),strcat('F',xlsLine),strcat('G',xlsLine),strcat('H',xlsLine),strcat('I',xlsLine),strcat('J',xlsLine)};
column{2} = {strcat('N',xlsLine),strcat('O',xlsLine),strcat('P',xlsLine),strcat('Q',xlsLine),strcat('R',xlsLine),strcat('S',xlsLine),strcat('T',xlsLine),strcat('U',xlsLine),strcat('V',xlsLine)};
column{3} = {strcat('Z',xlsLine),strcat('AA',xlsLine),strcat('AB',xlsLine),strcat('AC',xlsLine),strcat('AD',xlsLine),strcat('AE',xlsLine),strcat('AF',xlsLine),strcat('AG',xlsLine),strcat('AH',xlsLine)};



if strcmp(sys,'GPS')
    multipathNum = max(parameter(2).pathNum(prn, :)) - 1;
    for i = 1 : multipathNum
        multiPara(i).codeDelay = parameter(2).pathPara(prn).codePhaseDelay(i+1,:) * codeMeters;
        multiPara(i).attenu = parameter(2).pathPara(prn).CNR(1,:) - parameter(2).pathPara(prn).CNR(i+1,:);
        multiPara(i).I_amp = parameter(2).pathPara(prn).ampI(i+1,:);
        multiPara(i).Q_amp = parameter(2).pathPara(prn).ampQ(i+1,:);
        multiPara(i).elevation = parameter(2).Elevation(prn, :);
        multiPara(i).CNR = parameter(2).pathPara(prn).CNR(1,:);
        multiPara(i).carriPhase = atan2(multiPara(i).Q_amp, multiPara(i).I_amp) ./pi * 180;
        multiPara(i).carriPhase(multiPara(i).codeDelay==0) = NaN;
        multiPara(i).attenu(multiPara(i).codeDelay==0) = NaN;
        multiPara(i).codeDelay(multiPara(i).codeDelay==0) = NaN;
        multiPara(i).elevation(multiPara(i).codeDelay==0) = NaN;
        % 计算连续的载波相位
        for j = 1 : length(timeIndex)
            if isnan(multiPara(i).carriPhase(j))
                skipN = 0;
                continue;
            end
            if j == 1
                multiPara(i).contiPhase(j) = multiPara(i).carriPhase(j);
                continue;
            end
            if isnan(multiPara(i).carriPhase(j-1))
                multiPara(i).contiPhase(j) = multiPara(i).carriPhase(j);
            else
                phaseErr_step = multiPara(i).carriPhase(j)-multiPara(i).carriPhase(j-1);
                if phaseErr_step > loopPhase  % 说明超过+-180度
                    skipN = skipN - 1;
                elseif phaseErr_step < -loopPhase
                    skipN = skipN + 1;
                end
                multiPara(i).contiPhase(j) = multiPara(i).carriPhase(j) + skipN*360;
            end
        end % EOF : j = 1 : length(timeIndex)
    end % EOF : i = 1 : multipathNum
elseif strcmp(sys,'BDS')
    multipathNum = max(parameter(1).pathNum(prn, :)) - 1;
    for i = 1 : multipathNum
        multiPara(i).codeDelay = parameter(1).pathPara(prn).codePhaseDelay(i+1,:) * codeMeters;
        multiPara(i).attenu = parameter(1).pathPara(prn).CNR(1,:) - parameter(1).pathPara(prn).CNR(i+1,:);
        multiPara(i).I_amp = parameter(1).pathPara(prn).ampI(i+1,:);
        multiPara(i).Q_amp = parameter(1).pathPara(prn).ampQ(i+1,:);
        multiPara(i).carriPhase = atan2(multiPara(i).Q_amp, multiPara(i).I_amp) ./pi * 180;
        multiPara(i).elevation = parameter(1).Elevation(prn, :);
        multiPara(i).CNR = parameter(1).pathPara(prn).CNR(1,:);
        multiPara(i).carriPhase(multiPara(i).codeDelay==0) = NaN;
        multiPara(i).attenu(multiPara(i).codeDelay==0) = NaN;
        multiPara(i).codeDelay(multiPara(i).codeDelay==0) = NaN;
        multiPara(i).elevation(multiPara(i).codeDelay==0) = NaN;
        % 计算连续的载波相位
        for j = 1 : length(timeIndex)
            if isnan(multiPara(i).carriPhase(j))
                skipN = 0;
                continue;
            end
            if j == 1
                multiPara(i).contiPhase(j) = multiPara(i).carriPhase(j);
                continue;
            end
            if isnan(multiPara(i).carriPhase(j-1))
                multiPara(i).contiPhase(j) = multiPara(i).carriPhase(j);
            else
                phaseErr_step = multiPara(i).carriPhase(j)-multiPara(i).carriPhase(j-1);
                if phaseErr_step > loopPhase  % 说明超过+-180度
                    skipN = skipN - 1;
                elseif phaseErr_step < -loopPhase
                    skipN = skipN + 1;
                end
                multiPara(i).contiPhase(j) = multiPara(i).carriPhase(j) + skipN*360;
            end
        end % EOF : j = 1 : length(timeIndex)
    end
end
% -----分段------------%
for i = 1 : multipathNum
    startIndex = 0;
    for j = 1:length(multiPara(i).codeDelay(:))
        if isnan(multiPara(i).codeDelay(j))
            startIndex = 0;
            continue;
        end
        if startIndex == 0
            multiPara(i).pathNum = multiPara(i).pathNum + 1;
            multiPara(i).pathIndex(multiPara(i).pathNum,1) = j;
            startIndex = 1;
        end
        multiPara(i).pathIndex(multiPara(i).pathNum,2) = j;
    end
end
% ——————计算多普勒频移变化量——————%
for i = 1 : multipathNum
    for j = 1 : multiPara(i).pathNum
        x1 = multiPara(i).pathIndex(j,1); % 首坐标
        x2 = multiPara(i).pathIndex(j,2);
        pointNum = x2 - x1 + 1;
        for k = x1 : x2
            if pointNum < 2*window+1  
                p = polyfit(timeIndex(x1:x2), multiPara(i).contiPhase(x1:x2), 1);
                multiPara(i).doppRate(k) = p(1)/360;
            else
                if k-window < x1
                    x1_1 = x1;
                else
                    x1_1 = k-window;
                end
                if k+window > x2
                    x2_2 = x2;
                else
                    x2_2 = k+window;
                end
                p = polyfit(timeIndex(x1_1:x2_2), multiPara(i).contiPhase(x1_1:x2_2), 1);
                multiPara(i).doppRate(k) = p(1)/360;
            end
        end
    end
end
    

%————————平滑处理——————————%
smooth = 80;
for i = 1:multipathNum
    for j = smooth+1 : length(multiPara(i).codeDelay) - smooth
        multiPara(i).codeDelay(j) = mean(multiPara(i).codeDelay((j-smooth):(j+smooth)));
        multiPara(i).attenu(j) = mean(multiPara(i).attenu((j-smooth):(j+smooth)));
        if i<=1
            multiPara(i).carriPhase(j) = mean(multiPara(i).carriPhase((j-smooth):(j+smooth)));
        end
    end
end



%———————— 画图 ——————————
RGB = [0.2,0.6,1; 1,0.4,0; 0.47,0.67,0.19];
figureName = strcat(sys,' PRN  ',num2str(prn),'     CodeDelay');
figure();
subplot(2,2,1);
for i = 1:multipathNum
    hold on;
    line1 = plot([0.1:0.1:length(multiPara(i).codeDelay)/10], multiPara(i).codeDelay,'-','LineWidth',2,'Color',RGB(i,:));
end
title(figureName);
grid on
grid minor
set(gca, 'GridLineStyle', '-.');
set(gca, 'GridAlpha', 0.4);
set(gca, 'MinorGridAlpha', 0.6);
hold off;

figureName = strcat(sys,' PRN  ',num2str(prn),'     PowerAttenu');
% figure();
subplot(2,2,2);
for i = 1:multipathNum
    hold on;
    plot([0.1:0.1:length(multiPara(i).codeDelay)/10], multiPara(i).attenu,'-*','LineWidth',2,'MarkerSize',4,'Color',RGB(i,:));
end
title(figureName);
grid on
grid minor
set(gca, 'GridLineStyle', '-.');
set(gca, 'GridAlpha', 0.4);
set(gca, 'MinorGridAlpha', 0.6);
hold off;

figureName = strcat(sys,' PRN  ',num2str(prn),'     CarriDelay');
% figure();
subplot(2,2,3);
for i = 1:multipathNum
    hold on;
    plot([0.1:0.1:length(multiPara(i).codeDelay)/10], multiPara(i).carriPhase,'-','LineWidth',2,'Color',RGB(i,:));
end
title(figureName);
grid on
grid minor
set(gca, 'GridLineStyle', '-.');
set(gca, 'GridAlpha', 0.4);
set(gca, 'MinorGridAlpha', 0.6);
hold off;

figureName = strcat(sys,' PRN  ',num2str(prn),'     CarriConti');
% figure();
subplot(2,2,4);
for i = 1:multipathNum
    hold on;
    plot(multiPara(i).contiPhase,'-','LineWidth',2,'Color',RGB(i,:));
end
title(figureName);
grid on
grid minor
set(gca, 'GridLineStyle', '-.');
set(gca, 'GridAlpha', 0.4);
set(gca, 'MinorGridAlpha', 0.6);
hold off;

figureName = strcat(sys,' PRN  ',num2str(prn),'     doppRate');
figure();
subplot(2,2,1);
for i = 1:multipathNum
    hold on;
    plot(multiPara(i).doppRate,'-*','LineWidth',2,'MarkerSize',4,'Color',RGB(i,:));
end
title(figureName);
grid on
grid minor
set(gca, 'GridLineStyle', '-.');
set(gca, 'GridAlpha', 0.4);
set(gca, 'MinorGridAlpha', 0.6);
hold off;

figureName = strcat(sys,' PRN  ',num2str(prn),'     elevation');
subplot(2,2,2);
for i = 1:1
    hold on;
    plot(multiPara(i).elevation,'-','LineWidth',2,'Color',RGB(i,:));
end
title(figureName);
grid on
grid minor
set(gca, 'GridLineStyle', '-.');
set(gca, 'GridAlpha', 0.4);
set(gca, 'MinorGridAlpha', 0.6);
hold off;

figureName = strcat(sys,' PRN  ',num2str(prn),'     CNR');
subplot(2,2,3);
for i = 1:1
    hold on;
    plot(multiPara(i).CNR,'-','LineWidth',1,'Color',RGB(i,:));
end
title(figureName);
grid on
grid minor
set(gca, 'GridLineStyle', '-.');
set(gca, 'GridAlpha', 0.4);
set(gca, 'MinorGridAlpha', 0.6);
hold off;

% ——————更新多普勒频移变化量——————%
for i = 1 : multipathNum
    pathNum = size(multiPara(i).pathIndex,1);
    for j = 1 : pathNum
        x1 = multiPara(i).pathIndex(j,1); % 首坐标
        x2 = multiPara(i).pathIndex(j,2);
        pointNum = x2 - x1 + 1;
        for k = x1 : x2
            if pointNum < 2*window+1  
                p = polyfit(timeIndex(x1:x2), multiPara(i).contiPhase(x1:x2), 1);
                multiPara(i).doppRate(k) = p(1)/360;
            else
                if k-window < x1
                    x1_1 = x1;
                else
                    x1_1 = k-window;
                end
                if k+window > x2
                    x2_2 = x2;
                else
                    x2_2 = k+window;
                end
                p = polyfit(timeIndex(x1_1:x2_2), multiPara(i).contiPhase(x1_1:x2_2), 1);
                multiPara(i).doppRate(k) = p(1)/360;
            end
        end
    end
end
    
% 计算平均延时和能量衰减
for i = 1 : multipathNum
    pathNum = size(multiPara(i).pathIndex,1);
    multiPara(i).delay_sect = zeros(pathNum, 1);
    multiPara(i).atten_sect = zeros(pathNum, 1);
    multiPara(i).timeLen = zeros(pathNum, 1);
    multiPara(i).dopp_sect = zeros(pathNum, 1);
    multiPara(i).el_sect = zeros(pathNum, 1);
    multiPara(i).lifeTime_Flag = zeros(pathNum, 1);
    for j = 1 : pathNum
        multiPara(i).atten_sect(j) = mean(multiPara(i).attenu(multiPara(i).pathIndex(j,1):multiPara(i).pathIndex(j,2)));
        multiPara(i).delay_sect(j) = mean(multiPara(i).codeDelay(multiPara(i).pathIndex(j,1):multiPara(i).pathIndex(j,2)));
        multiPara(i).dopp_sect(j) = mean(multiPara(i).doppRate(multiPara(i).pathIndex(j,1):multiPara(i).pathIndex(j,2)));
        multiPara(i).timeLen(j) = (multiPara(i).pathIndex(j,2) - multiPara(i).pathIndex(j,1) + 1) * timeInterval;
        multiPara(i).el_sect(j) = mean(multiPara(i).elevation(multiPara(i).pathIndex(j,1):multiPara(i).pathIndex(j,2)));
        for k = 1 : size(lifeTime_ALL, 1)
            if multiPara(i).pathIndex(j,1)>=lifeTime_ALL(k,1) && multiPara(i).pathIndex(j,2)<=lifeTime_ALL(k,2)
                multiPara(i).lifeTime_Flag(j) = 1;
            end
        end
    end
end
if isWriteXls
    xlswrite(xlsName, {strcat(sys,'_',num2str(prn))}, sheetName,strcat('A',xlsLine));
    for i = 1 : multipathNum
        if ~isempty(multiPara(i).timeLen)
            xlswrite(xlsName, multiPara(i).pathIndex(:,1), sheetName, column{1,i}{1,1});
            xlswrite(xlsName, multiPara(i).pathIndex(:,2), sheetName, column{1,i}{1,2});
            xlswrite(xlsName, multiPara(i).delay_sect, sheetName, column{1,i}{1,3});
            xlswrite(xlsName, multiPara(i).atten_sect, sheetName, column{1,i}{1,4});
            xlswrite(xlsName, multiPara(i).dopp_sect, sheetName, column{1,i}{1,5});
            xlswrite(xlsName, multiPara(i).timeLen, sheetName, column{1,i}{1,6});
            xlswrite(xlsName, multiPara(i).el_sect, sheetName, column{1,i}{1,7});
            xlswrite(xlsName, ones(length(multiPara(i).timeLen), 1), sheetName, column{1,i}{1,8});
            xlswrite(xlsName, multiPara(i).lifeTime_Flag, sheetName, column{1,i}{1,9});
        end
    end
end





%——————————————去除不像多径的点——————————%
% for i = pathNum : -1 : 1
%     if pathIndex(i,2)-pathIndex(i,1)+1<=5
%         codeDelay(pathIndex(i,1):pathIndex(i,2)) = NaN;
%         attenu(pathIndex(i,1):pathIndex(i,2)) = NaN;
%         pathIndex(i,:) = [];
%     end
% end
% pathNum = size(pathIndex,1);
%——————————————去除前后收敛阶段的数据点————————%
% for i = pathNum : -1 : 1
%     if pathIndex(pathNum,2) > pathIndex(pathNum,1)
%         for j = pathIndex(pathNum,1) : pathIndex(pathNum,2)-1
%             if codeDelay(j+1)-codeDelay(j)>20
%                 codeDelay(j+1) = 
