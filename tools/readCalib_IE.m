function [XYZ, LLH, TOWSEC, HHMMSS] = readCalib_IE(filename)
%   function :  Read the calibration file which is processed by Inertial Explorer
%         
%   Input:
%       filename = 'E:\calibration\xxx.txt';  % The file name with detailed path
%   
%	Output:
%       calibPara = 
%       llh(3) = height above ellipsoid in meters
%
%	xyz(1) = ECEF x-coordinate in meters
%	xyz(2) = ECEF y-coordinate in meters
%	xyz(3) = ECEF z-coordinate in meters



fid = fopen(filename);
if fid==-1
   error('Calibration file not found or permission denied');
end
frewind(fid)
%—————————— 读取总共记录时刻次数 ————————%
lineNum = 0;
while ~feof(fid)
    line = fgetl(fid);
    lineNum = lineNum + 1;
    if strcmp(line(1:9), 'Data Date')
        year = str2double(line(14:17));
        month = str2double(line(19:20));
        day = str2double(line(22:23));
    end
    if strcmp(line(1:5), 'START')
        headLineNum = lineNum; % the line number of head message
        fidData = fid;
    end
end
epochNum = lineNum - headLineNum; % the line number of data calibration message
frewind(fid)


calibPara = struct(...
    'SOW',           [],...                          % 此段数据所有可见卫星信号的PRN号
    'LLH',              nan(epochNum,3),...      % 当前时刻可见卫星的PRN号
    'XYZ',              nan(epochNum,logCount),...             % PDOP值 [1 × 记录时刻]
    'localClkErr',      nan(1,logCount),...             % 本地钟差 [1 × 记录时刻]
    'localClkDrift',    nan(1,logCount),...             % 本地钟漂 [1 × 记录时刻]
    'Elevation',        nan(maxPrnNo,logCount),...      % 仰角 [卫星PRN号 × 记录时刻]
    'Azimuth',          nan(maxPrnNo,logCount),...      % 方位角 [卫星PRN号 × 记录时刻]
    'Pseudorange',      nan(maxPrnNo,logCount),...      % 伪距 [卫星PRN号 × 记录时刻]
    'InteDopp',         nan(maxPrnNo,logCount),...      % 积分多普勒 [卫星PRN号 × 记录时刻]
    'TransTime',        nan(maxPrnNo,logCount),...      % 信号发射时间 [卫星PRN号 × 记录时刻]
    'carriErr',         nan(maxPrnNo,logCount),...      % 载波环估计误差方差 （°）[卫星PRN号 × 记录时刻]
    'carriPhase',       nan(maxPrnNo,logCount),...      % 载波相位值 [卫星PRN号 × 记录时刻]
    'doppFreq',        nan(maxPrnNo,logCount),...      % 载波频率 [卫星PRN号 × 记录时刻]
    'codePhase',        nan(maxPrnNo,logCount),...      % 扩频码相位 [卫星PRN号 × 记录时刻]
    'satPos',           '',...                          % 卫星位置
    'satClkErr',        nan(maxPrnNo,logCount),...      % 卫星钟差 [卫星PRN号 × 记录时刻]
    'satClkDrift',      nan(maxPrnNo,logCount),...      % 卫星钟差漂移 [卫星PRN号 × 记录时刻]
    'pathNum',          nan(maxPrnNo,logCount),...      % 信号路径数目 [卫星PRN号 × 记录时刻]
    'codePhaseErr',     nan(maxPrnNo,logCount),...      % 多径引起的码相位偏差 [卫星PRN号 × 记录时刻]
    'pathPara',         ''...
    );






%  Loop through the file
k = 0;  breakflag = 0;
headEnd = 0;  % 跳过头文件
while 1     % this is the numeral '1'
   line = fgetl(fid);
   if ~ischar(line)
       breakflag = 1; 
       break;
   end
   if strcmp(line(1:5),'ho mi')
       headEnd = 1;
       continue;
   end
   if headEnd == 0
       continue;
   end
   k = k + 1;    
   hour = str2double(line(1:2));
   min  = str2double(line(4:5));
   sec  = str2double(line(7:11));
   todsec = 3600*hour + 60*min + sec;  % time of day in seconds       
   daynum = dayofweek(year,month,day);
   TOWSEC(k) = todsec + 86400*daynum;   % 当前条数的周内秒
   HHMMSS(1, k) = hour;
   HHMMSS(2, k) = min;
   HHMMSS(3, k) = sec;
   latitude(k) = str2double(line(13:26));
   longitude(k) = str2double(line(28:41));
   height(k) = str2double(line(43:54));         
   LLH(k,:) = [latitude(k), longitude(k), height(k)];
   XYZ(k,:) = llh2xyz(LLH(k,:));  % 转化为xyz坐标   
%    waitbar(linecount/numlines,bar1)
end  % End the WHILE 1 Loop
fclose(fid);