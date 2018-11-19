function [multiPara] = MPrecord_update(multiPara, multipathNum, lifeTime_ALL, timeIndex)

window = 200000; %求多普勒频移的窗口大小
timeInterval = 0.1; % second
loopPhase = 200; %跳过整周的相位差


% —————————————————— 更新多普勒频移变化量 ——————————————%
for i = 1 : multipathNum
    pathNum = size(multiPara(i).pathIndex_Auto,1);
    for j = 1 : pathNum
        x1 = multiPara(i).pathIndex_Auto(j,1); % 首坐标
        x2 = multiPara(i).pathIndex_Auto(j,2);
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

for i = 1 : multipathNum
    multiPara(i).codeDelay_Auto = nan(1, length(multiPara(i).codeDelay_Auto));
end

% 计算平均延时和能量衰减
for i = 1 : multipathNum
    pathNum = size(multiPara(i).pathIndex_Auto,1);
    multiPara(i).delay_sect = zeros(pathNum, 1);
    multiPara(i).atten_sect = zeros(pathNum, 1);
    multiPara(i).multiCNR_sect = zeros(pathNum, 1);
    multiPara(i).timeLen = zeros(pathNum, 1);
    multiPara(i).dopp_sect = zeros(pathNum, 1);
    multiPara(i).el_sect = zeros(pathNum, 1);
    multiPara(i).lifeTime_Flag = zeros(pathNum, 1);
    for j = 1 : pathNum
        x_start = multiPara(i).pathIndex_Auto(j,1);
        y_end = multiPara(i).pathIndex_Auto(j,2);
        % 记录自动修正后的多径码相位延时
        multiPara(i).codeDelay_Auto(x_start:y_end) = multiPara(i).codeDelay(x_start:y_end);        
        multiPara(i).atten_sect(j) = mean(multiPara(i).attenu(multiPara(i).pathIndex_Auto(j,1):multiPara(i).pathIndex_Auto(j,2)));
        multiPara(i).multiCNR_sect(j) = mean(multiPara(i).multi_CNR(multiPara(i).pathIndex_Auto(j,1):multiPara(i).pathIndex_Auto(j,2)));
        multiPara(i).delay_sect(j) = mean(multiPara(i).codeDelay(multiPara(i).pathIndex_Auto(j,1):multiPara(i).pathIndex_Auto(j,2)));
        multiPara(i).dopp_sect(j) = mean(multiPara(i).doppRate(multiPara(i).pathIndex_Auto(j,1):multiPara(i).pathIndex_Auto(j,2)));
        multiPara(i).timeLen(j) = (multiPara(i).pathIndex_Auto(j,2) - multiPara(i).pathIndex_Auto(j,1) + 1) * timeInterval;
        multiPara(i).el_sect(j) = mean(multiPara(i).elevation_fit(multiPara(i).pathIndex_Auto(j,1):multiPara(i).pathIndex_Auto(j,2)));
        for k = 1 : size(lifeTime_ALL, 1)
            if multiPara(i).pathIndex_Auto(j,1)>=lifeTime_ALL(k,1) && multiPara(i).pathIndex_Auto(j,2)<=lifeTime_ALL(k,2)
                multiPara(i).lifeTime_Flag(j) = 1;
            end
        end
    end
end