function [gpsCN0] = GPS_getChnCN0(channels, activeChannel_GPS)

gpsCN0 = zeros(2, 32);

N = size(activeChannel_GPS, 2);

for n=1:N
    chn = activeChannel_GPS(1,n);
    prn = activeChannel_GPS(2,n);
    % DLOS' CN0
    if (strcmp('GPS_L1CA',channels(chn).SYST))
        gpsCN0(1,prn) = channels(chn).CH_L1CA(1).CN0_Estimator.CN0(1);
        if channels(chn).STR_CAD.CadUnit_N > 1
            % MP's CN0
            gpsCN0(2,prn) = channels(chn).CH_L1CA(2).CN0_Estimator.CN0(1);
        end
    elseif (strcmp('GPS_L1CA_L2C',channels(chn).SYST))
        gpsCN0(1,prn) = channels(chn).CH_L1CA_L2C(1).CN0_Estimator.CN0(1);
        if channels(chn).STR_CAD.CadUnit_N > 1
            % MP's CN0
            gpsCN0(2,prn) = channels(chn).CH_L1CA_L2C(2).CN0_Estimator.CN0(1);
        end
    end
    
end