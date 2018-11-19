function [Val, Jacob] = ConstantVelocity_MP(X, T)
% 此函数为低速模型中的状态转移矩阵
Val = zeros(size(X));
Val(1) = X(1) + T * X(2);     % 位置预测
Val(2) = X(2);      % 预测位置保持不变
Jacob = [1,T; 0,1];


end