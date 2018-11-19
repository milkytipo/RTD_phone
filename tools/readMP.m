%--------------------------------------------------------------------------
% GNSS Time Series:    TOWSEC    size: 1 by time_length
%
% 包含多径的卫星号：    prnNum     结构体型变量  
%       子结构体：     prnNum(i).prn     size:  1 by number_of_satellite       
%                     其中i为时刻，与TOWSEC相对应
%
% 多径输出参数：   parameter   结构体型变量
%  码相位延时      parameter(i).codeDelay     size:  time_length by unit_number
%  I路幅值         parameter(i).I             size:  time_length by unit_number 
%  Q路幅值         parameter(i).Q             size:  time_length by unit_number
%  SNR             parameter(i).SNR          size:  time_length by unit_number
%  CNR             parameter(i).CNR          size:  time_length by unit_number
%  载波相位延时     parameter(i).carriDelay   size:  time_length by unit_number
%                      其中i为卫星PRN号
%
%--------------------------------------------------------------------------

function [parameter, prnNum, prnMax, TOWSEC] = readMP(filename)
%filename='F:\wangyz\多径研究项目\sv_cadll\trunk\m\logfile\The_Three_Towers.15BMP';

decimate_factor=1;     %  If it is equal to '1', then every data point is read in and stored.  If it is equal
%                        to '2', then every second data point is stored.
%                        If '3', then every third data point is stored,
%                        et cetera.
if decimate_factor < 1, error('decimate_factor must be a positive integer'), end
if rem(decimate_factor,1) > 0, error('decimate_factor must be a positive integer'), end
fid = fopen(filename);
if fid==-1
   error('RINEX Navigation message data file not found or permission denied');
end
maxPathnum = 0;
frewind(fid)
% POSITION_XYZ=NaN; ANTDELTA=NaN; OBSINT=NaN;codeDelay1=NaN;codeDelay2=NaN;codeDelay3=[NaN];I1=NaN;I2=NaN;I3=NaN;
% Q1=NaN;Q2=NaN;Q3=NaN;SNR1=NaN;SNR2=NaN;SNR3=NaN;CNR1=NaN;CNR2=NaN;CNR3=NaN;carriDelay1=NaN;carriDelay2=NaN;carriDelay3=NaN;
linecount = 0;
prnMax = [];
%  Parse header
while 1   % this is the numeral '1'
    line = fgetl(fid);
    linecount = linecount + 1;

    len = length(line);
    if len < 80, line(len+1:80) = '0'; end
    
    if line(61:73) == 'END OF HEADER',
        break
    end
    if line(61:79) == 'APPROX POSITION XYZ',
        POSITION_XYZ(1) = str2num(line(1:14));
        POSITION_XYZ(2) = str2num(line(15:28));
        POSITION_XYZ(3) = str2num(line(29:42));
    end
    if line(61:80) == 'ANTENNA: DELTA H/E/N',
        ANTDELTA(1) = str2num(line(1:14));
        ANTDELTA(2) = str2num(line(15:28));
        ANTDELTA(3) = str2num(line(29:42));
    end
    if line(61:79) == 'SYS / # / OBS TYPES',
        numobs = str2num(line(5:6));
        if numobs > 9, 
            error('number of types of observations > 9')
        end
        obtype(1,:) = line(8:10);
        obtype(2,:) = line(12:14);
        obtype(3,:) = line(16:18);
        obtype(4,:) = line(20:22);
    end
    if line(61:68) == 'INTERVAL',
        OBSINT = str2num(line(1:10));
    end
end
%  Loop through the file
k = 0;  breakflag = 0;
prnNum = struct('prn',[]);
parameter = struct(...
    'codeDelay',        [],...
    'I',                [],...
    'Q',                [],...
    'SNR',              [],...
    'CNR',              [],...                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
    'carriDelay',       [] ...
);
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

       epochflg(k) = str2double(line(30:32));
       sumSat(k) = str2double(line(33:35));
       sumPath(k) = str2double(line(38:39));

%        CLOCKOFFSET(k) = str2double(line(69:80));
%        SVID_MAT(ch(1:numsvs(k)),k) = 1;
       
       for i = 1:sumPath(k),
           line = fgetl(fid);
           if ~ischar(line), break, end
           linecount = linecount + 1;
      
           len = length(line);
           if len < 80,
              line(len+1:80) = '0';
           end
           ch(k,i)=str2double(line(2:3));
           if ~ismember(ch(k,i),prnMax)
               prnMax = [prnMax,ch(k,i)];
           end
           pathNum = str2double(line(8:9));
           if pathNum > maxPathnum
                maxPathnum = pathNum;
           end
           ob(ch(k,i),k,pathNum,1) = str2double(line(11:21));       % 码相位延时
           ob(ch(k,i),k,pathNum,2) = str2double(line(24:34));       % I幅值
           ob(ch(k,i),k,pathNum,3) = str2double(line(37:47));       % Q幅值
           ob(ch(k,i),k,pathNum,4) = str2double(line(50:60));       % 信噪比
           ob(ch(k,i),k,pathNum,5) = str2double(line(63:73));       % 载噪比
           % 计算载波相位延时
           ob(ch(k,i),k,pathNum,6) = atan2(ob(ch(k,i),k,pathNum,3),ob(ch(k,i),k,pathNum,2)) ...
               - atan2(ob(ch(k,i),k,1,3),ob(ch(k,i),k,1,2));
       end   % End the "for i = 1:numsvs(k)" Loop
       prnNum(k).prn = intersect(ch(k,:),ch(k,:));   % 此刻可见卫星号
       prnNum(k).prn(find(prnNum(k).prn==0)) = []; 
   end  % End the "for ideci = 1:decimate_factor" Loop
   if breakflag == 1, break, end
%    waitbar(linecount/numlines,bar1)
end  % End the WHILE 1 Loop
fclose(fid); 
satLen = length(ob(:,1,1,1));
prnMax = sort(prnMax);
for i = 1 : satLen
    % 直达径：码相位延时、I幅值、Q幅值、信噪比、载噪比
    parameter(i).codeDelay = reshape(ob(i,:,:,1),[size(ob(i,:,:,1),2),size(ob(i,:,:,1),3)]);
    parameter(i).I = reshape(ob(i,:,:,2),[size(ob(i,:,:,2),2),size(ob(i,:,:,2),3)]);
    parameter(i).Q = reshape(ob(i,:,:,3),[size(ob(i,:,:,3),2),size(ob(i,:,:,3),3)]);
    parameter(i).SNR = reshape(ob(i,:,:,4),[size(ob(i,:,:,4),2),size(ob(i,:,:,4),3)]);
    parameter(i).CNR = reshape(ob(i,:,:,5),[size(ob(i,:,:,5),2),size(ob(i,:,:,5),3)]);
    parameter(i).carriDelay = reshape(ob(i,:,:,6),[size(ob(i,:,:,6),2),size(ob(i,:,:,6),3)]);
end
% % 直达径：码相位延时、I幅值、Q幅值、信噪比、载噪比
% codeDelay.path1 = ob(:,:,1,1);
% I.path1 = ob(:,:,1,2);
% Q.path1 = ob(:,:,1,3);
% SNR.path1 = ob(:,:,1,4);
% CNR.path1 = ob(:,:,1,5);
% carriDelay.path1 = ob(:,:,1,6);
% % 多径1：码相位延时、I幅值、Q幅值、信噪比、载噪比
% if maxPathnum > 1
%     codeDelay.path2 = ob(:,:,2,1);
%     I.path2 = ob(:,:,2,2);
%     Q.path2 = ob(:,:,2,3);
%     SNR.path2 = ob(:,:,2,4);
%     CNR.path2 = ob(:,:,2,5);
%     carriDelay.path2 = ob(:,:,2,6);
% end
% % 多径2：码相位延时、I幅值、Q幅值、信噪比、载噪比
% if maxPathnum > 2
%     codeDelay.path3 = ob(:,:,3,1);
%     I.path3 = ob(:,:,3,2);
%     Q.path3 = ob(:,:,3,3);
%     SNR.path3 = ob(:,:,3,4);
%     CNR.path3 = ob(:,:,3,5);
%     carriDelay.path3 = ob(:,:,3,6);
% end

%end
