function channel = acq_valueTransfer(channel, acqed_channel, SYST)

global GSAR_CONSTANTS;

channel.CH_STATUS = acqed_channel.CH_STATUS;

switch SYST
    case 'BDS_B1I'
        channel.codeTable = generateB1ICode(acqed_channel.PRNID);
        channel.bitSync = acqed_channel.bitSync;   %bitSync结构体传递赋值
        
    case 'GPS_L1CA'
        channel.codeTable = generateCAcode(acqed_channel.PRNID);
        channel.bitSync = acqed_channel.bitSync;
        channel.acq.CM_peak = acqed_channel.acq.CM_peak;

    case 'GPS_L1CA_L2C'
        channel.acq.CM_peak = acqed_channel.acq.CM_peak;
end

%% 通道结构体参数传递赋值
channel.LO2_CarPhs = acqed_channel.LO2_CarPhs;
channel.LO2_fd = acqed_channel.LO2_fd;
channel.fdPre = acqed_channel.fdPre;
channel.fdIndex = acqed_channel.fdIndex;
channel.LO2_framp = acqed_channel.LO2_framp;
channel.codePhaseErr = acqed_channel.codePhaseErr;
channel.LO_CodPhs = acqed_channel.LO_CodPhs;
channel.LO_Fcode_fd = acqed_channel.LO_Fcode_fd;
channel.Fcode_fdPre = acqed_channel.Fcode_fdPre;
%% 热捕获时传递参数
channel.Tcohn_cnt = acqed_channel.Tcohn_cnt;
channel.WN = acqed_channel.WN;
switch SYST
    case 'BDS_B1I'
        channel.SOW = acqed_channel.SOW;
        channel.Frame_N = acqed_channel.Frame_N;
    case {'GPS_L1CA','GPS_L1CA_L2C'}
        channel.TOW_6SEC = acqed_channel.TOW_6SEC;
end
channel.SubFrame_N = acqed_channel.SubFrame_N;
channel.Word_N = acqed_channel.Word_N;
channel.Bit_N = acqed_channel.Bit_N;
channel.T1ms_N = acqed_channel.T1ms_N;
channel.Tcohn_N = acqed_channel.Tcohn_N;
%% lockDect结构体传递赋值
channel.lockDect.WN = acqed_channel.lockDect.WN;
channel.lockDect.SOW = acqed_channel.lockDect.SOW;
channel.lockDect.Frame_N = acqed_channel.lockDect.Frame_N;
channel.lockDect.SubFrame_N = acqed_channel.lockDect.SubFrame_N;
channel.lockDect.Word_N = acqed_channel.lockDect.Word_N;
channel.lockDect.Bit_N = acqed_channel.lockDect.Bit_N;
channel.lockDect.T1ms_N = acqed_channel.lockDect.T1ms_N;
channel.lockDect.codePhase = acqed_channel.lockDect.codePhase;
channel.lockDect.carriPhase = acqed_channel.lockDect.carriPhase;
channel.lockDect.carriDopp = acqed_channel.lockDect.carriDopp;
channel.lockDect.codeDopp = acqed_channel.lockDect.codeDopp;

%% 载噪比估计
channel.CN0_Estimator = acqed_channel.CN0_Estimator;

%% 采样点传递赋值
channel.Samp_Posi = acqed_channel.Samp_Posi;

%% 捕获acq结构体变量传递
channel.acq.ACQ_STATUS = acqed_channel.acq.ACQ_STATUS;
channel.acq.processing = acqed_channel.acq.processing;
channel.acq.TimeLen = acqed_channel.acq.TimeLen;
channel.acq.hotWaitTime = acqed_channel.acq.hotWaitTime;
channel.acq.hotAcqTime = acqed_channel.acq.hotAcqTime;

channel.acq.TC = acqed_channel.acq.TC;
channel.acq.skipNumberOfCodes = acqed_channel.acq.skipNumberOfCodes;
channel.acq.accum = acqed_channel.acq.accum;
channel.acq.acqID = acqed_channel.acq.acqID;
channel.acq.resiData = acqed_channel.acq.resiData;
channel.acq.resiN = acqed_channel.acq.resiN;
%acqResults结构体变量传递
channel.acq.acqResults.sv = acqed_channel.acq.acqResults.sv;
channel.acq.acqResults.acqed = acqed_channel.acq.acqResults.acqed;
channel.acq.acqResults.corr = acqed_channel.acq.acqResults.corr;
channel.acq.acqResults.corrpeak = acqed_channel.acq.acqResults.corrpeak;
channel.acq.acqResults.samps = (1:GSAR_CONSTANTS.STR_RECV.fs*0.001);
channel.acq.acqResults.freqIdx = acqed_channel.acq.acqResults.freqIdx;
channel.acq.acqResults.codeIdx = acqed_channel.acq.acqResults.codeIdx;
channel.acq.acqResults.nc = acqed_channel.acq.acqResults.nc;
channel.acq.acqResults.snr = acqed_channel.acq.acqResults.snr;
channel.acq.acqResults.doppler = acqed_channel.acq.acqResults.doppler;
channel.acq.acqResults.RcFsratio = acqed_channel.acq.acqResults.RcFsratio;
channel.acq.acqResults.freqOrder = (-(acqed_channel.acq.freqSearch -1)/2:(acqed_channel.acq.freqSearch -1)/2) * acqed_channel.acq.freqBin; 

channel.acq.skipNumberOfSamples = acqed_channel.acq.skipNumberOfSamples;
channel.acq.skipNperCode = acqed_channel.acq.skipNperCode;
channel.acq.carriPhase = acqed_channel.acq.carriPhase;
channel.acq.Samp_Posi_dot = acqed_channel.acq.Samp_Posi_dot;


end