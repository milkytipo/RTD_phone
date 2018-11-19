function receiver = actvChns_get(receiver)

actvPvtChannels = receiver.actvPvtChannels;

actvPvtChannels.actChnsNum_BDS = 0;
actvPvtChannels.actChnsNum_GPS = 0;

for n= 1 : receiver.config.recvConfig.numberOfChannels(1).channelNumAll
    
    switch receiver.channels(n).SYST
        case 'BDS_B1I'
            if strcmp(receiver.channels(n).CH_B1I(1).CH_STATUS, 'SUBFRAME_SYNCED')
                
                prnNum = receiver.channels(n).CH_B1I(1).PRNID;
                if (receiver.naviMsg.BDS_B1I.ephemeris(prnNum).ephReady==1) && (receiver.naviMsg.BDS_B1I.ephemeris(prnNum).eph.health==0)
                    actvPvtChannels.actChnsNum_BDS = actvPvtChannels.actChnsNum_BDS + 1;
                    actvPvtChannels.BDS(1, actvPvtChannels.actChnsNum_BDS) = n;
                    actvPvtChannels.BDS(2, actvPvtChannels.actChnsNum_BDS) = prnNum;
                end
            end %EOF "if strcmp(receiver.channels(n).CH_B1I(1).CH_STATUS, 'SUBFRAME_SYNCED')"
            
        case 'GPS_L1CA'
            if strcmp(receiver.channels(n).CH_L1CA(1).CH_STATUS, 'SUBFRAME_SYNCED')                
                prnNum = receiver.channels(n).CH_L1CA(1).PRNID;
                if (receiver.naviMsg.GPS_L1CA.ephemeris(prnNum).ephReady==1) && (receiver.naviMsg.GPS_L1CA.ephemeris(prnNum).eph.health==0)
                    actvPvtChannels.actChnsNum_GPS = actvPvtChannels.actChnsNum_GPS + 1;
                    actvPvtChannels.GPS(1, actvPvtChannels.actChnsNum_GPS) = n;
                    actvPvtChannels.GPS(2, actvPvtChannels.actChnsNum_GPS) = prnNum;
                end
            end %EOF "if strcmp(receiver.channels(n).CH_L1CA(1).CH_STATUS, 'SUBFRAME_SYNCED')"
            
        case 'GPS_L1CA_L2C'
            if strcmp(receiver.channels(n).CH_L1CA_L2C(1).CH_STATUS, 'SUBFRAME_SYNCED')        
                prnNum = receiver.channels(n).CH_L1CA_L2C(1).PRNID;
                L1_available = (receiver.naviMsg.GPS_L1CA.ephemeris(prnNum).ephReady==1) && ...
                    (receiver.naviMsg.GPS_L1CA.ephemeris(prnNum).eph.health==0); 
                L2_available = (receiver.naviMsg.GPS_L2C.ephemeris(prnNum).ephReady==1) && ...
                    (receiver.naviMsg.GPS_L2C.ephemeris(prnNum).eph.L2_health==0);
                if ( L1_available || L2_available) 
                    actvPvtChannels.actChnsNum_GPS = actvPvtChannels.actChnsNum_GPS + 1;
                    actvPvtChannels.GPS(1, actvPvtChannels.actChnsNum_GPS) = n;
                    actvPvtChannels.GPS(2, actvPvtChannels.actChnsNum_GPS) = prnNum;
                end
            end
            
    end %EOF "switch receiver.channels(n).SYST"
end %EOF "for n= 1 : receiver.config.recvConfig.numberOfChannels(1).channelNumAll"

receiver.actvPvtChannels = actvPvtChannels;
