function Hd = prefilter_design
%UNTITLED Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 8.2 and the DSP System Toolbox 8.5.
% Generated on: 06-Jun-2014 10:23:28

% Equiripple Lowpass filter designed using the FIRPM function.

% All frequency values are in MHz.
Fs = 62;  % Sampling Frequency

Fpass = 11;               % Passband Frequency
Fstop = 13;               % Stopband Frequency
Dpass = 0.0057563991496;  % Passband Ripple
Dstop = 0.01;             % Stopband Attenuation
dens  = 20;               % Density Factor

% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], [Dpass, Dstop]);

% Calculate the coefficients using the FIRPM function.
Hd  = firpm(N, Fo, Ao, W, {dens});
% Hd = dfilt.dffir(b);

% [EOF]