function [pvtCalculator, recv_timer, satelliteTable] = ...
    kalmanPVT_resiraim_GPS(satpos, satpos_ref,obs, obs_ref,transmitTime,transmitTime_ref, satClkCorr,satClkCorr_ref, CN0, CN0_ref, ...
                       config, channels, activeChannel_GPS, satelliteTable, ephemeris_para, recv_timer, pvtCalculator,pvtCalculator_ref, parameter,loop,pvtForecast_Succ,IMU_MEMS)
% satpos              - matrix[6x32], each column for a sat [x;y;z;vx;vy;vz]
% obs                 - vector[1x32], each for a sat pseudorange [meter]
% transmitTime        - vector[1x32], each for a sat transmit time [sec]
% satClkCorr          - matrix[2x32], each colum for a sat [clk_dt; clk_df]
% config              - receiver config struct
% channels            - receiver channel list, [nx1:channel]
% activeChannel_GPS   - matrix[2xNum], row1 for channel ID list; row2 for
%                       prn list; Num for number of active channels
% satelliteTable      - 
% ephemeris_para      - ephemeris.para struct for GPS, [1x32 struct]
% recv_timer          - receiver local timer
% pvtCalculator       - PVT struct
% pvtForecast_Succ    - forcast PVT solution is avaible: 1 - valid; 0 - invalid
basestation= [ -2853445.926; 4667466.476; 3268291.272];
elevationMask = config.recvConfig.elevationMask;
nmbOfSatellites = size(activeChannel_GPS, 2);
el = zeros(1,32);
az = zeros(1,32);
iono = zeros(1,32);
trop = zeros(1,32);
psr =  zeros(1,32);
c = 2.99792458e8;
% chi-square threshold with n freedom and alpha confidence
% chi2inv_Table = [19.5, 23.0, 25.9, 28.5, 30.9, 33.1, 35.3, 37.33, 39.34, 41.3, 43.21, 45.1, 46.91, 48.72, 50.49, 52.25, 53.97, 55.68];
satWarningNum = 0;

refPos = [-2850197.286; 4655185.885; 3288382.972];  % 静态点
[el, az, iono, trop, psr, satelliteTable] = ...
        sats_el_az_psr_predict_GPS(satpos, activeChannel_GPS, refPos, satelliteTable, ephemeris_para, recv_timer);

if pvtForecast_Succ
    % there is a trustable last PVT solution, so we can compute the 
    % predicted satellite elevation and azimuth. 
    % And the predicted pseudorange.
%     [el, az, iono, trop, psr, satelliteTable] = ...
%         sats_el_az_psr_predict_GPS(satpos, activeChannel_GPS, pvtCalculator.posForecast, satelliteTable, ephemeris_para, recv_timer);
    
    if recv_timer.rclkErr2Syst_UpCnt(2) < recv_timer.rclkErr2Syst_Thre % _UpCnt(2) is clkErr to GPS syst
        [satWarningNum, satWarning_list] = satpreSelect_historyPvtraim(...
            activeChannel_GPS, ...
            psr, ...
            obs, ...
            iono, ...
            trop, ...
            satClkCorr, ...
            pvtCalculator.clkErrForecast(2), ...% predicted recv2GPS clk error
            config);
    end
end

activChn_raim = activeChannel_GPS;
for n=1:satWarningNum
    warning_prn = satWarning_list(2,n);
    idx = find(activChn_raim(2,:)==warning_prn, 1);
    activChn_raim(:,idx) = [];
end
nmbOfSat_inraim = size(activChn_raim, 2);
inraim = 1;
lspvt_raim_coder = 0;
rankBreak = 0;

while (nmbOfSat_inraim>=4) && (inraim == 1)
    if pvtCalculator.kalman.preTag == 0 % The Kalman filter hasn't been initialized!
    % Perform least-square pvt solution with raim integrity check
    % Return values of leastSquarePos_GPS1:
    % pos_xyz        - vector [3x1]
    % vel_xyz        - vector [4x1], vel_xyz(4) is clk drift, [Hz]
    % cdtu           - scalar
    % az_actv        - vector [1 x nmbOfSat_inraim]
    % el_actv        - vector [1 x nmbOfSat_inraim]
    % iono_actv      - vector [1 x nmbOfSat_inraim]
    % trop_actv      - vector [1 x nmbOfSat_inraim]
    % bEsti          - vector [1 x nmbOfSat_inraim]
    % psrCorr        - vector [1 x nmbOfSat_inraim]
        [pos_xyz, vel_xyz, cdtu_delta, az_actv, el_actv, iono_actv, trop_actv, bEsti, psrCorr, DOP, rankBreak] = ...
            leastSquarePos_GPS_DD(satpos,satpos_ref, obs,obs_ref,  transmitTime, transmitTime_ref, ephemeris_para, activChn_raim, satClkCorr,satClkCorr_ref,  pvtCalculator, pvtCalculator_ref,recv_timer, pvtForecast_Succ, el, az, iono, trop, CN0,CN0_ref);%这个posxyz实际上是bur,包括速度和cdtu
%         [pos_xyz, vel_xyz, cdtu_delta, az_actv, el_actv, iono_actv, trop_actv, bEsti, psrCorr, DOP, rankBreak] = ...
%             leastSquarePos_GPS1(satpos,satpos_ref, obs,obs_ref,  transmitTime, transmitTime_ref, ephemeris_para, activChn_raim, satClkCorr,satClkCorr_ref,  pvtCalculator, pvtCalculator_ref,recv_timer, pvtForecast_Succ, el, az, iono, trop, CN0,CN0_ref);%这个posxyz实际上是bur,包括速度和cdtu
%  
    else
        [pos_xyz, vel_xyz, cdtu_delta, az_actv, el_actv, iono_actv, trop_actv, bEsti, psrCorr, DOP, KalFilt_tmp] = ...
            kalmanPos_GPS1(satpos, satpos_ref,obs,obs_ref, transmitTime, activChn_raim, satClkCorr,satClkCorr_ref, pvtCalculator,pvtCalculator_ref, pvtForecast_Succ, el, az, iono, trop, CN0,IMU_MEMS);  %这个posxyz实际上是bur
    end
    
    % Compute the pseudorange difference between the predicted psr and the
    % observed psr (with corrections)
    prError = 0;
    if pvtForecast_Succ
        prError = psrCorr - psr(activChn_raim(2,:));
        prError = prError - median(prError);
    end
    
    if nmbOfSat_inraim>=5
        [raimPass, mxprErr_id ] = resi_raim('GPS_L1CA', bEsti, prError, pvtForecast_Succ, activChn_raim);
        
        if raimPass  % raim check pass! it can jump out the while loop
            inraim = 0;
            lspvt_raim_coder = 1; % case1 - 定位卫星数目大于4，且通过了RAIM校验
        else % raim check failed. Needs to adjust the activChn_raim chain and goto the loop again
            activChn_raim = [activChn_raim(:, 1:mxprErr_id-1), activChn_raim(:, mxprErr_id+1:nmbOfSat_inraim)];
            nmbOfSat_inraim = nmbOfSat_inraim - 1;
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
        end %  EOF : rankBreak
        
    end %EOF "if nmbOfSat_inraim>=5"
end

% 根据pvt的不同情况进行更新策略
switch lspvt_raim_coder
    case 0 % sat_pvt_number < 4
        if pvtForecast_Succ % 存在历史预测值   
            pvtCalculator.positionXYZ = pvtCalculator.posForecast+basestation;
            % Get the LLH Coordinates
            [pvtCalculator.positionLLH(1), pvtCalculator.positionLLH(2), pvtCalculator.positionLLH(3)] = ...
                cart2geo( pvtCalculator.positionXYZ(1), pvtCalculator.positionXYZ(2), pvtCalculator.positionXYZ(3), 5 );
            pvtCalculator.positionValid = 1;
            pvtCalculator.posiCheck     = 2; %pvt solution is predicted one
            pvtCalculator.pvtSats(2).pvtS_Num = 0; %no sats involved in pvt
        else
            pvtCalculator.positionValid = -1;
            pvtCalculator.posiCheck     = 0; % there is no pvt solution
        end
        recv_timer = recvTimer_corr('GPS_L1CA', recv_timer, 0);
        
    case 1 % sat_pvt_number>=5 & passing the raim checking
        pvtCalculator.positionXYZ = pos_xyz+basestation;
        pvtCalculator.posiLast = pos_xyz+basestation;
        % Get the LLH Coordinates
        [pvtCalculator.positionLLH(1), pvtCalculator.positionLLH(2), pvtCalculator.positionLLH(3)] = ...
            cart2geo( pvtCalculator.positionXYZ(1), pvtCalculator.positionXYZ(2), pvtCalculator.positionXYZ(3), 5 );
        pvtCalculator.positionVelocity = vel_xyz(1:3);
        pvtCalculator.positionAccelaration = [parameter(2).IMU_ax(loop),parameter(2).IMU_ay(loop),parameter(2).IMU_az(loop)];
        pvtCalculator.positionDOP = DOP;
        pvtCalculator.clkErr(2,1) = cdtu_delta;        % accumulated clk bias [meter]
%         pvtCalculator.clkErr(2,2) = pvtCalculator.clkErr(2,2) + vel_xyz(4);  % accumulated clk drift freq [Hz]
%         pvtCalculator.clkErr(2,2) = vel_xyz(4);
        pvtCalculator.clkErr(2,2) = 0;
        % 更新定位标志信息
        pvtCalculator.positionValid = 1;
        pvtCalculator.posiCheck     = 1;
        pvtCalculator.pvtSats(2).pvtS_Num = nmbOfSat_inraim;
        if nmbOfSat_inraim>0
            pvtCalculator.pvtSats(2).pvtS_prnList(1:nmbOfSat_inraim) = activChn_raim(2, 1:nmbOfSat_inraim);
        end
        
        % correct recv_timer system
        recv_timer = recvTimer_corr('GPS_L1CA', recv_timer, cdtu_delta/c);
        recv_timer.timeCheck = 1;  % 时间系统一旦正确就认为不会再错
        recv_timer.rclkErr2Syst_UpCnt(2) = 0; % reset the recv clkErr counter of GPS
        pvtCalculator.timeLast = recv_timer.recvSOW;
        
        % Update the check-passed KalFilt_tmp into pvtCalculator
        switch pvtCalculator.kalman.preTag
            case 0 % The Kalman filter has not been initialized
                if recv_timer.rclkErr2Syst_UpCnt(2) == 0
                    pvtCalculator.kalman.preTag = 2; % Kalman filter is ready for being initialized
                end
            case 1
                pvtCalculator.kalman = KalFilt_tmp;
%                 pvtCalculator.kalman.stt_dtf(1,2) = 0; % % local clk error has been corrected in recv_timer
        end
        
        
    case 2 % case2 - 定位卫星数目=4，有预测位置信息且伪距校验通过
        pvtCalculator.posiLast = pos_xyz+basestation;
        pvtCalculator.positionXYZ = pos_xyz+basestation;
        % Get the LLH Coordinates
        [pvtCalculator.positionLLH(1), pvtCalculator.positionLLH(2), pvtCalculator.positionLLH(3)] = ...
            cart2geo( pvtCalculator.positionXYZ(1), pvtCalculator.positionXYZ(2), pvtCalculator.positionXYZ(3), 5 );
        pvtCalculator.positionVelocity = vel_xyz(1:3);
        pvtCalculator.positionAccelaration = [parameter(2).IMU_ax(loop),parameter(2).IMU_ay(loop),parameter(2).IMU_az(loop)];
        pvtCalculator.positionDOP = DOP;
        pvtCalculator.clkErr(2,1) = cdtu_delta;        % accumulated clk bias [meter]
%         pvtCalculator.clkErr(2,2) = pvtCalculator.clkErr(2,2) + vel_xyz(4);  % accumulated clk drift freq [Hz]
        pvtCalculator.clkErr(2,2) = 0;
        pvtCalculator.positionValid = 1;
        pvtCalculator.posiCheck     = 1;% pvt solution is computed one with pseudorange checking
        pvtCalculator.pvtSats(2).pvtS_Num = nmbOfSat_inraim;
        if nmbOfSat_inraim>0
            pvtCalculator.pvtSats(2).pvtS_prnList(1:nmbOfSat_inraim) = activChn_raim(2, 1:nmbOfSat_inraim);
        end
        % correct recv_timer system
        recv_timer = recvTimer_corr('GPS_L1CA', recv_timer, cdtu_delta/c);
        recv_timer.rclkErr2Syst_UpCnt(2) = 0; % reset the recv clkErr counter of GPS
        pvtCalculator.timeLast = recv_timer.recvSOW;
        % Update the check-passed KalFilt_tmp into pvtCalculator
        if pvtCalculator.kalman.preTag == 1 % Kalman filter positioning mode
            pvtCalculator.kalman = KalFilt_tmp;
%             pvtCalculator.kalman.stt_dtf(1,2) = 0; % local clk error has been corrected in recv_timer
        end
        
    case 10 % case10- 定位卫星数目=4，有预测位置信息,但是伪距校验未通过
        pvtCalculator.positionXYZ = pvtCalculator.posForecast;
        % Get the LLH Coordinates
        [pvtCalculator.positionLLH(1), pvtCalculator.positionLLH(2), pvtCalculator.positionLLH(3)] = ...
            cart2geo( pvtCalculator.positionXYZ(1), pvtCalculator.positionXYZ(2), pvtCalculator.positionXYZ(3), 5 );
        pvtCalculator.positionValid = 1;
        pvtCalculator.posiCheck     = 2;%pvt solution is predicted one
        pvtCalculator.pvtSats(2).pvtS_Num = 0;
        recv_timer = recvTimer_corr('GPS_L1CA', recv_timer, 0);
        
    case 11 % sat_pvt_number==4 & pvtForecast_Succ==0 & cannot do raim checking
%         pvtCalculator.posiLast = pvtCalculator.positionXYZ;
        pvtCalculator.positionXYZ = pos_xyz+basestation;
        pvtCalculator.positionVelocity = vel_xyz(1:3); % [vx; vy; vz; cdf(Hz)]
        pvtCalculator.positionAccelaration = [parameter(2).IMU_ax(loop),parameter(2).IMU_ay(loop),parameter(2).IMU_az(loop)];
        % Get the LLH Coordinates
        [pvtCalculator.positionLLH(1), pvtCalculator.positionLLH(2), pvtCalculator.positionLLH(3)] = ...
            cart2geo( pvtCalculator.positionXYZ(1), pvtCalculator.positionXYZ(2), pvtCalculator.positionXYZ(3), 5 );
        pvtCalculator.positionDOP = DOP;
        % 更新定位标志信息
        if (DOP(1)<25) && (pvtCalculator.positionLLH(3)>-100) && (pvtCalculator.positionLLH(3)<500)
            pvtCalculator.positionValid = 1;
        else
            pvtCalculator.positionValid = 0;
        end
        pvtCalculator.posiCheck     = 0;%pvt solution is computed but no raim checking
        pvtCalculator.pvtSats(2).pvtS_Num = nmbOfSat_inraim;
        if nmbOfSat_inraim>0
            pvtCalculator.pvtSats(2).pvtS_prnList(1:nmbOfSat_inraim) = activChn_raim(2, 1:nmbOfSat_inraim);
        end
        if recv_timer.timeCheck == -1
            recv_timer.timeCheck = 0;
        end
        recv_timer = recvTimer_corr('GPS_L1CA', recv_timer, 0);
        
    otherwise
        error('kalmanPVT_resiraim_GPS(): Illegal lspvt_raim_coder value');
end
% save log information
pvtCalculator.pvtReadySats(2).pvtS_Num = nmbOfSatellites;
pvtCalculator.pvtReadySats(2).pvtS_prnList(1:nmbOfSatellites) = activeChannel_GPS(2,1:nmbOfSatellites);
% For BDS
pvtCalculator.pvtSats(1).pvtS_Num = 0;
pvtCalculator.pvtReadySats(1).pvtS_Num = 0;


