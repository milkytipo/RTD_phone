function [pvtCalculator] = saveMatrix(doubleDiff, pvtCalculator, satPositions, activeChannel)
refxyz = [-2853445.340, 4667464.957, 3268291.032];    % 基准站坐标--行向量
basePrn = pvtCalculator.doubleDiff.basePrn;    % 参考卫星PRN号
pvtCalculator.doubleDiff.numTime = pvtCalculator.doubleDiff.numTime + 1;    % 历元计数加1
if pvtCalculator.doubleDiff.numTime > 0 
    numTime = mod(pvtCalculator.doubleDiff.numTime, 100);     % 当前观测历元计数
    if numTime == 0
        numTime = 100;
    end
    pvtCalculator.doubleDiff.obs(numTime, :) = doubleDiff;      % 保存当前历元的观测量双差(列表示卫星号)
    vectorBase = (satPositions(:,basePrn)'-refxyz)/norm(satPositions(:,basePrn)'-refxyz);         % 参考卫星方向向量
    for i = 1:length(activeChannel(2,:))
        if activeChannel(2,i) ~= basePrn
            vectorUse = (satPositions(:,activeChannel(2,i))'-refxyz)/norm(satPositions(:,activeChannel(2,i))'-refxyz);   % 其余卫星方向向量
            pvtCalculator.doubleDiff.vector(activeChannel(2,i),:,numTime) = (vectorBase - vectorUse)/(299792458/1561098000);     % 卫星观测方向差（行表示卫星号）
        end
    end
end
end

