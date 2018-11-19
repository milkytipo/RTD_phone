function [rxTime] = get_rxTime(SYST, recv_time)
% half_week = 302400;     % seconds
switch SYST
    case 'GPS_L1CA'
%         if recv_time.recvSOW_GPS == -1
%             % Here we need to be caution with week end-start condition
%             transtimeList = transmitTime.GPS(transmitTime.GPS~=0);
%             if (max(transtimeList) - min(transtimeList)) > half_week % This case means it is a week end-start time
%                 transtimeList = transtimeList < half_week;
%             end
% %             rxTime = median(transmitTime.GPS(transmitTime.GPS~=0)) + 70*1e-3; % 取中位数，防止首次判断时间出现异常值
%             rxTime = median(transtimeList) + 70*1e-3;
%             recv_time.recvSOW_GPS = rxTime;
%         else
%             rxTime = recv_time.recvSOW_GPS;
%         end
        rxTime = recv_time.recvSOW_GPS;
        
    case 'BDS_B1I'
        rxTime = recv_time.recvSOW_BDS;
end