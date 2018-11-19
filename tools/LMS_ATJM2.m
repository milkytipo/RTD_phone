clc;clear;close all;
Rnk = 128;      %LMS自适应滤波器阶数
u = 0.0000001;  %LMS自适应滤波器权值更新率
fs = 62e6;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid = fopen('I:\gnssdata\CaoxiNorthRoadtoSJTUxuhui.dat','r');
skip = 1100;   % s
fseek(fid,skip*fs*2,'bof');
data = fread(fid,2*62e6*0.1,'bit8');
fclose(fid);
N = length(data);
x_i = data(1:2:N)';
x_q = data(2:2:N)';
x = x_i + 1i*x_q;
N=N/2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
w = zeros(Rnk,1);%滤波自适应权值
%分别对I/Q支路LMS自适应滤波处理
%输入分别为x_i,x_q，滤波输出分别为e_i,e_q
for n=Rnk+1:N-100   
    y(n) = w'*[x(n-1:-1:n-Rnk)].';
    e(n) = x(n) - y(n);
    w = w + u * [x(n-1:-1:n-Rnk)].' * e(n)';
end
N=N-100;
% figure,plot(20*log10(abs(fft(x_i+i*x_q))),'-*r') %滤波输入原始频谱
figure,plot((-N/2:N/2-1)*fs/N,20*log10(abs(fftshift(fft(x(1:N))))),'-*r')
% figure,plot(20*log10(abs(fft(y_i+i*y_q))),'-*r') %滤波输出处理后频谱
figure,plot((-N/2:N/2-1)*fs/N,20*log10(abs(fftshift(fft(e(1:N))))),'-*r')