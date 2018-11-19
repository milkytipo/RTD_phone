function receiver = logFileOutput(receiver)

if receiver.config.logConfig.isOutputLog == 0
    return;
end
if receiver.pvtCalculator.logOutput.logReady == 1
    receiver.pvtCalculator.logOutput.logReady = 0;
else
    return;
end

C = 299792458;
SYST = receiver.syst;
logFilePath = receiver.config.logConfig.logFilePath;
pvtCalculator = receiver.pvtCalculator;
logNamePart = pvtCalculator.logOutput.logName;
position = pvtCalculator.positionXYZ;
velocity = pvtCalculator.positionVelocity;

time = receiver.timer;
rawP = pvtCalculator.logOutput.rawP;
inteDoppler.BDS = pvtCalculator.BDS.doppSmooth(:,1);
inteDoppler.GPS = pvtCalculator.GPS.doppSmooth(:,1);
dopplerfre.BDS = pvtCalculator.BDS.doppSmooth(:,3);
dopplerfre.GPS = pvtCalculator.GPS.doppSmooth(:,3);
CNR.BDS = pvtCalculator.BDS.CNR;
CNR.GPS = pvtCalculator.GPS.CNR;
SNR.BDS = pvtCalculator.BDS.SNR;
SNR.GPS = pvtCalculator.GPS.SNR;
carrierVar.BDS = pvtCalculator.BDS.carriVar;
carrierVar.GPS = pvtCalculator.GPS.carriVar;

EphAll.BDS = receiver.naviMsg.BDS_B1I.ephemeris;
EphAll.GPS = receiver.naviMsg.GPS_L1CA.ephemeris;

satClkErr = pvtCalculator.logOutput.satClkErr;
satPositions = pvtCalculator.logOutput.satPos;
dop = pvtCalculator.positionDOP;
el.BDS = receiver.satelliteTable(1).satElevation;
el.GPS = receiver.satelliteTable(2).satElevation;
az.BDS = receiver.satelliteTable(1).satAzimuth;
az.GPS = receiver.satelliteTable(2).satAzimuth;
channels = receiver.channels;
svNum.BDS = receiver.actvPvtChannels.actChnsNum_BDS;
svNum.GPS = receiver.actvPvtChannels.actChnsNum_GPS;
activeChannel.BDS = receiver.actvPvtChannels.BDS(:,1:svNum.BDS);
activeChannel.GPS = receiver.actvPvtChannels.GPS(:,1:svNum.GPS);
posiNum = pvtCalculator.pvtSats(1).pvtS_Num + pvtCalculator.pvtSats(2).pvtS_Num;
clkErr = 0;
% clkDrift = 0;
if strcmp(time.timeType, 'GPST')
    clkErr = pvtCalculator.clkErr(2,1) / C;
%     clkDrift = pvtCalculator.clkErr(2,2) / C;
elseif strcmp(time.timeType, 'BDST')
    clkErr = pvtCalculator.clkErr(1,1) / C;
%     clkDrift = pvtCalculator.clkErr(1,2) / C;
end
pvtCalculator.logOutput.logTimes = pvtCalculator.logOutput.logTimes + 1;
%=== Convert to geodetic coordinates ==============================
%-------save x,y,z to XYZ.txt-------------------------------------%
logName = strcat(logFilePath, logNamePart, '_XYZ.txt');
fid = fopen(logName, 'a');
fprintf(fid,'%f%20f%20f\n',position(1),position(2),position(3));
fclose(fid);
%-------printf results          ----------------------------------%
[latitude,longitude,height] = cart2geo(position(1),position(2),position(3),5);
% fprintf('Positioning -- latitude: %.6f＜;longitude: %.6f＜;height: %.2f \n', ...
%      latitude,longitude,height);
% fprintf('%f   %20f  %20f\n',xyzdt(1),xyzdt(2),xyzdt(3));
%-------save la,lon,H to LLH.txt----------------------------------% 
logName = strcat(logFilePath, logNamePart, '_LLH.txt');
fid = fopen(logName, 'a');
fprintf(fid,'%f%20f%20.3f\n',latitude,longitude,height);
fclose(fid);

%！！！！！！！！！！補竃log猟周！！！！！！！！！！%
switch SYST
       case 'BDS_B1I'
          %%  臼況汽狼由猟周補竃
           satNo = sort(activeChannel.BDS(2,:),2);
%            satNo(satNo == 0) = []; % 肇茅0圷殆
           %！！！！！！！！！！！！！！.O猟周！！！！！！！！！！！！！！！！！！%
           logName = strcat(logFilePath, logNamePart, '.15O');
           fid_0=fopen(logName);
           if fid_0==-1
               rinexobs_header(position,time, logName);
           else
               fclose(fid_0);
           end
           rinexobs_data(time,rawP.BDS,inteDoppler.BDS,dopplerfre.BDS,CNR.BDS,clkErr,satNo, logName);
            %！！！！！！！！！！！！！！.R猟周！！！！！！！！！！！！！！！！！！%
           logName = strcat(logFilePath, logNamePart, '.15R');
           fid_1=fopen(logName);
           if fid_1==-1
               rinexnavi_header(logName);
           else
               fclose(fid_1);
           end
           pvtCalculator = rinexnavi_data(time,EphAll.BDS,satClkErr.BDS(1,:),satNo, pvtCalculator,logName);
            %！！！！！！！！！！！！！！.BMP猟周！！！！！！！！！！！！！！！！！！%
%            logName = strcat(logFilePath, logNamePart, '.15BMP');
%            fid_2=fopen(logName);
%            if fid_2==-1
%                rinexmp_header(time,logName);
%            else
%                fclose(fid_2);
%            end
%            rinexmp_data(time,channels,activeChannel.BDS,logName);
            %！！！！！！！！！！！！！！allObs猟周！！！！！！！！！！！！！！！！！！%
           logName = strcat(logFilePath, logNamePart, '_allObs.txt');
           fid_2=fopen(logName);
           if fid_2==-1
               obs_header(time,logName);
           else
               fclose(fid_2);
           end
           OutputOBS(time, svNum, channels, el, az, dop, activeChannel, pvtCalculator, logName, SYST);
           %！！！！！！！！！！！！ NEMA ！！！！！！！！！！！！！！！！！！！！%
           OutputGPBMP(time,channels,activeChannel.BDS, logFilePath, logNamePart)
%            OutputSateObsBDS(el.BDS, az.BDS, dop, time,satNo, logFilePath, logNamePart, carrierVar.BDS, SNR.BDS, CNR.BDS, satPositions.BDS, satClkErr.BDS);      % 補竃寮佛議剿叔才圭了叔佚連才寮佛了崔
           OutputGPGGA(latitude, longitude, height, time, posiNum, logFilePath, logNamePart , pvtCalculator.posiCheck);  % 補竃GPGGA方象
           OutputGPFPD(time, latitude, longitude, height, velocity, logFilePath, logNamePart);
           OutputGPBPL(time, logFilePath, logNamePart, carrierVar.BDS, satNo);
           if receiver.config.logConfig.isCorrShapeStore
               OutputCorr_BDS(channels, time, activeChannel.BDS, logFilePath, logNamePart);
           end
           
       case 'GPS_L1CA'
           %% GPS汽狼由猟周補竃
           satNo = sort(activeChannel.GPS(2,:),2);
%            satNo(satNo == 0) = []; % 肇茅0圷殆
           %！！！！！！！！！！！！！！.O猟周！！！！！！！！！！！！！！！！！！%
           logName = strcat(logFilePath, logNamePart, '.15O');
           fid_0=fopen(logName);
           if fid_0==-1
               rinexobsGPS_header(position,time, logName);
           else
               fclose(fid_0);
           end
           rinexobsGPS_data(time,rawP.GPS,inteDoppler.GPS,dopplerfre.GPS,CNR.GPS,clkErr,satNo, logName);
            %！！！！！！！！！！！！！！.N猟周！！！！！！！！！！！！！！！！！！%
           logName = strcat(logFilePath, logNamePart, '.15N');
           fid_1=fopen(logName);
           if fid_1==-1
               rinexnaviGPS_header(logName);
           else
               fclose(fid_1);
           end
           pvtCalculator = rinexnaviGPS_data(time,EphAll.GPS,satClkErr.GPS(1,:),satNo, pvtCalculator,logName);
            %！！！！！！！！！！！！！！.GMP猟周！！！！！！！！！！！！！！！！！！%
%            logName = strcat(logFilePath, logNamePart, '.15GMP');
%            fid_2=fopen(logName);
%            if fid_2==-1
%                rinexmpGPS_header(time,logName);
%            else
%                fclose(fid_2);
%            end
%            rinexmpGPS_data(time,channels,activeChannel.GPS,logName); 
            %！！！！！！！！！！！！！！allObs猟周！！！！！！！！！！！！！！！！！！%
           logName = strcat(logFilePath, logNamePart, '_allObs.txt');
           fid_2=fopen(logName);
           if fid_2==-1
               obs_header(time,logName);
           else
               fclose(fid_2);
           end
           OutputOBS(time, svNum, channels, el, az, dop, activeChannel, pvtCalculator, logName, SYST);
           %！！！！！！！！！！！！ NEMA ！！！！！！！！！！！！！！！！！！！！%
           OutputGPGMP(time,channels,activeChannel.GPS, logFilePath, logNamePart);
%            OutputSateObsGPS(el.GPS, az.GPS, dop, time,satNo, logFilePath, logNamePart, carrierVar.GPS, SNR.GPS, CNR.GPS, satPositions.GPS, satClkErr.GPS);      % 補竃寮佛議剿叔才圭了叔佚連才寮佛了崔
           OutputGPGGA(latitude, longitude, height, time, posiNum, logFilePath, logNamePart , pvtCalculator.posiCheck);  % 補竃GPGGA方象
           OutputGPFPD(time, latitude, longitude, height, velocity, logFilePath, logNamePart);
           OutputGPGPL(time, logFilePath, logNamePart, carrierVar.GPS, satNo);
           if receiver.config.logConfig.isCorrShapeStore
               OutputCorr_GPS(channels, time, activeChannel.GPS, logFilePath, logNamePart);
           end
       case 'B1I_L1CA'
           %% 臼況GPS褒狼由猟周補竃
           satNo.GPS = [];
           satNo.BDS = [];
           if svNum.BDS > 0
               satNo.BDS = sort(activeChannel.BDS(2,:),2);
%                satNo.BDS(satNo.BDS == 0) = []; % 肇茅0圷殆
           end
           if svNum.GPS > 0
               satNo.GPS = sort(activeChannel.GPS(2,:),2);
%                satNo.GPS(satNo.GPS == 0) = []; % 肇茅0圷殆
           end
           %！！！！！！！！！！！！！！.O猟周！！！！！！！！！！！！！！！！！！%
           logName = strcat(logFilePath, logNamePart, '.15O');
           fid_0=fopen(logName);
           if fid_0==-1
               rinexobs_header_dual(position,time, logName);
           else
               fclose(fid_0);
           end
           rinexobs_data_dual(time,rawP,inteDoppler,dopplerfre,CNR,clkErr,satNo, logName);
            %！！！！！！！！！！！！！！allObs猟周！！！！！！！！！！！！！！！！！！%
           logName = strcat(logFilePath, logNamePart, '_allObs.txt');
           fid_2=fopen(logName);
           if fid_2==-1
               obs_header(time,logName);
           else
               fclose(fid_2);
           end
           OutputOBS(time, svNum, channels, el, az, dop, activeChannel, pvtCalculator, logName, SYST);
%！！！！！！！！！！！！！！！！！！ BDS 猟周 ！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！%           
            %！！！！！！！！！！！！！！BDS .R/NEMA猟周！！！！！！！！！！！！！！！！！！%
           if svNum.BDS > 0
               logName = strcat(logFilePath, logNamePart, '.15R');
               fid_1=fopen(logName);
               if fid_1==-1
                   rinexnavi_header(logName);
               else
                   fclose(fid_1);
               end
               pvtCalculator = rinexnavi_data(time,EphAll.BDS,satClkErr.BDS(1,:),satNo.BDS, pvtCalculator,logName);
               %！！！！！！！！！！！！ BDS .BMP猟周 ！！！！！！！！！！！！！！！！！！！！%
%                logName = strcat(logFilePath, logNamePart, '.15BMP');
%                fid_2=fopen(logName);
%                if fid_2==-1
%                    rinexmp_header(time,logName);
%                else
%                    fclose(fid_2);
%                end
%                rinexmp_data(time,channels,activeChannel.BDS,logName); 
                %！！！！！！！！！！！！ BDS NEMA ！！！！！！！！！！！！！！！！！！！！%
               OutputGPBMP(time,channels,activeChannel.BDS, logFilePath, logNamePart);
               if receiver.config.logConfig.isCorrShapeStore
                   OutputCorr_BDS(channels, time, activeChannel.BDS, logFilePath, logNamePart);
               end
%                OutputSateObsBDS(el.BDS, az.BDS, dop, time,satNo.BDS, logFilePath, logNamePart, carrierVar.BDS, SNR.BDS, CNR.BDS, satPositions.BDS, satClkErr.BDS);      % 補竃寮佛議剿叔才圭了叔佚連才寮佛了崔
           end
%！！！！！！！！！！！！！！！！！！GPS 猟周 ！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！%
            %！！！！！！！！！！！！GPS .N 猟周 ！！！！！！！！！！！！！！！！！！！！%
           if svNum.GPS > 0
               logName = strcat(logFilePath, logNamePart, '.15N');
               fid_1=fopen(logName);
               if fid_1==-1
                   rinexnaviGPS_header(logName);
               else
                   fclose(fid_1);
               end
               pvtCalculator = rinexnaviGPS_data(time,EphAll.GPS,satClkErr.GPS(1,:),satNo.GPS, pvtCalculator,logName);
               %！！！！！！！！！！！！！！GPS .GMP猟周！！！！！！！！！！！！！！！！！！%
%                logName = strcat(logFilePath, logNamePart, '.15GMP');
%                fid_2=fopen(logName);
%                if fid_2==-1
%                    rinexmpGPS_header(time,logName);
%                else
%                    fclose(fid_2);
%                end
%                rinexmpGPS_data(time,channels,activeChannel.GPS,logName); 
               %！！！！！！！！！！！！ GPS NEMA ！！！！！！！！！！！！！！！！！！！！%
               OutputGPGMP(time,channels,activeChannel.GPS, logFilePath, logNamePart);
               if receiver.config.logConfig.isCorrShapeStore
                   OutputCorr_GPS(channels, time, activeChannel.GPS, logFilePath, logNamePart);
               end
%                OutputSateObsGPS(el.GPS, az.GPS, dop, time,satNo.GPS, logFilePath, logNamePart, carrierVar.GPS, SNR.GPS, CNR.GPS, satPositions.GPS, satClkErr.GPS);      % 補竃寮佛議剿叔才圭了叔佚連才寮佛了崔
           end
%！！！！！！！！！！！！！！！！！！！！！！ NEMA ！！！！！！！！！！！！！！！！！！！！！！！！！！！！%
           OutputGPFPD(time, latitude, longitude, height, velocity, logFilePath, logNamePart);
           OutputGPGGA(latitude, longitude, height, time, posiNum, logFilePath, logNamePart , pvtCalculator.posiCheck);  % 補竃GPGGA方象
end

receiver.pvtCalculator = pvtCalculator;

