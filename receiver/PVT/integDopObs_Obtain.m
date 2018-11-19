function pvtCalculator = integDopObs_Obtain(pvtCalculator, channels, actvPvtChannels, config)
global GSAR_CONSTANTS;
BDS_maxPrnNo = config.recvConfig.configPage.systConfig.BDS_B1I.maxPrnNo;      % 最大卫星数目
GPS_maxPrnNo = config.recvConfig.configPage.systConfig.GPS_L1CA.maxPrnNo;     % 最大卫星数目

%--------------- Obtain BDS integral Dopplar measurements ----------------
% Backup last epoch integral Dopplar measurements
pvtCalculator.BDS.doppSmooth(1:BDS_maxPrnNo, 2) = pvtCalculator.BDS.doppSmooth(1:BDS_maxPrnNo, 1); 
% Save up this epoch integral Dopplar measurements
pvtCalculator.BDS.doppSmooth(1:BDS_maxPrnNo, 1) = zeros(BDS_maxPrnNo,1);

if actvPvtChannels.actChnsNum_BDS > 0
    for m = 1:actvPvtChannels.actChnsNum_BDS
        chn = actvPvtChannels.BDS(1, m);
        prn = actvPvtChannels.BDS(2, m);
        pvtCalculator.BDS.doppSmooth(prn, 1) = -1*channels(chn).CH_B1I(1).carrPhaseAccum*GSAR_CONSTANTS.C/GSAR_CONSTANTS.STR_B1I.B0; % [meter]
%         pvtCalculator.BDS.doppSmooth(prn, 3) = -1*(channels(chn).CH_B1I(1).LO2_fd * GSAR_CONSTANTS.C/GSAR_CONSTANTS.STR_B1I.B0 + pvtCalculator.clkErr(1,2));
        pvtCalculator.BDS.doppSmooth(prn, 3) = -channels(chn).CH_B1I(1).LO2_fd * GSAR_CONSTANTS.C/GSAR_CONSTANTS.STR_B1I.B0;
        pvtCalculator.BDS.doppSmooth(prn, 4) = pvtCalculator.BDS.doppSmooth(prn, 4) + 1;
        pvtCalculator.BDS.SNR(prn) = channels(chn).ALL.SNR;
        pvtCalculator.BDS.CNR(prn) = channels(chn).CH_B1I(1).CN0_Estimator.CN0(1);
        pvtCalculator.BDS.carriVar(prn) = channels(chn).CH_B1I(1).lockDect.sigma;
    end
end

%--------------- Obtain GPS integral Dopplar measurements ----------------
% Backup last epoch integral Dopplar measurements
pvtCalculator.GPS.doppSmooth(1:GPS_maxPrnNo, 2) = pvtCalculator.GPS.doppSmooth(1:GPS_maxPrnNo, 1); 
% Save up this epoch integral Dopplar measurements
pvtCalculator.GPS.doppSmooth(1:GPS_maxPrnNo, 1) = zeros(GPS_maxPrnNo,1);

if actvPvtChannels.actChnsNum_GPS > 0
    for m = 1:actvPvtChannels.actChnsNum_GPS
        chn = actvPvtChannels.GPS(1, m);
        prn = actvPvtChannels.GPS(2, m);
        if (strcmp(channels(chn).SYST, 'GPS_L1CA'))
            pvtCalculator.GPS.doppSmooth(prn, 1) = -1*channels(chn).CH_L1CA(1).carrPhaseAccum*GSAR_CONSTANTS.C/GSAR_CONSTANTS.STR_L1CA.L0; % [meter]
    %         pvtCalculator.GPS.doppSmooth(prn, 3) = -1*(channels(chn).CH_L1CA(1).LO2_fd * GSAR_CONSTANTS.C/GSAR_CONSTANTS.STR_L1CA.L0 + pvtCalculator.clkErr(2,2));
            pvtCalculator.GPS.doppSmooth(prn, 3) = -channels(chn).CH_L1CA(1).LO2_fd * GSAR_CONSTANTS.C/GSAR_CONSTANTS.STR_L1CA.L0;
            pvtCalculator.GPS.doppSmooth(prn, 4) = pvtCalculator.GPS.doppSmooth(prn, 4) + 1;
            pvtCalculator.GPS.SNR(prn) = channels(chn).ALL.SNR;
            pvtCalculator.GPS.CNR(prn) = channels(chn).CH_L1CA(1).CN0_Estimator.CN0(1);
            pvtCalculator.GPS.carriVar(prn) = channels(chn).CH_L1CA(1).lockDect.sigma;
        elseif (strcmp(channels(chn).SYST, 'GPS_L1CA_L2C'))
            pvtCalculator.GPS.doppSmooth(prn, 1) = -channels(chn).CH_L1CA_L2C(1).carrPhaseAccum*GSAR_CONSTANTS.C/GSAR_CONSTANTS.STR_L1CA.L0; % [meter]          
            pvtCalculator.GPS.doppSmooth(prn, 3) = -channels(chn).CH_L1CA_L2C(1).LO2_fd * GSAR_CONSTANTS.C/GSAR_CONSTANTS.STR_L1CA.L0;
            pvtCalculator.GPS.doppSmooth(prn, 4) = pvtCalculator.GPS.doppSmooth(prn, 4) + 1;
            pvtCalculator.GPS.SNR(prn) = channels(chn).ALL.SNR;
            pvtCalculator.GPS.CNR(prn) = channels(chn).CH_L1CA_L2C(1).CN0_Estimator.CN0(1);
            pvtCalculator.GPS.carriVar(prn) = channels(chn).CH_L1CA_L2C(1).lockDect.sigma;
        end
    end
end




