% Constant Velocity model for GPS navigation.
function [Val, Jacob] = ConstantVelocity(X, T)
% 此函数为低速模型中的状态转移矩阵
Val = zeros(size(X));
Val(1:2:end) = X(1:2:end) + T * X(2:2:end);     % 位置预测
Val(2:2:end) = X(2:2:end);      % 预测速度保持不变
Jacob = [1,T; 0,1];
Jacob = blkdiag(Jacob,Jacob,Jacob,Jacob);

end