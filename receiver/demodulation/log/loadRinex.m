function [pvtCalculator]= loadRinex(positionType, pvtCalculator)
   %% 计算伪距单差校正量
    if positionType == 10
        filename = pvtCalculator.diffFile;
        decimate_factor = 1;
        [C1, L1,ch,TOWSEC] = read_rinex(filename,decimate_factor);
        TOWSEC = TOWSEC-14 ; %%貌似是司南接收机的钟差,北斗需要减去14秒，GPS不需要
        pvtCalculator.prError = C1';
        pvtCalculator.carriError = L1';
        pvtCalculator.towSec = TOWSEC;
    end
    
    %% hatch smoothing
%     prref = C1I;%观测伪距
%     adrref = L1I*299792458/1561098000;%积分多普勒乘以波长
%     smint = 50;%平滑时长
%     %refxyz = [-2853445.340,4667464.957,3268291.032];%参考系坐标
%     value_rinex = zeros(30,2);
%     prsmref = zeros(30, length(TOWSEC));
%     for i = 1:length(TOWSEC)
%        svidref = ch(i,:);
%        [prsmref(:,i),value_rinex] = ...
%        hatch_BD(prref(:,i),adrref(:,i),svidref,smint,value_rinex);%载波相位平滑滤波
%     end
end