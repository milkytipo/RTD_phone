%% start PVT
% initial
function [recv_time, ephemeris, pvtCalculator, config] = pointPos(SYST,channels, config, recv_time, ephemeris, pvtCalculator, actvPvtChannels)
%% 初始化
svnum.BDS = 0;% this flag is to find whether avaliable satellite is above 4
svnum.GPS = 0;
activeChannel.GPS = [];% avaliable channels
activeChannel.BDS = [];
posiChannel.GPS = [];   % raim算法过滤后的信道
posiChannel.BDS = [];
checkNGEO = 0;%%检测NGEO卫星
inteDoppler.BDS = zeros(1,32);%积分多普勒值
inteDoppler.GPS = zeros(1,32);
dopplerfre.BDS = zeros(1,32);%多普勒频移
dopplerfre.GPS = zeros(1,32);
CNR.BDS = zeros(1,32);  %输出信噪比
CNR.GPS = zeros(1,32);
SNR.BDS = zeros(1,32);  %输出信噪比
SNR.GPS = zeros(1,32);
carrierVar.BDS = zeros(1, 32);  % 输出载波环方差
carrierVar.GPS = zeros(1, 32);
EphAll.BDS = [];
EphAll.GPS = [];
rawP.GPS = [];
rawP.BDS = [];
satClkCorr.BDS = [];
satClkCorr.GPS = [];
satPositions.BDS = [];
satPositions.GPS = [];
raimG = []; % 状态矩阵
raimB = [];
prError = [];
raimFlag = 0;   % 如果值为1，则raim校验通过

if pvtCalculator.positionValid ==-1
    posiLast = [];
    transmitimeLast = [];
else
    posiLast = pvtCalculator.posiLast;
    transmitimeLast = pvtCalculator.timeLast;
end


%% start PVT
for n = 1 : config.recvConfig.numberOfChannels(1).channelNumAll
    switch channels(n).SYST
        case 'BDS_B1I'
            prnNum = channels(n).CH_B1I(1).PRNID;
%             if  ~isnan(prnNum) && (ephemeris(1).para(prnNum).ephReady==1 || ephemeris(1).para(prnNum).updateReady == 1) ...
%                     && ephemeris(1).para(prnNum).ephUpdate.health==0 && strcmp(channels(n).CH_B1I(1).CH_STATUS, 'SUBFRAME_SYNCED')
%                 svnum.BDS = svnum.BDS + 1;
%                 activeChannel.BDS(1,svnum.BDS) = n;
%                 activeChannel.BDS(2,svnum.BDS) = channels(n).CH_B1I(1).PRNID;
%                 if activeChannel.BDS(2,svnum.BDS)>5
%                     checkNGEO = 1;
%                 end
%                 if ephemeris(1).para(prnNum).updateReady == 0
%                     ephemeris(1).para(prnNum).eph = ephemeris(1).para(prnNum).ephUpdate;   % 首次保存星历数据
%                     ephemeris(1).para(prnNum).updateReady = 1;
%                 else
%                     if ~isequal(ephemeris(1).para(prnNum).eph, ephemeris(1).para(prnNum).ephUpdate) ...
%                             && ephemeris(1).para(prnNum).ephReady==1% 判断是否有星历更新
%                         if ephemeris(1).para(prnNum).updating == 0
%                             ephemeris(1).para(prnNum).ephReady = 0;        %重置星历数据
%                             ephemeris(1).para(prnNum).subframeID(1:10) = 1:10;
%                             ephemeris(1).para(prnNum).updating = 1;   % 置1表示星历正在更新中
%                         else
%                             ephemeris(1).para(prnNum).eph = ephemeris(1).para(prnNum).ephUpdate;  % 更新星历
%                             ephemeris(1).para(prnNum).updating = 0;   % 更新完后置0
%                         end
%                     end
%                 end
%                 % 积分多普勒值
%                 inteDoppler.BDS(activeChannel.BDS(2,svnum.BDS)) = -1*channels(n).CH_B1I(1).carrPhaseAccum*299792458/1561098000; % 单位为米
%                 % 多普勒频移
%                 dopplerfre.BDS(activeChannel.BDS(2,svnum.BDS)) = channels(n).CH_B1I(1).LO2_fd;
%                 % 判断该卫星上一秒钟是否失锁，若失锁则重新计数
%                 if pvtCalculator.BDS.doppSmooth(activeChannel.BDS(2,svnum.BDS),3) == 1
%                     pvtCalculator.BDS.doppSmooth(activeChannel.BDS(2,svnum.BDS),2) = pvtCalculator.BDS.doppSmooth(activeChannel.BDS(2,svnum.BDS),1);
%                     pvtCalculator.BDS.doppSmooth(activeChannel.BDS(2,svnum.BDS),1) = inteDoppler.BDS(activeChannel.BDS(2,svnum.BDS));
%                     pvtCalculator.BDS.doppSmooth(activeChannel.BDS(2,svnum.BDS),4) = dopplerfre.BDS(activeChannel.BDS(2,svnum.BDS));
%                 else
%                     pvtCalculator.BDS.doppSmooth(activeChannel.BDS(2,svnum.BDS),2) = 0;
%                     pvtCalculator.BDS.doppSmooth(activeChannel.BDS(2,svnum.BDS),1) = inteDoppler.BDS(activeChannel.BDS(2,svnum.BDS));
%                     pvtCalculator.BDS.doppSmooth(activeChannel.BDS(2,svnum.BDS),4) = dopplerfre.BDS(activeChannel.BDS(2,svnum.BDS));
%                 end
%                 % 载噪比
%                 CNR.BDS(activeChannel.BDS(2,svnum.BDS))=channels(n).CH_B1I(1).CN0_Estimator.CN0;
%                 % 载波环方差
%                 carrierVar.BDS(activeChannel.BDS(2,svnum.BDS))=channels(n).CH_B1I(1).sigma;
%                 % 信噪比
%                 SNR.BDS(activeChannel.BDS(2,svnum.BDS)) = channels(n).ALL(1).SNR;
%             end
        case 'GPS_L1CA'
            prnNum = channels(n).CH_L1CA(1).PRNID;
            
%             % updateReady == 1: checking the new eph validation
%             if ~isnan(prnNum) && (ephemeris(2).para(prnNum).updateReady==1) && strcmp(channels(n).CH_L1CA(1).CH_STATUS, 'SUBFRAME_SYNCED')
%                 % perform the step 1 checking procedure
%                 [ephemeris(2).para(prnNum), updateSuccess] = ephUpdate_checkingStep1(ephemeris(2).syst, ephemeris(2).para(prnNum), posiLast, transmitimeLast);
%                 
%                 if updateSuccess ==1
%                     if (ephemeris(2).para(prnNum).ephReady ==1)
%                         ephemeris(2).para(prnNum).eph = ephsatorbit_cpy(ephemeris(2).syst, ephemeris(2).para(prnNum).eph, ephemeris(2).para(prnNum).ephUpdate);
%                         ephemeris(2).para(prnNum).ephTrustLevel = ephemeris(2).para(prnNum).ephUpdateTrustLevel;
%                     else % (ephemeris(2).para(prnNum).ephReady ==0)
%                         % ephupdate checking step 1 pass. if there is no previsou eph
%                         % available and there is no posiLast available, the
%                         % further raim checking cannot be performed, so we
%                         % update the ephupdate into eph and use it into the
%                         % first PVT calculation.
%                         % 首次保存星历数据
%                         ephemeris(2).para(prnNum).eph = ephemeris(2).para(prnNum).ephUpdate;
%                         ephemeris(2).para(prnNum).ephRaid = ephemeris(2).para(prnNum).ephUpdate;
%                         ephemeris(2).para(prnNum).ephTrustLevel = ephemeris(2).para(prnNum).ephUpdateTrustLevel;
%                         ephemeris(2).para(prnNum).ephReady = 1;
%                     end %EOF "if (ephemeris(2).para(prnNum).ephReady ==1)"
%                 end %EOF "if updateSuccess ==1"
%                 
%                 %凡是接收完一次数据帧，不管成功更新与否，均需要重新将subframeID置成1:10.
%                 ephemeris(2).para(prnNum).subframeID(1:10) = 1:10;
%                 ephemeris(2).para(prnNum).updateReady = 0;
%                 ephemeris(2).para(prnNum).ephUpdateTrustLevel = 0;
%             end %EOF "if ~isnan(prnNum) && (ephemeris(2).para(prnNum).updateReady==1) && strcmp(channels(n).CH_L1CA(1).CH_STATUS, 'SUBFRAME_SYNCED')"
            
            % Counting the svnum available to do PVT
%             if ~isnan(prnNum) && (ephemeris(2).para(prnNum).ephReady==1) && (ephemeris(2).para(prnNum).eph.health==0) && strcmp(channels(n).CH_L1CA(1).CH_STATUS, 'SUBFRAME_SYNCED')
%                 svnum.GPS = svnum.GPS + 1;
%                 % activeChannel.GPS: row1: channel No.;
%                 % activeChannel.GPS: row2: PRN that the channel is tracking;
%                 activeChannel.GPS(1,svnum.GPS) = n;
%                 activeChannel.GPS(2,svnum.GPS) = channels(n).CH_L1CA(1).PRNID;
%                 if activeChannel.GPS(2,svnum.GPS)>5
%                     checkNGEO = 1;
%                 end
%                 
%                 % 积分多普勒值
%                 inteDoppler.GPS(activeChannel.GPS(2,svnum.GPS)) = -1*channels(n).CH_L1CA(1).carrPhaseAccum*299792458/1575420000; % 单位为米
%                 % 多普勒频移
%                 dopplerfre.GPS(activeChannel.GPS(2,svnum.GPS)) = channels(n).CH_L1CA(1).LO2_fd;
%                 % 判断该卫星上一秒钟是否失锁，若失锁则重新计数
%                 if pvtCalculator.GPS.doppSmooth(activeChannel.GPS(2,svnum.GPS),3) == 1
%                     pvtCalculator.GPS.doppSmooth(activeChannel.GPS(2,svnum.GPS),2) = pvtCalculator.GPS.doppSmooth(activeChannel.GPS(2,svnum.GPS),1);
%                     pvtCalculator.GPS.doppSmooth(activeChannel.GPS(2,svnum.GPS),1) = inteDoppler.GPS(activeChannel.GPS(2,svnum.GPS));
%                     pvtCalculator.GPS.doppSmooth(activeChannel.GPS(2,svnum.GPS),4) = dopplerfre.GPS(activeChannel.GPS(2,svnum.GPS));
%                 else
%                     pvtCalculator.GPS.doppSmooth(activeChannel.GPS(2,svnum.GPS),2) = 0;
%                     pvtCalculator.GPS.doppSmooth(activeChannel.GPS(2,svnum.GPS),1) = inteDoppler.GPS(activeChannel.GPS(2,svnum.GPS));
%                     pvtCalculator.GPS.doppSmooth(activeChannel.GPS(2,svnum.GPS),4) = dopplerfre.GPS(activeChannel.GPS(2,svnum.GPS));
%                 end
%                 % 载噪比
%                 CNR.GPS(activeChannel.GPS(2,svnum.GPS))=channels(n).CH_L1CA(1).CN0_Estimator.CN0;
%                 % 载波环方差
%                 carrierVar.GPS(activeChannel.GPS(2,svnum.GPS))=channels(n).CH_L1CA(1).sigma;
%                 % 信噪比
%                 SNR.GPS(activeChannel.GPS(2,svnum.GPS)) = channels(n).ALL(1).SNR;
%             end %EOF "if ~isnan(prnNum) && (ephemeris(2).para(prnNum).ephReady==1) && (ephemeris(2).para(prnNum).eph.health==0) && strcmp(channels(n).CH_L1CA(1).CH_STATUS, 'SUBFRAME_SYNCED')"
    end %EOF "switch channels(n).SYST"
    %%   开始计算各个卫星的观测量并定位
%     if n==config.recvConfig.numberOfChannels(1).channelNumAll && (svnum.BDS>=1||svnum.GPS>=1)
%         % 计算北斗卫星的观测量
%         if svnum.BDS >= 1
%             % 更新锁定标志位
%             pvtCalculator.BDS.doppSmooth(1:32,3) = 0;
%             pvtCalculator.BDS.doppSmooth(activeChannel.BDS(2,:),3) = 1;
%             % find trasmition time
%             [transmitTime.BDS] = findTransTime_BD(channels,activeChannel.BDS(1,:));
%             recv_time.weeknum_BDS = ephemeris(1).para(activeChannel.BDS(2,1)).eph.weekNumber;  %%更新周计数
%             % Compute satellite position
%             [satPositions.BDS, satClkCorr.BDS,EphAll.BDS] = BD_calculateSatPosition(transmitTime.BDS, ephemeris(1).para,activeChannel.BDS(2,:));
%             if recv_time.recvSOW_BDS == -1
%                 rxTime_BDS = median(transmitTime.BDS(transmitTime.BDS~=0)) + 70*1e-3;   % 取中位数，防止首次判断时间出现异常值
%                 recv_time.recvSOW_BDS = rxTime_BDS;
%             else
%                 rxTime_BDS = recv_time.recvSOW_BDS;
%             end
%             % Compute the Pseudo-range / receiver time
%             [rawP.BDS] = calculatePseudoranges(transmitTime.BDS,rxTime_BDS,activeChannel.BDS);
%         end
%         % 计算GPS观测量
%         if svnum.GPS >= 1
%             % 更新锁定标志位
%             pvtCalculator.GPS.doppSmooth(1:32,3) = 0;
%             pvtCalculator.GPS.doppSmooth(activeChannel.GPS(2,:),3) = 1;
%             % find trasmition time
%             [transmitTime.GPS] = findTransTime_GPS(channels, activeChannel.GPS(1,:));
%             % Compute satellite position
%             [satPositions.GPS, satClkCorr.GPS, EphAll.GPS] = GPS_calculateSatPosition(transmitTime.GPS, ephemeris(2).para,activeChannel.GPS(2,:));
%             % update time //  if BDS is used, local time uses BDT
%             recv_time.weeknum_GPS = ephemeris(2).para(activeChannel.GPS(2,1)).eph.weekNumber;  % 更新周计数
%             if recv_time.recvSOW_GPS == -1
%                 rxTime_GPS = median(transmitTime.GPS(transmitTime.GPS~=0)) + 70*1e-3; % 取中位数，防止首次判断时间出现异常值
%                 recv_time.recvSOW_GPS = rxTime_GPS;
%             else
%                 rxTime_GPS = recv_time.recvSOW_GPS;
%             end
%             % Compute the Pseudo-range / receiver time
%             [rawP.GPS] = calculatePseudoranges(transmitTime.GPS, rxTime_GPS, activeChannel.GPS);
%         end
%         %% 计算卫星位置和速度
%         posiChannel = activeChannel;
%         while (1)
%             [raimFlag, posiChannel,activeChannel,svnum] =raim(prError, raimG, raimB, posiChannel, raimFlag, SYST, svnum, pvtCalculator, recv_time, rawP, activeChannel);
%             if raimFlag == 1
%                 break;
%             end
%             if strcmp(SYST,'BDS_B1I') || (strcmp(SYST,'B1I_L1CA')&&svnum.GPS==0)
%                 [xyzdt,el,az,dop, raimG, raimB,prError,pvtCalculator] = leastSquarePos_BDS(satPositions.BDS, rawP.BDS+satClkCorr.BDS(1,:)*299792458, ...
%                     transmitTime.BDS,ephemeris(1).para,activeChannel.BDS, config.recvConfig.elevationMask, checkNGEO,satClkCorr.BDS(2,:),pvtCalculator, posiChannel.BDS,recv_time);
%             elseif strcmp(SYST,'GPS_L1CA') || (strcmp(SYST,'B1I_L1CA')&&svnum.BDS==0)
%                 [xyzdt,el,az,dop, raimG, raimB,prError,pvtCalculator] = leastSquarePos_GPS(satPositions.GPS, rawP.GPS+satClkCorr.GPS(1,:)*299792458, ...
%                     transmitTime.GPS, ephemeris(2).para, activeChannel.GPS, config.recvConfig.elevationMask,satClkCorr.GPS(2,:),pvtCalculator, posiChannel.GPS,recv_time);
%             elseif  strcmp(SYST,'B1I_L1CA')
%                 [xyzdt,el,az,dop, raimG, raimB,prError,pvtCalculator] = leastSquarePos_dual(satPositions, rawP, transmitTime, ephemeris, activeChannel, config.recvConfig.elevationMask, satClkCorr, pvtCalculator, posiChannel,recv_time);
%             end
%         end
%         
%         config.recvConfig.truePosition = [xyzdt(1), xyzdt(2), xyzdt(3)];
%         %%
%         % ————————————跟新系统时间————————%
%         switch SYST
%             case 'BDS_B1I'
%                 recv_time.recvSOW_BDS = recv_time.recvSOW_BDS - xyzdt(4);   % 修正本地时间误差
%                 recv_time.weeknum = recv_time.weeknum_BDS;
%                 recv_time.recvSOW = recv_time.recvSOW_BDS;
%                 config.recvConfig.trueTime = recv_time.recvSOW;
%                 [BJyear,BJmonth,BJday_2] = calculate_yymmdd(recv_time.weeknum, 0);
%             case 'GPS_L1CA'
%                 recv_time.recvSOW_GPS = recv_time.recvSOW_GPS - xyzdt(4);
%                 recv_time.weeknum = recv_time.weeknum_GPS;
%                 recv_time.recvSOW = recv_time.recvSOW_GPS;
%                 config.recvConfig.trueTime = recv_time.recvSOW;
%                 [BJyear,BJmonth,BJday_2] = calculateGPS_yymmdd(recv_time.weeknum, 0);
%             case 'B1I_L1CA'
%                 if recv_time.recvSOW_BDS == -1
%                     recv_time.recvSOW_GPS = recv_time.recvSOW_GPS - xyzdt(4);
%                     recv_time.weeknum = recv_time.weeknum_GPS;
%                     recv_time.recvSOW = recv_time.recvSOW_GPS - recv_time.GPST2BDT;
%                     config.recvConfig.trueTime = recv_time.recvSOW;
%                     [BJyear,BJmonth,BJday_2] = calculateGPS_yymmdd(recv_time.weeknum, 0);
%                 else
%                     recv_time.recvSOW_BDS = recv_time.recvSOW_BDS - xyzdt(4);
%                     recv_time.recvSOW_GPS = recv_time.recvSOW_GPS - xyzdt(5);
%                     recv_time.weeknum = recv_time.weeknum_BDS;
%                     recv_time.recvSOW = recv_time.recvSOW_BDS;
%                     config.recvConfig.trueTime = recv_time.recvSOW;
%                     [BJyear,BJmonth,BJday_2] = calculate_yymmdd(recv_time.weeknum, 0);
%                 end
%         end
%         %————————————跟新上次正确定位的定位时间——————————%
%         if pvtCalculator.posiTag == 1
%             pvtCalculator.timeLast = recv_time.recvSOW;  % 记录此次定位时间
%             pvtCalculator.posiTag = 0;                   % 跟新标志位设为0
%         end
%         %————————————计算时分秒信息————————————————%
%         [BJday_1, BJhour, BJmin, BJsec] = sow2BJT(recv_time.recvSOW);
%         recv_time.year = BJyear;
%         recv_time.month = BJmonth;
%         recv_time.day = BJday_1 + BJday_2;
%         recv_time.hour = BJhour;
%         recv_time.min = BJmin;
%         recv_time.sec = BJsec;
%         
%         %——————————log文件输出————————————%
%         logFileOutput(SYST, config, pvtCalculator, xyzdt, recv_time, rawP, inteDoppler, dopplerfre, CNR, EphAll,...
%             satClkCorr, satPositions, dop, el, az, channels, activeChannel, carrierVar, SNR, svnum,length(raimB));
%     end
    %
    %        %% 给界面输出参数信息
    %         for nn = 1:length(el(3,:))
    %             pvtCalculator.sateStatus(1,el(2,nn)) = el(1,nn);             % 输入仰角
    %             pvtCalculator.sateStatus(2,az(2,nn)) = az(1,nn);                % 输入方位角
    %             pvtCalculator.sateStatus(3,el(2,nn)) = rawP(el(2,nn));        % 输入伪距
    %         end
    %         pvtCalculator.positionXYZ = xyzdt(1:3);
    %         pvtCalculator.positionLLH = [latitude, longitude, height];
    %         pvtCalculator.positionTime = [recv_time.year, recv_time.month, recv_time.day, recv_time.hour, recv_time.min, recv_time.sec];
    %         pvtCalculator.positionDOP = dop(2);
    
end

%% Start PVT
if (svnum.BDS + svnum.GPS)>1
    % 计算GPS观测量
    if svnum.GPS >= 1
        % Find trasmition time
        [transmitTime.GPS] = findTransTime_GPS(channels, activeChannel.GPS(1,:));
        % Compute satellite position
        [satPositions.GPS, satClkCorr.GPS, EphAll.GPS] = GPS_calculateSatPosition(transmitTime.GPS, ephemeris(2).para, activeChannel.GPS(2,:));
        
%         % Update time //  if BDS is used, local time uses BDT
%         recv_time.weeknum_GPS = ephemeris(2).para(activeChannel.GPS(2,1)).eph.weekNumber;  % 更新周计数
%         if recv_time.recvSOW_GPS == -1
%             rxTime_GPS = median(transmitTime.GPS(transmitTime.GPS~=0)) + 70*1e-3; % 取中位数，防止首次判断时间出现异常值
%             recv_time.recvSOW_GPS = rxTime_GPS;
%         else
%             rxTime_GPS = recv_time.recvSOW_GPS;
%         end
        % Get the receiver local time
        [rxTime_GPS, recv_time] = get_rxTime('GPS_L1CA', recv_time, transmitTime);
        
        % Compute the Pseudo-range / receiver time
        [rawP.GPS] = calculatePseudoranges(transmitTime.GPS, rxTime_GPS, activeChannel.GPS);
    end
    
    if strcmp(SYST,'BDS_B1I') || (strcmp(SYST,'B1I_L1CA')&&svnum.GPS==0)
%         [xyzdt,el,az,dop, raimG, raimB,prError,pvtCalculator] = leastSquarePos_BDS(satPositions.BDS, rawP.BDS+satClkCorr.BDS(1,:)*299792458, ...
%                     transmitTime.BDS,ephemeris(1).para,activeChannel.BDS, config.recvConfig.elevationMask, checkNGEO,satClkCorr.BDS(2,:),pvtCalculator, posiChannel.BDS,recv_time);
    elseif strcmp(SYST,'GPS_L1CA') || (strcmp(SYST,'B1I_L1CA')&&svnum.BDS==0)
        [xyzdt,el,az,dop, raimG, raimB,prError,pvtCalculator] = ...
            leastSquarePos_GPS(satPositions.GPS, ...% matrix[6x32], each column for a sat [x;y;z;vx;vy;vz]
                               rawP.GPS, ...% vector[1x32], each for a sat pseudorange [meter]    %rawP.GPS+satClkCorr.GPS(1,:)*299792458, ...
                               transmitTime.GPS, ...% vector[1x32], each for a sat transmit time [sec]
                               ephemeris(2).para, ...% struct_vector[1x32], eph_para
                               activeChannel.GPS, ...% [2xNum], row1 is active CH No.; row2 is active CH prn; Num is the number of active chs
                               config.recvConfig.elevationMask, ...% a scalar
                               satClkCorr.GPS, ...% matrix[2x32], each colum for a sat [clk_dt; clk_df]
                               pvtCalculator, ...% PVT Calculator Structure
                               ...posiChannel.GPS,...
                               recv_time);
    elseif  strcmp(SYST,'B1I_L1CA')
%         [xyzdt,el,az,dop, raimG, raimB,prError,pvtCalculator] = leastSquarePos_dual(satPositions, rawP, transmitTime, ephemeris, activeChannel, config.recvConfig.elevationMask, satClkCorr, pvtCalculator, posiChannel,recv_time);
    end
end

end