function [recv_channel] = hotBitSync_init(recv_channel, config)
global GSAR_CONSTANTS;
switch recv_channel.SYST
    case 'GPS_L1CA'
        Gps_Bitsync_config                 = config.recvConfig.configPage.bitSyncConfig.GPS_L1CA;
        
        recv_channel.CH_L1CA.bitSync.STATUS= 'strong';  %strong/weak
        recv_channel.CH_L1CA.bitSync.waitSec = Gps_Bitsync_config.waitSec;
        recv_channel.CH_L1CA.bitSync.waitNum = 0;
        recv_channel.CH_L1CA.bitSync.waitTimes = Gps_Bitsync_config.waitTimes;
        recv_channel.CH_L1CA.bitSync.TC    = round(Gps_Bitsync_config.tcoh*1e3);
        recv_channel.CH_L1CA.bitSync.noncoh= Gps_Bitsync_config.nnchList;
        % Cause use bitSync process of Beidou, GPS L1 C/A as Beidou B1I D2 without NH code 
        recv_channel.CH_L1CA.bitSync.nhCode= ones(1, 20);
        recv_channel.CH_L1CA.bitSync.nhLength = 20;
        % finer dopplar search
        recv_channel.CH_L1CA.bitSync.frange= Gps_Bitsync_config.hotFreqRange;
        recv_channel.CH_L1CA.bitSync.fbin  = Gps_Bitsync_config.hotFreqBin;
        recv_channel.CH_L1CA.bitSync.fnum  = recv_channel.CH_L1CA.bitSync.frange/recv_channel.CH_L1CA.bitSync.fbin + 1;
        % Center frequency
        recv_channel.CH_L1CA.bitSync.freqCenter  = recv_channel.CH_L1CA.LO2_IF0 + recv_channel.CH_L1CA.LO2_fd;
        recv_channel.CH_L1CA.bitSync.Fcodesearch = recv_channel.CH_L1CA.LO_Fcode0 + recv_channel.CH_L1CA.LO_Fcode_fd;
        
        recv_channel.CH_L1CA.bitSync.sampPerCode = round(GSAR_CONSTANTS.STR_L1CA.ChipNum / recv_channel.CH_L1CA.bitSync.Fcodesearch * GSAR_CONSTANTS.STR_RECV.fs);
        recv_channel.CH_L1CA.bitSync.skipNumberOfSamples = 0;
        recv_channel.CH_L1CA.bitSync.skipNperCode = recv_channel.CH_L1CA.bitSync.sampPerCode*(1 - GSAR_CONSTANTS.STR_L1CA.Fcode0 / recv_channel.CH_L1CA.bitSync.Fcodesearch);
        
        recv_channel.CH_L1CA.bitSync.accum = 0;
        recv_channel.CH_L1CA.bitSync.resiData   = [];
        recv_channel.CH_L1CA.bitSync.resiN      = 0;
        recv_channel.CH_L1CA.bitSync.carriPhase = recv_channel.CH_L1CA.Samp_Posi - recv_channel.CH_L1CA.bitSync.sampPerCode;     % 本地生成载波的起始时间对应的采样点
        recv_channel.CH_L1CA.bitSync.Samp_Posi_dot = 0;
        recv_channel.CH_L1CA.bitSync.offCarri   = [];
        recv_channel.CH_L1CA.bitSync.bitSyncID  = 0;
        recv_channel.CH_L1CA.bitSync.corr       = [];
        recv_channel.CH_L1CA.bitSync.corrtmp    = [];
        
        recv_channel.CH_L1CA.bitSync.bitSyncResults.sv      = 0;
        recv_channel.CH_L1CA.bitSync.bitSyncResults.synced  = 0;
        recv_channel.CH_L1CA.bitSync.bitSyncResults.nc_corr = 0;
        recv_channel.CH_L1CA.bitSync.bitSyncResults.freqIdx = 0;
        recv_channel.CH_L1CA.bitSync.bitSyncResults.bitIdx  = 0;
        recv_channel.CH_L1CA.bitSync.bitSyncResults.doppler = 0;
        
    case 'BDS_B1I'
        if strcmp(recv_channel.CH_B1I.navType,'B1I_D1')
            Bds_Bitsync_config            = config.recvConfig.configPage.bitSyncConfig.BDS_B1I.NGEO;
            recv_channel.CH_B1I.bitSync.nhCode= [-1 -1 -1 -1 -1 1 -1 -1 1 1 -1 1 -1 1 -1 -1 1 1 1 -1];
            recv_channel.CH_B1I.bitSync.nhLength = 20;
            
        else
            Bds_Bitsync_config            = config.recvConfig.configPage.bitSyncConfig.BDS_B1I.GEO;
            recv_channel.CH_B1I.bitSync.nhCode= [1 1];
            recv_channel.CH_B1I.bitSync.nhLength = 2;
        end
        
        recv_channel.CH_B1I.bitSync.STATUS= 'strong';  %strong/weak
        recv_channel.CH_B1I.bitSync.waitSec = Bds_Bitsync_config.waitSec;
        recv_channel.CH_B1I.bitSync.waitNum = 0;
        recv_channel.CH_B1I.bitSync.waitTimes = Bds_Bitsync_config.waitTimes;
        recv_channel.CH_B1I.bitSync.TC    = round(Bds_Bitsync_config.tcoh*1e3);
        recv_channel.CH_B1I.bitSync.noncoh= Bds_Bitsync_config.nnchList;
        % finer dopplar search
        recv_channel.CH_B1I.bitSync.frange= Bds_Bitsync_config.hotFreqRange;
        recv_channel.CH_B1I.bitSync.fbin  = Bds_Bitsync_config.hotFreqBin;
        recv_channel.CH_B1I.bitSync.fnum  = recv_channel.CH_B1I.bitSync.frange/recv_channel.CH_B1I.bitSync.fbin + 1;
        % Center frequency
        recv_channel.CH_B1I.bitSync.freqCenter  = recv_channel.CH_B1I.LO2_IF0 + recv_channel.CH_B1I.LO2_fd;
        recv_channel.CH_B1I.bitSync.Fcodesearch = recv_channel.CH_B1I.LO_Fcode0 + recv_channel.CH_B1I.LO_Fcode_fd;
        
        recv_channel.CH_B1I.bitSync.sampPerCode = round(GSAR_CONSTANTS.STR_B1I.ChipNum / recv_channel.CH_B1I.bitSync.Fcodesearch * GSAR_CONSTANTS.STR_RECV.fs);
        recv_channel.CH_B1I.bitSync.skipNumberOfSamples = 0;
        recv_channel.CH_B1I.bitSync.skipNperCode = recv_channel.CH_B1I.bitSync.sampPerCode*(1 - GSAR_CONSTANTS.STR_B1I.Fcode0 / recv_channel.CH_B1I.bitSync.Fcodesearch);
        
        recv_channel.CH_B1I.bitSync.accum = 0;
        recv_channel.CH_B1I.bitSync.resiData   = [];
        recv_channel.CH_B1I.bitSync.resiN      = 0;
        %?? Here the bds is inconsistent with gps, caution!!!
        recv_channel.CH_B1I.bitSync.carriPhase = recv_channel.CH_B1I.Samp_Posi - recv_channel.CH_B1I.bitSync.sampPerCode;     % ????????????????????????????
        recv_channel.CH_B1I.bitSync.Samp_Posi_dot = 0;
        recv_channel.CH_B1I.bitSync.offCarri   = [];
        recv_channel.CH_B1I.bitSync.bitSyncID  = 0;
        recv_channel.CH_B1I.bitSync.corr       = [];
        recv_channel.CH_B1I.bitSync.corrtmp    = [];
        
        recv_channel.CH_B1I.bitSync.bitSyncResults.sv      = 0;
        recv_channel.CH_B1I.bitSync.bitSyncResults.synced  = 0;
        recv_channel.CH_B1I.bitSync.bitSyncResults.nc_corr = 0;
        recv_channel.CH_B1I.bitSync.bitSyncResults.freqIdx = 0;
        recv_channel.CH_B1I.bitSync.bitSyncResults.bitIdx  = 0;
        recv_channel.CH_B1I.bitSync.bitSyncResults.doppler = 0;
end
