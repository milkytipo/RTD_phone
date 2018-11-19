function [multiPara, multipathNum] = logRead_MP(parameter, sys, prn, timeIndex)

loopPhase = 200; %跳过整周的相位差
window = 200000; %求多普勒频移的窗口大小
skipN = 0; % 载波跳过的周期数
multiPara = struct(...
    'pathNum',      0,...
    'codeDelay',    nan(1,length(timeIndex)),...
    'codeDelay_Auto',    nan(1,length(timeIndex)),...   % 自动化处理后的多径码相位延时
    'attenu',       nan(1,length(timeIndex)),...
    'multi_CNR',    nan(1,length(timeIndex)),...
    'carriPhase',   nan(1,length(timeIndex)),...
    'contiPhase',   nan(1,length(timeIndex)),...
    'doppRate',     nan(1,length(timeIndex)),...
    'I_amp',        nan(1,length(timeIndex)),...
    'Q_amp',        nan(1,length(timeIndex)),...
    'elevation',    nan(1,length(timeIndex)),...
    'elevation_fit',    nan(1,length(timeIndex)),...
    'CNR',          nan(1,length(timeIndex)),...
    'pathIndex',    [],...
    'pathIndex_Auto',[],...
    'pathIndex_1s',[],...
    'delay_sect',   [],...
    'atten_sect',   [],...
    'multiCNR_sect',   [],...
    'dopp_sect',    [],...
    'el_sect',      [],...
    'timeLen',      [],...
    'lifeTime_Flag',[]... % 判断数据是否可以计算生命周期
    );
multiPara(1:3) = multiPara;

if strcmp(sys,'GPS')
    codeMeters = 299792458/1023000;
elseif strcmp(sys,'BDS')
    codeMeters = 299792458/2046000;
end

if strcmp(sys,'GPS')
    multipathNum = max(parameter(2).pathNum(prn, :)) - 1;
    for i = 1 : multipathNum
        multiPara(i).codeDelay = parameter(2).pathPara(prn).codePhaseDelay(i+1,:) * codeMeters;
        multiPara(i).attenu = parameter(2).pathPara(prn).CNR(1,:) - parameter(2).pathPara(prn).CNR(i+1,:);
        multiPara(i).multi_CNR = parameter(2).pathPara(prn).CNR(i+1,:);
        multiPara(i).I_amp = parameter(2).pathPara(prn).ampI(i+1,:);
        multiPara(i).Q_amp = parameter(2).pathPara(prn).ampQ(i+1,:);
        multiPara(i).elevation = parameter(2).Elevation(prn, :);
        multiPara(i).CNR = parameter(2).pathPara(prn).CNR(1,:);
        multiPara(i).carriPhase = atan2(multiPara(i).Q_amp, multiPara(i).I_amp) ./pi * 180;
        multiPara(i).carriPhase(multiPara(i).codeDelay==0) = NaN;
        multiPara(i).attenu(multiPara(i).codeDelay==0) = NaN;
        multiPara(i).multi_CNR(multiPara(i).codeDelay==0) = NaN;
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
        multiPara(i).multi_CNR = parameter(1).pathPara(prn).CNR(i+1,:);
        multiPara(i).I_amp = parameter(1).pathPara(prn).ampI(i+1,:);
        multiPara(i).Q_amp = parameter(1).pathPara(prn).ampQ(i+1,:);
        multiPara(i).carriPhase = atan2(multiPara(i).Q_amp, multiPara(i).I_amp) ./pi * 180;
        multiPara(i).elevation = parameter(1).Elevation(prn, :);
        multiPara(i).CNR = parameter(1).pathPara(prn).CNR(1,:);
        multiPara(i).carriPhase(multiPara(i).codeDelay==0) = NaN;
        multiPara(i).attenu(multiPara(i).codeDelay==0) = NaN;
        multiPara(i).multi_CNR(multiPara(i).codeDelay==0) = NaN;
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
% --—————————————— 分段 ————————————————————%
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
% ——————————————计算多普勒频移变化量————————————————%
for i = 1 : multipathNum
    for j = 1 : multiPara(i).pathNum
        x1 = multiPara(i).pathIndex(j,1); % 首坐标
        x2 = multiPara(i).pathIndex(j,2);
        pointNum = x2 - x1 + 1;
        for k = x1 : x2
            if pointNum > 1
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
            else
                multiPara(i).doppRate(k) = 0;
            end
        end
    end
end
% ——————————————仰角拟合————————————————%
elev = multiPara(1).elevation;
elev(isnan(elev)) = 0;
elev_time = timeIndex;
elev_time(elev==0) = [];
elev(elev==0) = [];
if ~isempty(elev)
    p = polyfit(elev_time, elev, 1);
end
for i = 1 : multipathNum
    multiPara(i).elevation_fit = p(1)*timeIndex + p(2);
end