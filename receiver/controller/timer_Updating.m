function receiver = timer_Updating(receiver, N)
global GSAR_CONSTANTS;     
half_week = GSAR_CONSTANTS.WEEKLONGSEC/2;

% recvSyst = receiver.syst;
channels = receiver.channels;
timer = receiver.timer;
actvPvtChannels = receiver.actvPvtChannels;

timeinterval_elaps = N / GSAR_CONSTANTS.STR_RECV.fs;

%% recvTimer progressing
if timer.recvSOW_BDS == -1 % this means the local BDS timer has not been initialized
    if actvPvtChannels.actChnsNum_BDS > 0
        transTime_bds = findTransTime_BD(channels, actvPvtChannels.BDS(1,1:actvPvtChannels.actChnsNum_BDS));
        transtimeList = transTime_bds(transTime_bds~=0);
        
        if (max(transtimeList) - min(transtimeList)) > half_week
            transtimeList = transtimeList(transtimeList < half_week);
        end
        timer.recvSOW_BDS = median(transtimeList) + 70*1e-3;
        timer.weeknum_BDS = receiver.naviMsg.BDS_B1I.ephemeris(actvPvtChannels.BDS(2,1)).eph.weekNumber;
    end
else % local bds timer has been initialized
    timer.recvSOW_BDS = timer.recvSOW_BDS + timeinterval_elaps;
end
[timer.weeknum_BDS, timer.recvSOW_BDS] = timerWeekSow_Increment(timer.weeknum_BDS, timer.recvSOW_BDS);

if timer.recvSOW_GPS == -1
    if actvPvtChannels.actChnsNum_GPS > 0
        transTime_gps = findTransTime_GPS(channels, actvPvtChannels.GPS(1,1:actvPvtChannels.actChnsNum_GPS));
        transtimeList = transTime_gps(transTime_gps~=0);
        
        if (max(transtimeList) - min(transtimeList)) > half_week
            transtimeList = transtimeList(transtimeList < half_week);
        end
        timer.recvSOW_GPS = median(transtimeList) + 70*1e-3;
        timer.weeknum_GPS = receiver.naviMsg.GPS_L1CA.ephemeris(actvPvtChannels.GPS(2,1)).eph.weekNumber;
    end
else
    timer.recvSOW_GPS = timer.recvSOW_GPS + timeinterval_elaps;
end
[timer.weeknum_GPS, timer.recvSOW_GPS] = timerWeekSow_Increment(timer.weeknum_GPS, timer.recvSOW_GPS);

switch timer.timeType
    case 'NULL'
        if timer.recvSOW_BDS ~= -1
            timer.timeType = 'BDST';
            timer.recvSOW = timer.recvSOW_BDS;
            timer.weeknum = timer.weeknum_BDS;
        elseif timer.recvSOW_GPS ~= -1
            timer.timeType = 'GPST';
            timer.recvSOW = timer.recvSOW_GPS;
            timer.weeknum = timer.weeknum_GPS;
        end
    case 'BDST'
        if timer.recvSOW_BDS ~= -1
            timer.recvSOW = timer.recvSOW_BDS;
            timer.weeknum = timer.weeknum_BDS;
        elseif timer.recvSOW_GPS ~= -1
            timer.recvSOW = timer.recvSOW_GPS - timer.BDT2GPST(1);
            timer.weeknum = timer.weeknum_GPS - timer.BDT2GPST(2);
        end
    case 'GPST'
        if timer.recvSOW_GPS ~= -1
            timer.recvSOW = timer.recvSOW_GPS;
            timer.weeknum = timer.weeknum_GPS;
        elseif timer.recvSOW_BDS ~= -1
            timer.recvSOW = timer.recvSOW_BDS + timer.BDT2GPST(1);
            timer.weeknum = timer.weeknum_BDS + timer.BDT2GPST(2);
        end
end

%% 控制读取的数据边沿与定位时间对齐
if (timer.recvSOW ~= -1) && (receiver.pvtCalculator.dataNum < 0)
    Tunit = timeinterval_elaps;
    round_check = mod(timer.recvSOW, receiver.pvtCalculator.pvtT);
    if round_check >= receiver.pvtCalculator.pvtT/2
        timeAdd = 2 * receiver.pvtCalculator.pvtT - round_check;
    else
        timeAdd = receiver.pvtCalculator.pvtT - round_check;
    end    
    timer.tNext = timer.recvSOW + timeAdd;
    receiver.pvtCalculator.dataNum = ceil(timeAdd/Tunit);
end

% update the receiver clk error counters
timer.rclkErr2Syst_UpCnt = timer.rclkErr2Syst_UpCnt + timeinterval_elaps;


receiver.timer = timer;


% if timer.recvSOW ~= -1
%     timer.recvSOW = timer.recvSOW + N / GSAR_CONSTANTS.STR_RECV.fs;  
% end
% if timer.recvSOW_BDS ~= -1
%     timer.recvSOW_BDS = timer.recvSOW_BDS + N / GSAR_CONSTANTS.STR_RECV.fs;
% end
% if timer.recvSOW_GPS ~= -1;     
%     timer.recvSOW_GPS = timer.recvSOW_GPS + N / GSAR_CONSTANTS.STR_RECV.fs;
% end  