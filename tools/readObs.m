function [parameter, SOW] = readObs(filename)


% 功能：软件接收机输出参数LOG文件读取代码
% 输入：
%       filename : 文件路径及文件名
% 输出：
%       SOW :   记录时刻的SOW值     [1 × 记录时刻]
%       parameter : 详细记录参数    [系统 × 参数数目]
%                   各个参数具体说明参考parameter初始化注释
% 说明：SOW中的记录时刻与各个参数中的记录时刻相对应，同一记录时刻时间一致。
%       记录值为NaN表示此刻无该卫星数据记录。
%--------------------------------------------------------------------------
% clear;clc;
% filename = 'E:\陆家嘴数据处理代码\m\logfile\Lujiazui_static_point_10_2016-5-18_9-24-36_allObs.txt';
maxPrnNo = 35;      % 系统PRN号最大值
maxPath = 5;        % 每颗卫星信号最多达到路径数目
firstEpoch = 1;     % 记录参数的开始时刻
endEpoch = 100000000;  % 记录参数的结束时刻
wrongLine = [];     % 记录有误的信息行号
logCountAll = 0;    % 读取总记录次数
linecount = 0;      % 当前读取信息行在文件中的行号
debug = 0;          % 若为调试状态则设为1
fid = fopen(filename);
if fid == -1
    error('message data file not found or permission denied');
end
%—————————— 读取总共记录时刻次数 ————————%
while 1
    line = fgetl(fid);
    if ~ischar(line)
        break;
    end
    if strcmp(line(1), '>')
        logCountAll = logCountAll + 1;
    end
end
 fclose(fid); 
 if endEpoch > logCountAll
     endEpoch = logCountAll;
 end
 logCount = endEpoch - firstEpoch + 1;
%% 初始化
%———————————— 参数初始化 ————————————%
SOW = nan(4,logCount);          % 记录时刻的SOW值、时、分、秒 [4 × 记录时刻]
parameter = struct(...
    'SYST',              '',...                         % 系统
    'prnMax',           [],...                          % 此段数据所有可见卫星信号的PRN号
    'prnNo',            nan(maxPrnNo,logCount),...      % 当前时刻可见卫星的PRN号
    'PDOP',             nan(1,logCount),...             % PDOP值 [1 × 记录时刻]
    'localClkErr',      nan(1,logCount),...             % 本地钟差 [1 × 记录时刻]
    'localClkDrift',    nan(1,logCount),...             % 本地钟漂 [1 × 记录时刻]
    'Elevation',        nan(maxPrnNo,logCount),...      % 仰角 [卫星PRN号 × 记录时刻]
    'Azimuth',          nan(maxPrnNo,logCount),...      % 方位角 [卫星PRN号 × 记录时刻]
    'Pseudorange',      nan(maxPrnNo,logCount),...      % 伪距 [卫星PRN号 × 记录时刻]
    'InteDopp',         nan(maxPrnNo,logCount),...      % 积分多普勒 [卫星PRN号 × 记录时刻]
    'TransTime',        nan(maxPrnNo,logCount),...      % 信号发射时间 [卫星PRN号 × 记录时刻]
    'carriErr',         nan(maxPrnNo,logCount),...      % 载波环估计误差方差 （°）[卫星PRN号 × 记录时刻]
    'carriPhase',       nan(maxPrnNo,logCount),...      % 载波相位值 [卫星PRN号 × 记录时刻]
    'doppFreq',        nan(maxPrnNo,logCount),...       % 多普勒频率 [卫星PRN号 × 记录时刻]
    'codePhase',        nan(maxPrnNo,logCount),...      % 扩频码相位 [卫星PRN号 × 记录时刻]
    'satPos',           '',...                          % 卫星位置
    'satClkErr',        nan(maxPrnNo,logCount),...      % 卫星钟差 [卫星PRN号 × 记录时刻]
    'satClkDrift',      nan(maxPrnNo,logCount),...      % 卫星钟差漂移 [卫星PRN号 × 记录时刻]
    'pathNum',          nan(maxPrnNo,logCount),...      % 信号路径数目 [卫星PRN号 × 记录时刻]
    'codePhaseErr',     nan(maxPrnNo,logCount),...      % 多径引起的码相位偏差 [卫星PRN号 × 记录时刻]
    'pathPara',         ''...
    );
parameter(1:2,1) = parameter;
satPos = struct(...
    'position',         nan(3,logCount),...             % 卫星位置 [(X Y Z) × 记录时刻]
    'velocity',         nan(3,logCount)...              % 卫星速度 [(Vx Vy Vz) × 记录时刻]
    );
pathPara = struct(...
    'codePhaseDelay',   nan(maxPath,logCount),...             % 码相位延时 [1 × 记录时刻]
    'ampI',             nan(maxPath,logCount),...             % I路信号幅值 [1 × 记录时刻]
    'ampQ',             nan(maxPath,logCount),...             % Q路信号幅值 [1 × 记录时刻]
    'SNR',              nan(maxPath,logCount),...             % 信噪比 [1 × 记录时刻]
    'CNR',              nan(maxPath,logCount)...              % 载噪比 [1 × 记录时刻]
    );
parameter(1).SYST = 'BDS_B1I';      % 第一行记录北斗B1I信号参数
parameter(2).SYST = 'GPS_L1CA';     % 第二行记录GPS L1CA信号参数
parameter(1).satPos = satPos;
parameter(1).satPos(1:maxPrnNo,1) = parameter(1).satPos;
parameter(2).satPos = satPos;
parameter(2).satPos(1:maxPrnNo,1) = parameter(2).satPos;
parameter(1).pathPara = pathPara;
parameter(1).pathPara(1:maxPrnNo,1) = parameter(1).pathPara;
parameter(2).pathPara = pathPara;
parameter(2).pathPara(1:maxPrnNo,1) = parameter(2).pathPara;

%% 读取参数
fid = fopen(filename);
if fid == -1
   error('message data file not found or permission denied');
end

% —————————— 读取文件头信息 ——————————%
while 1   % this is the numeral '1'
    line = fgetl(fid);
    linecount = linecount + 1;
    len = length(line);
    if len < 80, line(len+1:80) = '0'; end 
    if strcmp(line(61:73),'END OF HEADER')
        break
    end
    if strcmp(line(61:79), 'APPROX POSITION XYZ')
        POSITION_XYZ(1) = str2double(line(1:14));
        POSITION_XYZ(2) = str2double(line(15:28));
        POSITION_XYZ(3) = str2double(line(29:42));
    end
    if strcmp(line(61:80), 'ANTENNA: DELTA H/E/N')
        ANTDELTA(1) = str2double(line(1:14));
        ANTDELTA(2) = str2double(line(15:28));
        ANTDELTA(3) = str2double(line(29:42));
    end
    if strcmp(line(61:79), 'SYS / # / OBS TYPES')
        numobs = str2double(line(5:6));
        if numobs > 9
            error('number of types of observations > 9')
        end
        obtype(1,:) = line(8:10);
        obtype(2,:) = line(12:14);
        obtype(3,:) = line(16:18);
        obtype(4,:) = line(20:22);
    end
    if strcmp(line(61:68), 'INTERVAL')
        OBSINT = str2double(line(1:10));
    end
end

%—————————————— 读取参数观测量 ————————————%
k = 0;              % 读取文件的历元计数
breakflag = 0;      % 循环跳出标志位
while 1
    %—————————— 读取记录时刻信息 ——————————%
    k = k + 1;                      % 读取历元计数加1
    linecount = linecount + 1;      % 读取行数加1
    if k < firstEpoch
        continue;
    elseif k > endEpoch
        break;
    end
    line = fgetl(fid);
    if ~ischar(line)
        breakflag = 1; 
        break;
    end
    year = str2double(line(3:6));
    month = str2double(line(8:9));
    day = str2double(line(11:12));
    hour = str2double(line(14:15));
    minute = str2double(line(17:18));
    second = str2double(line(20:29));
    todsec = 3600*hour + 60*minute + second;  % time of day in seconds
    daynum = dayofweek(year,month,day);
    SOW(1, k) = todsec + 86400*daynum; % 根据年月日，计算SOW值
    SOW(2, k) = hour;
    SOW(3, k) = minute;
    SOW(4, k) = second;
    satNum = str2double(line(31:32));
    parameter(1).PDOP(k) = str2double(line(34:39));
    parameter(2).PDOP(k) = str2double(line(34:39));
    parameter(1).localClkErr(k) = str2double(line(41:55));
    parameter(1).localClkDrift(k) = str2double(line(57:64));
    parameter(2).localClkErr(k) = str2double(line(66:80));
    parameter(2).localClkDrift(k) = str2double(line(82:89));
    satNum_BDS = 0;
    satNum_GPS = 0;
   %—————————— 读取每颗卫星的观测量 ——————————%
    for i = 1 : satNum
        line = fgetl(fid);
        sys = line(1);
        linecount = linecount + 1;
        switch sys
            case 'C' % 北斗系统
                satNum_BDS = satNum_BDS + 1;
                prn = str2double(line(2:3));
                parameter(1).prnNo(satNum_BDS, k) = prn;
                if ~ismember(prn, parameter(1).prnMax)
                    parameter(1).prnMax = [parameter(1).prnMax, prn];
                end
                parameter(1).Elevation(prn,k) = str2double(line(5:9));
                if parameter(1).Elevation(prn,k) < 0 % 若记录仰角小于0，则跳过
                    wrongLine = [wrongLine, linecount]; % 保存记录有误的文本行号
                    if debug == 0
                        continue;
                    end
                end
                parameter(1).Azimuth(prn,k) = str2double(line(11:16));
                Pseudorange = str2double(line(18:31));
                if abs(Pseudorange) > 99999999 % 若记录伪距异常，则跳过
                    wrongLine = [wrongLine, linecount]; % 保存记录有误的文本行号
                    if debug == 0
                        continue;
                    end
                end
                parameter(1).Pseudorange(prn,k) = Pseudorange;
                parameter(1).InteDopp(prn,k) = str2double(line(33:46));
                parameter(1).TransTime(prn,k) = str2double(line(48:66));
                parameter(1).carriErr(prn,k) = str2double(line(68:75))*360;
                parameter(1).carriPhase(prn,k) = str2double(line(77:84));
                parameter(1).doppFreq(prn,k) = str2double(line(86:98)) - 1561098000;
                parameter(1).codePhase(prn,k) = str2double(line(100:109));
                parameter(1).satClkErr(prn,k) = str2double(line(189:202));
                parameter(1).satClkDrift(prn,k) = str2double(line(204:211));
                parameter(1).satPos(prn).position(1:3,k) = [str2double(line(111:124));str2double(line(126:139));str2double(line(141:154))];
                parameter(1).satPos(prn).velocity(1:3,k) = [str2double(line(156:165));str2double(line(167:176));str2double(line(178:187))];
                parameter(1).pathNum(prn,k) = str2double(line(213:214));
                pathNo = parameter(1).pathNum(prn,k);
                if pathNo > 5 % 若记录伪距异常，则跳过
                    wrongLine = [wrongLine, linecount]; % 保存记录有误的文本行号
                    if debug == 0
                        continue;
                    end
                end
                for j = 1 : pathNo  % 读取此卫星每条到达径参数
                    index = 215 + 48*(j-1);
                    No = str2double(line(index+(1:2)));
                    if No == 1
                        parameter(1).pathPara(prn).codePhaseDelay(No,k) = 0;
                        parameter(1).codePhaseErr(prn, k) = str2double(line(index+(4:11)));
                    else
                        parameter(1).pathPara(prn).codePhaseDelay(No,k) = str2double(line(index+(4:11)));
                    end
                    parameter(1).pathPara(prn).ampI(No,k) = str2double(line(index+(13:23)));
                    parameter(1).pathPara(prn).ampQ(No,k) = str2double(line(index+(25:35)));
                    parameter(1).pathPara(prn).SNR(No,k) = str2double(line(index+(37:41)));
                    parameter(1).pathPara(prn).CNR(No,k) = str2double(line(index+(43:47)));
                end
            case 'G' % GPS系统
                satNum_GPS = satNum_GPS + 1;
                prn = str2double(line(2:3));
                parameter(2).prnNo(satNum_GPS, k) = prn;
                if ~ismember(prn, parameter(2).prnMax)
                    parameter(2).prnMax = [parameter(2).prnMax, prn];
                end
                parameter(2).Elevation(prn,k) = str2double(line(5:9));
                if parameter(2).Elevation(prn,k) < 0 % 若记录仰角小于0，则跳过
                    wrongLine = [wrongLine, linecount]; % 保存记录有误的文本行号
                    if debug == 0
                        continue;
                    end
                end
                parameter(2).Azimuth(prn,k) = str2double(line(11:16));
                Pseudorange = str2double(line(18:31));
                if abs(Pseudorange) > 99999999 % 若记录伪距异常，则跳过
                    wrongLine = [wrongLine, linecount]; % 保存记录有误的文本行号
                    if debug == 0
                        continue;
                    end
                end
                parameter(2).Pseudorange(prn,k) = Pseudorange;
                parameter(2).InteDopp(prn,k) = str2double(line(33:46));
                parameter(2).TransTime(prn,k) = str2double(line(48:66));
                parameter(2).carriErr(prn,k) = str2double(line(68:75))*360;
                parameter(2).carriPhase(prn,k) = str2double(line(77:84));
                parameter(2).doppFreq(prn,k) = str2double(line(86:98)) - 1575420000;
                parameter(2).codePhase(prn,k) = str2double(line(100:109));
                parameter(2).satClkErr(prn,k)= str2double(line(189:202));
                parameter(2).satClkDrift(prn,k) = str2double(line(204:211));
                parameter(2).satPos(prn).position(1:3,k) = [str2double(line(111:124));str2double(line(126:139));str2double(line(141:154))];
                parameter(2).satPos(prn).velocity(1:3,k) = [str2double(line(156:165));str2double(line(167:176));str2double(line(178:187))];
                parameter(2).pathNum(prn,k) = str2double(line(213:214));
                pathNo = parameter(2).pathNum(prn,k);
                if pathNo > 5 % 若记录伪距异常，则跳过
                    wrongLine = [wrongLine, linecount]; % 保存记录有误的文本行号
                    if debug == 0
                        continue;
                    end
                end
                for j = 1 : pathNo  % 读取此卫星每条到达径参数
                    index = 215 + 48*(j-1);
                    No = str2double(line(index+(1:2)));
                    if No == 1
                        parameter(2).pathPara(prn).codePhaseDelay(No,k) = 0;
                        parameter(2).codePhaseErr(prn, k) = str2double(line(index+(4:11)));
                    else
                        parameter(2).pathPara(prn).codePhaseDelay(No,k) = str2double(line(index+(4:11)));
                    end
                    parameter(2).pathPara(prn).ampI(No,k) = str2double(line(index+(13:23)));
                    parameter(2).pathPara(prn).ampQ(No,k) = str2double(line(index+(25:35)));
                    parameter(2).pathPara(prn).SNR(No,k) = str2double(line(index+(37:41)));
                    parameter(2).pathPara(prn).CNR(No,k) = str2double(line(index+(43:47)));
                end
        end % EOF : switch sys
    end % EOF : for i = 1 : satNum
end % EOF : while 1
parameter(1).prnMax = sort(parameter(1).prnMax);
parameter(2).prnMax = sort(parameter(2).prnMax);