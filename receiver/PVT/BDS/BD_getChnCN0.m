function [bdsCN0] = BD_getChnCN0(channels, activeChannel_BDS)

bdsCN0 = zeros(2, 32);

N = size(activeChannel_BDS, 2);

for n=1:N
    chn = activeChannel_BDS(1,n);
    prn = activeChannel_BDS(2,n);
    % DLOS' CN0
    bdsCN0(1,prn) = channels(chn).CH_B1I(1).CN0_Estimator.CN0;
    if channels(chn).STR_CAD.CadUnit_N > 1
        % MP's CN0
        bdsCN0(2,prn) = channels(chn).CH_B1I(2).CN0_Estimator.CN0;
    end
end