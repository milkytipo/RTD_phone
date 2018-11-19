function [weeknum, recvSOW] = timerWeekSow_Increment(weeknum, recvSOW)
global GSAR_CONSTANTS;
weeklongSec = GSAR_CONSTANTS.WEEKLONGSEC;

if recvSOW >= weeklongSec
    weeknum = weeknum + 1;
    recvSOW = recvSOW - weeklongSec;
end