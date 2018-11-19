% This file will perform the receiver's function
clear;
clc;
close all;
addpath('..\acquisition\acq_lib\');
addpath('..\acquisition\gps_ca\');
addpath('..\acquisition\gps_l2c\');
addpath('..\acquisition\gps_l2c\block\');
addpath('..\acquisition\gps_l2c\blockfolded\');
addpath('..\acquisition\gps_l2c\fftsrch\');
addpath('..\..\receiver\');
addpath('..\..\sisgen\');
addpath('..\..\sisgen\L2C_SIS_Gen');
addpath('..\..\..\m\');

SYST = 'GPS_L2C';               % GPS_CA / GPS_L2C /

Flag_Call = 'CallinMex';        % CallinMex / CallinMatlab


global STR_Constants;
STR_Constants = SV_Constants();

STR_Constants.STR_RECV.IF = 100e3;           % 中频置为0
STR_Constants.STR_RECV.RECV_fs0 = 6e6;   % 设置采样频率
STR_Constants.STR_RECV.fs = 6e6;

STR_SV = SV_Initializing(SYST, Flag_Call);
STR_SV.navbit_ctrl = 0;
STR_SV.L2C_SV.fd = 0;
STR_SV.L2C_SV.framp = 0;
STR_SV.L2C_SV.fjerk = 0;
STR_SV.L2C_SV.Codphs = 0;                % 设置初始码相位
STR_SV.noise_ctrl = 1;

MpModelCount = 0;

fs = STR_Constants.STR_RECV.fs;        % sampling frequency,[Hz]

T = 1; 

N = round(fs*T);
  
[IFData, STR_SV] = SV_SIS_Gen(SYST, STR_SV, fs, N, Flag_Call); 

i = STR_SV.L2C_SV.PRNID;

[CodPhs, fd] = Receiver_Processing(IFData, STR_Constants.STR_RECV.IF, STR_SV.L2C_SV.Carphs, ...
               STR_Constants.STR_L2C.Fcode0_Multiplex, fs, STR_SV.L2C_SV.PRNID, 'DispYes');

  


