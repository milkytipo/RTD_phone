%% acquisition operation configurations
function [acqConfig] = ConfigureAcq(syst)

if strcmp(syst,'BD_B1I') 
    % Settings for GEO satellites     
    acqConfig.GEO.tcoh           = 1e-3;       % Coherent integration time,[s]
    acqConfig.GEO.nnchList       = [0 20 200]; % 0 is redundant; since the GEO's bit duration is 2ms, the pull
    acqConfig.GEO.freqBin        = 250;        %
    acqConfig.GEO.freqRange      = 2e3;        % Frequency range for acquisition process
    acqConfig.GEO.coldFreqRange  = 2e3;        % Frequency range for cold acquisition
    acqConfig.GEO.warmFreqRange  = 1e3;        % Frequency range for warm acquisition, commonly half of cold one
    acqConfig.GEO.threhold       = 8;
    acqConfig.GEO.svNumToAcq     = 5;          % Unknown sofar
    acqConfig.GEO.oscOffset      = 0;          % Freq offset from IF to all channels, simulating to the offset effect caused by oscillator
    
    % Settings for NGEO satellites
    acqConfig.NGEO.tcoh          = 1e-3;       % Since the effects of NH codes, the longest coherent integration time is 1ms.
    acqConfig.NGEO.nnchList      = [0 20 100]; % 0 is redundant; 20 corresponding to strong singal; 200 corresponding to weak signal.
    acqConfig.NGEO.freqBin       = 500;        % frequency search step [Hz], relative to the parameter 'tcoh'
    acqConfig.NGEO.freqRange     = 8e3;        % frequency search range, -5KHz ~ +5KHz
    acqConfig.NGEO.coldFreqRange = 8e3;       % Frequency range for cold acquisition
    acqConfig.NGEO.warmFreqRange = 1e3;       % Frequency range for warm acquisition, commonly half of cold one
    acqConfig.NGEO.threhold      = 8;          % Acquisition detection threshold
    acqConfig.NGEO.svNumToAcq    = 5;          % Unknown sofar
    acqConfig.NGEO.oscOffset     = 0;          % Freq offset from IF to all channels, simulating to the offset effect caused by oscillator
    
elseif strcmp(syst,'GPS_L1CA') 
    acqConfig.tcoh               = 1e-3;       % Coherent integration time 
    acqConfig.nnchList           = [0 20 60];  % 0 is redundant
    acqConfig.svNumToAcq         = 8;
    acqConfig.freqBin            = 500;
    acqConfig.freqRange          = 10e3;        % Frequency range for acquisition process
    acqConfig.coldFreqRange      = 10e3;        % Frequency range for cold acquisition
    acqConfig.warmFreqRange      = 1e3;        % Frequency range for warm acquisition, commonly half of cold one
    acqConfig.threhold           = 12;
    acqConfig.oscOffset          = 0;          % Freq offset from IF to all channels, simulating to the offset effect caused by oscillator
end

end