function  [DiffPara] = RangeCorrPr(channels,activeChannel, DiffPara, EphAll)
    %%%%%通过RINEX计算伪距差分信息
    if  ~isequal(DiffPara.PrevEph, EphAll)
        filename='F:\wangyz\trunk\roof_rinex\803739092q.15O';
        decimate_factor = 1;
        refxyz = [-2853445.340,4667464.957,3268291.032]';%参考系坐标
        [C1I, L1I,ch,TOWSEC] = read_rinex(filename,decimate_factor);
        TOWSEC = TOWSEC -14; %%貌似是司南接收机的钟差
        PR_error = zeros(length(TOWSEC), 30);
        prref = C1I';%观测伪距
        adrref = L1I*299792458/1561098000;%积分多普勒乘以波长
        transmitTime = zeros(1,30);
        satpos_corr = zeros(3,30);
        for j = 1:length(TOWSEC)
            for jj = 1:length(ch(j,:))
                if ch(j,jj) ~= 0
                    transmitTime(ch(j,jj)) = TOWSEC(j) - prref(j,ch(j,jj))/299792458;
                end
            end
            [satPositions, satClkCorr,eph_all] = BD_calculateSatPosition(transmitTime, ...
                 channels,activeChannel);    
            for jj = 1:length(ch(j,:))
                if ch(j,jj) ~= 0
                    satpos_corr(:, ch(j,jj)) = e_r_corr(...
                        prref(j,ch(j,jj))/299792458 + satClkCorr(ch(j,jj)), satPositions(1:3, ch(j,jj)));%卫星i经过地球自转修正后的位置
                    PR_error(j,ch(j,jj)) =prref(j,ch(j,jj)) - norm(refxyz - satpos_corr(1:3,ch(j,jj)));
                end
            end
        end
        DiffPara.PrevEph = EphAll;
        DiffPara.PrError = PR_error;
        DiffPara.TowSec  = TOWSEC;
    end
end

% % smint = 50;%平滑时长
% % %refxyz = [-2853445.340,4667464.957,3268291.032];%参考系坐标
% % %prc = 0*ones(24,length(TOWSEC));%伪距差分量
% % value_rinex = zeros(30,2);
% % prsmref = zeros(30, length(TOWSEC));
% %     for i = 1:length(TOWSEC)
% %        svidref = ch(i,:);
% %        [prsmref(:,i),value_rinex] = ...
% %            hatch_BD(prref(:,i),adrref(:,i),svidref,smint,value_rinex);%载波相位平滑滤波
% %     end
% %  end
      
   
    