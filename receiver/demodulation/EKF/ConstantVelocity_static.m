% Constant Velocity model for GPS navigation.
function [Val, Jacob] = ConstantVelocity_static(X, T)
% 此函数为低速模型中的状态转移矩阵
Val = zeros(size(X));
Val(4) = X(4) + T * X(5);     % 位置预测
Val([1,2,3,5]) = X([1,2,3,5]);      % 预测位置保持不变
Jacob = [1,T; 0,1];
Jacob = blkdiag(1,1,1,Jacob);

end