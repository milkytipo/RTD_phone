clc;clear all;close all;
fs = 62e6;
delta = 0.01;  % notch filter updating step
ka = 0.97;
z0 = 0.9;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid = fopen('I:\gnssdata\CaoxiNorthRoadtoSJTUxuhui.dat','r');
skip = 6;   % s
fseek(fid,skip*fs*2,'bof');
data = fread(fid,2*62e6*0.01,'bit8');
fclose(fid);
N = length(data);
z_i = data(1:2:N)';
z_q = data(2:2:N)';
N=N/2;
% z = z_i + 1i*z_q;

z = z_i + 1i*z_q;
z0_vect = zeros(1,N);
x_i = zeros(1,N);
x_f = zeros(1,N);

xfn = 0;
xin = 0;
xin1= 0;
xin2= 0;
Exi = 1;

% b = [1  -z0];
% a = [1 -ka*z0];
% y = filter(b,a,z);

for n=1:N
    xin = z(n) + ka*z0*xin1;
    x_f(n) = xin - z0*xin1;
        
    Exi = 0.95*Exi + (1-0.95)*abs(xin)^2;
    z0_vect(n) = z0 + delta/Exi * x_f(n)*xin1';
    
    xin1 = xin;
    x_i(n) = xin;
    z0 = z0_vect(n);

   % ************************************
   
%    x_f(n) = xin - 2*real(z0)*xin1 + abs(z0)^2*xin2;
%    x_i(n) = z(n) + 2*ka*real(z0)*xin1 - (ka*abs(z0))^2*xin2;
% %    Exi = 0.95*Exi + (1-0.95)*abs(x_i(n))^2;
% %    u = 0.01/Exi;
%    z0_vect(n) = z0 - u*4*x_f(n)*(z0*xin2 - xin1);
%    
%    xfn = x_f(n);
%    xin2 = xin1;
%    xin1 = xin;
%    xin = x_i(n);
%    z0 = z0_vect(n);
end

% figure,plot(20*log10(abs(fft(x_i+i*x_q))),'-*r') %滤波输入原始频谱
figure,plot((-N/2:N/2-1)*fs/N,20*log10(abs(fftshift(fft(z)))),'-*r')
% figure,plot(20*log10(abs(fft(y_i+i*y_q))),'-*r') %滤波输出处理后频谱
figure,plot((-N/2:N/2-1)*fs/N,20*log10(abs(fftshift(fft(x_f)))),'-*r')
% figure,plot((-N/2:N/2-1)*fs/N,20*log10(abs(fftshift(fft(y)))),'-*r')

% Notch filter 2

z0_2nd = 0.9*exp(1i*2*pi*-5.246/62);

z0_vect_2nd = zeros(1,N);
x_i_2nd = zeros(1,N);
x_f_2nd = zeros(1,N);

xfn_2nd = 0;
xin_2nd = 0;
xin1_2nd= 0;
Exi = 1;

z_2nd = x_f;

for n=1:N
    xin_2nd = z_2nd(n) + ka*z0_2nd*xin1_2nd;
    x_f_2nd(n) = xin_2nd - z0_2nd*xin1_2nd;
        
    Exi = 0.95*Exi + (1-0.95)*abs(xin_2nd)^2;
    z0_vect_2nd(n) = z0_2nd + delta/Exi * x_f_2nd(n)*xin1_2nd';
    
    xin1_2nd = xin_2nd;
    x_i_2nd(n) = xin_2nd;
    z0_2nd = z0_vect_2nd(n);
end

figure,plot((-N/2:N/2-1)*fs/N,20*log10(abs(fftshift(fft(x_f_2nd)))),'-*r')

