%% Initialize time structure.
function [time]= TimerInitializing(time, config)
time.recvSOW = -1;    % 接收机本地时间
time.recvSOW_BDS = -1;    % （北斗系统时间）
time.recvSOW_GPS = -1;    % （GPS系统时间）
time.weeknum = -1;  % 周数
time.weeknum_BDS = -1;  % 北斗周
time.weeknum_GPS = -1;  % GPS周
time.year = -1;
time.month = -1;
time.day = -1;
time.hour = -1;
time.min = -1;
time.sec = -1;
time.timeType = config.recvConfig.timeType;   % NULL / GPST / BDST / UTC
time.timeCheck = -1;  % 时间确认标志位
time.rclkErr2Syst_UpCnt = ones(size(time.rclkErr2Syst_UpCnt)) * time.rclkErr2Syst_Thre;
time.BDT2GPST = [14, 332];  % [SOW, week]
time.tNext = -1;  % 下一次定位的时间
time.CL_time = -1;
end
