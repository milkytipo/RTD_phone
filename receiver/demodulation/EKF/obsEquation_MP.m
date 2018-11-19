% Compute Val = || Xs - X || + b and its Jacobian.
function [Val, Jacob] = obsEquation_MP(X)
% 观测矩阵
% Each row of SV is the coordinate of a satellite.

%——————计算观测方程——————————%

Jacob = blkdiag(1,1);

%————————计算预测观测值——————————%
Val(1, 1) = X(1);  % 预测多径延迟误差
Val(2, 1) = X(2);  % 预测多径延迟误差的变化量
end