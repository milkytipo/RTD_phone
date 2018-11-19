function [raimPass, mxprErr_id] = resi_raim(SYST, bEsti, prError, pvtForecast_Succ, activChn_raim)
% bEsti           - vector [nmbOfSat_inraim x 1], compact vector of
%                   estimated residuals
% prError         - vector [nmbOfSat_inraim x 1], compact vector of
%                   pseudorange error
% 

% chi-square threshold with n freedom and alpha confidence
chi2inv_Table = 1*[19.5, 23.0, 25.9, 28.5, 30.9, 33.1, 35.3, 37.33, 39.34, 41.3, 43.21, 45.1, 46.91, 48.72, 50.49, 52.25, 53.97, 55.68];

switch SYST
    case {'BDS_B1I', 'GPS_L1CA'}
        nmbOfSat_inraim = size(activChn_raim, 2);
    case 'B1I_L1CA'
        nmbOfSat_inraim = activChn_raim; % when syst=B1I_L1CA, the input activChn_raim is a number, not a vector anymore
end


WSSE = bEsti'*bEsti;         % 误差检测值

raimPass = 1;
mxprErr_id = 0;

thresValue = chi2inv_Table(nmbOfSat_inraim - 4);
thresValue = 999999;
if WSSE > thresValue
    if pvtForecast_Succ % there is predicted pseudorange, so we use the measurement prError
        [mx_prErr, mxprErr_id] = max(abs(prError));
%         fault_sat_id = activChn_raim(:, mxprErr_id);
    else % there is no predicted psr, so we use the measurement bEsti
        [mx_prErr, mxprErr_id] = max(abs(bEsti));
    end
%     [mx_prErr, mxprErr_id] = max(abs(bEsti));
    raimPass = 0;
end

% 
% if ~isempty(H)
%     if size(H,1) >= 5
%         if strcmp(SYST,'BDS_B1I') || (strcmp(SYST,'B1I_L1CA')&&svnum.GPS==0)
%             bEsti = raimB - H/(H'*H)*H'*raimB;    % 残余分量
%             WSSE = (norm(bEsti))^2;         % 误差检测值
%             if WSSE > chi2inv(0.99999, size(H,1)-4)
%                 if (recv_time.recvSOW-pvtCalculator.timeLast)<5 && pvtCalculator.posiLast(1)~=0 && pvtCalculator.posiCheck==1   % 认为上一时刻位置信息有效
%                     [~, maxNum] = max(abs(prError));
%                     posiChannel.BDS(:, maxNum) = [];
%                     svnum.BDS = svnum.BDS - 1;
%                 else
%                     [~, maxNum] = max(abs(bEsti));
%                     posiChannel.BDS(:, maxNum) = [];
%                     svnum.BDS = svnum.BDS - 1;
%                 end
%             else
%                 raimFlag = 1;   % 满足检验要求
%             end
%         elseif strcmp(SYST,'GPS_L1CA') || (strcmp(SYST,'B1I_L1CA')&&svnum.BDS==0)
%             bEsti = raimB - H/(H'*H)*H'*raimB;    % 残余分量
%             WSSE = (norm(bEsti))^2;         % 误差检测值
%             if WSSE > chi2inv(0.99999, size(H,1)-4)
%                 if (recv_time.recvSOW-pvtCalculator.timeLast)<5 && pvtCalculator.posiLast(1)~=0 && pvtCalculator.posiCheck==1   % 认为上一时刻位置信息有效
%                     [~, maxNum] = max(abs(prError));
%                     posiChannel.GPS(:, maxNum) = [];
%                     svnum.GPS = svnum.GPS - 1;
%                 else
%                     [~, maxNum] = max(abs(bEsti));
%                     posiChannel.GPS(:, maxNum) = [];
%                     svnum.GPS = svnum.GPS - 1;
%                 end
%             else
%                 raimFlag = 1;   % 满足检验要求
%             end
%         elseif  strcmp(SYST,'B1I_L1CA')
%             bEsti = raimB - H/(H'*H)*H'*raimB;    % 残余分量
%             WSSE = (norm(bEsti))^2;         % 误差检测值
%             if WSSE > chi2inv(0.99999, size(H,1)-4)
%                 if (recv_time.recvSOW-pvtCalculator.timeLast)<5 && pvtCalculator.posiLast(1)~=0 && pvtCalculator.posiCheck==1   % 认为上一时刻位置信息有效
%                     [~, maxNum] = max(abs(prError));
%                     numBD = size(posiChannel.BDS, 2);   % 双系统定位中北斗卫星使用的数目
%                     if maxNum <= numBD
%                         posiChannel.BDS(:, maxNum) = [];
%                         svnum.BDS = svnum.BDS - 1;
%                     else
%                         posiChannel.GPS(:, maxNum-numBD) = [];
%                         svnum.GPS = svnum.GPS - 1;
%                     end
%                 else
%                     [~, maxNum] = max(abs(bEsti));
%                     numBD = size(posiChannel.BDS, 2);   % 双系统定位中北斗卫星使用的数目
%                     if maxNum <= numBD
%                         posiChannel.BDS(:, maxNum) = [];
%                         svnum.BDS = svnum.BDS - 1;
%                     else
%                         posiChannel.GPS(:, maxNum-numBD) = [];
%                         svnum.GPS = svnum.GPS - 1;
%                     end
%                 end
%             else
%                 raimFlag = 1;   % 满足检验要求
%             end
%         end
%     else
%         raimFlag = 1;   % 小于5颗卫星无法使用raim算法
%     end
% end
