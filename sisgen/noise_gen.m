function [noise]=noise_gen(Bn,N0,RFGAIN,NF,N,IF,fs,IQForm)
% This function is to generate noise_gen
%Output:
% noise             - noise
%Input:
% Bn                - Bandpass bandwidth
% N0                - Noise power density, dB-Hz
% RFGAIN            - RF front-end gain, from the first LNA to AD, dB
% N                 - sampling number
% IF                - Intermediate frequency
% fs                - Sampling frequency,Hz
% IQForm            - IQ format, 'Complex'->generate complex noise, 
%                     'Real'->generate real noise

%Total noise power in the allowed bandwidth
N0LNA = N0 + RFGAIN + NF;

sigma = sqrt(10^(N0LNA/10)*Bn);

noise_li = sigma*randn(N,1);

noise_lq = sigma*randn(N,1);

noise = zeros(N,1);

if strcmp(IQForm,'Real')
    noise(1:N,1) = noise_li.*cos(2*pi*(0:N-1)'*IF/fs) - noise_lq.*sin(2*pi*(0:N-1)'*IF/fs);
else
    error('Non-recognized IQForm flag in noise_gen');
end