% Cold Start Channel Initializing
function [channel] = ColdStartChInitialize(Syst, CH_Status, prn, configPage, GSAR_CONSTANTS, channel)
% Syst:         System flag, BDS_B1I, GPS_L1CA ...
% CH_Status:    Channel status, COLD_ACQ, Bit_Sync ...
% prn:          prn
% configPage:   Global signal processing algorithm-related config parameters
% GSAR_CONSTANTS: Receiver hardware-related config parameters
% channel:      Channel structure
switch Syst
    case 'BDS_B1I'
        channel = BdsCH_ColdInitialize(channel, Syst, CH_Status, prn, configPage, GSAR_CONSTANTS);
        
end

