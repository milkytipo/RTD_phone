function [el,az,SNR,CNR,carriVar,satPos_x,satPos_y,satPos_z,satVel_x,satVel_y,satVel_z,satClcErr,satClcErrDot,TOWSEC] = readSatobs(filename)
%--------------------------------------------------------------------------
% GNSS Time Series: TOWSEC
% Satellite parameter:  
%     Sat Elevation: el;    NUM_PRN x TIME_LENTH
%     Sat Azimuth:   az;    NUM_PRN x TIME_LENTH
%     Sat SNR:   SNR;
%     Sat CNR:   CNR;
%     Sat Carrier Loop variance:   carriVar;
%     Sat Position: x: satPos_x
%                   y: satPos_y
%                   z: satPos_z   
%     Sat clock error :   satClcErr
%     Sat clock frequency error  :  satClcErrDot
%--------------------------------------------------------------------------

% filename='D:\Work\mp_research\sv_cadll\trunk\m\logfile\The_Three_Towers_SateObs.txt';
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
GDOP = NaN; PDOP = NaN; SNR = NaN; CNR = NaN; carriVar = NaN; el = NaN; az = NaN;
satPos_x = NaN; satPos_y = NaN; satPos_z = NaN;
linecount = 0;
%  Loop through the file
k = 0;  breakflag = 0;
while 1     % this is the numeral '1'
   k = k + 1;    % 'k' is keeping track of our time steps
   %
   for ideci = 1:decimate_factor,
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
       epochflg(k) = str2double(line(30:31));
       numsvs(k) = str2double(line(32:34));
       GDOP(k) = str2double(line(36:43));
       PDOP(k) = str2double(line(45:52));
%        CLOCKOFFSET(k) = str2double(line(69:80));
%        SVID_MAT(ch(1:numsvs(k)),k) = 1;
   
       for i = 1:numsvs(k),
           line = fgetl(fid);
           if ~ischar(line), break, end
           linecount = linecount + 1;
      
           len = length(line);
           if len < 80,
              line(len+1:80) = '0';
           end
           ch(k,i)=str2double(line(2:3));
           SVID_MAT(ch(k,i),k) = 1;           
           ob(ch(k,i),k,1) = str2double(line(4:15));            
           ob(ch(k,i),k,2) = str2double(line(16:27));
           ob(ch(k,i),k,3) = str2double(line(28:39));
           ob(ch(k,i),k,4) = str2double(line(40:51));
           ob(ch(k,i),k,5) = str2double(line(53:64));
           ob(ch(k,i),k,6) = str2double(line(66:79));         % ÎÀÐÇxÖá×ø±ê
           ob(ch(k,i),k,7) = str2double(line(81:94));         % ÎÀÐÇyÖá×ø±ê
           ob(ch(k,i),k,8) = str2double(line(96:109));       % ÎÀÐÇzÖá×ø±ê
           ob(ch(k,i),k,9) = str2double(line(111:124));       % ÎÀÐÇÖÓ²î£¨m£©
           ob(ch(k,i),k,10) = str2double(line(126:139));       % ÎÀÐÇÖÓ²îÆ¯ÒÆ£¨m/s£©
           ob(ch(k,i),k,11) = str2double(line(141:154));       % ÎÀÐÇxÖáËÙ¶È
           ob(ch(k,i),k,12) = str2double(line(156:169));       % ÎÀÐÇyÖáËÙ¶È
           ob(ch(k,i),k,13) = str2double(line(171:184));       % ÎÀÐÇzÖáËÙ¶È
       end   % End the "for i = 1:numsvs(k)" Loop
   end  % End the "for ideci = 1:decimate_factor" Loop
   if breakflag == 1, break, end
%    waitbar(linecount/numlines,bar1)
end  % End the WHILE 1 Loop
el = ob(:,:,1);
az = ob(:,:,2);
SNR = ob(:,:,3);
CNR = ob(:,:,4);
carriVar = ob(:,:,5);
satPos_x = ob(:,:,6);
satPos_y = ob(:,:,7);
satPos_z = ob(:,:,8);
satClcErr = ob(:,:,9);
satClcErrDot = ob(:,:,10);
satVel_x = ob(:,:,11);
satVel_y = ob(:,:,12);
satVel_z = ob(:,:,13);
fclose(fid);
