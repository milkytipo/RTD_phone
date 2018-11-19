function [pvtCalculator, recv_timer, satelliteTable_bds, satelliteTable_gps] = mmPVT_stdraim_JoinGpsBds_v1 (...
                                            satpos_bds, satpos_gps, obs_bds, obs_gps, transmitTime_bds, transmitTime_gps, satClkCorr_bds, satClkCorr_gps,...
                                            cn0_bds, cn0_gps, config, activeChannel_BDS, activeChannel_GPS, satelliteTable_bds, satelliteTable_gps, ephemeris_para_bds,...
                                            ephemeris_para_gps, recv_timer, pvtCalculator, pvtForecast_Succ)
                                        
                                        
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

% for best position selection
mmPvtEstmts = initiaizeCheckParamPVT();

BDS_maxPrnNo = config.recvConfig.configPage.systConfig.BDS_B1I.maxPrnNo;
GPS_maxPrnNo = config.recvConfig.configPage.systConfig.GPS_L1CA.maxPrnNo;
elevationMask = config.recvConfig.elevationMask;

% check number of active satellites of BDS and GPS

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

satWarningNum_bds = 0;
satWarningNum_gps = 0;

if pvtForecast_Succ 
    
    % there is a trustable last PVT solution, so we can compute the 
    % predicted satellite elevation and azimuth. 
    % And the predicted pseudorange.
    [el_bds, az_bds, iono_bds, trop_bds, psr_bds, satelliteTable_bds] = ...
        sats_el_az_psr_predict_BDS(satpos_bds, activeChannel_BDS, pvtCalculator.posForecast, satelliteTable_bds, ephemeris_para_bds, recv_timer);
    % when the avaible history pos info is trustable, the pre-raim by using
    % history positions are applied.
    
    if recv_timer.rclkErr2Syst_UpCnt(1) < recv_timer.rclkErr2Syst_Thre % _UpCnt(1) is clkErr to BDS syst
        [satWarningNum_bds, satWarning_list_bds] = satpreSelect_historyPvtraim(...
                         activeChannel_BDS, ...
                         psr_bds, ...
                         obs_bds, ...
                         iono_bds, ...
                         trop_bds, ...
                         satClkCorr_bds);
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
                         satClkCorr_gps);
    end
end

activChn_raim_bds = activeChannel_BDS;
nmbOfSat_inraim_bds = size(activChn_raim_bds, 2);
%==========================================================================
% this part of code decides which possible satellites have errors so to
% remove them from estimation. However it is commented to increase
% redundancy
% for n=1:satWarningNum_bds
%     warning_prn_bds = satWarning_list_bds(2,n);
%     idx = find(activChn_raim_bds(2,:)==warning_prn_bds, 1);
%     activChn_raim_bds(:,idx) = [];
% end
%==========================================================================


activChn_raim_gps = activeChannel_GPS;
nmbOfSat_inraim_gps = size(activChn_raim_gps, 2);
%==========================================================================
% this part of code decides which possible satellites have errors so to
% remove them from estimation. However it is commented to increase
% redundancy
% for n=1:satWarningNum_gps
%     warning_prn_gps = satWarning_list_gps(2,n);
%     idx = find(activChn_raim_gps(2,:)==warning_prn_gps, 1);
%     activChn_raim_gps(:,idx) = [];
% end
%==========================================================================
% total number of available satellites
nmbOfSat_inraim = nmbOfSat_inraim_bds + nmbOfSat_inraim_gps;
if nmbOfSat_inraim < 5
    return;
end
inraim = 1;
mmpvt_raim_coder = 0;
mmpvt_coder = 0;
NGEOFlag = 0;
if nmbOfSat_inraim_gps
    NGEOFlag = 1;
elseif nmbOfSat_inraim_bds
    NGEOFlag = sum(activChn_raim_bds(2,:)>5);
end

% For joint pvt solution, the current algorithm is divided into three taks
% 1: Compute pvt using all sats from individual GNSS systems because some
% times pvt from a signle gnss is better than joint
% 2: Compute pvt using joint system

% algorithm papram initialization
bdsPvt = 0;
gpsPvt = 0;
joint  = 0;
bRaim = [];
% start pvt estimation process
while (nmbOfSat_inraim>=5) && (inraim == 1) && (NGEOFlag>0)
    
    if nmbOfSat_inraim_gps==0 %there is only BDS sats available
        [pos_xyz, vel_xyz_bds, cdtu_bds, az_actv_bds, el_actv_bds, iono_actv_bds, trop_actv_bds, bRaim_bds, DOP, rankBreak, psrCorr_bds] = ...
            mmEstPos_Bds(satpos_bds,...
                         obs_bds, ...
                         transmitTime_bds,...
                         ephemeris_para_bds,...
                         activChn_raim_bds,...
                         satClkCorr_bds, ...
                         pvtCalculator, ...
                         recv_timer, ...
                         pvtForecast_Succ, ...
                         el_bds, ...
                         az_bds, ...
                         iono_bds, ...
                         trop_bds, ...
                         cn0_bds);
        
        prError = 0;
        psr = psr_bds(activChn_raim_bds(2,:));
        psrCorr = psrCorr_bds;
        bRaim =  bRaim_bds;
        if pvtForecast_Succ
            prError = psrCorr - psr;
%             prError = prError - median(prError);
        end 
        vel_xyz = [vel_xyz_bds; pvtCalculator.clkErr(2,2)]; % For GPS clk drift, we keep it unchanged
        cdtu = [cdtu_bds; pvtCalculator.clkErr(1,2)]; % we use the predicted clkErr as cdtu of GPS
        [mmPvtEstmts] = updatePvtEstmts(mmPvtEstmts, pos_xyz, vel_xyz, DOP,cdtu, prError, activChn_raim_bds,[],...
                                        'BDS_B1I');
    elseif nmbOfSat_inraim_bds==0 %there is only GPS sats available
        % compute pvt using gps only satellites
            [pos_xyz, vel_xyz_gps, cdtu_gps, az_actv_gps, el_actv_gps, iono_actv_gps, trop_actv_gps, bRaim_gps, psrCorr_gps, DOP, rankBreak] = ...
                mmEstPos_Gps(satpos_gps, ...
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
                             cn0_gps);
             
          prError = 0;
          psr = psr_gps(activChn_raim_gps(2,:));
          psrCorr = psrCorr_gps;
          bRaim =  bRaim_gps;  
          vel_xyz = [vel_xyz_gps(1:3); pvtCalculator.clkErr(1,2); vel_xyz_gps(4)]; % For BDS clk drift, we keep it unchanged
          cdtu = [pvtCalculator.clkErr(1); cdtu_gps]; % we use the predicted clkErr as cdtu of BDS
          [mmPvtEstmts] = updatePvtEstmts(mmPvtEstmts, pos_xyz, vel_xyz, DOP,cdtu, prError, [], activChn_raim_gps,...
                                        'GPS_L1CA');
    else
        [pos_xyz, vel_xyz, cdtu, ...
        az_actv_bds, az_actv_gps, el_actv_bds, ~, iono_actv_bds, ~, trop_actv_bds, trop_actv_gps, ...
        bRaim, psrCorr, DOP,rankBreak] = ...
        mmEstimatorPos_JointBdsGps(satpos_bds, satpos_gps, ...
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
                                    cn0_bds, cn0_gps);
                              
        prError = 0;
        psr = [psr_bds(activChn_raim_bds(2,:)), psr_gps(activChn_raim_gps(2,:))];
        if pvtForecast_Succ
            prError = psrCorr - psr;
%             prError = prError - median(prError);
        end
        [mmPvtEstmts] = updatePvtEstmts(mmPvtEstmts, pos_xyz, vel_xyz, DOP,cdtu, prError, activChn_raim_bds, activChn_raim_gps,'B1I_L1CA'); 
    end
   % apply RAIM  corrections
   if nmbOfSat_inraim>=6
       [raimPass, mxprErr_id] = stndrdResi_raim('B1I_L1CA', pos_xyz, pvtCalculator.posForecast, bRaim, prError, pvtForecast_Succ,nmbOfSat_inraim);
       bRaim = [];
       
       if raimPass  % raim check pass! it can jump out the while loop
           inraim = 0;
           mmpvt_raim_coder = 1; % case1
       else
% %            if (~bdsPvt || ~gpsPvt) && (~joint)
% %                continue;
% %            elseif joint == 1
% %                joint = -1;
% %            else
% %                joint = 1;
% %                continue;
% %            end
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
       end
       
   else % in the cas of nmbOfSat_inraim==4, it can not perform raim check
%        if rankBreak
           inraim = 0;
           mmpvt_raim_coder = 0;
%        else
%            if pvtForecast_Succ~=1
%                inraim = 0;
%                mmpvt_raim_coder = 11; % case11
%            else
%                maxPsrErr = max(abs(prError));
%                if maxPsrErr < 25 % meter
%                    mmpvt_raim_coder = 2; % case2 
%                else
%                    mmpvt_raim_coder = 10; %case10
%                end
%                inraim = 0;
%            end
%        end
   end
end

[pos_xyz,vel_xyz,cdtu,DOP,pvtS_Num,sat_inraim_bds, sat_inraim_gps, mmpvt_coder] = pvtEstimateBest(mmPvtEstmts,pvtCalculator.posForecast,pvtForecast_Succ,mmpvt_raim_coder);
global debugVar;
debugVar = debugVar + 1;
if debugVar >= 80;
    xyz = 1;
end
switch mmpvt_coder
    case 1 % 
        if pvtForecast_Succ 
            est_vel_err = sqrt((pvtCalculator.positionVelocity(1) - vel_xyz(1))^2 + ...
                           (pvtCalculator.positionVelocity(2) - vel_xyz(2))^2 + ...
                           (pvtCalculator.positionVelocity(3) - vel_xyz(3))^2 );
            if est_vel_err < 15 
                pvtCalculator.positionVelocity = vel_xyz(1:3);
            else
                pvtCalculator.positionVelocity = pvtCalculator.positionVelocity;
            end
            pvtCalculator.positionXYZ = pvtCalculator.posForecast;
            pvtCalculator.posiLast = pvtCalculator.positionXYZ;
            [pvtCalculator.positionLLH(1), pvtCalculator.positionLLH(2), pvtCalculator.positionLLH(3)] = ...
            cart2geo( pvtCalculator.positionXYZ(1), pvtCalculator.positionXYZ(2), pvtCalculator.positionXYZ(3), 5 );
            pvtCalculator.positionValid = 1;
            pvtCalculator.posiCheck     = 2; % pvt solution is predicted one
            pvtCalculator.pvtSats(1).pvtS_Num   = 0; %no sats involved in pvt
            pvtCalculator.pvtSats(2).pvtS_Num   = 0; %no sats involved in pvt
            recv_timer = recvTimer_corr('B1I_L1CA', recv_timer, [0;0]);
% %         else
% %             pvtCalculator.positionXYZ = pos_xyz;
% %             % Get the LLH Coordinates
% %             [pvtCalculator.positionLLH(1), pvtCalculator.positionLLH(2), pvtCalculator.positionLLH(3)] = ...
% %                 cart2geo( pvtCalculator.positionXYZ(1), pvtCalculator.positionXYZ(2), pvtCalculator.positionXYZ(3), 5 );
% %             pvtCalculator.positionDOP = DOP;
% %             pvtCalculator.positionVelocity = vel_xyz(1:3);
% %             pvtCalculator.positionValid = 0;
% %             pvtCalculator.posiCheck     = 0; % there is no pvt solution
% %             pvtCalculator.pvtSats(1).pvtS_Num  = 0;     %
% % %             if pvtS_Num(1)>0
% %                 pvtCalculator.pvtSats(1).pvtS_prnList(1:pvtS_Num(1)) = 0;
% % %             end
% %             pvtCalculator.pvtSats(2).pvtS_Num   = 0; %sats involved in pvt
% % %             if pvtS_Num(2)>0
% %                pvtCalculator.pvtSats(2).pvtS_prnList(1:pvtS_Num(2)) = 0;
% % %             end
% %             if recv_timer.timeCheck == -1
% %                 recv_timer.timeCheck = 0;
% %             end
% %             recv_timer = recvTimer_corr('B1I_L1CA', recv_timer, [0;0]);
        end
        
        
    case 2 % sat_pvt_number>=6 & passing the raim checking
        if pvtForecast_Succ
            est_vel_err = sqrt((pvtCalculator.positionVelocity(1) - vel_xyz(1))^2 + ...
                           (pvtCalculator.positionVelocity(2) - vel_xyz(2))^2 + ...
                           (pvtCalculator.positionVelocity(3) - vel_xyz(3))^2 );
            if est_vel_err < 15 
                pvtCalculator.positionVelocity = vel_xyz(1:3);
            else
                pvtCalculator.positionVelocity = pvtCalculator.positionVelocity;
            end
            pvtCalculator.positionXYZ = pvtCalculator.posForecast;
%             pvtCalculator.positionXYZ = pos_xyz;
            pvtCalculator.posiLast = pvtCalculator.positionXYZ;
            [pvtCalculator.positionLLH(1), pvtCalculator.positionLLH(2), pvtCalculator.positionLLH(3)] = ...
            cart2geo( pvtCalculator.positionXYZ(1), pvtCalculator.positionXYZ(2), pvtCalculator.positionXYZ(3), 5 );
            pvtCalculator.positionValid = 1;
            pvtCalculator.posiCheck     = 2; % pvt solution is predicted one
            pvtCalculator.pvtSats(1).pvtS_Num   = 0; %no sats involved in pvt
            pvtCalculator.pvtSats(2).pvtS_Num   = 0; %no sats involved in pvt
            recv_timer = recvTimer_corr('B1I_L1CA', recv_timer, [0;0]);
        else
            pvtCalculator.positionXYZ = pos_xyz;
            % Get the LLH Coordinates
            [pvtCalculator.positionLLH(1), pvtCalculator.positionLLH(2), pvtCalculator.positionLLH(3)] = ...
                cart2geo( pvtCalculator.positionXYZ(1), pvtCalculator.positionXYZ(2), pvtCalculator.positionXYZ(3), 5 );
            pvtCalculator.positionDOP = DOP;
            pvtCalculator.positionVelocity = vel_xyz(1:3);
            pvtCalculator.positionValid = 0;  % for debug only
            pvtCalculator.posiCheck     = 0; % there is no pvt solution
            pvtCalculator.pvtSats(1).pvtS_Num  = pvtS_Num(1);     %
            pvtCalculator.pvtSats(1).pvtS_prnList(1:pvtS_Num(1)) = 0;
            pvtCalculator.pvtSats(2).pvtS_prnList(1:pvtS_Num(2)) = 0;
% %             if pvtS_Num(1)>0
% %                 pvtCalculator.pvtSats(1).pvtS_prnList(1:pvtS_Num(1)) = sat_inraim_bds;
% %             end
% %             pvtCalculator.pvtSats(2).pvtS_Num   = pvtS_Num(2); %sats involved in pvt
% %             if pvtS_Num(2)>0
% %                pvtCalculator.pvtSats(2).pvtS_prnList(1:pvtS_Num(2)) = sat_inraim_gps;
% %             end
            if recv_timer.timeCheck == -1
                recv_timer.timeCheck = 0;
            end
            recv_timer = recvTimer_corr('B1I_L1CA', recv_timer, [0;0]);
        end
               
    case 3 
        if pvtForecast_Succ
            est_vel_err = sqrt((pvtCalculator.positionVelocity(1) - vel_xyz(1))^2 + ...
                           (pvtCalculator.positionVelocity(2) - vel_xyz(2))^2 + ...
                           (pvtCalculator.positionVelocity(3) - vel_xyz(3))^2 );
            if est_vel_err < 15 
                pvtCalculator.positionVelocity = vel_xyz(1:3);
            else
                pvtCalculator.positionVelocity = pvtCalculator.positionVelocity;
            end
            pvtCalculator.positionXYZ = pvtCalculator.posForecast;
            pvtCalculator.posiLast = pvtCalculator.positionXYZ;
            % Get the LLH Coordinates
            [pvtCalculator.positionLLH(1), pvtCalculator.positionLLH(2), pvtCalculator.positionLLH(3)] = ...
                    cart2geo( pvtCalculator.positionXYZ(1), pvtCalculator.positionXYZ(2), pvtCalculator.positionXYZ(3), 5 );
%             pvtCalculator.positionVelocity = vel_xyz(1:3);
            pvtCalculator.clkErr(1,1) = cdtu(1);
            pvtCalculator.clkErr(1,2) = pvtCalculator.clkErr(1,2) + vel_xyz(4);  % BDS: accumulated clk drift freq [Hz]
            pvtCalculator.clkErr(2,1) = cdtu(2);     % GPS: accumulated clk bias [meter]
            pvtCalculator.clkErr(2,2) = pvtCalculator.clkErr(2,2) + vel_xyz(5);  % GPS: accumulated clk drift freq [Hz]
            pvtCalculator.positionValid = 1;
            pvtCalculator.posiCheck     = 2; % pvt solution is computed one with raim
             % correct recv_timer system
            recv_timer.timeCheck = 1; % 时间系统一旦正确就认为不会再错
            recv_timer.rclkErr2Syst_UpCnt(1) = 0; % reset the recv clkErr counter of BDS
            recv_timer.rclkErr2Syst_UpCnt(2) = 0; % reset the recv clkErr counter of GPS
%             recv_timer = recvTimer_corr('B1I_L1CA', recv_timer, cdtu/c);
            recv_timer = recvTimer_corr('B1I_L1CA', recv_timer, [0,0]);  % for debug only
            pvtCalculator.timeLast = recv_timer.recvSOW;
        else
            pvtCalculator.positionXYZ = pos_xyz;
%             pvtCalculator.posiLast = pos_xyz;
            pvtCalculator.posiLast = pos_xyz;
            [pvtCalculator.positionLLH(1), pvtCalculator.positionLLH(2), pvtCalculator.positionLLH(3)] = ...
                    cart2geo( pvtCalculator.positionXYZ(1), pvtCalculator.positionXYZ(2), pvtCalculator.positionXYZ(3), 5 );
            pvtCalculator.positionVelocity = vel_xyz(1:3);
            pvtCalculator.positionDOP = DOP;
            pvtCalculator.clkErr(1,1) = cdtu(1);     % BDS: accumulated clk bias [meter]
            pvtCalculator.clkErr(1,2) = pvtCalculator.clkErr(1,2) + vel_xyz(4);  % BDS: accumulated clk drift freq [Hz]
            pvtCalculator.clkErr(2,1) = cdtu(2);     % GPS: accumulated clk bias [meter]
            pvtCalculator.clkErr(2,2) = pvtCalculator.clkErr(2,2) + vel_xyz(5);  % GPS: accumulated clk drift freq [Hz]
                
            pvtCalculator.positionValid = 1;
            % for test only
%             if mmpvt_raim_coder
                pvtCalculator.posiCheck     = 1; % pvt solution is computed one with raim
%             else
%                 pvtCalculator.posiCheck     = 0;
%             end
            %-------------------------------    
            pvtCalculator.pvtSats(1).pvtS_Num  = pvtS_Num(1);     %
            if pvtS_Num(1)>0
                    pvtCalculator.pvtSats(1).pvtS_prnList(1:pvtS_Num(1)) = sat_inraim_bds;
            end
            pvtCalculator.pvtSats(2).pvtS_Num   = pvtS_Num(2); %sats involved in pvt
            if pvtS_Num(2)>0
                pvtCalculator.pvtSats(2).pvtS_prnList(1:pvtS_Num(2)) = sat_inraim_gps;
            end
                
            % correct recv_timer system
            recv_timer.timeCheck = 1; % 时间系统一旦正确就认为不会再错
            recv_timer.rclkErr2Syst_UpCnt(1) = 0; % reset the recv clkErr counter of BDS
            recv_timer.rclkErr2Syst_UpCnt(2) = 0; % reset the recv clkErr counter of GPS
%             recv_timer = recvTimer_corr('B1I_L1CA', recv_timer, cdtu/c);
            recv_timer = recvTimer_corr('B1I_L1CA', recv_timer, [0,0]);  % for debug only
            pvtCalculator.timeLast = recv_timer.recvSOW;
        end
        
    case 4 % case 4, the position is very good raim pass/fail
        
       
        pvtCalculator.positionXYZ = pos_xyz;
        pvtCalculator.posiLast = pos_xyz;
        % Get the LLH Coordinates
       [pvtCalculator.positionLLH(1), pvtCalculator.positionLLH(2), pvtCalculator.positionLLH(3)] = ...
                    cart2geo( pvtCalculator.positionXYZ(1), pvtCalculator.positionXYZ(2), pvtCalculator.positionXYZ(3), 5 );
       pvtCalculator.positionVelocity = vel_xyz(1:3);
       pvtCalculator.positionDOP = DOP;
       pvtCalculator.clkErr(1,1) = cdtu(1);     % BDS: accumulated clk bias [meter]
       pvtCalculator.clkErr(1,2) = pvtCalculator.clkErr(1,2) + vel_xyz(4);  % BDS: accumulated clk drift freq [Hz]
       pvtCalculator.clkErr(2,1) = cdtu(2);     % GPS: accumulated clk bias [meter]
       pvtCalculator.clkErr(2,2) = pvtCalculator.clkErr(2,2) + vel_xyz(5);  % GPS: accumulated clk drift freq [Hz]
                
       pvtCalculator.positionValid = 1;
       pvtCalculator.posiCheck     = 1; % pvt solution is computed one with raim
                
       pvtCalculator.pvtSats(1).pvtS_Num  = pvtS_Num(1);     %
       if pvtS_Num(1)>0
            pvtCalculator.pvtSats(1).pvtS_prnList(1:pvtS_Num(1)) = sat_inraim_bds;
       end
       pvtCalculator.pvtSats(2).pvtS_Num   = pvtS_Num(2); %sats involved in pvt
       if pvtS_Num(2)>0
           pvtCalculator.pvtSats(2).pvtS_prnList(1:pvtS_Num(2)) = sat_inraim_gps;
       end
                
       % correct recv_timer system
       recv_timer.timeCheck = 1; % 时间系统一旦正确就认为不会再错
       recv_timer.rclkErr2Syst_UpCnt(1) = 0; % reset the recv clkErr counter of BDS
       recv_timer.rclkErr2Syst_UpCnt(2) = 0; % reset the recv clkErr counter of GPS
       recv_timer = recvTimer_corr('B1I_L1CA', recv_timer, cdtu/c);
       pvtCalculator.timeLast = recv_timer.recvSOW;
                
                       
        
    otherwise
        error('mmPVT_resiraim_JointBdsGps(): Illegal mmpvt_coder value');
end

% save log information
% pvtCalculator.logOutput.GPSraimChn = activChn_raim;
pvtCalculator.pvtReadySats(1).pvtS_Num = nmbOfSatellites_bds;
pvtCalculator.pvtReadySats(1).pvtS_prnList(1:nmbOfSatellites_bds) = activeChannel_BDS(2,1:nmbOfSatellites_bds);
pvtCalculator.pvtReadySats(2).pvtS_Num = nmbOfSatellites_gps;
pvtCalculator.pvtReadySats(2).pvtS_prnList(1:nmbOfSatellites_gps) = activeChannel_GPS(2,1:nmbOfSatellites_gps);

    
% end




    
    