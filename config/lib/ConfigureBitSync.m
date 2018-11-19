%% Bit synchronization configurations
function [bitSyncConfig] = ConfigureBitSync(syst)

global GSAR_CONSTANTS;

if strcmp(syst, 'BD_B1I') 
    % settings for GEO satellites     
    bitSyncConfig.GEO.tcoh           = GSAR_CONSTANTS.STR_B1I.T_D2; % coherent integration time,[s]
    bitSyncConfig.GEO.nnchList       = [50,100];   % 25 non-coherent of T_D2 coherent is equivalent 50ms at all
    bitSyncConfig.GEO.freqBin        = 50;   % Hz
    bitSyncConfig.GEO.freqRange      = 500;  % -250Hz ~ 250Hz
    bitSyncConfig.GEO.threshold      = 1.25;  % threshold (the largest value / the second largest )
    bitSyncConfig.GEO.fcorrect       = 1;
    bitSyncConfig.GEO.waitSec        = 2;   % 比特同步不成功后的等待时间 (秒)
    % settings for NGEO satellites
    bitSyncConfig.NGEO.tcoh           = 10e-3; % coherent integration time,[s]. 0.01s is expected.
    bitSyncConfig.NGEO.nnchList       = [20,50];   % 10 non-coherent of 10ms coherent is equivalent 100ms at all.
    bitSyncConfig.NGEO.freqBin        = 50;   % Hz, 50Hz is fit for coherent integration time of 0.01s.
    bitSyncConfig.NGEO.freqRange      = 600;  % -250Hz ~ 250Hz
    bitSyncConfig.NGEO.threshold      = 1.25;   
    bitSyncConfig.NGEO.fcorrect       = 1;
    bitSyncConfig.NGEO.waitSec        = 2;   % 比特同步不成功后的等待时间 (秒)
elseif strcmp(syst, 'GPS_L1CA') 
    bitSyncConfig.tcoh                = 20e-3; % coherent integration time,[s].
    bitSyncConfig.nnchList            = [20, 200];   % 10 non-coherent of 10ms coherent is equivalent 100ms at all.
    bitSyncConfig.freqBin             = 25;   % Hz
    bitSyncConfig.freqRange           = 500;  % -250Hz ~ 250Hz
    bitSyncConfig.threshold           = 1;
    bitSyncConfig.fcorrect            = 1;    %
end
