% Constant Velocity model for GPS navigation.
function [Val, Jacob] = ConstantVelocity_dual(X, T)
% �˺���Ϊ����ģ���е�״̬ת�ƾ���
Val = zeros(size(X));
Val(1:2:end) = X(1:2:end) + T * X(2:2:end);     % λ��Ԥ��
Val(2:2:end) = X(2:2:end);      % Ԥ���ٶȱ��ֲ���
Jacob = [1,T; 0,1];
Jacob = blkdiag(Jacob,Jacob,Jacob,Jacob,Jacob);

end