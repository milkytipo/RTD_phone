function [Vel, TOWSEC] = readFile(filename)
% filename='G:\positionVisible\code\data file\MinhangTV_Moving_1-1050s_GPGGA.txt';   % 输入文件名字
% YYMMDD = '20150610';    % 输入年月日信息
fid = fopen(filename);
if fid==-1
   error('message data file not found or permission denied');
end

frewind(fid)
%  Loop through the file
k = 0;  breakflag = 0;
headEnd = 0;  % 跳过头文件
while 1     % this is the numeral '1'
   line = fgetl(fid);
   if ~ischar(line), breakflag = 1; break, end
   if strcmp(line(1:10),'    (sec) ')
       headEnd = 1;
       continue;
   end
   if headEnd == 0
       continue;
   end
   k = k + 1;    
%    hour = str2double(line(1:2));
%    min  = str2double(line(4:5));
%    sec  = str2double(line(7:11));
%    todsec = 3600*hour + 60*min + sec;  % time of day in seconds       
%    daynum = dayofweek(year,month,day);
   TOWSEC(k) = str2double(line(1:9));   % 当前条数的周内秒
   Vel(k, 1) = str2double(line(51:58));
   Vel(k, 2) = str2double(line(61:68));
   Vel(k, 3) = str2double(line(71:78));
%    latitude(k) = str2double(line(11:22));
%    longitude(k) = str2double(line(28:41));
%    height(k) = str2double(line(43:54));         
%    LLH(k,:) = [latitude(k), longitude(k), height(k)];
%    XYZ(k,:) = llh2xyz(LLH(k,:));  % 转化为xyz坐标   
%    waitbar(linecount/numlines,bar1)
end  % End the WHILE 1 Loop
fclose(fid);