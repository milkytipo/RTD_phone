function [feature_Norm, feature, timeLen, pos_xyz, vel, enuMap] = featureGet(parameter, fileNum, CNR_std_ublox)

% ———————— [可见卫星数，DOP值，均值，方差，波动性，被遮挡卫星数，遮挡比例系数, 误差] ————————————————
pNum = 9; % 总特征数量

%% %———————————— 特征参数初始化 ————————————%
index = 0;
timeLen = zeros(fileNum, 1);
for i = 1 : fileNum
    timeLen(i) = size(parameter(i).SOW, 2);
end
% [可见卫星数，DOP值，均值，方差，被遮挡卫星数]
tNum = sum(timeLen); % 总历元数量
feature = zeros(tNum, pNum);
feature_Norm = zeros(tNum, pNum);
pos_xyz = zeros(tNum, 3);
vel = zeros(sum(timeLen), 1);
enuMap = zeros(3, sum(timeLen));
%% %————————————  参数特征提取  ————————————————
for i = 1 : fileNum
    paraFile = parameter(i);
    for k = 1 : timeLen(i)
        index = index + 1;
        pos_xyz(index, :) = paraFile.pos_xyz(:, k)';
        vel(index) = paraFile.vel(k);
        
        % ———————— 1、可见卫星数特征 —————————— %
        feature(index, 1) = paraFile.satNum(k);
        
        %  ———————— 2、GDOP值特征 —————————— %
        feature(index, 2) = paraFile.GDOP(k);
        
        % ——————— 3~5、载噪比均值、方差和波动性 ———————%
        attenuation = zeros(1, paraFile.satNum(k));   % 均值、方差
        atten_var = zeros(1, paraFile.satNum(k));   % 波动性
        if paraFile.satNum(k) > 1
            for j = 1 : paraFile.satNum(k)
                prn = paraFile.prnNo(j, k);
                el = paraFile.Elevation(prn, k);
                if el == 0
                    CNR_std = CNR_std_ublox(1);
                else
                    CNR_std = CNR_std_ublox(el);
                end
                attenuation(j) = paraFile.CNR(prn, k) - CNR_std;
                atten_var(j) = paraFile.CNR_Var(prn, k);
            end
            feature(index, 3) = mean(attenuation);
            feature(index, 4) = sqrt(var(attenuation));
            feature(index, 5) = mean(atten_var);
        elseif paraFile.satNum(k) == 1
            prn = paraFile.prnNo(1, k);
            el = paraFile.Elevation(prn, k);
            if el == 0
                CNR_std = CNR_std_ublox(1);
            else
                CNR_std = CNR_std_ublox(el);
            end
            attenuation(1) = paraFile.CNR(prn, k) - CNR_std;
            feature(index, 3) = mean(attenuation);
            feature(index, 4) = feature(index-1, 4); % 由于只有1个数，所以默认设为5
            feature(index, 5) = mean(atten_var);
        elseif  paraFile.satNum(k) == 0
            feature(index, 3) = -40;
            feature(index, 4) = feature(index-1, 4); % 由于只有0个数，所以默认设为5
            feature(index, 5) = feature(index-1, 5);
        end % if paraFile.satNum(k) > 1
        
        % —————————— 6、被遮挡卫星数 ——————————%
        feature(index, 6) = paraFile.blockNum(k);
        
        % —————————— 7、卫星遮挡比例系数 ——————————%
        feature(index, 7) = feature(index, 6) / (feature(index, 6)+feature(index, 1));
        
         % —————————— 8、GDOP增大比例 ——————————%
        feature(index, 8) = paraFile.GDOP_ratio(k);
        
        % —————————— 9、定位误差 ——————————%
        feature(index, 9) = paraFile.ENU_error(4, k);
       
    end % for k = 1 : timeLen(i)
end % for i = 1 : fileNum

%% %%%%%%%%%%% 参数归一化 %%%%%%%%%%%%%%
for i = 1 : pNum    
%     Mu = median(feature(:, i));
%     sigma = sum(abs(feature(:, i) - Mu))/N;
    Mu = mean(feature(:, i));
    sigma = sqrt(sum((feature(:, i) - Mu).^2) /tNum);   
    feature_Norm(:, i) = (feature(:, i) - Mu) / sigma;
end

%% %%%%%%%%%%% 计算地图显示用的ENU坐标 %%%%%%%%%%%%%%
index = 1;
for i = 1 : fileNum
    ENU_temp = parameter(i).pos_enu;
    enuMap(:,index:(index+timeLen(i)-1)) = ENU_temp + [(max(enuMap(1,:)) - min(ENU_temp(1,:)) + 500);0;0];
    index = index + timeLen(i);
end   

end % EOF : function