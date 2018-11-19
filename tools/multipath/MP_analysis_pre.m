clear;clc;close all;
fileName_MP = 'D:\数据处理结果\Lujiazui_static_point_11_2016-5-18_18-55-19\Lujiazui_static_point_11_2016-5-18_18-55-19.15GMP';
%fileName_O = 'D:\数据处理结果\Lujiazui_static_2_2016-5-18_18-55-19\Lujiazui_static_2_2016-5-18_18-55-19.15O';
% filename_Sateobs_BDS = 'C:\Users\wyz\Desktop\logfile+m\logfile\The_Three_Towers_SateObs_BDS.txt';
% [el_BDS,az_BDS,SNR_BDS,CNR_BDS,carriVar_BDS,satPos_x_BDS,satPos_y_BDS,satPos_z_BDS,satVel_x_BDS,satVel_y_BDS,satVel_z_BDS,satClcErr_BDS,satClcErrDot_BDS,TOWSEC_BDS]...
%      = readSatobs(filename_Sateobs_BDS);
[parameter,prnNum,prnMax,TOWSEC_1] = readMP(fileName_MP);
% [C1, L1,S1,D1,satnum,TOWSEC_2] = read_rinex(fileName_O,1);
xlsName = 'D:\论文和汇报\论文材料\IAG\LuJiazui_Data_Analysis.xlsx';
sheetName = 'lujiazui_1_2016-7-4_20-19-48';
prn = 6;
multipathNum = 2;
xlsLine = '125';
sys = 'GPS'; % BDS / GPS
isWriteXls = 0;

multiPara = struct(...
    'pathNum',      0,...
    'codeDelay',    [],...
    'attenu',       [],...
     'I_amp',        [],...
    'Q_amp',        [],...
    'pathIndex',    [],...
    'delay_sect',   [],...    
    'atten_sect',   [],...
    'timeLen',      []....
    );
multiPara(1:multipathNum) = multiPara;

if strcmp(sys,'GPS')
    codeMeters = 299792458/1023000;
elseif strcmp(sys,'BDS')
    codeMeters = 299792458/2046000;
end
% column = cell{3,5};
column{1} = {strcat('B',xlsLine),strcat('C',xlsLine),strcat('D',xlsLine),strcat('E',xlsLine),strcat('F',xlsLine)};
column{2} = {strcat('H',xlsLine),strcat('I',xlsLine),strcat('J',xlsLine),strcat('K',xlsLine),strcat('L',xlsLine)};
column{3} = {strcat('N',xlsLine),strcat('O',xlsLine),strcat('P',xlsLine),strcat('Q',xlsLine),strcat('R',xlsLine)};



for i = 1 : multipathNum
    multiPara(i).codeDelay = parameter(prn).codeDelay(:,i+1) * codeMeters;
    multiPara(i).attenu = parameter(prn).CNR(:,1) - parameter(prn).CNR(:,i+1);
    multiPara(i).I_amp = parameter(prn).I(:,i+1);
    multiPara(i).Q_amp = parameter(prn).Q(:,i+1);
    multiPara(i).carriPhase = atan2(multiPara(i).Q_amp, multiPara(i).I_amp) ./pi * 180;
    multiPara(i).carriPhase(multiPara(i).codeDelay==0) = NaN;
    multiPara(i).attenu(multiPara(i).codeDelay==0) = NaN;
    multiPara(i).codeDelay(multiPara(i).codeDelay==0) = NaN;
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
%———————— 画图 ——————————
figure();
RGB = [1,0,0;0,0.498,0;0,0,1];
for i = 1:multipathNum
    hold on;
    plot(multiPara(i).codeDelay,'-','Color',RGB(i,:));
end
hold off;
figure();
RGB = [1,0,0;0,0.498,0;0,0,1];
for i = 1:multipathNum
    hold on;
    plot(multiPara(i).attenu,'-','Color',RGB(i,:));
end
hold off;
figure();
RGB = [1,0,0;0,0.498,0;0,0,1];
for i = 1:multipathNum
    hold on;
    plot(multiPara(i).carriPhase,'-','Color',RGB(i,:));
end
hold off;
% 计算平均延时和能量衰减
for i = 1 : multipathNum
    pathNum = size(multiPara(i).pathIndex,1);
    multiPara(i).delay_sect = zeros(pathNum, 1);
    multiPara(i).atten_sect = zeros(pathNum, 1);
    multiPara(i).timeLen = zeros(pathNum, 1);
    for j = 1 : pathNum
        multiPara(i).atten_sect(j) = mean(multiPara(i).attenu(multiPara(i).pathIndex(j,1):multiPara(i).pathIndex(j,2)));
        multiPara(i).delay_sect(j) = mean(multiPara(i).codeDelay(multiPara(i).pathIndex(j,1):multiPara(i).pathIndex(j,2)));
        multiPara(i).timeLen(j) = multiPara(i).pathIndex(j,2) - multiPara(i).pathIndex(j,1) + 1;
    end
end
if isWriteXls
    xlswrite(xlsName, {strcat(sys,'_',num2str(prn))},sheetName,strcat('A',xlsLine));
    for i = 1 : multipathNum
        if ~isempty(multiPara(i).timeLen)
            xlswrite(xlsName, multiPara(i).pathIndex(:,1),sheetName,column{1,i}{1,1});
            xlswrite(xlsName, multiPara(i).pathIndex(:,2),sheetName,column{1,i}{1,2});
            xlswrite(xlsName, multiPara(i).delay_sect,sheetName,column{1,i}{1,3});
            xlswrite(xlsName, multiPara(i).atten_sect,sheetName,column{1,i}{1,4});
            xlswrite(xlsName, multiPara(i).timeLen,sheetName,column{1,i}{1,5});
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
