%% Function File No.2
% Title:Navigation Signal Playback
% Note:Analysis of Position Error
%
% Author:NLS
% Date:2016/5/30
% Version:0.9
%
% Shanghai Jiao Tong University
%%
function [satePara_BDS,satePara_GPS, Position, Time]=readGSV(filename, YYMMDD, timeLength)


satePara_BDS = struct(...
    'elevation',        nan(timeLength, 1),...
    'azimuth',          nan(timeLength, 1),...
    'CNR',                 nan(timeLength, 1)...
    );
satePara_BDS(1:32) = satePara_BDS;
satePara_GPS = satePara_BDS;

Time = struct(...
    'SOW',                  nan(timeLength, 1),...
    'HH',                      nan(timeLength, 1),...
    'MM',                      nan(timeLength, 1),...
    'SS',                       nan(timeLength, 1)...
    );
Position = nan(timeLength, 3);

fid = fopen(filename);
if fid==-1
    error('message data file not found or permission denied');
end
frewind(fid);

year=str2double(YYMMDD(1:4));
month=str2double(YYMMDD(5:6));
day=str2double(YYMMDD(7:8));
latitude=NaN;    % 纬度
longitude=NaN; % 经度
height=NaN;

k=0;  % 历元计数器
line_flag = 0; % GGA标志位

while 1
    line=fgetl(fid);
    if ~ischar(line)
        break;
    end
    line_flag = line_flag + 1;
    head=line(1:6);
    if strcmp(head, '$GNGGA') || strcmp(head, '$GPGGA')
        commaNum=0;
        k = k + 1;
        len=length(line);
        for i=1:len
            if strcmp(line(i), ',')
                commaNum=commaNum+1;
                if commaNum==1
                    hour=str2double(line(i+1:i+2));
                    min=str2double(line(i+3:i+4));
                    sec=str2double(line(i+5:i+10));
                    todsec=3600*hour+60*min+sec;
                    daynum=dayofweek(year,month,day);
                    Time.SOW(k) = todsec+86400*daynum;     % 当前条数的周内秒
                    Time.HH(k) = hour;
                    Time.MM(k) = min;
                    Time.SS(k) = sec;
                end
                if commaNum==2
                    latitude=str2double(line(i+1:i+2))+str2double(line(i+3:i+9))/60;
                end
                if commaNum==4
                    longitude=str2double(line(i+1:i+3))+str2double(line(i+4:i+10))/60;
                end
                if commaNum == 8
                    height=str2double(line(i+1:i+5));
                end
            end
        end
        Position(k, :)=[latitude, longitude, height];
    end
    
    if strcmp(head, '$GPGSV')
        commaNum = 0;
        len = length(line);
        for i = 1 : len
            if strcmp(line(i), ',')
                commaNum=commaNum+1;
                if commaNum == 4
                    prn = str2double(line(i+1:i+2));
                    if isnan(prn) || prn>32
                        break;
                    end
                end
                if commaNum == 5
                    if (i + 2)  > len
                        break;
                    end
                    satePara_GPS(prn).elevation(k) = str2double(line(i+1:i+2));
                end
                if commaNum == 6
                    if (i + 3)  > len
                        break;
                    end
                    satePara_GPS(prn).azimuth(k) = str2double(line(i+1:i+3));
                end
                if commaNum == 7
                    if (i + 2)  > len
                        break;
                    end
                    satePara_GPS(prn).CNR(k) = str2double(line(i+1:i+2));
                end
                
                if commaNum == 8
                    prn = str2double(line(i+1:i+2));
                    if isnan(prn) || prn>32
                        break;
                    end
                end
                if commaNum == 9
                    if (i + 2)  > len
                        break;
                    end
                    satePara_GPS(prn).elevation(k) = str2double(line(i+1:i+2));
                end
                if commaNum == 10
                    if (i + 3)  > len
                        break;
                    end
                    satePara_GPS(prn).azimuth(k) = str2double(line(i+1:i+3));
                end
                if commaNum == 11
                    if (i + 2)  > len
                        break;
                    end
                    satePara_GPS(prn).CNR(k) = str2double(line(i+1:i+2));
                end
                
                if commaNum == 12
                    if (i + 2)  > len
                        break;
                    end
                    prn = str2double(line(i+1:i+2));
                    if isnan(prn) || prn>32
                        break;
                    end
                end
                if commaNum == 13
                    if (i + 2)  > len
                        break;
                    end
                    satePara_GPS(prn).elevation(k) = str2double(line(i+1:i+2));
                end
                if commaNum == 14
                    if (i + 3)  > len
                        break;
                    end
                    satePara_GPS(prn).azimuth(k) = str2double(line(i+1:i+3));
                end
                if commaNum == 15
                    if (i + 2)  > len
                        break;
                    end
                    satePara_GPS(prn).CNR(k) = str2double(line(i+1:i+2));
                end
                
                if commaNum == 16
                    if (i + 2)  > len
                        break;
                    end
                    prn = str2double(line(i+1:i+2));
                    if isnan(prn) || prn>32
                        break;
                    end
                end
                if commaNum == 17
                    if (i + 2)  > len
                        break;
                    end
                    satePara_GPS(prn).elevation(k) = str2double(line(i+1:i+2));
                end
                if commaNum == 18
                    if (i + 3)  > len
                        break;
                    end
                    satePara_GPS(prn).azimuth(k) = str2double(line(i+1:i+3));
                end
                if commaNum == 19
                    if (i + 2)  > len
                        break;
                    end
                    satePara_GPS(prn).CNR(k) = str2double(line(i+1:i+2));
                end
                
            end%if strcmp(line(i), ',')
        end%for i = 1 : len
    end% if strcmp(head, '$GPGSV')
    
    if strcmp(head, '$BDGSV')
        commaNum = 0;
        len = length(line);
        for i = 1 : len
            if strcmp(line(i), ',')
                commaNum=commaNum+1;
                if commaNum == 4
                    if (i + 2)  > len
                        break;
                    end
                    prn = str2double(line(i+1:i+2));
                    if isnan(prn) || prn>32
                        break;
                    end
                end
                if commaNum == 5
                    if (i + 2)  > len
                        break;
                    end
                    satePara_BDS(prn).elevation(k) = str2double(line(i+1:i+2));
                end
                if commaNum == 6
                    if (i + 3)  > len
                        break;
                    end
                    satePara_BDS(prn).azimuth(k) = str2double(line(i+1:i+3));
                end
                if commaNum == 7
                    if (i + 2)  > len
                        break;
                    end
                    satePara_BDS(prn).CNR(k) = str2double(line(i+1:i+2));
                end
                
                if commaNum == 8
                    if (i + 2)  > len
                        break;
                    end
                    prn = str2double(line(i+1:i+2));
                    if isnan(prn) || prn>32
                        break;
                    end
                end
                if commaNum == 9
                    if (i + 2)  > len
                        break;
                    end
                    satePara_BDS(prn).elevation(k) = str2double(line(i+1:i+2));
                end
                if commaNum == 10
                    if (i + 3)  > len
                        break;
                    end
                    satePara_BDS(prn).azimuth(k) = str2double(line(i+1:i+3));
                end
                if commaNum == 11
                    if (i + 2)  > len
                        break;
                    end
                    satePara_BDS(prn).CNR(k) = str2double(line(i+1:i+2));
                end
                
                if commaNum == 12
                    if (i + 2)  > len
                        break;
                    end
                    prn = str2double(line(i+1:i+2));
                    if isnan(prn) || prn>32
                        break;
                    end
                end
                if commaNum == 13
                    if (i + 2)  > len
                        break;
                    end
                    satePara_BDS(prn).elevation(k) = str2double(line(i+1:i+2));
                end
                if commaNum == 14
                    if (i + 3)  > len
                        break;
                    end
                    satePara_BDS(prn).azimuth(k) = str2double(line(i+1:i+3));
                end
                if commaNum == 15
                    if (i + 2)  > len
                        break;
                    end
                    satePara_BDS(prn).CNR(k) = str2double(line(i+1:i+2));
                end
                
                if commaNum == 16
                    if (i + 2)  > len
                        break;
                    end
                    prn = str2double(line(i+1:i+2));
                    if isnan(prn) || prn>32
                        break;
                    end
                end
                if commaNum == 17
                    if (i + 2)  > len
                        break;
                    end
                    satePara_BDS(prn).elevation(k) = str2double(line(i+1:i+2));
                end
                if commaNum == 18
                    if (i + 3)  > len
                        break;
                    end
                    satePara_BDS(prn).azimuth(k) = str2double(line(i+1:i+3));
                end
                if commaNum == 19
                    if (i + 2)  > len
                        break;
                    end
                    satePara_BDS(prn).CNR(k) = str2double(line(i+1:i+2));
                end
                
            end%if strcmp(line(i), ',')
        end%for i = 1 : len
    end% if strcmp(head, '$BDGSV')
    
end
fclose(fid);

end