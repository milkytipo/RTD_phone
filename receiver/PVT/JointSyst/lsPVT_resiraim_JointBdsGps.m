function [pvtCalculator, recv_timer, satelliteTable_bds, satelliteTable_gps] = ...
    lsPVT_resiraim_JointBdsGps(satpos_bds, satpos_gps, obs_bds, obs_gps, transmitTime_bds, transmitTime_gps, satClkCorr_bds, satClkCorr_gps, ...
                       CN0_bds, CN0_gps, ...
                       config, activeChannel_BDS, activeChannel_GPS, satelliteTable_bds, satelliteTable_gps, ephemeris_para_bds, ephemeris_para_gps, ...
                       recv_timer, pvtCalculator, pvtForecast_Succ)
% satpos              - matrix[6x32], each column for a sat [x;y;z;vx;vy;vz]
% obs                 - vector[1x32], each for a sat pseudorange [meter]
% transmitTime        - vector[1x32], each for a sat transmit time [sec]
% satClkCorr          - matrix[2x32], each colum for a sat [clk_dt; clk_df]
% config              - receiver config struct
% channels            - receiver channel list, [nx1:channel]
% activeChannel_BDS   - matrix[2xNum], row1 for channel ID list; row2 for
%                       prn list; Num for number of active channels
% satelliteTable      - 
% ephemeris_para      - ephemeris.para struct for GPS, [1x32 struct]
% recv_timer          - receiver local timer
% pvtCalculator       - PVT struct
% pvtForecast_Succ    - forcast PVT solution is avaible: 1 - valid; 0 - invalid

BDS_maxPrnNo = config.recvConfig.configPage.systConfig.BDS_B1I.maxPrnNo;
GPS_maxPrnNo = config.recvConfig.configPage.systConfig.GPS_L1CA.maxPrnNo;
elevationMask = config.recvConfig.elevationMask;

nmbOfSatellites_bds = size(activeChannel_BDS, 2);
el_bds = zeros(1,BDS_maxPrnNo);
az_bds = zeros(1,BDS_maxPrnNo);
iono_bds = zeros(1,BDS_maxPrnNo);
trop_bds = zeros(1,BDS_maxPrnNo);
psr_bds =  zeros(1,BDS_maxPrnNo);
c = 2.99792458e8;

nmbOfSatellites_gps = size(activeChannel_GPS, 2);
el_gps = zeros(1,GPS_maxPrnNo);
az_gps = zeros(1,GPS_maxPrnNo);
iono_gps = zeros(1,GPS_maxPrnNo);
trop_gps = zeros(1,GPS_maxPrnNo);
psr_gps =  zeros(1,GPS_maxPrnNo);
% chi-square threshold with n freedom and alpha confidence
% chi2inv_Table = [19.5, 23.0, 25.9, 28.5, 30.9, 33.1, 35.3, 37.33, 39.34, 41.3, 43.21, 45.1, 46.91, 48.72, 50.49, 52.25, 53.97, 55.68];
satWarningNum_bds = 0;
satWarningNum_gps = 0;


refPos = [-2850197.286; 4655185.885; 3288382.972];  % 静态点
[el_bds, az_bds, iono_bds, trop_bds, psr_bds, satelliteTable_bds] = ...
        sats_el_az_psr_predict_BDS(satpos_bds, activeChannel_BDS, refPos, satelliteTable_bds, ephemeris_para_bds, recv_timer);
[el_gps, az_gps, iono_gps, trop_gps, psr_gps, satelliteTable_gps] = ...
        sats_el_az_psr_predict_GPS(satpos_gps, activeChannel_GPS, refPos, satelliteTable_gps, ephemeris_para_gps, recv_timer);
    
if pvtForecast_Succ 
    % there is a trustable last PVT solution, so we can compute the 
    % predicted satellite elevation and azimuth. 
    % And the predicted pseudorange.
%     [el_bds, az_bds, iono_bds, trop_bds, psr_bds, satelliteTable_bds] = ...
%         sats_el_az_psr_predict_BDS(satpos_bds, activeChannel_BDS, pvtCalculator.posForecast, satelliteTable_bds, ephemeris_para_bds, recv_timer);
    % when the avaible history pos info is trustable, the pre-raim by using
    % history positions are applied.
    if recv_timer.rclkErr2Syst_UpCnt(1) < recv_timer.rclkErr2Syst_Thre % _UpCnt(1) is clkErr to BDS syst
        [satWarningNum_bds, satWarning_list_bds] = satpreSelect_historyPvtraim(...
                         activeChannel_BDS, ...
                         psr_bds, ...
                         obs_bds, ...
                         iono_bds, ...
                         trop_bds, ...
                         satClkCorr_bds, ...
                         pvtCalculator.clkErrForecast(1), ...% predicted recv2BDS clk error 
                         config);
    end
    
    [el_gps, az_gps, iono_gps, trop_gps, psr_gps, satelliteTable_gps] = ...
        sats_el_az_psr_predict_GPS(satpos_gps, activeChannel_GPS, pvtCalculator.posForecast, satelliteTable_gps, ephemeris_para_gps, recv_timer);
    if recv_timer.rclkErr2Syst_UpCnt(2) < recv_timer.rclkErr2Syst_Thre % _UpCnt(2) is clkErr to BDS syst
        [satWarningNum_gps, satWarning_list_gps] = satpreSelect_historyPvtraim(...
                         activeChannel_GPS, ...
                         psr_gps, ...
                         obs_gps, ...
                         iono_gps, ...
                         trop_gps, ...
                         satClkCorr_gps, ...
                         pvtCalculator.clkErrForecast(2), ...% predicted recv2GPS clk error 
                         config);
    end
end % if pvtForecast_Succ 

activChn_raim_bds = activeChannel_BDS;
for n=1:satWarningNum_bds
    warning_prn_bds = satWarning_list_bds(2,n);
    idx = find(activChn_raim_bds(2,:)==warning_prn_bds, 1);
    activChn_raim_bds(:,idx) = [];
end
nmbOfSat_inraim_bds = size(activChn_raim_bds, 2);

activChn_raim_gps = activeChannel_GPS;
for n=1:satWarningNum_gps
    warning_prn_gps = satWarning_list_gps(2,n);
    idx = find(activChn_raim_gps(2,:)==warning_prn_gps, 1);
    activChn_raim_gps(:,idx) = [];
end
nmbOfSat_inraim_gps = size(activChn_raim_gps, 2);

nmbOfSat_inraim = nmbOfSat_inraim_bds + nmbOfSat_inraim_gps;
inraim = 1;
lspvt_raim_coder = 0;

NGEOFlag = 0;
if nmbOfSat_inraim_gps
    NGEOFlag = 1;
elseif nmbOfSat_inraim_bds
    NGEOFlag = sum(activChn_raim_bds(2,:)>5);
end


while (nmbOfSat_inraim>=5) && (inraim == 1) && (NGEOFlag>0)
    if nmbOfSat_inraim_gps==0 %there is only BDS sats available
        [pos_xyz, vel_xyz_bds, cdtu_bds, az_actv_bds, el_actv_bds, iono_actv_bds, trop_actv_bds, bEsti_bds, psrCorr_bds, DOP, rankBreak] = ...
            leastSquarePos_BDS1(satpos_bds, ...
                                obs_bds, ...
                                transmitTime_bds, ...
                                ephemeris_para_bds, ...
                                activChn_raim_bds, ...
                                satClkCorr_bds, ...
                                pvtCalculator, ...
                                recv_timer, ...
                                pvtForecast_Succ, ...
                                el_bds, ...
                                az_bds, ...
                                iono_bds, ...
                                trop_bds, ...
                                CN0_bds);
        psrCorr = psrCorr_bds;
        psr = psr_bds(activChn_raim_bds(2,:));
        bEsti = bEsti_bds;
        vel_xyz = [vel_xyz_bds; pvtCalculator.clkErr(2,2)]; % For GPS clk drift, we keep it unchanged
        cdtu = [cdtu_bds; pvtCalculator.clkErrForecast(2)]; % we use the predicted clkErr as cdtu of GPS
        
    elseif nmbOfSat_inraim_bds==0 %there is only GPS sats available
        [pos_xyz, vel_xyz_gps, cdtu_gps, az_actv_gps, el_actv_gps, iono_actv_gps, trop_actv_gps, bEsti_gps, psrCorr_gps, DOP, rankBreak] = ...
            leastSquarePos_GPS1(satpos_gps, ...
                                obs_gps, ...
                                transmitTime_gps, ...
                                ephemeris_para_gps, ...
                                activChn_raim_gps, ...
                                satClkCorr_gps, ...
                                pvtCalculator, ...
                                recv_timer, ...
                                pvtForecast_Succ, ...
                                el_gps, ...
                                az_gps, ...
                                iono_gps, ...
                                trop_gps, ...
                                CN0_gps);
        psrCorr = psrCorr_gps;
        psr = psr_bds(activChn_raim_gps(2,:));
        bEsti = bEsti_gps;
        vel_xyz = [vel_xyz_gps(1:3); pvtCalculator.clkErr(1,2); vel_xyz_gps(4)]; % For BDS clk drift, we keep it unchanged
        cdtu = [pvtCalculator.clkErrForecast(1); cdtu_gps]; % we use the predicted clkErr as cdtu of BDS
    else
    % Perform least-square pvt solution with raim integrity check
    % Return values of leastSquarePos_GPS1:
    % pos_xyz        - vector [3x1]
    % cdtu           - vector [2x1], e1 is for syst1, e2 is for syst2
    % az_actv        - vector [1 x nmbOfSat_inraim]
    % el_actv        - vector [1 x nmbOfSat_inraim]
    % iono_actv      - vector [1 x nmbOfSat_inraim]
    % trop_actv      - vector [1 x nmbOfSat_inraim]
    % bEsti          - vector [1 x (nmbOfSat_inraim_bds+nmbOfSat_inraim_gps)]
    % psrCorr        - vector [1 x (nmbOfSat_inraim_bds+nmbOfSat_inraim_gps)]
    [pos_xyz, vel_xyz, cdtu, ...
        az_actv_bds, az_actv_gps, el_actv_bds, el_actv_gps, iono_actv_bds, iono_actv_gps, trop_actv_bds, trop_actv_gps, ...
        bEsti, psrCorr, DOP,rankBreak] = ...
        leastSquarePos_JointBdsGps1(satpos_bds, satpos_gps, ...
                                    obs_bds, obs_gps, ...
                                    transmitTime_bds, transmitTime_gps, ...
                                    ephemeris_para_bds, ephemeris_para_gps, ...
                                    activChn_raim_bds, activChn_raim_gps, ...
                                    satClkCorr_bds, satClkCorr_gps, ...
                                    pvtCalculator, ...
                                    recv_timer, ...
                                    pvtForecast_Succ, ...
                                    el_bds, el_gps, ...
                                    az_bds, az_gps, ...
                                    iono_bds, iono_gps, ...
                                    trop_bds, trop_gps, ...
                                    CN0_bds, CN0_gps);
      psr = [psr_bds(activChn_raim_bds(2,:)), psr_gps(activChn_raim_gps(2,:))];
    end
    
    % Compute the pseudorange difference between the predicted psr and the
    % observed psr (with corrections)
    prError = 0;
    if pvtForecast_Succ
        prError = psrCorr - psr;
        prError = prError - median(prError);
    end
    
    if nmbOfSat_inraim>=6
        [raimPass, mxprErr_id] = resi_raim('B1I_L1CA', bEsti, prError, pvtForecast_Succ, nmbOfSat_inraim);
%         raimPass = 1; % for debugging
        if raimPass  % raim check pass! it can jump out the while loop
            inraim = 0;
            lspvt_raim_coder = 1; % case1 - 定位卫星数目大于5，且通过了RAIM校验
        else % raim check failed. Needs to adjust the activChn_raim chain and goto the loop again
            if mxprErr_id<=nmbOfSat_inraim_bds % BDS measurements are arranged before GPS'
                activChn_raim_bds = [activChn_raim_bds(:, 1:mxprErr_id-1), activChn_raim_bds(:, mxprErr_id+1:nmbOfSat_inraim_bds)];
                nmbOfSat_inraim_bds = nmbOfSat_inraim_bds - 1;
            else
                mxprErr_id_prime = mxprErr_id - nmbOfSat_inraim_bds;
                activChn_raim_gps = [activChn_raim_gps(:, 1:mxprErr_id_prime-1), activChn_raim_gps(:, mxprErr_id_prime+1:nmbOfSat_inraim_gps)];
                nmbOfSat_inraim_gps = nmbOfSat_inraim_gps -1;
            end
            nmbOfSat_inraim = nmbOfSat_inraim_bds + nmbOfSat_inraim_gps;
            
            NGEOFlag = 0;
            if nmbOfSat_inraim_gps
                NGEOFlag = 1;
            elseif nmbOfSat_inraim_bds
                NGEOFlag = sum(activChn_raim_bds(2,:)>5);
            end
        end %EOF "if raimPass"
        
    else % in the cas of nmbOfSat_inraim==4, it can not perform raim check
        if rankBreak
            inraim = 0;
            lspvt_raim_coder = 0;
        else
            if pvtForecast_Succ~=1 % 首次只有5颗卫星定位，且没有可信的历史位置数据作为参考
                inraim = 0;
                lspvt_raim_coder = 11; % case11 - 定位卫星数目=4，无预测位置信息，无法进行RAIM校验
            else % in the case of nmbOfSat_inraim==4, but we have predicted pseodorange info, so we still can do some checking
                maxPsrErr = max(abs(prError));
                if maxPsrErr < config.recvConfig.configPage.Pvt.pseudorangePreErrThre % meter
                    lspvt_raim_coder = 2; % case2 - 定位卫星数目=4，有预测位置信息且伪距校验通过
                else
                    lspvt_raim_coder = 10; %case10- 定位卫星数目=4，有预测位置信息,但是伪距校验未通过
                end
                inraim = 0;
            end %EOF "if pvtForecast_Succ~=1"
        end
        
    end %EOF "if nmbOfSat_inraim>=5"
end

% 根据pvt的不同情况进行更新策略
switch lspvt_raim_coder
    case 0 % sat_pvt_number < 5
        if pvtForecast_Succ % 存在历史预测值
%             pvtCalculator.posiLast = pvtCalculator.positionXYZ;
            pvtCalculator.positionXYZ = pvtCalculator.posForecast;
            % Get the LLH Coordinates
            [pvtCalculator.positionLLH(1), pvtCalculator.positionLLH(2), pvtCalculator.positionLLH(3)] = ...
                cart2geo( pvtCalculator.positionXYZ(1), pvtCalculator.positionXYZ(2), pvtCalculator.positionXYZ(3), 5 );
            pvtCalculator.positionValid = 1;
            pvtCalculator.posiCheck     = 2; %pvt solution is predicted one
            
            pvtCalculator.pvtSats(1).pvtS_Num   = 0; %no sats involved in pvt
            pvtCalculator.pvtSats(2).pvtS_Num   = 0; %no sats involved in pvt 
        else
            pvtCalculator.positionValid = -1;
            pvtCalculator.posiCheck     = 0; % there is no pvt solution
        end
        recv_timer = recvTimer_corr('B1I_L1CA', recv_timer, [0;0]);
        
    case 1 % sat_pvt_number>=6 & passing the raim checking
        pvtCalculator.positionXYZ = pos_xyz;
        pvtCalculator.posiLast = pos_xyz;
        % Get the LLH Coordinates
        [pvtCalculator.positionLLH(1), pvtCalculator.positionLLH(2), pvtCalculator.positionLLH(3)] = ...
            cart2geo( pvtCalculator.positionXYZ(1), pvtCalculator.positionXYZ(2), pvtCalculator.positionXYZ(3), 5 );
        pvtCalculator.positionVelocity = vel_xyz(1:3);
        pvtCalculator.positionDOP = DOP;
        pvtCalculator.clkErr(1,1) = cdtu(1);     % BDS: accumulated clk bias [meter]
%         pvtCalculator.clkErr(1,2) = pvtCalculator.clkErr(1,2) + vel_xyz(4);  % BDS: accumulated clk drift freq [Hz]
        pvtCalculator.clkErr(1,2) = vel_xyz(4);  % BDS: accumulated clk drift freq [Hz]
        pvtCalculator.clkErr(2,1) = cdtu(2);     % GPS: accumulated clk bias [meter]
%         pvtCalculator.clkErr(2,2) = pvtCalculator.clkErr(2,2) + vel_xyz(5);  % GPS: accumulated clk drift freq [Hz]
        pvtCalculator.clkErr(2,2) = vel_xyz(5);  % GPS: accumulated clk drift freq [Hz]
        % 更新定位标志信息
        pvtCalculator.positionValid = 1;
        pvtCalculator.posiCheck     = 1;% pvt solution is computed one with raim
        
        pvtCalculator.pvtSats(1).pvtS_Num  = nmbOfSat_inraim_bds;     %activChn_raim(2,:);
        if nmbOfSat_inraim_bds>0
            pvtCalculator.pvtSats(1).pvtS_prnList(1:nmbOfSat_inraim_bds) = activChn_raim_bds(2,1:nmbOfSat_inraim_bds);
        end
        pvtCalculator.pvtSats(2).pvtS_Num  = nmbOfSat_inraim_gps;     %activChn_raim(2,:);
        if nmbOfSat_inraim_gps>0
            pvtCalculator.pvtSats(2).pvtS_prnList(1:nmbOfSat_inraim_gps) = activChn_raim_gps(2, 1:nmbOfSat_inraim_gps);
        end
        
        % correct recv_timer system
        recv_timer.timeCheck = 1; % 时间系统一旦正确就认为不会再错
        if nmbOfSat_inraim_bds >0
            recv_timer.rclkErr2Syst_UpCnt(1) = 0; % reset the recv clkErr counter of BDS
        end
        if nmbOfSat_inraim_gps >0
            recv_timer.rclkErr2Syst_UpCnt(2) = 0; % reset the recv clkErr counter of GPS
        end
        recv_timer = recvTimer_corr('B1I_L1CA', recv_timer, cdtu/c);
        pvtCalculator.timeLast = recv_timer.recvSOW;
        
    case 2 % case2 - 定位卫星数目=5，有预测位置信息且伪距校验通过
        pvtCalculator.posiLast = pos_xyz;
        pvtCalculator.positionXYZ = pos_xyz;
        % Get the LLH Coordinates
        [pvtCalculator.positionLLH(1), pvtCalculator.positionLLH(2), pvtCalculator.positionLLH(3)] = ...
            cart2geo( pvtCalculator.positionXYZ(1), pvtCalculator.positionXYZ(2), pvtCalculator.positionXYZ(3), 5 );
        pvtCalculator.positionVelocity = vel_xyz(1:3);
        pvtCalculator.positionDOP = DOP;
        pvtCalculator.clkErr(1,1) = cdtu(1);     % BDS: accumulated clk bias [meter]
%         pvtCalculator.clkErr(1,2) = pvtCalculator.clkErr(1,2) + vel_xyz(4);  % BDS: accumulated clk drift freq [Hz]
        pvtCalculator.clkErr(1,2) = vel_xyz(4);  % BDS: accumulated clk drift freq [Hz]
        pvtCalculator.clkErr(2,1) = cdtu(2);     % GPS: accumulated clk bias [meter]
%         pvtCalculator.clkErr(2,2) = pvtCalculator.clkErr(2,2) + vel_xyz(5);  % GPS: accumulated clk drift freq [Hz]
        pvtCalculator.clkErr(2,2) = vel_xyz(5);  % GPS: accumulated clk drift freq [Hz]
        
        pvtCalculator.positionValid = 1;
        pvtCalculator.posiCheck     = 1;% pvt solution is computed one with pseudorange checking
        
        pvtCalculator.pvtSats(1).pvtS_Num  = nmbOfSat_inraim_bds;     %activChn_raim(2,:);
        if nmbOfSat_inraim_bds>0
            pvtCalculator.pvtSats(1).pvtS_prnList(1:nmbOfSat_inraim_bds) = activChn_raim_bds(2,1:nmbOfSat_inraim_bds);
        end
        pvtCalculator.pvtSats(2).pvtS_Num  = nmbOfSat_inraim_gps;     %activChn_raim(2,:);
        if nmbOfSat_inraim_gps>0
            pvtCalculator.pvtSats(2).pvtS_prnList(1:nmbOfSat_inraim_gps) = activChn_raim_gps(2, 1:nmbOfSat_inraim_gps);
        end
        % correct recv_timer system
        recv_timer = recvTimer_corr('B1I_L1CA', recv_timer, cdtu/c);
        if nmbOfSat_inraim_bds >0
            recv_timer.rclkErr2Syst_UpCnt(1) = 0; % reset the recv clkErr counter of BDS
        end
        if nmbOfSat_inraim_gps >0
            recv_timer.rclkErr2Syst_UpCnt(2) = 0; % reset the recv clkErr counter of GPS
        end
        pvtCalculator.timeLast = recv_timer.recvSOW;
        
    case 10 % case10- 定位卫星数目=5，有预测位置信息,但是伪距校验未通过
%         pvtCalculator.posiLast = pvtCalculator.positionXYZ;
        pvtCalculator.positionXYZ = pvtCalculator.posForecast;
        % Get the LLH Coordinates
        [pvtCalculator.positionLLH(1), pvtCalculator.positionLLH(2), pvtCalculator.positionLLH(3)] = ...
            cart2geo( pvtCalculator.positionXYZ(1), pvtCalculator.positionXYZ(2), pvtCalculator.positionXYZ(3), 5 );
        pvtCalculator.positionValid = 1;
        pvtCalculator.posiCheck     = 2;%pvt solution is predicted one
        pvtCalculator.pvtSats(1).pvtS_Num   = 0; %no sats involved in pvt
        pvtCalculator.pvtSats(2).pvtS_Num   = 0; %no sats involved in pvt
        recv_timer = recvTimer_corr('B1I_L1CA', recv_timer, [0;0]);
        
    case 11 % sat_pvt_number==5 & pvtForecast_Succ==0 & cannot do raim checking
        
        pvtCalculator.positionXYZ = pos_xyz;
        % Get the LLH Coordinates
        [pvtCalculator.positionLLH(1), pvtCalculator.positionLLH(2), pvtCalculator.positionLLH(3)] = ...
            cart2geo( pvtCalculator.positionXYZ(1), pvtCalculator.positionXYZ(2), pvtCalculator.positionXYZ(3), 5 );
        pvtCalculator.positionDOP = DOP;
        pvtCalculator.positionVelocity = vel_xyz(1:3);
        % 更新定位标志信息
        if (DOP(1)<25) && (pvtCalculator.positionLLH(3)>-100) && (pvtCalculator.positionLLH(3)<500)
            pvtCalculator.positionValid = 1;
        else
            pvtCalculator.positionValid = 0;
        end
        pvtCalculator.posiCheck     = 0;%pvt solution is computed but no raim checking
        
        pvtCalculator.pvtSats(1).pvtS_Num  = nmbOfSat_inraim_bds;     %activChn_raim(2,:);
        if nmbOfSat_inraim_bds>0
            pvtCalculator.pvtSats(1).pvtS_prnList(1:nmbOfSat_inraim_bds) = activChn_raim_bds(2,1:nmbOfSat_inraim_bds);
        end
        pvtCalculator.pvtSats(2).pvtS_Num  = nmbOfSat_inraim_gps;     %activChn_raim(2,:);
        if nmbOfSat_inraim_gps>0
            pvtCalculator.pvtSats(2).pvtS_prnList(1:nmbOfSat_inraim_gps) = activChn_raim_gps(2, 1:nmbOfSat_inraim_gps);
        end
        if recv_timer.timeCheck == -1
            recv_timer.timeCheck = 0;
        end
        recv_timer = recvTimer_corr('B1I_L1CA', recv_timer, [0;0]);
        
        
    otherwise
        error('lsPVT_resiraim_JointBdsGps(): Illegal lspvt_raim_coder value');
end

% save log information
% pvtCalculator.logOutput.GPSraimChn = activChn_raim;
pvtCalculator.pvtReadySats(1).pvtS_Num = nmbOfSatellites_bds;
pvtCalculator.pvtReadySats(1).pvtS_prnList(1:nmbOfSatellites_bds) = activeChannel_BDS(2,1:nmbOfSatellites_bds);
pvtCalculator.pvtReadySats(2).pvtS_Num = nmbOfSatellites_gps;
pvtCalculator.pvtReadySats(2).pvtS_prnList(1:nmbOfSatellites_gps) = activeChannel_GPS(2,1:nmbOfSatellites_gps);


            
            