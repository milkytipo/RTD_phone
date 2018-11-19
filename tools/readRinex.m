% function [C1, L1,S1,D1,ch,TOWSEC]=read_rinex(filename,decimate_factor)
clear;
filename='F:\IF_DATA\20170813\BMAW14510070R_11.17O';
decimate_factor=1;     %  If it is equal to '1', then every data point is read in and stored.  If it is equal
%                        to '2', then every second data point is stored.
%                        If '3', then every third data point is stored,
%                        et cetera.
%   Output:    参数类型： 为结构体，包含.BDS和.GPS       
%               C1: 伪距              [卫星号 × 时长]
%               L1：积分多普勒
%               S1：载噪比
%               D1：多普勒频移
%               ch: 可用卫星号         [时长 × 可见卫星数目]
%               TOWSEC：周内秒         [1 × 时长] 
if decimate_factor < 1, error('decimate_factor must be a positive integer'), end
if rem(decimate_factor,1) > 0, error('decimate_factor must be a positive integer'), end
fid = fopen(filename);
if fid==-1
   error('RINEX Navigation message data file not found or permission denied');
end
numlines = 0;
while 1     % this is the numeral '1'
   numlines = numlines + 1;
   %
   line = fgetl(fid);
   if ~ischar(line), break, end
end
frewind(fid)
C1=[]; L1=[]; S1=[]; D1=[]; POSITION_XYZ=[]; ANTDELTA=[];
obtype.GPS(1,:) = 'NNN';
obtype.GPS(2,:) = 'NNN';
obtype.GPS(3,:) = 'NNN';
obtype.GPS(4,:) = 'NNN';
obtype.BDS(1,:) = 'NNN';
obtype.BDS(2,:) = 'NNN';
obtype.BDS(3,:) = 'NNN';
obtype.BDS(4,:) = 'NNN';
linecount = 0;
%  Parse header
while 1   % this is the numeral '1'
    line = fgetl(fid);
    linecount = linecount + 1;

    len = length(line);
    if len < 80, line(len+1:80) = '0'; end
    
    if line(61:73) == 'END OF HEADER'
        break
    end
    if line(61:79) == 'APPROX POSITION XYZ'
        POSITION_XYZ(1) = str2num(line(1:14));
        POSITION_XYZ(2) = str2num(line(15:28));
        POSITION_XYZ(3) = str2num(line(29:42));
    end
    if line(61:80) == 'ANTENNA: DELTA H/E/N'
        ANTDELTA(1) = str2num(line(1:14));
        ANTDELTA(2) = str2num(line(15:28));
        ANTDELTA(3) = str2num(line(29:42));
    end
    if line(61:79) == 'SYS / # / OBS TYPES'
        numobs = str2num(line(5:6));
        if numobs > 9
            error('number of types of observations > 9')
        end
        if line(1) == 'G'
            obtype.GPS(1,:) = line(8:10);
            obtype.GPS(2,:) = line(12:14);
            obtype.GPS(3,:) = line(16:18);
            obtype.GPS(4,:) = line(20:22);
        
            
        end
        if line(1) == 'C'
            obtype.BDS(1,:) = line(8:10);
            obtype.BDS(2,:) = line(12:14);
            obtype.BDS(3,:) = line(16:18);
            obtype.BDS(4,:) = line(20:22);
        

        end
    end
    if line(61:68) == 'INTERVAL'
        OBSINT = str2num(line(1:10));
    end
%     if line(61:79) == 'RCV CLOCK OFFS APPL',
%         clkoffappl = str2num(line(1:6));
%     end
%     if line(61:72) == 'LEAP SECONDS',
%         leapsec = str2num(line(1:6));
%     end
end
%  Loop through the file
k = 0;  breakflag = 0;
while 1     % this is the numeral '1'
   k = k + 1;    % 'k' is keeping track of our time steps
   %
   for ideci = 1:decimate_factor
       %
       line = fgetl(fid);
       if ~ischar(line), breakflag = 1; break, end
       linecount = linecount + 1;
       len = length(line);
       if len < 80, line(len+1:80) = '0'; end
       %
       year(k) = str2double(line(3:6));
       month(k) = str2double(line(8:9));
       day(k) = str2double(line(11:12));
       hour(k) = str2double(line(14:15));
       minute(k) = str2double(line(17:18));
       second(k) = str2double(line(19:29));
   
       todsec(k) = 3600*hour(k) + 60*minute(k) + second(k);  % time of day in seconds
       
       daynum = dayofweek(year(k),month(k),day(k));
       TOWSEC(k) = todsec(k) + 86400*daynum;

       epochflg(k) = str2double(line(30:32));
       numsvs(k) = str2double(line(33:35));

%        CLOCKOFFSET(k) = str2double(line(69:80));
%        SVID_MAT(ch(1:numsvs(k)),k) = 1;
       num_BDS = 0;
       num_GPS = 0;
       for i = 1:numsvs(k)
           line = fgetl(fid);
           if ~ischar(line), break, end
           linecount = linecount + 1;
      
           len = length(line);
           if len < 80
              line(len+1:80) = '0';
           end
           sys = line(1);   % 读取卫星系统
           if strcmp(sys,'C')
               num_BDS = num_BDS + 1;
               ch.BDS(k,num_BDS)=str2double(line(2:3));
               SVID_MAT.BDS(ch.BDS(k,num_BDS),k) = 1;
               if numobs > 0 
                 ob.BDS(ch.BDS(k,num_BDS),k,1) = str2double(line(4:17));
               end
               if numobs > 1
                 ob.BDS(ch.BDS(k,num_BDS),k,2) = str2double(line(20:33));
               end
               if numobs > 2
                 ob.BDS(ch.BDS(k,num_BDS),k,3) = str2double(line(36:49));
               end
               if numobs > 3
                 ob.BDS(ch.BDS(k,num_BDS),k,4) = str2double(line(52:65));
               end
           elseif strcmp(sys,'G')
               num_GPS = num_GPS + 1;
               ch.GPS(k,num_GPS)=str2double(line(2:3));
               SVID_MAT.GPS(ch.GPS(k,num_GPS),k) = 1;
               if numobs > 0
                 ob.GPS(ch.GPS(k,num_GPS),k,1) = str2double(line(4:17));
               end
               if numobs > 1
                 ob.GPS(ch.GPS(k,num_GPS),k,2) = str2double(line(20:33));
               end
               if numobs > 2
                 ob.GPS(ch.GPS(k,num_GPS),k,3) = str2double(line(36:49));
               end
               if numobs > 3
                 ob.GPS(ch.GPS(k,num_GPS),k,4) = str2double(line(52:65));
               end
           end

       end   % End the "for i = 1:numsvs(k)" Loop
   end  % End the "for ideci = 1:decimate_factor" Loop
   if breakflag == 1, break, end
%    waitbar(linecount/numlines,bar1)
end  % End the WHILE 1 Loop
for i = 1:4


    if strcmp(obtype.BDS(i,:), 'C1I') 
        C1.BDS = ob.BDS(:,:,i);
    end
    if strcmp(obtype.GPS(i,:), 'C1C')
        C1.GPS = ob.GPS(:,:,i);
    end
    if strcmp(obtype.BDS(i,:), 'L1I') 
        L1.BDS = ob.BDS(:,:,i);
    end
    if strcmp(obtype.GPS(i,:), 'L1C')
        L1.GPS = ob.GPS(:,:,i);
    end
    if strcmp(obtype.BDS(i,:), 'S1I') 
        S1.BDS = ob.BDS(:,:,i);
    end
    if strcmp(obtype.GPS(i,:), 'S1C')
        S1.GPS = ob.GPS(:,:,i);
    end
    if strcmp(obtype.BDS(i,:), 'D1I') 
        D1.BDS = ob.BDS(:,:,i);
    end
    if strcmp(obtype.GPS(i,:), 'D1C')
        D1.GPS = ob.GPS(:,:,i);
    end
end 
fclose(fid);
