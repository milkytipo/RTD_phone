%Extended_KF   Extended Kalman Filter
%
% Version 1.0, May 16,2011
% Version 2.0, May 10,2013
% Written by Chong You
% https://sites.google.com/site/chongyou1987/
% chong.you1987@gmail.com
%
% Syntax:
%     [Xo,Po] = Extended_KF(f,g,Q,R,Z,Xi,Pi)
%
% State Equation:
%     X(n+1) = f(X(n)) + w(n)
%     where the state X has the dimension N-by-1
% Observation Equation:
%     Z(n) = g(X(n)) + v(n)
%     where the observation y has the dimension M-by-1
%     w ~ N(0,Q) is gaussian noise with covariance Q
%     v ~ N(0,R) is gaussian noise with covariance R     
% Input:
%     f: function for state transition, it takes a state variable Xn and
%       returns 1) f(Xn) and 2) Jacobian of f at Xn. As a fake example:
%           function [Val, Jacob] = f(X)
%           Val = sin(X) + 3;
%           Jacob = cos(X);
%           end
%     g: function for measurement, it takes the state variable Xn and
%       returns 1) g(Xn) and 2) Jacobian of g at Xn.
%     Q: process noise covariance matrix, N-by-N
%     R: measurement noise covariance matrix, M-by-M
%     
%     Z: current measurement, M-by-1
%     
%     Xi: "a priori" state estimate, N-by-1
%     Pi: "a priori" estimated state covariance, N-by-N
% Output:
%     Xo: "a posteriori" state estimate, N-by-1
%     Po: "a posteriori" estimated state covariance, N-by-N
%
% Algorithm for Extended Kalman Filter:
% Linearize input functions f and g to get fy(state transition matrix)
% and H(observation matrix) for an ordinary Kalman Filter:
% State Equation:
%     X(n+1) = fy * X(n) + w(n)
% Observation Equation:
%     Z(n) = H * X(n) + v(n)
%
% 1. Xp = f(Xi)                     : One step projection, also provides 
%                                     linearization point
% 
% 2. 
%          d f    |
% fy = -----------|                 : Linearize state equation, fy is the
%          d X    |X=Xp               Jacobian of the process model
%       
% 
% 3.
%          d g    |
% H  = -----------|                 : Linearize observation equation, H is
%          d X    |X=Xp               the Jacobian of the measurement model
%             
%       
% 4. Pp = fy * Pi * fy' + Q         : Covariance of Xp
% 
% 5. K = Pp * H' * inv(H * Pp * H' + R): Kalman Gain
% 
% 6. Xo = Xp + K * (Z - g(Xp))      : Output state
% 
% 7. Po = [I - K * H] * Pp          : Covariance of Xo
	                                                                            
function [Xo,Po] = EKF(Q,R,Z,Xi,Pi,SV,T,posiChannel)
N_state = size(Xi, 1);    

[Xp, ~] = ConstantVelocity(Xi, T);%1 状态预测值

[~, fy] = ConstantVelocity(Xp, T);%2 状态转移矩阵

[gXp, H] = obsEquation(Xp, SV);%3 观测方程：  gXp：预测观测值   H：观测矩阵

Pp = fy * Pi * fy.' + Q;%4 先验估计误差协方差矩阵

K = Pp * H' / (H * Pp * H.' + R);%5 卡尔曼滤波增益
    
Xo = Xp + K * (Z - gXp);%6 状态矫正

I = eye(N_state, N_state);
Po = (I - K * H) * Pp;%7 更新后的误差协方差矩阵
    
 