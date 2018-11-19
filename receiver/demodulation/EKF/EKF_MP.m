function [Xo,Po] = EKF_MP(Q,R,Z,Xi,Pi,T)
N_state = size(Xi, 1);    

[Xp, ~] = ConstantVelocity_MP(Xi, T);%1 状态预测值

[~, fy] = ConstantVelocity_MP(Xp, T);%2 状态转移矩阵

[gXp, H] = obsEquation_MP(Xp);%3 观测方程：  gXp：预测观测值   H：观测矩阵

Pp = fy * Pi * fy.' + Q;%4 先验估计误差协方差矩阵

K = Pp * H' / (H * Pp * H.' + R);%5 卡尔曼滤波增益
    
Xo = Xp + K * (Z - gXp);%6 状态矫正

I = eye(N_state, N_state);
Po = (I - K * H) * Pp;%7 更新后的误差协方差矩阵
    
 