function [raimFlag, posiChannel,activeChannel,svnum] =raim(prError, raimG, raimB, posiChannel, raimFlag, SYST, svnum, pvtCalculator, recv_time, rawP, activeChannel)
% if isempty(raimG)  % 首次进入raim先去除伪距观测量奇异点 
%     if ~isempty(activeChannel.BDS)
%         for i =size(activeChannel.BDS, 2) : -1 : 1
%             if rawP.BDS(activeChannel.BDS(2,i))<9999999 || rawP.BDS(activeChannel.BDS(2,i))>99999999    % 满足此条件认为是奇异点
%                 activeChannel.BDS(:,i) = [];
%                 posiChannel.BDS(:,i) = [];
%             end
%         end
%     end
%     if ~isempty(activeChannel.GPS)
%         for i =size(activeChannel.GPS, 2) : -1 : 1
%             if rawP.GPS(activeChannel.GPS(2,i))<9999999 || rawP.GPS(activeChannel.GPS(2,i))>99999999    % 满足此条件认为是奇异点
%                 activeChannel.GPS(:,i) = [];
%                 posiChannel.GPS(:,i) = [];
%             end
%         end
%     end
% end   
if ~isempty(raimG)
    if size(raimG,1) >= 5
        if strcmp(SYST,'BDS_B1I') || (strcmp(SYST,'B1I_L1CA')&&svnum.GPS==0)
            bEsti = raimB - raimG/(raimG'*raimG)*raimG'*raimB;    % 残余分量
            WSSE = (norm(bEsti))^2;         % 误差检测值
            if WSSE > chi2inv(0.99999, size(raimG,1)-4)
                if (recv_time.recvSOW-pvtCalculator.timeLast)<5 && pvtCalculator.posiLast(1)~=0 && pvtCalculator.posiCheck==1   % 认为上一时刻位置信息有效
                    [~, maxNum] = max(abs(prError));
                    posiChannel.BDS(:, maxNum) = [];
                    svnum.BDS = svnum.BDS - 1;
                else
                    [~, maxNum] = max(abs(bEsti));
                    posiChannel.BDS(:, maxNum) = [];
                    svnum.BDS = svnum.BDS - 1;
                end
            else
                raimFlag = 1;   % 满足检验要求
            end
        elseif strcmp(SYST,'GPS_L1CA') || (strcmp(SYST,'B1I_L1CA')&&svnum.BDS==0)
            bEsti = raimB - raimG/(raimG'*raimG)*raimG'*raimB;    % 残余分量
            WSSE = (norm(bEsti))^2;         % 误差检测值
            if WSSE > chi2inv(0.99999, size(raimG,1)-4)
                if (recv_time.recvSOW-pvtCalculator.timeLast)<5 && pvtCalculator.posiLast(1)~=0 && pvtCalculator.posiCheck==1   % 认为上一时刻位置信息有效
                    [~, maxNum] = max(abs(prError));
                    posiChannel.GPS(:, maxNum) = [];
                    svnum.GPS = svnum.GPS - 1;
                else
                    [~, maxNum] = max(abs(bEsti));
                    posiChannel.GPS(:, maxNum) = [];
                    svnum.GPS = svnum.GPS - 1;
                end
            else
                raimFlag = 1;   % 满足检验要求
            end
        elseif  strcmp(SYST,'B1I_L1CA')
            bEsti = raimB - raimG/(raimG'*raimG)*raimG'*raimB;    % 残余分量
            WSSE = (norm(bEsti))^2;         % 误差检测值
            if WSSE > chi2inv(0.99999, size(raimG,1)-4)
                if (recv_time.recvSOW-pvtCalculator.timeLast)<5 && pvtCalculator.posiLast(1)~=0 && pvtCalculator.posiCheck==1   % 认为上一时刻位置信息有效
                    [~, maxNum] = max(abs(prError));
                    numBD = size(posiChannel.BDS, 2);   % 双系统定位中北斗卫星使用的数目
                    if maxNum <= numBD
                        posiChannel.BDS(:, maxNum) = [];
                        svnum.BDS = svnum.BDS - 1;
                    else
                        posiChannel.GPS(:, maxNum-numBD) = [];
                        svnum.GPS = svnum.GPS - 1;
                    end
                else
                    [~, maxNum] = max(abs(bEsti));
                    numBD = size(posiChannel.BDS, 2);   % 双系统定位中北斗卫星使用的数目
                    if maxNum <= numBD
                        posiChannel.BDS(:, maxNum) = [];
                        svnum.BDS = svnum.BDS - 1;
                    else
                        posiChannel.GPS(:, maxNum-numBD) = [];
                        svnum.GPS = svnum.GPS - 1;
                    end
                end
            else
                raimFlag = 1;   % 满足检验要求
            end
        end
    else
        raimFlag = 1;   % 小于5颗卫星无法使用raim算法
    end
end
