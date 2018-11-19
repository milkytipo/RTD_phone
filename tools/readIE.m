function [XYZ, LLH, TOWSEC, HHMMSS] = readIE(filename, YYMMDD)
% filename='G:\positionVisible\code\data file\MinhangTV_Moving_1-1050s_GPGGA.txt';   % 输入文件名字
% YYMMDD = '20150610';    % 输入年月日信息
year = str2double(YYMMDD(1:4));
month = str2double(YYMMDD(5:6));
day = str2double(YYMMDD(7:8));
fid = fopen(filename);
if fid==-1
   error('message data file not found or permission denied');
end
frewind(fid)
%  Loop through the file
k = 0;  breakflag = 0;
% 跳过头文件
while 1
    line = fgetl(fid);
   if strcmp(line(1), '>')
       break;
   end
end

while 1     % this is the numeral '1'
   line = fgetl(fid);
   if ~ischar(line)
       breakflag = 1; 
       break;
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
   latitude = str2double(line(15:16)) + str2double(line(18:19))/60 + str2double(line(21:28))/3600;
   longitude = str2double(line(31:33)) + str2double(line(35:36))/60 + str2double(line(38:45))/3600;
   height = str2double(line(50:56));         
   LLH(:, k) = [latitude; longitude; height];
   XYZ(:, k) = llh2xyz(LLH(:, k))';  % 转化为xyz坐标   
%    waitbar(linecount/numlines,bar1)
end  % End the WHILE 1 Loop
fclose(fid);