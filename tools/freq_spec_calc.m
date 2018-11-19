%% This file is used to calculate frequency spectrum of signal data.
clc; clear all; close all;
%% Set file related parameters.
% filepath = 'E:\mp_allday\static_2014-7-24_11-34-48.dat'; % file path of data file
filepath = 'H:\campers_2014-7-23\outdoor_2014-7-23-10-49-22.dat';
IQform = 'Complex'; % 'Real' or 'Complex'
datatype = 'int8'; % data type saved in file
fs = 62e6; % sampling frequency

switch datatype
    case 'int8'
        bytesPerData = 1;
    case 'int16'
        bytesPerData = 2;
end

%% Set user defined parameters.
skipTime = 0; % skip section's time length, [s]
procTime = 0.5; % the analyzed data fragment's time length, [s]  

%% Read signal data.
N = ceil(fs*procTime); % sampling points
skipBytes = round(fs*skipTime) * bytesPerData; % skip bytes

[fd, msg] = fopen(filepath, 'r');
if strcmp('Real', IQform)
    fseek(fd, skipBytes, 'bof');
	[signal, siscount] = fread(fd, N, datatype);
else % Complex
    fseek(fd, skipBytes*2, 'bof');
	[signal, siscount] = fread(fd, 2*N, datatype);
    signal = signal(1:2:length(signal)) + 1i*signal(2:2:length(signal));
    siscount = floor(siscount/2);
end

%% Calculate frequency spectrum.
df = fs / (N-1); % frequency resolution
f = (0:N-1) * df; % frequency per points

Y = fft(signal(1:N))/N * 2; 

figure, plot(f(1:N/2), abs(Y(1:N/2)));