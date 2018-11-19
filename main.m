%% Main script of testbench for GSARx and CADLL algorithm.
close all; fclose all; clear; clc; 

% Include subfolders, without signal generator
addpath(genpath('.\config\'));
addpath(genpath('.\receiver\'));
addpath(genpath('.\recorder\'));
addpath(genpath('.\tools\'));

%% Configuration for receiver parameters
global GSAR_CONSTANTS;                   
GSAR_CONSTANTS = GlobalConstants();      % Define some global constants
configOpt   = 'DEFAULT';                 % Default configuration ('DEFAULT') / External file configuration ('EXTERN') / Advanced config ('ADVANCED')
configFile  = '.\GSARx_v0.2_SJTU.conf';  % Ignore when using default settings 
% IF Data File Name
GSAR_CONSTANTS.STR_RECV.fileNum = 1;  %正确配置文件数量，算法会依次读取前N个文件
% GSAR_CONSTANTS.STR_RECV.datafilename = { ...
%     'E:\ZWX\2. MATLAB_workspace\louding\louding_2014-11-2_13-29-10.dat ', ...
%     '' };
% GSAR_CONSTANTS.STR_RECV.datafilename = { ...
%     'E:\ZWX\2. MATLAB_workspace\The_There_Towers\The_Three_Towers.dat ', ...
%     '' };  relock_real_2016-7-12_19-27-15      Lujiazui_Dynamic
GSAR_CONSTANTS.STR_RECV.datafilename = { ...
    'D:\20180324\people_square_2018-3-26_4-53-15.dat ', ...
    '' };

%% Setup the device parameters
signal.fid          = zeros(1,GSAR_CONSTANTS.STR_RECV.fileNum);  % signal file id
signal.sis          = cell(1,GSAR_CONSTANTS.STR_RECV.dataNum); % the read signal, 每个cell对应一个文件的数据
signal.sis_presv    = [];
signal.Tunit        = 0.250; % the data length read at each loop
signal.headData     = 0;
signal.equipType    = 1;   
% 宇致单频设备：　　1   
% 科大三院设备：　　2,21(无校验位)    
% 盛铂设备：　　　　3
% 宇志全频点设备：　4
% 仿真类型：　　　　100
signal.devSubtype   = 104; % 宇志全频点设备采集模式
%百位：0-4bits, 1-8bits, 2-12bits 采集数据位宽 
%十位：0-宽带， 1-窄带； 
%个位：0~5，对应不同的采集模式
sisSource_Init(signal);

%% Construct(Initialize) receiver structure
receiver = ReceiverConstruct();    % Construct the receiver structure

% Initial config settings
% ----------- navigation system type --------------
receiver.syst = 'GPS_L1CA';  % Navigation signal system: GPS_L1CA / BDS_B1I / B1I_L1CA / L1CA_L2C / B1I_B2I / B1I_B2I_L1CA_L2C
% receiver time type
receiver.config.recvConfig.timeType = 'GPST';   % NULLT / GPST / BDST

% ------------ receiver config       ---------------
receiver.config.recvConfig.startMode         = 'COLD_START';      % COLD_START / WARM_START
receiver.config.recvConfig.reacquireMode     = 'LIGHT';           % LIGHT / MEDIUM / HEAVY
                                                       % LIGHT: When a satellite has been acquired before and lost of lock, reacquire twice;
                                                       % MEDIUM: Use ephemeris info to assist, normal process, TODO;
                                                       % HEAVY: Reacquire until succeed.
receiver.config.recvConfig.satTableUpdatPeriod = 1;                % [s]. This interval is applied for the following situations:
                                                       % Case 1: Check downloaded almanac;
                                                       % Case 2: Fill up idle channels;
receiver.config.recvConfig.configPage        = ConfigLoad(configOpt, GSAR_CONSTANTS, configFile);
% Define Positioning Mode: 00 signle-point least-square; 01 signle-point Kalman filter; 02 single-point mm-estimator(only available for 'B1I_L1CA' mode);
%                          10 RTD least-square;
receiver.config.recvConfig.positionType      = 00;
% True position of the antenna if known, otherwise make it empty
receiver.config.recvConfig.truePosition      = [];
% True time of signal if known, otherwise make it -1
receiver.config.recvConfig.trueTime          = -1;

receiver.config.recvConfig.targetSatellites(1).syst        = 'BDS_B1I';
receiver.config.recvConfig.targetSatellites(1).prnNum      = [1,2,3,4,6];  %Three_Tower: 1,2,3,4,8,10 louding:1,2,3,4,5,6,8,9,11,12,14  relock：1,3,4,6,8,15
receiver.config.recvConfig.targetSatellites(2).syst        = 'GPS_L1CA';
receiver.config.recvConfig.targetSatellites(2).prnNum      = [11,22,1,19,17,18,6]; %louding:2,5,6,9,10,12,13,17,23,25 Three_Tower:4,7,11,16,30  relock：2,6,9,17,19


receiver.config.recvConfig.numberOfChannels(1).syst        = 'BDS_B1I';
receiver.config.recvConfig.numberOfChannels(1).channelNum  =5;            % Number of channels in BDS
receiver.config.recvConfig.numberOfChannels(2).syst        = 'GPS_L1CA';
receiver.config.recvConfig.numberOfChannels(2).channelNum  = 5;            % Number of channels in GPS

% Elevation mask to exclude signals from satellites at low elevation, [degree]
receiver.config.recvConfig.elevationMask      = 5;
% GPU batch in tracking
receiver.config.recvConfig.Batch1msN          = 5;
% Acquire Engine Parallel CH max number
%receiver.config.recvConfig.acqEngineParallelNum = 20;
receiver.config.recvConfig.coldAcqEngineParallelNum = 5;
receiver.config.recvConfig.hotAcqEngineParallelNum = 5;
% period time of cold acquiring signal again
receiver.config.recvConfig.reAcqPeriod = 10;      
% period time of hot acquiring signal again
receiver.config.recvConfig.hotAcqPeriod = 2;  % second  ( 0 : acquire every loop ) 
receiver.config.recvConfig.hotTime = 20; % /s    maximum length of hot acq time
receiver.config.recvConfig.raimFailure = 12; % 容忍raim失败的次数

% ------- PVT Freq config ----------
receiver.pvtCalculator.pvtT                 = 1;  % PVT frequency 1/receiver.pvtCalculator.pvtT [Hz]

% ------------ signal stream config    --------------
receiver.config.sisConfig.skipTime          = 0;               % Skip a section of signal file [s]
receiver.config.sisConfig.runTime           = 9999;             % Maximum running time [s]

% ------------ log files config        -----------------
receiver.config.logConfig.debugLevel        = 0;   % Level 1: Only carrier doppler frequency and carrier phase; 
                                                   % Level 2: Plus amplitudes and CADLL parameters;
                                                   % Level 3: Plus code doppler and code phase.
receiver.config.logConfig.debugFilePath     = '..\data\';
receiver.config.logConfig.logFilePath       = '.\logfile\';
receiver.config.logConfig.isOutputLog       = 0;
receiver.config.logConfig.isStoreResult     = 0;
receiver.config.logConfig.isAcqPlotMesh     = 0;
receiver.config.logConfig.isSyncPlotMesh    = 0;
receiver.config.logConfig.isTrackPlot       = 0; % Draw track figures every loop
receiver.config.logConfig.isCorrShapeStore  = 0; % Control flag to compute the correlation shapes
% receiver.config.logConfig.isStoreCorrMovie  = 0;

%% Reconfig receiver struct according to config parameters
receiver = ConfigReceiver(receiver);

% GPU detect
if gpuDeviceCount
    receiver.device.gpuExist = 1;   % This computer has a GPU device
    receiver.device.gpuParas = [];%gpuDevice;
else
    receiver.device.gpuExist = 0;   % This computer has no GPU device
    receiver.device.gpuParas = [];
end
receiver.device.gpuExist = 0; %gpuExist; % yes(1) / no(0)
%% 捕获函数是否使用 gpu 加速标志（临时添加，用于调试）
receiver.device.acq_gpuExist = 0;
% 捕获一次能够批处理数据量(以1ms为单位)
receiver.config.recvConfig.acq_Batch1msN = 2;

receiver.device.usingMatlabAcq = 0;  %acquire method --  0:C 1:MATLAB 
%% Start up the receiver according to the start mode
% Final step of configuration before receiver process, can't be affect by external config file.
receiver = StartReceiver(receiver); 

% Initialization for recorder
receiver = RecorderInitializing(receiver); % Cause recorder is related with channel assignment, need to be placed at the last

% Load RINEX file
receiver.pvtCalculator = loadRinex(receiver.config.recvConfig.positionType, receiver.pvtCalculator);

% Delete previous log file
delPrelog(receiver);

%% Going into the receiver processing loops
while 1
    % If receiver gets specific SOW, make sure do next PVT in the integral number of seconds
    tic;
    [N, receiver, signal] = sigRead_N_Calc(receiver, signal);
    
    % Get signal data
    [signal, siscount, receiver.config] = GetSignal(signal, receiver.config, N);

    if ( round(siscount)<round(N) ) %不round可能会有量化误差导致判断错误
        fclose('all');
        fprintf('All data has been processed!\n');
        break;
    end
    
    if round(receiver.config.sisConfig.runTime - signal.Tunit) == ceil(receiver.Trun)
        fclose('all');
       break; % Time's up!
    end
    
    receiver.Loop = receiver.Loop + 1;
    
    % Use the receiver to process the SV signal
    receiver = cumultiCH_recv_proc(receiver, signal.sis, N); 
    
    % Print out the elapsed running time
    receiver.Trun = receiver.Trun + N/GSAR_CONSTANTS.STR_RECV.fs;
    toc;
    receiver.elapseTime = receiver.elapseTime + toc;
    
    signal.sis = cell(1,GSAR_CONSTANTS.STR_RECV.dataNum); %删除数据以减小存档大小

    if rem(receiver.Loop, 189) == 0
        stop = 1;
    end
    if rem(receiver.Loop, 115) == 0
        stop = 1;
    end
    if rem(receiver.Loop, 10) == 0
        stop = 1;
    end
    
end
