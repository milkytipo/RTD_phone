function channel = GpsCH_L1L2_HotInitialize(channel, prn, configPage, predictInfo)

global GSAR_CONSTANTS;

%% First, empty multipath structs
channel.PLL(2:end)      = [];
channel.DLL(2:end)      = [];
channel.ALL(2:end)      = [];
channel.KalPreFilt(2:end)  = [];
channel.CH_L1CA_L2C(2:end) = [];

%% Initialize PLL
channel.PLL.REG = zeros(4,1);   % Filter registers
channel.PLL.IQ_d= zeros(2,1);

channel.CH_L1CA_L2C.PLL_L2.REG = zeros(4,1);   % Filter registers
channel.CH_L1CA_L2C.PLL_L2.IQ_d= zeros(2,1);

%% Initialize DLL
channel.DLL.REG = zeros(4,1); % Filter registers

channel.CH_L1CA_L2C.DLL_L2.REG = zeros(4,1); % Filter registers

%% Initialize KalmanFilter
%若必要，热启动可适当修改P矩阵初值
channel.KalPreFilt.loopErrState = [0, 0, 0, 0]';
channel.KalPreFilt.P            = diag(channel.KalPreFilt.P0);
channel.KalPreFilt.firstFiltering = int32(1);% flag indicating first loop filtering

channel.CH_L1CA_L2C.KalPreFilt_L1L2.loopErrState = [0, 0, 0, 0, 0, 0]';
channel.CH_L1CA_L2C.KalPreFilt_L1L2.P            = diag(channel.CH_L1CA_L2C.KalPreFilt_L1L2.P0);
channel.CH_L1CA_L2C.KalPreFilt_L1L2.K            = zeros(6);
channel.CH_L1CA_L2C.KalPreFilt_L1L2.firstFiltering = int32(1);% flag indicating first loop filtering
%A,H,Qd矩阵初始化在跟踪的环路滤波前进行,此处不必

%% Initialize ALL
channel.ALL.An     = configPage.trackConfig.all.An;
channel.ALL.AFn    = configPage.trackConfig.all.AFn;
channel.ALL.ai_v   = zeros(4,1);
channel.ALL.ai_reg = zeros(4,1);
channel.ALL.ai_freg= zeros(4,1);
channel.ALL.aq_v      = zeros(4,1);
channel.ALL.aq_reg    = zeros(4,1);
channel.ALL.aq_freg   = zeros(4,1);
channel.ALL.lambda    = 1;
channel.ALL.NormSampN = 0;
channel.ALL.TslotNormSampN = 0;
channel.ALL.a_avg     = zeros(4,1);
channel.ALL.a_std     = zeros(3,1);
channel.ALL.acnt      = 0;
channel.ALL.SNR       = 0;
channel.ALL.ai_kalfilt_state = [0, 0]';
channel.ALL.ai_kalfilt_P     = zeros(2,2);
channel.ALL.aq_kalfilt_state = [0, 0]';
channel.ALL.aq_kalfilt_P     = zeros(2,2);
channel.ALL.a_kalfilt_P0     = configPage.trackConfig.all.a_kalfilt_P0;
channel.ALL.a_kalfilt_Q      = configPage.trackConfig.all.a_kalfilt_Q;
channel.ALL.a_kalfilt_R      = configPage.trackConfig.all.a_kalfilt_R;

%% Initialize channel structure
channel.CH_L1CA_L2C.CH_STATUS     = 'HOT_ACQ';
channel.CH_L1CA_L2C.Samp_Posi     = 0; % sis pointer Samp_Posi will be initialized at other places
channel.CH_L1CA_L2C.LO_CodPhs     = predictInfo.codePhase;
channel.CH_L1CA_L2C.LO_CodPhs_L2  = predictInfo.codePhase + 1023*predictInfo.T1ms_N + 20460*predictInfo.CM_in_CL;
channel.CH_L1CA_L2C.LO2_CarPhs    = 0;
channel.CH_L1CA_L2C.LO2_CarPhs_L2 = 0;
channel.CH_L1CA_L2C.LO2_fd        = predictInfo.carriDopp;
channel.CH_L1CA_L2C.LO2_fd_L2     = 60/77*predictInfo.carriDopp;
channel.CH_L1CA_L2C.LO2_framp     = 0;
channel.CH_L1CA_L2C.LO2_framp_L2  = 0;
channel.CH_L1CA_L2C.LO_Fcode0     = GSAR_CONSTANTS.STR_L1CA.Fcode0;
channel.CH_L1CA_L2C.LO_Fcode_fd   = predictInfo.carriDopp / 1540;
channel.CH_L1CA_L2C.LO2_IF0       = GSAR_CONSTANTS.STR_RECV.IF_L1CA; 
channel.CH_L1CA_L2C.LO2_IF0_L2    = GSAR_CONSTANTS.STR_RECV.IF_L2C;

%Initialize information frame format
channel.CH_L1CA_L2C.WN         = predictInfo.WN;
channel.CH_L1CA_L2C.TOW_6SEC   = predictInfo.SOW;
channel.CH_L1CA_L2C.SubFrame_N = predictInfo.SubFrame_N;
channel.CH_L1CA_L2C.Word_N     = predictInfo.Word_N;
channel.CH_L1CA_L2C.Bit_N      = predictInfo.Bit_N;
channel.CH_L1CA_L2C.T1ms_N     = predictInfo.T1ms_N;
channel.CH_L1CA_L2C.bitInMessage = predictInfo.bitInMessage;
channel.CH_L1CA_L2C.CM_in_CL   = predictInfo.CM_in_CL;
channel.CH_L1CA_L2C.CL_time    = -1;
%Initialize the track parameters and registers

channel.CH_L1CA_L2C.preUnitNum = 0;

channel.CH_L1CA_L2C.trk_mode    = configPage.trackConfig.L2C_trk_mode;
channel.CH_L1CA_L2C.Trk_Count   = 0;
channel.CH_L1CA_L2C.Tcohn_N     = 5;  % hot pullin  conherent time
channel.CH_L1CA_L2C.Tcohn_cnt   = 0;

channel.CH_L1CA_L2C.Tslot_I     = zeros(3,1);
channel.CH_L1CA_L2C.Tslot_Q     = zeros(3,1);
channel.CH_L1CA_L2C.Tslot_I_CM  = zeros(3,1);
channel.CH_L1CA_L2C.Tslot_Q_CM  = zeros(3,1);
channel.CH_L1CA_L2C.Tslot_I_CL  = zeros(3,1);
channel.CH_L1CA_L2C.Tslot_Q_CL  = zeros(3,1);
channel.CH_L1CA_L2C.T_I         = zeros(3,1);
channel.CH_L1CA_L2C.T_Q         = zeros(3,1);
channel.CH_L1CA_L2C.T_I_CM      = zeros(3,1);
channel.CH_L1CA_L2C.T_Q_CM      = zeros(3,1);
channel.CH_L1CA_L2C.T_I_CL      = zeros(3,1);
channel.CH_L1CA_L2C.T_Q_CL      = zeros(3,1);
channel.CH_L1CA_L2C.Loop_I      = zeros(3,15); %未使用
channel.CH_L1CA_L2C.Loop_Q      = zeros(3,15); %未使用
channel.CH_L1CA_L2C.Loop_N      = 0;           %未使用
channel.CH_L1CA_L2C.PromptIQ_D  = zeros(2,1);  %未使用
channel.CH_L1CA_L2C.PromptIQ_D_CM  = zeros(2,1);  %未使用
channel.CH_L1CA_L2C.PromptIQ_D_CL  = zeros(2,1);  %未使用
channel.CH_L1CA_L2C.T_pll_I     = zeros(3,1);  %未使用
channel.CH_L1CA_L2C.T_pll_Q     = zeros(3,1);  %未使用

channel.CH_L1CA_L2C.codePhaseErr = 0;
channel.CH_L1CA_L2C.carrPhaseAccum = 0; 
% 电文解调
channel.CH_L1CA_L2C.Frame_Sync  = 'NOT_FOUND';
channel.CH_L1CA_L2C.Frame_Sync_CNAV  = 'NOT_FOUND';
channel.CH_L1CA_L2C.SFNav       = uint32(zeros(10,1));
channel.CH_L1CA_L2C.SFNav_prev  = uint32(zeros(10,1));
channel.CH_L1CA_L2C.Msg_CNAV    = uint32(zeros(20,1));
channel.CH_L1CA_L2C.Msg_CNAV_prev  = uint32(zeros(20,1));
channel.CH_L1CA_L2C.Bit_Inv     = 0;
channel.CH_L1CA_L2C.Bit_Inv_CNAV  = 0;
channel.CH_L1CA_L2C.SF_Complete = 0;
channel.CH_L1CA_L2C.Msg_Complete = 0; 
channel.CH_L1CA_L2C.preamble_NAV_save = uint32(0);
channel.CH_L1CA_L2C.preamble_CNAV_save = uint32(0);
channel.CH_L1CA_L2C.NAV_sync_on = 0;
channel.CH_L1CA_L2C.CNAV_sync_on = 0;
channel.CH_L1CA_L2C.lastSixBits = uint32(0);

% 错误校验
channel.CH_L1CA_L2C.SOW_check      = -1;
channel.CH_L1CA_L2C.SubFrame_check = -1;
channel.CH_L1CA_L2C.invalidNum     = -1; % 电文各项参数有效性，-1：未知  0：有效   1、2、3...:连续错误的次数
channel.CH_L1CA_L2C.preUnitNum     = -1;
channel.CH_L1CA_L2C.bitDetect = zeros(3,1); % detect whether nav bit is correct

%% Initialize the CNR-computing parameters
channel.CH_L1CA_L2C.CN0_Estimator.CN0EstActive = 0;
channel.CH_L1CA_L2C.CN0_Estimator.muavg_T      = 1;
channel.CH_L1CA_L2C.CN0_Estimator.mupool_NMax  = round(channel.CH_L1CA_L2C.CN0_Estimator.muavg_T*1e3);
channel.CH_L1CA_L2C.CN0_Estimator.muk_cnt      = 0;
channel.CH_L1CA_L2C.CN0_Estimator.mu_avg       = zeros(7,1);
channel.CH_L1CA_L2C.CN0_Estimator.CN0          = zeros(7,1);
channel.CH_L1CA_L2C.CN0_Estimator.WideB_Pw_IQ      = zeros(14,1);
channel.CH_L1CA_L2C.CN0_Estimator.NarrowB_Pw_IQ    = zeros(14,1);

%%Define PLL disc sigma estimor
channel.CH_L1CA_L2C.lockDect.WN = 0;
channel.CH_L1CA_L2C.lockDect.SOW = 0;
channel.CH_L1CA_L2C.lockDect.Frame_N = 0;
channel.CH_L1CA_L2C.lockDect.SubFrame_N = 0;
channel.CH_L1CA_L2C.lockDect.Word_N = 0;
channel.CH_L1CA_L2C.lockDect.Bit_N = 0;
channel.CH_L1CA_L2C.lockDect.T1ms_N = 0;
channel.CH_L1CA_L2C.lockDect.codePhase = 0;
channel.CH_L1CA_L2C.lockDect.carriPhase = 0; %unused
channel.CH_L1CA_L2C.lockDect.carriDopp = 0;
channel.CH_L1CA_L2C.lockDect.codeDopp = 0; %unused
channel.CH_L1CA_L2C.lockDect.cos2phi = 0;  %unused
channel.CH_L1CA_L2C.lockDect.CN0Thres = 0; %unused
channel.CH_L1CA_L2C.lockDect.cos2phiThres = 0; %unused
channel.CH_L1CA_L2C.lockDect.lockTime    = 0;  %保存通道信息后记录经过的采样点数
channel.CH_L1CA_L2C.lockDect.sigma       = 0;  %平滑后的鉴相方差，小于一定值则会暂存通道信息
channel.CH_L1CA_L2C.lockDect.snr         = 0;  %保存载噪比
channel.CH_L1CA_L2C.lockDect.snrThre     = configPage.trackConfig.lockDect.snrThrelol;  %载噪比警告门限 dB-Hz
channel.CH_L1CA_L2C.lockDect.sigma_lock  = 0;
channel.CH_L1CA_L2C.lockDect.sigma_lock_checkT  = 0; %记录环路更新次数
channel.CH_L1CA_L2C.lockDect.sigma_checkT = configPage.trackConfig.lockDect.sigma_checkT;  %首次为1    
channel.CH_L1CA_L2C.lockDect.sigma_checkNMax = 50;  %每次给出锁定检测结果所需的环路更新次数
channel.CH_L1CA_L2C.lockDect.sigma_checkTimer= 0;
channel.CH_L1CA_L2C.lockDect.sigma_warningCnt= 0;   %50次中，警告次数达到25次时判定失锁
channel.CH_L1CA_L2C.lockDect.sigmaThrelol    = configPage.trackConfig.lockDect.sigmaThrelol;  %载波鉴相方差门限


%% Initialize Mems for recording the correlation shape of current Unit
% channel.CH_L1CA_L2C.CorrM_Bank.corrM_Spacing  = 2;
% channel.CH_L1CA_L2C.CorrM_Bank.corrM_Num      = 5 + 2 * round(2 * GSAR_CONSTANTS.STR_RECV.fs / GSAR_CONSTANTS.STR_L1CA.Fcode0 / channel.CH_L1CA_L2C.CorrM_Bank.corrM_Spacing);
% channel.CH_L1CA_L2C.CorrM_Bank.corrM_I_vt     = zeros(channel.CH_L1CA_L2C.CorrM_Bank.corrM_Num, 1);
% channel.CH_L1CA_L2C.CorrM_Bank.corrM_Q_vt     = zeros(channel.CH_L1CA_L2C.CorrM_Bank.corrM_Num, 1);
% channel.CH_L1CA_L2C.CorrM_Bank.corrM_Loop_I_vt     = zeros(210, 15); %与Loop_I列数一致
% channel.CH_L1CA_L2C.CorrM_Bank.corrM_Loop_Q_vt     = zeros(210, 15);
% channel.CH_L1CA_L2C.CorrM_Bank.uncancelled_corrM_I_vt = zeros(channel.CH_L1CA_L2C.CorrM_Bank.corrM_Num, 1);
% channel.CH_L1CA_L2C.CorrM_Bank.uncancelled_corrM_Q_vt = zeros(channel.CH_L1CA_L2C.CorrM_Bank.corrM_Num, 1);
% channel.CH_L1CA_L2C.CorrM_Bank.normRx_I_vt    = zeros(channel.CH_L1CA_L2C.CorrM_Bank.corrM_Num, 1);
% channel.CH_L1CA_L2C.CorrM_Bank.normRx_Q_vt    = zeros(channel.CH_L1CA_L2C.CorrM_Bank.corrM_Num, 1);
% channel.CH_L1CA_L2C.CorrM_Bank.normRx_vt      = zeros(channel.CH_L1CA_L2C.CorrM_Bank.corrM_Num, 1);
% channel.CH_L1CA_L2C.CorrM_Bank.corrM_I_vt_Save= zeros(channel.CH_L1CA_L2C.CorrM_Bank.corrM_Num, 1);
% channel.CH_L1CA_L2C.CorrM_Bank.corrM_Q_vt_Save= zeros(channel.CH_L1CA_L2C.CorrM_Bank.corrM_Num, 1);
% channel.CH_L1CA_L2C.CorrM_Bank.uncancelled_corrM_I_vt_Save = zeros(channel.CH_L1CA_L2C.CorrM_Bank.corrM_Num, 1);
% channel.CH_L1CA_L2C.CorrM_Bank.uncancelled_corrM_Q_vt_Save = zeros(channel.CH_L1CA_L2C.CorrM_Bank.corrM_Num, 1);

%% Initialize acq structure
channel.CH_L1CA_L2C.acq.acq_parameters.tcoh       = configPage.acqConfig.GPS_L1CA.tcoh;
channel.CH_L1CA_L2C.acq.acq_parameters.noncoh     = configPage.acqConfig.GPS_L1CA.nnchList;
channel.CH_L1CA_L2C.acq.acq_parameters.freqCenter = GSAR_CONSTANTS.STR_RECV.IF_L1CA;
channel.CH_L1CA_L2C.acq.acq_parameters.freqBin    = configPage.acqConfig.GPS_L1CA.freqBin;
channel.CH_L1CA_L2C.acq.acq_parameters.freqRange  = configPage.acqConfig.GPS_L1CA.coldFreqRange;
channel.CH_L1CA_L2C.acq.acq_parameters.thre_stronmode= configPage.acqConfig.GPS_L1CA.thre_stronmode;
channel.CH_L1CA_L2C.acq.acq_parameters.thre_weakmode = configPage.acqConfig.GPS_L1CA.thre_weakmode;

channel.CH_L1CA_L2C.acq.STATUS     = 'strong'; %strong/weak
channel.CH_L1CA_L2C.acq.ACQ_STATUS = 0;
channel.CH_L1CA_L2C.acq.acqID      = 0;
channel.CH_L1CA_L2C.acq.processing = -1;
channel.CH_L1CA_L2C.acq.TimeLen    = 0;
channel.CH_L1CA_L2C.acq.hotWaitTime = -9999;
channel.CH_L1CA_L2C.acq.hotAcqTime = 0;

% TC: number of code period for conherent integration, TC = 1, 1 period
channel.CH_L1CA_L2C.acq.TC         = round(channel.CH_L1CA_L2C.acq.acq_parameters.tcoh * 1e3);
channel.CH_L1CA_L2C.acq.L0Fc0_R    = GSAR_CONSTANTS.STR_L1CA.L0Fc0_R;
channel.CH_L1CA_L2C.acq.IF0        = channel.CH_L1CA_L2C.acq.acq_parameters.freqCenter;
channel.CH_L1CA_L2C.acq.freqSearch = channel.CH_L1CA_L2C.acq.acq_parameters.freqRange / channel.CH_L1CA_L2C.acq.acq_parameters.freqBin + 1;
channel.CH_L1CA_L2C.acq.freqBin    = channel.CH_L1CA_L2C.acq.acq_parameters.freqBin;
channel.CH_L1CA_L2C.acq.freqOrder  = [];

codePeriod_L1CA = GSAR_CONSTANTS.STR_L1CA.ChipNum / GSAR_CONSTANTS.STR_L1CA.Fcode0;
%integer samples per TC (s32 type)
channel.CH_L1CA_L2C.acq.sampPerTC_s= ceil(GSAR_CONSTANTS.STR_RECV.fs * codePeriod_L1CA);
channel.CH_L1CA_L2C.acq.sampPer2TC_s=2*channel.CH_L1CA_L2C.acq.sampPerTC_s;
channel.CH_L1CA_L2C.acq.skipNumberOfCodes=[];
channel.CH_L1CA_L2C.acq.skipNumberOfSamples = 0;
channel.CH_L1CA_L2C.acq.skipNperCode      = 0;
channel.CH_L1CA_L2C.acq.accum      = 0;
channel.CH_L1CA_L2C.acq.corrtmp    = [];
channel.CH_L1CA_L2C.acq.corr       = [];
channel.CH_L1CA_L2C.acq.resiData   = [];
channel.CH_L1CA_L2C.acq.resiN      = 0;
channel.CH_L1CA_L2C.acq.carriPhase = 0;
channel.CH_L1CA_L2C.acq.carriPhase_vt = 0;
channel.CH_L1CA_L2C.acq.Samp_Posi_dot = 0;

channel.CH_L1CA_L2C.acq.CM_corrtmp  = [];
channel.CH_L1CA_L2C.acq.CM_corr     = [];
channel.CH_L1CA_L2C.acq.CM_peak     = 0;
channel.CH_L1CA_L2C.acq.CL_corrtmp  = [];
channel.CH_L1CA_L2C.acq.CL_corr     = [];
channel.CH_L1CA_L2C.acq.CL_search   = [];

channel.CH_L1CA_L2C.acq.acqResults.sv           = 0;
channel.CH_L1CA_L2C.acq.acqResults.acqed        = 0;
channel.CH_L1CA_L2C.acq.acqResults.corr         = 0;
channel.CH_L1CA_L2C.acq.acqResults.corrpeak     = 0;
channel.CH_L1CA_L2C.acq.acqResults.freqOrder    = 0;
channel.CH_L1CA_L2C.acq.acqResults.samps        = 0;
channel.CH_L1CA_L2C.acq.acqResults.freqIdx      = 0;
channel.CH_L1CA_L2C.acq.acqResults.codeIdx      = 0;
channel.CH_L1CA_L2C.acq.acqResults.nc           = 0;
channel.CH_L1CA_L2C.acq.acqResults.snr          = 0;
channel.CH_L1CA_L2C.acq.acqResults.doppler      = 0;
channel.CH_L1CA_L2C.acq.acqResults.RcFsratio    = 0;

%% Initialize CADLL
% channel.STR_CAD.CADLL_MODE = 'CADLL';       % CADLL/CONVENTION
% channel.STR_CAD.CAD_STATUS = 'CAD_TRACK';   % CAD_TRACK/NEWMP_LOOKFOR/TRANSIENT
% channel.STR_CAD.CadCnt        = 0;
% channel.STR_CAD.MONI_TYPE     = 'MONI_ALLON';  % MONI_CODPHS_DIFF/MONI_A_STD/MONI_CN0/MONI_SNR/MONI_A_AVG/MONI_ALLON
% channel.STR_CAD.MONI_TYPE_TR  = 'MONI_ALLON';  % MONI_CODPHS_DIFF/MONI_A_STD/MONI_CN0/MONI_SNR/MONI_A_AVG/MONI_ALLON
% % Define the supported maximum number of units in cadll algorithm, CadUnitMax<=10;
% channel.STR_CAD.CadUnitMax     = configPage.cadConfig.CadUnitMax;
% channel.STR_CAD.CadUnit_N      = 1;             % define current number of units;
% channel.STR_CAD.MonitoringTime = configPage.cadConfig.MonitoringTime; % monitoring time before making a decision;
% channel.STR_CAD.MoniNMax       = round(channel.STR_CAD.MonitoringTime/1e-3); % Equivalent maximum number that Monitor counter counts to, the counter counts at a rate of 1kHz
% channel.STR_CAD.Moni_N         = 0;    % Monitor counter, counting from 0~MoniNMax-1, counting at a rate of 1kHz
% 
% channel.STR_CAD.CadU2_CodeIni = configPage.cadConfig.GPS_L1CA.CadU2_CodeIni; % Initial code phase delay in chips with respect to the first unit when inserting the second unit;
% channel.STR_CAD.CadUin_CodeIni= configPage.cadConfig.GPS_L1CA.CadUin_CodeIni;% The initial code phase delay in chips with respect the unit before when inserting the third and more unit;
% channel.STR_CAD.CadUin_AIni   = configPage.cadConfig.GPS_L1CA.CadUin_AIni;   % The initial amplitude of the inserted unit with repsect to the unit before;
% channel.STR_CAD.CadUin_ThetaIni=configPage.cadConfig.GPS_L1CA.CadUin_ThetaIni; % The initial carrier phase of the inserted unit with repsect to the unit before, [cycles];
% 
% channel.STR_CAD.CodPhsLagThre1 = configPage.cadConfig.GPS_L1CA.CodPhsLagThre1; % The mandatory code phase lag by force between two adjacent units,[chips]
% channel.STR_CAD.CodPhsLagThre2 = configPage.cadConfig.GPS_L1CA.CodPhsLagThre2; %The code phase lag threshold of two adjacent units; the latter unit will be shut down if its code phase delay is less than the threshold 
% channel.STR_CAD.CodPhsLag_Insrt_Thre3 = configPage.cadConfig.GPS_L1CA.CodPhsLag_Insrt_Thre3; % The least code phase lag between two adjacent units between that a trial unit can be inserted;
% 
% channel.STR_CAD.AThreLow1    = configPage.cadConfig.GPS_L1CA.AThreLow1;  % the lowest amplitude1 permitted;
% channel.STR_CAD.AThreLow2    = configPage.cadConfig.GPS_L1CA.AThreLow2;  % the lowest amplitude2 permitted;
% channel.STR_CAD.AThreLow3    = configPage.cadConfig.GPS_L1CA.AThreLow3;
% channel.STR_CAD.ADevThre     = configPage.cadConfig.GPS_L1CA.ADevThre;   % permitted maximum std deviation ratio of estimated amplitude to noise's;
% 
% channel.STR_CAD.SNRThre1     = configPage.cadConfig.GPS_L1CA.SNRThre1;   % permitted minimum SNR1 (estimated)
% channel.STR_CAD.SNRThre2     = configPage.cadConfig.GPS_L1CA.SNRThre2;   % permitted minimum SNR2 (estimated)
% channel.STR_CAD.SNRThre3     = configPage.cadConfig.GPS_L1CA.SNRThre3;
% channel.STR_CAD.SNRThre4     = configPage.cadConfig.GPS_L1CA.SNRThre4;
%    
% channel.STR_CAD.Unit0SNR_Det   = 0;
% % channel.STR_CAD.CN0Thre      = 23;       % permitted minimum CN0 (estimated)
% % channel.STR_CAD.ThetaDevThre = 15;       % permitted maximum std deviation of estimated carrier phase bias,[deg];
% % % Define thresholds for loss of lock detection
% % channel.STR_CAD.SNRThrelol   = 5; % [dB], TODO,unused currently
% % channel.STR_CAD.sigmaThrelol = 0.015;
% % channel.STR_CAD.LossThre     = 2; % Loss of lock level
% 
% channel.STR_CAD.CodPhsDiff_Avg      = zeros(channel.STR_CAD.CadUnitMax,1); % Computing the code phase lag between two adjacent units
% channel.STR_CAD.CodPhsDiff_Avg_prev = zeros(channel.STR_CAD.CadUnitMax,1); %Store the previous CodPhsDiff_Avg
% channel.STR_CAD.A_Avg               = zeros(channel.STR_CAD.CadUnitMax,1); % Computing the normalized average amplitude of a signal component during one monitoring time
% channel.STR_CAD.A_Std               = zeros(channel.STR_CAD.CadUnitMax,1); % Compute the normalized amplitude stadard deviation of a signal component during one monitoring time.
% channel.STR_CAD.UnitErrTang_N       = int32(zeros(channel.STR_CAD.CadUnitMax,1)); % Allocate the tang registers for counting the number of errors of each unit
% % Initialize some parameters regarding detecting a new MP
% % The checking point of a new multipath in the CADLL chain, also called the inserted point. The new 
% % unit will be inserted between InsrtNo~InsrtNo+1, so InsrtNo will be 0~CadUnit_N-1.
% channel.STR_CAD.InsrtNo       = 0;
% channel.STR_CAD.CadCH_L1CA_Tr = channel.CH_L1CA; % Trail CH for GPS_L1CA signal in cadll detecting a new multipath
% channel.STR_CAD.CadCH_L1CA_Tr.CH_STATUS = 'TRACK';
% channel.STR_CAD.CadDLL_Tr     = channel.DLL;    % Trail CH's DLL structure
% channel.STR_CAD.CadALL_Tr     = channel.ALL;    % Trail CH's ALL structure
% 
% channel.STR_CAD.TrConfirmT    = 1; % The time for estimating the new multipath's CNR,[s]
% channel.STR_CAD.TrConfirm_NMAX = round(channel.STR_CAD.TrConfirmT/1e-3); % Equivalent number of 1ms for estimating the new multipath's CNR,[s]
% % % CN0 threshold for detecting a new multipath signal, one below that is deemed as nuisances.
% % channel.STR_CAD.TrCN0Thre      = 23;    %16;
% % channel.STR_CAD.TrSNRThre      = -8;    %-13;
% % channel.STR_CAD.TrAmpThre      = 0.08;     %0.07; % Divide amplitude of trail ch by amplitude of LOS
% channel.STR_CAD.TrCodphsDiff_Avg = 0;
% channel.STR_CAD.TrChkSum_Errcode = uint32(0);  % CH_Tr checksum error code
% channel.STR_CAD.Codfreq_Proj_Tr_ErrTang = 0;
% % Initialize the time of CAD_TRACK status and TRASIENT status 
% channel.STR_CAD.CadLoopTime       = 1; % Stably tracking time between two MP detecting operations,[s]
% channel.STR_CAD.CadLoop_NMAX      = round(channel.STR_CAD.CadLoopTime/1e-3); %1000
% channel.STR_CAD.CadTransientTime  = 0.5; % Transient time
% channel.STR_CAD.CadTransient_NMAX = round(channel.STR_CAD.CadTransientTime/1e-3); %500
% % Finish the resultant initializations
% switch channel.STR_CAD.CAD_STATUS
%     case 'CAD_TRACK'
%         channel.STR_CAD.CadCnt = channel.STR_CAD.CadLoop_NMAX;%Debugging
%     case 'NEWMP_LOOKFOR'
%         channel.STR_CAD.CadCnt = channel.STR_CAD.TrConfirm_NMAX;
%     case 'TRANSIENT'
%         channel.STR_CAD.CadCnt = channel.STR_CAD.CadTransient_NMAX;
% end

%% Initialize STR_CH_noise
% channel.CH_ns.Codphs_ns   = 0; % noise channle's code phase
% channel.CH_ns.Tslot_ns_IQ = zeros(2,1); %1ms correlations of noise channel, I,Q channels
% channel.CH_ns.T_ns_IQ = zeros(4,1); %Tms correlations of noise channel, I,Q channels
% channel.CH_ns.Avg_ns_IQ   = zeros(2,1); % average over 1s, I,Q channels
% channel.CH_ns.Sq_ns_IQ    = zeros(2,1); % average squares over 1s, I,Q channels
% channel.CH_ns.ns_Std      = 0; % noise channel's std
% channel.CH_ns.NsCnt       = 0; % noise channle counter
% channel.CH_ns.NormFactor  = 0; % normalizing factor


