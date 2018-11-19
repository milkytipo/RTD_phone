clc;clear;close all;
fs = 62e6;
fid = fopen('I:\gnssdata\CaoxiNorthRoadtoSJTUxuhui.dat','r');
skip = 0;   % s
fseek(fid,skip*fs*2,'bof');
data = fread(fid,2*fs*0.01,'bit8');
fclose(fid);
N = length(data);
data=data(1:2:N)+i*data(2:2:N);
N=N/2;
figure,plot(0:N-1,imag(data),'-*r',0:N-1,real(data),'-*b'),title(['GPS L1+BD2 B1采样信号波形图']);
figure,plot((-N/2:N/2-1)*fs/N,20*log10(abs(fftshift(fft(data)))),'-*r'),title(['GPS L1+BD2 B1采样信号频谱图']);