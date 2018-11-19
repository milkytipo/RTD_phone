function df = freqCorrect( array, peak_idx, d)
%根据频率域的相关峰形状估计准确的峰值位置，采用三个点的三角峰估计，类似EPL鉴码器。
%适用于CM捕获，比特同步等情形。
% 输入-- array: 不同频率的相关峰值，1维向量  peak_idx:峰值位置  d:每个点的频率间隔
% 输出-- df = 真实频率值 - 搜索频率值

N = length(array);

if (peak_idx == N || peak_idx == 1)
    df = 0;
    return;
else
    E = array(peak_idx-1);
    P = array(peak_idx);
    L = array(peak_idx+1);
end

if E>L
    df = 0.5*d*(L-E)/(P-L);
else
    df = 0.5*d*(L-E)/(P-E);
end