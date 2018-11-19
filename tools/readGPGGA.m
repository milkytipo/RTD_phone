function [XYZ, TOWSEC] = readGPGGA(filename, YYMMDD)
% filename='G:\positionVisible\code\data file\MinhangTV_Moving_1-1050s_GPGGA.txt';   % 输入文件名字
% YYMMDD = '20150610';    % 输入年月日信息
year = str2double(YYMMDD(1:4));
month = str2double(YYMMDD(5:6));
day = str2double(YYMMDD(7:8));
decimate_factor=1;     %  If it is equal to '1', then every data point is read in and stored.  If it is equal
%                        to '2', then every second data point is stored.
%                        If '3', then every third data point is stored,
%                        et cetera.
if decimate_factor < 1, error('decimate_factor must be a positive integer'), end
if rem(decimate_factor,1) > 0, error('decimate_factor must be a positive integer'), end
fid = fopen(filename);
if fid==-1
   error('message data file not found or permission denied');
end
% numlines = 0;
% while 1     % this is the numeral '1'
%    numlines = numlines + 1;
%    %
%    line = fgetl(fid);
%    if ~ischar(line), break, end
% end
frewind(fid)
hour = NaN;  % 时分秒
min = NaN;
sec = NaN;
latitude = NaN; % 纬度
longitude = NaN; % 经度
height = NaN;   % 
linecount = 0;

%  Loop through the file
k = 0;  breakflag = 0;
while 1     % this is the numeral '1'
   k = k + 1;    % 'k' is keeping track of our time steps
   numBit = 0; % 逗号的个数
   for ideci = 1:decimate_factor,
       %
       line = fgetl(fid);
       if ~ischar(line), breakflag = 1; break, end
       
           linecount = linecount + 1;
           len = length(line);    
           for ii = 1:len 
               if strcmp(line(ii), ',')
                   numBit = numBit + 1;     % 逗号个数加1
                   if numBit == 1
                       hour = str2double(line(ii+1:ii+2));
                       min  = str2double(line(ii+3:ii+4));
                       sec  = str2double(line(ii+5:ii+10));
                       todsec = 3600*hour + 60*min + sec;  % time of day in seconds       
                       daynum = dayofweek(year,month,day);
                       TOWSEC(k) = todsec + 86400*daynum;   % 当前条数的周内秒
                   end
                   if numBit == 2
                       latitude(k) = str2double(line(ii+1:ii+2)) + str2double(line(ii+3:ii+9))/60;
                   end
                   if numBit == 4
                       longitude(k) = str2double(line(ii+1:ii+3)) + str2double(line(ii+4:ii+10))/60;
                   end
                   if numBit == 8
                       height(k) = str2double(line(ii+1:ii+5));
                   end

               end
           end   % End the "for i = 1:numsvs(k)" Loop
   end  % End the "for ideci = 1:decimate_factor" Loop
   if breakflag == 1, break, end
   LLH(k,:) = [latitude(k), longitude(k), height(k)];
   XYZ(k,:) = llh2xyz(LLH(k,:));  % 转化为xyz坐标   
%    waitbar(linecount/numlines,bar1)
end  % End the WHILE 1 Loop
fclose(fid);
