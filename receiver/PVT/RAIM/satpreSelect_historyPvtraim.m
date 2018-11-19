function [warningNum, warning_list] = satpreSelect_historyPvtraim(activeChannel, psr_predict, obs, iono_corr, trop_corr, satClkCorr, clkErrForecast, config)
% activeChannel    - active channel&prn list, mat [2xnmbOfSatellites]
% psr_predict          - predicted pseudoranges, vector [1x32]
% obs                  - measured pseudoranges, vector [1x32]
% iono_corr            - iono corrections, vector [1x32]
% trop_corr            - trop corrections, vector [1x32]
% satClkCorr           - sat clk correction parameters, mat [2x32]
% recv_timer           - receiver timer struct
nmbOfSatellites = size(activeChannel, 2);
warning_list = zeros(3, nmbOfSatellites);
warningNum = 0;
c = 299792458;

for n=1:nmbOfSatellites
    prn = activeChannel(2,n);
    psr_mr = obs(prn) + c*satClkCorr(1,prn) - iono_corr(prn) - trop_corr(prn) - clkErrForecast;
    psr_pr = psr_predict(prn);
    
    psrerr = abs(psr_pr-psr_mr);
    if psrerr > config.recvConfig.configPage.Pvt.pseudorangePreErrThre % This threshould should be tuned to get the best prection for pre-pseurodage error checking
        warningNum = warningNum + 1;
        warning_list(1, warningNum) = activeChannel(1,n);
        warning_list(2, warningNum) = activeChannel(2,n);
        warning_list(3, warningNum) = psrerr;
    end
end