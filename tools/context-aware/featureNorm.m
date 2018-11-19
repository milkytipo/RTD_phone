function [feature] = featureNorm(feature)
%% %%%%%%%%%%% 参数标准化 %%%%%%%%%%%%%%
num = size(feature, 2);
N = size(feature, 1);
for i = 1 : num    
%     Mu = median(feature(:, i));
%     sigma = sum(abs(feature(:, i) - Mu))/N;
    Mu = mean(feature(:, i));
    sigma = sqrt(sum((feature(:, i) - Mu).^2) /N);   
    feature(:, i) = (feature(:, i) - Mu) / sigma;
end