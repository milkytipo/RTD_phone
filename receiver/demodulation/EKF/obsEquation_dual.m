% Compute Val = || Xs - X || + b and its Jacobian.
function [Val, Jacob] = obsEquation_dual(X, SV,useNum_BDS)
% 观测矩阵
% Each row of SV is the coordinate of a satellite.
dX = bsxfun(@minus, X([1,3,5])', SV(:,1:3));% 卫星位置与接收机位置差
%——————计算观测方程——————————%
Jacob = zeros(2*size(SV, 1), size(X, 1));
Jacob(1:2:2*size(SV,1), [1,3,5]) = bsxfun(@rdivide, dX, sum(dX .^2, 2) .^0.5);
Jacob(2:2:2*size(SV,1), [2,4,6]) = bsxfun(@rdivide, dX, sum(dX .^2, 2) .^0.5);
Jacob(1:2:2*useNum_BDS, 7) = 1; % for BDS
Jacob(1:2:2*useNum_BDS, 9) = 0; % for BDS
Jacob(2:2:2*useNum_BDS, 8) = 1; % for BDS
Jacob(2:2:2*useNum_BDS, 10) = 0; % for BDS
Jacob((1:2:2*(size(SV,1)-useNum_BDS))+2*useNum_BDS, 7) = 0; % for GPS
Jacob((1:2:2*(size(SV,1)-useNum_BDS))+2*useNum_BDS, 9) = 1; % for GPS
Jacob((2:2:2*(size(SV,1)-useNum_BDS))+2*useNum_BDS, 8) = 0; % for GPS
Jacob((2:2:2*(size(SV,1)-useNum_BDS))+2*useNum_BDS, 10) = 1; % for GPS
%————————计算预测观测值——————————%
Val(1:2:2*useNum_BDS, 1) = sum(dX(1:useNum_BDS,:) .^2, 2) .^0.5 + X(7);  % BDS预测伪距值
Val((1:2:2*(size(SV,1)-useNum_BDS))+2*useNum_BDS, 1) = sum(dX(useNum_BDS+1:end,:) .^2, 2) .^0.5 + X(9);  % GPS预测伪距值
Val(2:2:2*useNum_BDS, 1) = Jacob(2:2:2*useNum_BDS, [2,4,6,8]) * X([2,4,6,8]);  % 预测BDS多普勒频移
Val((2:2:2*(size(SV,1)-useNum_BDS))+2*useNum_BDS, 1) = Jacob((2:2:2*(size(SV,1)-useNum_BDS))+useNum_BDS, [2,4,6,10]) * X([2,4,6,10]);  % 预测GPS多普勒频移
end