function [pvtCalculator, recv_timer, satelliteTable] = ...
    lsPVT_resiraim_BDS(satpos, obs, transmitTime, satClkCorr, CN0_bds, ...
                       config, activeChannel_BDS, satelliteTable, ephemeris_para, recv_timer, pvtCalculator, pvtForecast_Succ)
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
elevationMask = config.recvConfig.elevationMask;
nmbOfSatellites = size(activeChannel_BDS, 2);
el = zeros(1,BDS_maxPrnNo);
az = zeros(1,BDS_maxPrnNo);
iono = zeros(1,BDS_maxPrnNo);
trop = zeros(1,BDS_maxPrnNo);
psr =  zeros(1,BDS_maxPrnNo);
c = 2.99792458e8;
% chi-square threshold with n freedom and alpha confidence
% chi2inv_Table = [19.5, 23.0, 25.9, 28.5, 30.9, 33.1, 35.3, 37.33, 39.34, 41.3, 43.21, 45.1, 46.91, 48.72, 50.49, 52.25, 53.97, 55.68];

refPos = [-2850197.286; 4655185.885; 3288382.972];  % 静态点
[el, az, iono, trop, psr, satelliteTable] = ...
    sats_el_az_psr_predict_BDS(satpos, activeChannel_BDS, refPos, satelliteTable, ephemeris_para, recv_timer);

satWarningNum = 0;
if pvtForecast_Succ 
    % there is a trustable last PVT solution, so we can compute the 
    % predicted satellite elevation and azimuth. 
    % And the predicted pseudorange.
%     [el, az, iono, trop, psr, satelliteTable] = ...
%         sats_el_az_psr_predict_BDS(satpos, activeChannel_BDS, pvtCalculator.posForecast, satelliteTable, ephemeris_para, recv_timer);
    
    % when the avaible history pos info is trustable, the pre-raim by using
    % history positions are applied.
    if recv_timer.rclkErr2Syst_UpCnt(1) < recv_timer.rclkErr2Syst_Thre % (1) is clkErr to BDS syst
        [satWarningNum, satWarning_list] = satpreSelect_historyPvtraim(...
                         activeChannel_BDS, ...
                         psr, ...
                         obs, ...
                         iono, ...
                         trop, ...
                         satClkCorr, ...
                         pvtCalculator.clkErrForecast(1), ...% predicted recv2BDS clk error 
                         config);
    end
end

activChn_raim = activeChannel_BDS;
for n=1:satWarningNum
    warning_prn = satWarning_list(2,n);
    idx = find(activChn_raim(2,:)==warning_prn, 1);
    activChn_raim(:,idx) = [];
end
nmbOfSat_inraim = size(activChn_raim, 2);

inraim = 1;
lspvt_raim_coder = 0;
NGEOFlag = sum(activChn_raim(2,:)>5);

while (nmbOfSat_inraim>=4) && (inraim == 1) && NGEOFlag
    % Perform least-square pvt solution with raim integrity check
    % Return values of leastSquarePos_GPS1:
    % pos_xyz        - vector [3x1]
    % cdtu           - scalar
    % az_actv        - vector [1 x nmbOfSat_inraim]
    % el_actv        - vector [1 x nmbOfSat_inraim]
    % iono_actv      - vector [1 x nmbOfSat_inraim]
    % trop_actv      - vector [1 x nmbOfSat_inraim]
    % bEsti          - vector [1 x nmbOfSat_inraim]
    % psrCorr        - vector [1 x nmbOfSat_inraim]
    [pos_xyz, vel_xyz, cdtu, az_actv, el_actv, iono_actv, trop_actv, bEsti, psrCorr, DOP, rankBreak] = ...
        leastSquarePos_BDS1(satpos, obs, transmitTime, ephemeris_para, activChn_raim, satClkCorr, pvtCalculator, recv_timer, pvtForecast_Succ, el, az, iono, trop, CN0_bds);
    
    % Compute the pseudorange difference between the predicted psr and the
    % observed psr (with corrections)
    prError = 0;
    if pvtForecast_Succ
        prError = psrCorr - psr(activChn_raim(2,:));
        prError = prError - median(prError);
    end
    
    if nmbOfSat_inraim>=5
        [raimPass, mxprErr_id] = resi_raim('BDS_B1I', bEsti, prError, pvtForecast_Succ, activChn_raim);
%         raimPass = 1; % for debugging
        if raimPass  % raim check pass! it can jump out the while loop
            inraim = 0;
            lspvt_raim_coder = 1; % case1 - 定位卫星数目大于4，且通过了RAIM校验
        else % raim check failed. Needs to adjust the activChn_raim chain and goto the loop again
            activChn_raim = [activChn_raim(:, 1:mxprErr_id-1), activChn_raim(:, mxprErr_id+1:nmbOfSat_inraim)];
            nmbOfSat_inraim = nmbOfSat_inraim - 1;
            NGEOFlag = sum(activChn_raim(2,:)>5);
        end %EOF "if raimPass"
        
    else % in the cas of nmbOfSat_inraim==4, it can not perform raim check
        if rankBreak
            inraim = 0;
            lspvt_raim_coder = 0;
        else
            if pvtForecast_Succ~=1 % 首次只有4颗卫星定位，且没有可信的历史位置数据作为参考
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
        end % EOF : if rankBreak
        
    end %EOF "if nmbOfSat_inraim>=5"
end %EOF "while (nmbOfSat_inraim>=4) && (inraim == 1) && NGEOFlag"

% 根据pvt的不同情况进行更新策略
switch lspvt_raim_coder
    case 0 % sat_pvt_number < 4
        if pvtForecast_Succ % 存在历史预测值
            pvtCalculator.positionXYZ = pvtCalculator.posForecast;
            % Get the LLH Coordinates
            [pvtCalculator.positionLLH(1), pvtCalculator.positionLLH(2), pvtCalculator.positionLLH(3)] = ...
                cart2geo( pvtCalculator.positionXYZ(1), pvtCalculator.positionXYZ(2), pvtCalculator.positionXYZ(3), 5 );
            pvtCalculator.positionValid = 1;
            pvtCalculator.posiCheck     = 2; %pvt solution is predicted one
            pvtCalculator.pvtSats(1).pvtS_Num  = 0; %no sats involved in pvt
        else
            pvtCalculator.positionValid = -1;
            pvtCalculator.posiCheck     = 0; % there is no pvt solution
        end
        recv_timer = recvTimer_corr('BDS_B1I', recv_timer, 0);
        
    case 1 % sat_pvt_number>=5 & passing the raim checking
        pvtCalculator.positionXYZ = pos_xyz;
        pvtCalculator.posiLast = pos_xyz;
        % Get the LLH Coordinates
        [pvtCalculator.positionLLH(1), pvtCalculator.positionLLH(2), pvtCalculator.positionLLH(3)] = ...
            cart2geo( pvtCalculator.positionXYZ(1), pvtCalculator.positionXYZ(2), pvtCalculator.positionXYZ(3), 5 );
        pvtCalculator.positionVelocity = vel_xyz(1:3);
        pvtCalculator.positionDOP = DOP;
        pvtCalculator.clkErr(1,1) = cdtu;        % accumulated clk bias [meter]
%         pvtCalculator.clkErr(1,2) = pvtCalculator.clkErr(1,2) + vel_xyz(4);  % accumulated clk drift freq [Hz]
        pvtCalculator.clkErr(1,2) = vel_xyz(4);
        % 更新定位标志信息
        pvtCalculator.positionValid = 1;
        pvtCalculator.posiCheck     = 1;% pvt solution is computed one with raim  
        pvtCalculator.pvtSats(1).pvtS_Num = nmbOfSat_inraim;
        if nmbOfSat_inraim>0
            pvtCalculator.pvtSats(1).pvtS_prnList(1:nmbOfSat_inraim) = activChn_raim(2, 1:nmbOfSat_inraim);
        end
        % correct recv_timer system
        recv_timer = recvTimer_corr('BDS_B1I', recv_timer, cdtu/c);
        recv_timer.timeCheck = 1; % 时间系统一旦正确就认为不会再错
        recv_timer.rclkErr2Syst_UpCnt(1) = 0; % reset the recv clkErr counter
        pvtCalculator.timeLast = recv_timer.recvSOW;
        
    case 2 % case2 - 定位卫星数目=4，有预测位置信息且伪距校验通过
        pvtCalculator.posiLast = pos_xyz;
        pvtCalculator.positionXYZ = pos_xyz;
        % Get the LLH Coordinates
        [pvtCalculator.positionLLH(1), pvtCalculator.positionLLH(2), pvtCalculator.positionLLH(3)] = ...
            cart2geo( pvtCalculator.positionXYZ(1), pvtCalculator.positionXYZ(2), pvtCalculator.positionXYZ(3), 5 );
        pvtCalculator.positionVelocity = vel_xyz(1:3);
        pvtCalculator.positionDOP = DOP;
        pvtCalculator.clkErr(1,1) = cdtu;        % accumulated clk bias [meter]
%         pvtCalculator.clkErr(1,2) = pvtCalculator.clkErr(1,2) + vel_xyz(4);  % accumulated clk drift freq [Hz]
        pvtCalculator.clkErr(1,2) = vel_xyz(4);
        
        pvtCalculator.positionValid = 1;
        pvtCalculator.posiCheck     = 1;% pvt solution is computed one with pseudorange checking
        pvtCalculator.pvtSats(1).pvtS_Num = nmbOfSat_inraim;
        if nmbOfSat_inraim>0
            pvtCalculator.pvtSats(1).pvtS_prnList(1:nmbOfSat_inraim) = activChn_raim(2, 1:nmbOfSat_inraim);
        end
        % correct recv_timer system
        recv_timer = recvTimer_corr('BDS_B1I', recv_timer, cdtu/c);
        recv_timer.rclkErr2Syst_UpCnt(1) = 0; % reset the recv clkErr counter
        pvtCalculator.timeLast = recv_timer.recvSOW;
        
    case 10 % case10- 定位卫星数目=4，有预测位置信息,但是伪距校验未通过
        pvtCalculator.positionXYZ = pvtCalculator.posForecast;
        % Get the LLH Coordinates
        [pvtCalculator.positionLLH(1), pvtCalculator.positionLLH(2), pvtCalculator.positionLLH(3)] = ...
            cart2geo( pvtCalculator.positionXYZ(1), pvtCalculator.positionXYZ(2), pvtCalculator.positionXYZ(3), 5 );
        pvtCalculator.positionValid = 1;
        pvtCalculator.posiCheck     = 2;%pvt solution is predicted one
        pvtCalculator.pvtSats(1).pvtS_Num = 0;
        recv_timer = recvTimer_corr('BDS_B1I', recv_timer, 0);
        
    case 11 % sat_pvt_number==4 & pvtForecast_Succ==0 & cannot do raim checking
        
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
        pvtCalculator.pvtSats(1).pvtS_Num = nmbOfSat_inraim;
        if nmbOfSat_inraim>0
            pvtCalculator.pvtSats(1).pvtS_prnList(1:nmbOfSat_inraim) = activChn_raim(2, 1:nmbOfSat_inraim);
        end
        if recv_timer.timeCheck == -1
            recv_timer.timeCheck = 0;
        end
        recv_timer = recvTimer_corr('BDS_B1I', recv_timer, 0);
        
        
    otherwise
        error('lsPVT_resiraim_BDS(): Illegal lspvt_raim_coder value');
end

% save log information
% pvtCalculator.logOutput.GPSraimChn = activChn_raim;
pvtCalculator.pvtReadySats(1).pvtS_Num = nmbOfSatellites;
pvtCalculator.pvtReadySats(1).pvtS_prnList(1:nmbOfSatellites) = activeChannel_BDS(2,1:nmbOfSatellites);

% For GPS
pvtCalculator.pvtSats(2).pvtS_Num = 0;
pvtCalculator.pvtReadySats(2).pvtS_Num = 0;


            