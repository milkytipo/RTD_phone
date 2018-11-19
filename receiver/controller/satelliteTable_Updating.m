function receiver = satelliteTable_Updating(receiver, N)
global GSAR_CONSTANTS;
config         = receiver.config;
channels       = receiver.channels;
satelliteTable = receiver.satelliteTable;
timer          = receiver.timer;
naviMsg        = receiver.naviMsg;
pvtCalculator  = receiver.pvtCalculator;

% if timer.recvSOW==-1
%     return;
% end

% 判断是否执行更新
start_updateTable = 0;
if strcmp(receiver.syst, 'BDS_B1I') %|| strcmp(receiver.syst, 'B1I_L1CA')
    satelliteTable(1).updateTime.timeInterval = satelliteTable(1).updateTime.timeInterval + N/GSAR_CONSTANTS.STR_RECV.fs;
    if satelliteTable(1).updateTime.timeInterval >= config.recvConfig.satTableUpdatPeriod
        start_updateTable = 1;
    end
elseif strcmp(receiver.syst, 'GPS_L1CA')
    satelliteTable(2).updateTime.timeInterval = satelliteTable(2).updateTime.timeInterval + N/GSAR_CONSTANTS.STR_RECV.fs;
    if satelliteTable(2).updateTime.timeInterval >= config.recvConfig.satTableUpdatPeriod
        start_updateTable = 1;
    end
elseif strcmp(receiver.syst, 'B1I_L1CA')
    satelliteTable(1).updateTime.timeInterval = satelliteTable(1).updateTime.timeInterval + N/GSAR_CONSTANTS.STR_RECV.fs;
    satelliteTable(2).updateTime.timeInterval = satelliteTable(2).updateTime.timeInterval + N/GSAR_CONSTANTS.STR_RECV.fs;
    if satelliteTable(1).updateTime.timeInterval >= config.recvConfig.satTableUpdatPeriod
        start_updateTable = 1;
    end
end
    
% if satelliteTable(1).updateTime.recvSOW==-1
%     start_updateTable = 1;
% else
%     last_updatetime = satelliteTable(1).updateTime.weeknum * GSAR_CONSTANTS.WEEKLONGSEC + satelliteTable(1).updateTime.recvSOW; % 此处有bug，考虑GPS和BDS周数不一致
%     current_time = timer.weeknum * GSAR_CONSTANTS.WEEKLONGSEC + timer.recvSOW;
%     
%     if abs(current_time - last_updatetime) >= config.recvConfig.satTableUpdatPeriod
%         start_updateTable = 1;
%     end
% end

chNum = config.recvConfig.numberOfChannels(1).channelNumAll;
activeChannel_BDS = zeros(2, chNum);
activeChannel_GPS = zeros(2, chNum);
activeNum_BDS = 0;
activeNum_GPS = 0;
for i = 1 : chNum
    if strcmp(channels(i).STATUS, 'TRACK') || strcmp(channels(i).STATUS, 'SUBFRAME_SYNCED')
        switch channels(i).SYST
            case 'BDS_B1I'
                activeNum_BDS = activeNum_BDS + 1;
                activeChannel_BDS(1,activeNum_BDS) = i;
                activeChannel_BDS(2,activeNum_BDS) = channels(i).CH_B1I.PRNID;
            case 'GPS_L1CA'
                activeNum_GPS = activeNum_GPS + 1;
                activeChannel_GPS(1,activeNum_GPS) = i;
                activeChannel_GPS(2,activeNum_GPS) = channels(i).CH_L1CA.PRNID;
        end
    end
    if strcmp(channels(i).STATUS, 'ACQ_FAIL')   % 若捕获失败，则相应卫星block设为1，并根据条件设置blockAge
        switch channels(i).SYST
            case 'BDS_B1I'
                prn = channels(i).CH_B1I.PRNID;
                satelliteTable(1).satBlock(prn) = 1;
                if satelliteTable(1).satVisible(prn) == 1
                    satelliteTable(1).satBlockAge(prn) = config.recvConfig.reAcqPeriod;  % 设置重新捕获时间
                else
                    satelliteTable(1).satBlockAge(prn) = config.recvConfig.reAcqPeriod * 3;  % 设置重新捕获时间
                end
            case 'GPS_L1CA'
                prn = channels(i).CH_L1CA.PRNID;
                satelliteTable(2).satBlock(prn) = 1;
                if satelliteTable(2).satVisible(prn) == 1
                    satelliteTable(2).satBlockAge(prn) = config.recvConfig.reAcqPeriod;  % 设置重新捕获时间
                else
                    satelliteTable(2).satBlockAge(prn) = config.recvConfig.reAcqPeriod * 3;  % 设置重新捕获时间
                end
        end
    end
end

%--------------- update satellites' positions --------------------
bds_maxprnNo = config.recvConfig.configPage.systConfig.BDS_B1I.maxPrnNo;
gps_maxprnNo = config.recvConfig.configPage.systConfig.GPS_L1CA.maxPrnNo;

%----- update satelliteTable ephemerisReady list from the ephemeris struct ------
for n = 1 : bds_maxprnNo % BDS satelliteTable
    satelliteTable(1).ephemerisReady(n) = naviMsg.BDS_B1I.ephemeris(n).ephReady;
    if naviMsg.BDS_B1I.almanac.dect(n)==1 && naviMsg.BDS_B1I.almanac.hea(n)==0
        satelliteTable(1).almanacReady(n) = 1; % 
    end
end
for n = 1 : gps_maxprnNo % GPS satelliteTable
    satelliteTable(2).ephemerisReady(n) = naviMsg.GPS_L1CA.ephemeris(n).ephReady;
    if naviMsg.GPS_L1CA.almanac.dect(n)==1 && naviMsg.GPS_L1CA.almanac.hea(n)==0
        satelliteTable(2).almanacReady(n) = 1; % 
    end
end



if start_updateTable
    if strcmp(receiver.syst, 'BDS_B1I') || strcmp(receiver.syst, 'B1I_L1CA')
        
%         transmitTime = zeros(bds_maxprnNo, 1) + timer.recvSOW_BDS;
        transmitTime = zeros(bds_maxprnNo, 1) + get_rxTime('BDS_B1I', timer);

        for n = 1 : bds_maxprnNo % loop around the satllite table
            satPos_UpdatReady = 0;
            if transmitTime >=0
                % Caculate satellite xyz positions with eph or alm info
                if satelliteTable(1).ephemerisReady(n) % 1: sat's ephemeris available
                    activePrn = satelliteTable(1).PRN(n);
                    [satPositions, ~, ~] = BD_calculateSatPosition(transmitTime, naviMsg.BDS_B1I.ephemeris, activePrn);
                    satelliteTable(1).satPosxyz(1:6,n) = satPositions(1:6, satelliteTable(1).PRN(n));
                    satelliteTable(1).ephemerisAge(n) = ephAge_compute('BDS_B1I', timer, naviMsg.BDS_B1I.ephemeris(n).eph); 
                    satelliteTable(1).satHealth(n) = naviMsg.BDS_B1I.ephemeris(n).eph.health;
                    satPos_UpdatReady = 1;
                elseif satelliteTable(1).almanacReady(n) % 1: sat's almanac is available
                    activePrn = satelliteTable(1).PRN(n);
                    satPositions = calSatPosAlm('BDS_B1I', timer.recvSOW_BDS, naviMsg.BDS_B1I.almanac.alm(n), activePrn);
                    satelliteTable(1).satPosxyz(1:6,n) = satPositions(1:6);
                    satelliteTable(1).almanacAge(n) = almAge_compute(timer, naviMsg.BDS_B1I.almanac.alm(n), 'BDS_B1I'); 
                    satPos_UpdatReady = 1;
                end
                % Caculate satellite elevation and azimuth info if possible
                if satPos_UpdatReady &&  (pvtCalculator.posiCheck==1) %~isempty(config.recvConfig.truePosition) && satPos_UpdatReady

%                     [az, el, ~] = topocent(config.recvConfig.truePosition(1:3), satelliteTable(1).satPosxyz(1:3,n) - config.recvConfig.truePosition(1:3));
                    [az, el, ~] = topocent(pvtCalculator.positionXYZ(1:3), satelliteTable(1).satPosxyz(1:3,n) - pvtCalculator.positionXYZ(1:3));
                    satelliteTable(1).satElevation(n) = el;
                    satelliteTable(1).satAzimuth(n) = az;
                    if el > 0
                        satelliteTable(1).satVisible(n) = 1;
                    else
                        satelliteTable(1).satVisible(n) = 0;
                    end
                end
            end %EOF "if transmitTime >=0"
            
            if strcmp(satelliteTable(1).processState(n), 'TRACK') || strcmp(satelliteTable(1).processState(n), 'SUBFRAME_SYNCED')
                satelliteTable(1).satVisible(n) = 1;
            end
             % Update Sat signal SNR or MP info if possible
            if activeNum_BDS > 0 %~isempty(activeChannel_BDS)
                if ismember(n,activeChannel_BDS(2,:))
                    [~,~,index] = intersect(n,activeChannel_BDS(2,:));
                    satelliteTable(1).SCNR(2,n) = channels(activeChannel_BDS(1,index)).CH_B1I(1).CN0_Estimator.CN0;
                    satelliteTable(1).SCNR(1,n) = channels(activeChannel_BDS(1,index)).ALL.SNR;
                    satelliteTable(1).MPStatus(n) = channels(activeChannel_BDS(1,index)).STR_CAD.CadUnit_N;
                end
            end
            % 设置blockage 
            if satelliteTable(1).satBlock(n) == 1
                satelliteTable(1).satBlockAge(n) = satelliteTable(1).satBlockAge(n) - satelliteTable(1).updateTime.timeInterval;  % update blockAge
            end
            
        end%EOF "for n=1:bds_maxprnNo % loop around the satllite table"  
        % Update time
        satelliteTable(1).updateTime.timeInterval = 0;  % 更新成功则清0
        satelliteTable(1).updateTime.recvSOW = timer.recvSOW;
        satelliteTable(1).updateTime.weeknum = timer.weeknum;
    end %EOF：if SYST == BDS
    
    if strcmp(receiver.syst, 'GPS_L1CA') || strcmp(receiver.syst, 'B1I_L1CA')
        
%         transmitTime = zeros(gps_maxprnNo, 1) + timer.recvSOW_GPS;
        transmitTime = zeros(gps_maxprnNo, 1) + get_rxTime('GPS_L1CA', timer);

        for n = 1 : gps_maxprnNo % loop around the satllite table
            satPos_UpdatReady = 0;
            if transmitTime >=0
                % Caculate satellite xyz positions with eph or alm info
                if satelliteTable(2).ephemerisReady(n) % 1: sat's ephemeris available
                    activePrn = satelliteTable(2).PRN(n);
                    [satPositions, ~, ~] = GPS_calculateSatPosition(transmitTime, naviMsg.GPS_L1CA.ephemeris, activePrn);
                    satelliteTable(2).satPosxyz(1:6,n) = satPositions(1:6, satelliteTable(2).PRN(n));

                    satelliteTable(2).ephemerisAge(n) = ephAge_compute('GPS_L1CA', timer, naviMsg.GPS_L1CA.ephemeris(n).eph); 
                    satelliteTable(2).satHealth(n) = naviMsg.GPS_L1CA.ephemeris(n).eph.health;
                    satPos_UpdatReady = 1;
                elseif satelliteTable(2).almanacReady(n) % 1: sat's almanac is available
                    activePrn = satelliteTable(2).PRN(n);
                    satPositions = calSatPosAlm('GPS_L1CA', timer.recvSOW_GPS, naviMsg.GPS_L1CA.almanac.alm(n), activePrn);
                    satelliteTable(2).satPosxyz(1:6,n) = satPositions(1:6);
                    satelliteTable(2).almanacAge(n) = almAge_compute(timer, naviMsg.GPS_L1CA.almanac.alm(n), 'GPS_L1CA');
                    satPos_UpdatReady = 1;
                end
                % Caculate satellite elevation and azimuth info if possible
                if satPos_UpdatReady &&  (pvtCalculator.posiCheck==1)% ~isempty(config.recvConfig.truePosition) && satPos_UpdatReady

%                     [az, el, ~] = topocent(config.recvConfig.truePosition(1:3), satelliteTable(2).satPosxyz(1:3,n) - config.recvConfig.truePosition(1:3));
                    [az, el, ~] = topocent(pvtCalculator.positionXYZ(1:3), satelliteTable(2).satPosxyz(1:3,n) - pvtCalculator.positionXYZ(1:3));
                    satelliteTable(2).satElevation(n) = el;
                    satelliteTable(2).satAzimuth(n) = az;
                    if el > 0
                        satelliteTable(2).satVisible(n) = 1;
                    else
                        satelliteTable(2).satVisible(n) = 0;
                    end
                end
            end %EOF "if transmitTime >=0"
            
            if strcmp(satelliteTable(2).processState(n), 'TRACK') || strcmp(satelliteTable(2).processState(n), 'SUBFRAME_SYNCED')
                satelliteTable(2).satVisible(n) = 1;
                %这里是否需要把对应satBlock也设为1
            end
            % Update Sat signal SNR or MP info if possible
            if activeNum_GPS > 0 % ~isempty(activeChannel_GPS)
                if ismember(n,activeChannel_GPS(2,:))
                    [~,~,index] = intersect(n,activeChannel_GPS(2,:));
                    satelliteTable(2).SCNR(2,n) = channels(activeChannel_GPS(1,index)).CH_L1CA(1).CN0_Estimator.CN0;
                    %Here we use SNR to show the satellite's signal
                    %strength
                    satelliteTable(2).SCNR(1,n) = channels(activeChannel_GPS(1,index)).ALL.SNR;
                    satelliteTable(2).MPStatus(n) = channels(activeChannel_GPS(1,index)).STR_CAD.CadUnit_N;
                end
            end
            % 设置blockage
            if satelliteTable(2).satBlock(n) == 1
                satelliteTable(2).satBlockAge(n) = satelliteTable(2).satBlockAge(n) - satelliteTable(2).updateTime.timeInterval;  % update blockAge
            end
        end%EOF "for n=1:gps_maxprnNo % loop around the satllite table"

        % Update time
        satelliteTable(2).updateTime.timeInterval = 0;  % 更新成功则清0
        satelliteTable(2).updateTime.recvSOW = timer.recvSOW;
        satelliteTable(2).updateTime.weeknum = timer.weeknum;
    end %EOF：if SYST == GPS
end %EOF： if start_updateTable
receiver.config         = config;
receiver.channels       = channels;
receiver.satelliteTable = satelliteTable;
receiver.timer          = timer;
receiver.naviMsg        = naviMsg;