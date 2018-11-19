function [raimPass, mxprErr_id] = stndrdResi_raim(SYST,pos_calc, pos_forecast, bRaim, prError, pvtForecast_Succ,activChn_raim)

% Input: 
%      1: pos_calc = calculated position [3x1]
%      2: pos_forecast = predicted position [3x1]
%      3: SYST         = type of estimator
%      4: bRaim        = [1x1] structure contains information for raim
%      5: prError      = pseudornage error difference between predicted and
%      corrected
%      
% Output:
%      1: raimPass = 1/0 raim test
%      2: mxprErr_id = satellite ID with observation error

% This function predicts if the estimated position is trustable and no
% further processing is requried. For the verification of posiotion,
% difference of currant estimated position and predicted position (if
% available), prError and predicts weights from mm estimator
% if last position is avaialble and pvtForecast_Succ is valid, just check
% the difference of calculated and predicted positions and prError

% chi-square threshold with n freedom and alpha confidence
chi2inv_Table = 1*[19.5, 23.0, 25.9, 28.5, 30.9, 33.1, 35.3, 37.33, 39.34, 41.3, 43.21, 45.1, 46.91, 48.72, 50.49, 52.25, 53.97, 55.68];
raimPass = 1;
switch SYST
    case {'BDS_B1I', 'GPS_L1CA'}
        nmbOfSat_inraim = size(activChn_raim, 2);
    case 'B1I_L1CA'
        nmbOfSat_inraim = activChn_raim; % when syst=B1I_L1CA, the input activChn_raim is a number, not a vector anymore
end

if isempty(bRaim)
    raimPass = 0;
    mxprErr_id = 0;
    return;
end
WSSE = bRaim.bEsti'*bRaim.bEsti; 
while(1)
    if pvtForecast_Succ && raimPass
        pos_diff = pos_calc - pos_forecast;
        wPrError_sum = sum(abs(prError'.*bRaim.mmWghts));
        % check if the position can be trusted
        if (sum(abs(pos_diff))<=5) && (wPrError_sum<50) && (wPrError_sum~=0)
            raimPass = 1;
            mxprErr_id = 0;
            return;
        else
            raimPass = 0;
            continue;
        end
    elseif WSSE <= chi2inv_Table(nmbOfSat_inraim - 4)
        raimPass = 1;
        mxprErr_id = 0;
        return;
    else
        if pvtForecast_Succ % there is predicted pseudorange, so we use the measurement prError
            [~, mxprErr_id] = max(abs(prError));
            raimPass = 0;
            return;
        else
            [~, mxprErr_id] = max(abs(bRaim.bEsti));
            [~, mxprErr_id1] = max(abs(bRaim.omc));
            raimPass = 0;
        end
        return;
    end
    
end
        
    
    