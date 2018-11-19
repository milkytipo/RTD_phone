function [channel_spc] = coldBitSync_init_new(channel_spc, config, SYST)
global GSAR_CONSTANTS;
switch SYST
    case 'GPS_L1CA'
        Gps_Bitsync_config                 = config.recvConfig.configPage.bitSyncConfig.GPS_L1CA;
        
        channel_spc.bitSync.STATUS= 'strong';  %strong/weak
        channel_spc.bitSync.waitSec = Gps_Bitsync_config.waitSec;
        channel_spc.bitSync.waitNum = 0;
        channel_spc.bitSync.waitTimes = Gps_Bitsync_config.waitTimes;
        channel_spc.bitSync.TC    = round(Gps_Bitsync_config.tcoh*1e3);
        channel_spc.bitSync.noncoh= Gps_Bitsync_config.nnchList;
        % Cause use bitSync process of Beidou, GPS L1 C/A as Beidou B1I D2 without NH code 
        channel_spc.bitSync.nhCode= ones(1, 20);
        channel_spc.bitSync.nhLength = 20;
        % finer dopplar search
        channel_spc.bitSync.frange= Gps_Bitsync_config.freqRange;
        channel_spc.bitSync.fbin  = Gps_Bitsync_config.freqBin;
        channel_spc.bitSync.fnum  = channel_spc.bitSync.frange/channel_spc.bitSync.fbin + 1;
        % Center frequency
        channel_spc.bitSync.freqCenter  = channel_spc.LO2_IF0 + channel_spc.LO2_fd;
        channel_spc.bitSync.Fcodesearch = channel_spc.LO_Fcode0 + channel_spc.LO_Fcode_fd;
        
        channel_spc.bitSync.sampPerCode = round(GSAR_CONSTANTS.STR_L1CA.ChipNum / channel_spc.bitSync.Fcodesearch * GSAR_CONSTANTS.STR_RECV.fs);
        channel_spc.bitSync.skipNumberOfSamples = 0;
        channel_spc.bitSync.skipNperCode = channel_spc.bitSync.sampPerCode*(1 - GSAR_CONSTANTS.STR_L1CA.Fcode0 / channel_spc.bitSync.Fcodesearch);
        
        channel_spc.bitSync.accum = 0;
        channel_spc.bitSync.resiData   = [];
        channel_spc.bitSync.resiN      = 0;
        channel_spc.bitSync.carriPhase = 0;  
        channel_spc.bitSync.Samp_Posi_dot = 0;
        channel_spc.bitSync.offCarri   = [];
        channel_spc.bitSync.bitSyncID  = 0;
        channel_spc.bitSync.corr       = [];
        channel_spc.bitSync.corrtmp    = [];
        
        channel_spc.bitSync.bitSyncResults.sv      = 0;
        channel_spc.bitSync.bitSyncResults.synced  = 0;
        channel_spc.bitSync.bitSyncResults.nc_corr = 0;
        channel_spc.bitSync.bitSyncResults.freqIdx = 0;
        channel_spc.bitSync.bitSyncResults.bitIdx  = 0;
        channel_spc.bitSync.bitSyncResults.doppler = 0;
        
    case 'BDS_B1I'
        if strcmp(channel_spc.navType,'B1I_D1')
            Bds_Bitsync_config            = config.recvConfig.configPage.bitSyncConfig.BDS_B1I.NGEO;
            channel_spc.bitSync.nhCode= [-1 -1 -1 -1 -1 1 -1 -1 1 1 -1 1 -1 1 -1 -1 1 1 1 -1];
            channel_spc.bitSync.nhLength = 20;
            
        else
            Bds_Bitsync_config            = config.recvConfig.configPage.bitSyncConfig.BDS_B1I.GEO;
            channel_spc.bitSync.nhCode= [1 1];
            channel_spc.bitSync.nhLength = 2;
        end
        
        channel_spc.bitSync.STATUS= 'strong';  %strong/weak
        channel_spc.bitSync.waitSec = Bds_Bitsync_config.waitSec;
        channel_spc.bitSync.waitNum = 0;
        channel_spc.bitSync.waitTimes = Bds_Bitsync_config.waitTimes;
        channel_spc.bitSync.TC    = round(Bds_Bitsync_config.tcoh*1e3);
        channel_spc.bitSync.noncoh= Bds_Bitsync_config.nnchList;
        % finer dopplar search
        channel_spc.bitSync.frange= Bds_Bitsync_config.freqRange;
        channel_spc.bitSync.fbin  = Bds_Bitsync_config.freqBin;
        channel_spc.bitSync.fnum  = channel_spc.bitSync.frange/channel_spc.bitSync.fbin + 1;
        % Center frequency
        channel_spc.bitSync.freqCenter  = channel_spc.LO2_IF0 + channel_spc.LO2_fd;
        channel_spc.bitSync.Fcodesearch = channel_spc.LO_Fcode0 + channel_spc.LO_Fcode_fd;
        
        channel_spc.bitSync.sampPerCode = round(GSAR_CONSTANTS.STR_B1I.ChipNum / channel_spc.bitSync.Fcodesearch * GSAR_CONSTANTS.STR_RECV.fs);
        channel_spc.bitSync.skipNumberOfSamples = 0;
        channel_spc.bitSync.skipNperCode = channel_spc.bitSync.sampPerCode*(1 - GSAR_CONSTANTS.STR_B1I.Fcode0 / channel_spc.bitSync.Fcodesearch);
        
        channel_spc.bitSync.accum = 0;
        channel_spc.bitSync.resiData   = [];
        channel_spc.bitSync.resiN      = 0;
        %?? Here the bds is inconsistent with gps, caution!!!
        channel_spc.bitSync.carriPhase = 0;    
        channel_spc.bitSync.Samp_Posi_dot = 0;
        channel_spc.bitSync.offCarri   = [];
        channel_spc.bitSync.bitSyncID  = 0;
        channel_spc.bitSync.corr       = [];
        channel_spc.bitSync.corrtmp    = [];
        
        channel_spc.bitSync.bitSyncResults.sv      = 0;
        channel_spc.bitSync.bitSyncResults.synced  = 0;
        channel_spc.bitSync.bitSyncResults.nc_corr = 0;
        channel_spc.bitSync.bitSyncResults.freqIdx = 0;
        channel_spc.bitSync.bitSyncResults.bitIdx  = 0;
        channel_spc.bitSync.bitSyncResults.doppler = 0;
end
