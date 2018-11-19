function [positionXYZ, pvtCalculator] = carrDiffResult(pvtCalculator, activeChannel, checkNGEO)
refxyz = [-2853445.340, 4667464.957, 3268291.032];    % 基准站坐标--行向量
I0 = zeros(1,3);
positionXYZ = [0,0,0];
basePrn = pvtCalculator.doubleDiff.basePrn;    % 参考卫星PRN号
timeInterval = 60;      % 两个历元之间的时间间隔
numUse = 0;
if length(activeChannel(1,:))>=4 && checkNGEO==1
    for i = 1:length(activeChannel(2,:))
        if activeChannel(2,i) ~= basePrn
            numUse = numUse + 1;
            useChannel(numUse) = activeChannel(2,i);
        end
    end
    if numUse==4 && pvtCalculator.doubleDiff.numTime>=3*timeInterval+1        % 4个观测方程需要至少4个历元
        b = zeros(4*4,1);       % 初始化观测矩阵
        G = zeros(4*4,16);      % 初始化转移矩阵
        I1 = eye(4);            % 创建一个单位矩阵
        numTime1 = mod(pvtCalculator.doubleDiff.numTime, 100);     % 历元4对应矩阵位置
        if numTime1 == 0
            numTime1 = 100;
        end
        numTime2 = mod(pvtCalculator.doubleDiff.numTime-timeInterval, 100);     % 历元3对应矩阵位置
        if numTime2 == 0
            numTime2 = 100;
        end
        numTime3 = mod(pvtCalculator.doubleDiff.numTime-timeInterval*2, 100);     % 历元2对应矩阵位置
        if numTime3 == 0
            numTime3 = 100;
        end
        numTime4 = mod(pvtCalculator.doubleDiff.numTime-timeInterval*3, 100);     % 历元1对应矩阵位置
        if numTime4 == 0
            numTime4 = 100;
        end
        for i = 1:length(useChannel)

                b(i,1) = pvtCalculator.doubleDiff.obs(numTime4,useChannel(i));             % 输入四个历元的载波相位双差观测值
                b(i+numUse,1) = pvtCalculator.doubleDiff.obs(numTime3,useChannel(i));
                b(i+2*numUse,1) = pvtCalculator.doubleDiff.obs(numTime2,useChannel(i));
                b(i+3*numUse,1) = pvtCalculator.doubleDiff.obs(numTime1,useChannel(i));
                G(i,:) = [pvtCalculator.doubleDiff.vector(useChannel(i),:,numTime4), I0, I0, I0, I1(i,:)];      %输入转移矩阵第一列元素
                G(i+numUse,:) = [I0, pvtCalculator.doubleDiff.vector(useChannel(i),:,numTime3), I0, I0, I1(i,:)];
                G(i+2*numUse,:) = [I0, I0, pvtCalculator.doubleDiff.vector(useChannel(i),:,numTime2), I0, I1(i,:)];
                G(i+3*numUse,:) = [I0, I0, I0, pvtCalculator.doubleDiff.vector(useChannel(i),:,numTime1), I1(i,:)];
                deltaPhi(i,1) = pvtCalculator.doubleDiff.obs(numTime1,useChannel(i));      % 输入当前历元的载波相位观测值
                deltaI(i,:) = pvtCalculator.doubleDiff.vector(useChannel(i),:,numTime1);       % 当前历元的转移矩阵

        end
        if pvtCalculator.doubleDiff.nfixedValue ==0
            x = G \ b;      % 求解浮点解
            Q = inv(G'*G);  % 求协方差矩阵
            Qn = Q(13:16,13:16);    % 模糊度的协方差矩阵
            [nfixed,sqnorm,Qahat,Z] = lambda1 (x(13:16), Qn, 2, 1);     % 求解整周模糊度
            pvtCalculator.doubleDiff.nfixed = nfixed(:,1);              % 保存整周模糊度解
            pvtCalculator.doubleDiff.nfixedValue = 1;                   % 表明模糊度已求解
        end
        relativeVector = deltaI \ (deltaPhi-pvtCalculator.doubleDiff.nfixed);           % 求解相对基线向量
        positionXYZ = refxyz + relativeVector';
    end
    if numUse==5 && pvtCalculator.doubleDiff.numTime>=2*timeInterval+1        % 5个观测方程需要至少3个历元
        b = zeros(5*3,1);       % 初始化观测矩阵
        G = zeros(5*3,14);      % 初始化转移矩阵
        I1 = eye(5);            % 创建一个单位矩阵
        numTime1 = mod(pvtCalculator.doubleDiff.numTime, 100);     % 历元3对应矩阵位置
        if numTime1 == 0
            numTime1 = 100;
        end
        numTime2 = mod(pvtCalculator.doubleDiff.numTime-timeInterval, 100);     % 历元2对应矩阵位置
        if numTime2 == 0
            numTime2 = 100;
        end
        numTime3 = mod(pvtCalculator.doubleDiff.numTime-timeInterval*2, 100);     % 历元1对应矩阵位置
        if numTime3 == 0
            numTime3 = 100;
        end
        for i = 1:length(useChannel)

                b(i,1) = pvtCalculator.doubleDiff.obs(numTime3,useChannel(i));             % 输入四个历元的载波相位双差观测值
                b(i+numUse,1) = pvtCalculator.doubleDiff.obs(numTime2,useChannel(i));
                b(i+2*numUse,1) = pvtCalculator.doubleDiff.obs(numTime1,useChannel(i));

                G(i,:) = [pvtCalculator.doubleDiff.vector(useChannel(i),:,numTime3), I0, I0, I1(i,:)];      %输入转移矩阵第一列元素
                G(i+numUse,:) = [I0, pvtCalculator.doubleDiff.vector(useChannel(i),:,numTime2), I0, I1(i,:)];
                G(i+2*numUse,:) = [I0, I0, pvtCalculator.doubleDiff.vector(useChannel(i),:,numTime1), I1(i,:)];

                deltaPhi(i,1) = pvtCalculator.doubleDiff.obs(numTime1,useChannel(i));      % 输入当前历元的载波相位观测值
                deltaI(i,:) = pvtCalculator.doubleDiff.vector(useChannel(i),:,numTime1);       % 当前历元的转移矩阵

        end
        if pvtCalculator.doubleDiff.nfixedValue ==0
            x = G \ b;      % 求解浮点解
            Q = inv(G'*G);  % 求协方差矩阵
            Qn = Q(10:14,10:14);    % 模糊度的协方差矩阵
            [nfixed,sqnorm,Qahat,Z] = lambda1 (x(10:14), Qn, 2, 1);     % 求解整周模糊度
            pvtCalculator.doubleDiff.nfixed = nfixed(:,1);              % 保存整周模糊度解
            pvtCalculator.doubleDiff.nfixedValue = 1;                   % 表明模糊度已求解
        end
        relativeVector = deltaI \ (deltaPhi-pvtCalculator.doubleDiff.nfixed);           % 求解相对基线向量
        positionXYZ = refxyz + relativeVector';
    end
    if numUse>=6 && pvtCalculator.doubleDiff.numTime>=timeInterval+1        % 6个及以上观测方程需要至少2个历元
        b = zeros(numUse*2,1);       % 初始化观测矩阵
        G = zeros(numUse*2,2*3+numUse);      % 初始化转移矩阵
        I1 = eye(numUse);            % 创建一个单位矩阵
        numTime1 = mod(pvtCalculator.doubleDiff.numTime, 100);     % 历元2对应矩阵位置
        if numTime1 == 0
            numTime1 = 100;
        end
        numTime2 = mod(pvtCalculator.doubleDiff.numTime-timeInterval, 100);     % 历元1对应矩阵位置
        if numTime2 == 0
            numTime2 = 100;
        end
        for i = 1:length(useChannel)

                b(i,1) = pvtCalculator.doubleDiff.obs(numTime2,useChannel(i));             % 输入四个历元的载波相位双差观测值
                b(i+numUse,1) = pvtCalculator.doubleDiff.obs(numTime1,useChannel(i));           
                G(i,:) = [pvtCalculator.doubleDiff.vector(useChannel(i),:,numTime2), I0, I1(i,:)];      %输入转移矩阵第一列元素
                G(i+numUse,:) = [I0, pvtCalculator.doubleDiff.vector(useChannel(i),:,numTime1), I1(i,:)];        
                deltaPhi(i,1) = pvtCalculator.doubleDiff.obs(numTime1,useChannel(i));      % 输入当前历元的载波相位观测值
                deltaI(i,:) = pvtCalculator.doubleDiff.vector(useChannel(i),:,numTime1);       % 当前历元的转移矩阵

        end
        if pvtCalculator.doubleDiff.nfixedValue == 0
            x = G \ b;      % 求解浮点解
            Q = inv(G'*G);  % 求协方差矩阵
            Qn = Q(7:(2*3+numUse),7:(2*3+numUse));    % 模糊度的协方差矩阵
            [nfixed,sqnorm,Qahat,Z] = lambda1 (x(7:(2*3+numUse)), Qn, 2, 1);     % 求解整周模糊度
            pvtCalculator.doubleDiff.nfixed = nfixed(:,1);              % 保存整周模糊度解
            pvtCalculator.doubleDiff.nfixedValue = 1;                   % 表明模糊度已求解
        end
        relativeVector = deltaI \ (deltaPhi-pvtCalculator.doubleDiff.nfixed);           % 求解相对基线向量
        positionXYZ = refxyz + relativeVector';
    end
end
end
