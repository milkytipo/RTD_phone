% 通过读取log文件直接定位
clear;clc;
%% 初始化
svnum.BDS = 0;% this flag is to find whether avaliable satellite is above 4
svnum.GPS = 0;
activeChannel.GPS = [];% avaliable channels
activeChannel.BDS = [];
posiChannel.GPS = [];   % raim算法过滤后的信道
posiChannel.BDS = [];
checkNGEO = 0;%%检测NGEO卫星
inteDoppler.BDS = zeros(1,32);%积分多普勒值
inteDoppler.GPS = zeros(1,32);
dopplerfre.BDS = zeros(1,32);%多普勒频移
dopplerfre.GPS = zeros(1,32);
CNR.BDS = zeros(1,32);  %输出信噪比
CNR.GPS = zeros(1,32);
SNR.BDS = zeros(1,32);  %输出信噪比
SNR.GPS = zeros(1,32);
carrierVar.BDS = zeros(1, 32);  % 输出载波环方差
carrierVar.GPS = zeros(1, 32);
EphAll.BDS = [];
EphAll.GPS = [];
rawP.GPS = [];
rawP.BDS = [];
satClkCorr.BDS = [];
satClkCorr.GPS = [];
satPositions.BDS = [];
satPositions.GPS = [];
raimG = []; % 状态矩阵
raimB = []; 
raimFlag = 0;   % 如果值为1，则raim校验通过   
transmitTime = [];
config.elevationMask = 10;
config.logFilePath = '.\logfile\';
config.logName = 'dual_lsq';
posiMethod = 'lsq';
logFlag = 1;
multipathFlag = 0;
SYST = 'B1I_L1CA';  % system

prError = [];
pvtCalculator.posiLast = zeros(10,1);
pvtCalculator.posiTag = 0;
pvtCalculator.posiCheck = 0;
pvtCalculator.timeLast = 0;
pvtCalculator.maxInterval = 10;
pvtCalculator.kalman.preTag = 0;
pvtCalculator.kalman.mpPreTag = zeros(1,32);

times = 0;
% %————————————————————————————————%
% ephemeris(1).para(satnum.BDS(i,j)).eph.Alpha0 = 0;
% ephemeris(1).para(satnum.BDS(i,j)).eph.Alpha1 = 0;
% ephemeris(1).para(satnum.BDS(i,j)).eph.Alpha2 = 0;
% ephemeris(1).para(satnum.BDS(i,j)).eph.Alpha3 = 0;
% ephemeris(1).para(satnum.BDS(i,j)).eph.Beta0 = 0;
% ephemeris(1).para(satnum.BDS(i,j)).eph.Beta1 = 0;
% ephemeris(1).para(satnum.BDS(i,j)).eph.Beta2 = 0;
% ephemeris(1).para(satnum.BDS(i,j)).eph.Beta3 = 0;
% 
% %————————————————————————————————%




filename_15O = 'E:\多径研究项目\sv_cadll\trunk\m\logfile\relock_real_2016-7-12_19-27-15.15O';
[C1, L1,S1,D1,satnum,TOWSEC] = read_rinex(filename_15O,1);
if strcmp(SYST,'BDS_B1I') || strcmp(SYST,'B1I_L1CA')
    filename_Sateobs_BDS = 'E:\多径研究项目\sv_cadll\trunk\m\logfile\relock_real_2016-7-12_19-27-15_SateObs_BDS.txt';
    [el_BDS,az_BDS,SNR_BDS,CNR_BDS,carriVar_BDS,satPos_x_BDS,satPos_y_BDS,satPos_z_BDS,satVel_x_BDS,satVel_y_BDS,satVel_z_BDS,satClcErr_BDS,satClcErrDot_BDS,TOWSEC_BDS]...
        = readSatobs(filename_Sateobs_BDS);
    if multipathFlag == 1
        [parameter,prnNum,TOWSEC_MP] = readMP('L:\log数据\徐汇南丹路\xuhui3000-3600有多径\Xuhui_Nandan_Road_Dynamic.15BMP');
    end
end
if strcmp(SYST,'GPS_L1CA') || strcmp(SYST,'B1I_L1CA')
    filename_Sateobs_GPS = 'E:\多径研究项目\sv_cadll\trunk\m\logfile\relock_real_2016-7-12_19-27-15_SateObs_GPS.txt';
    [el_GPS,az_GPS,SNR_GPS,CNR_GPS,carriVar_GPS,satPos_x_GPS,satPos_y_GPS,satPos_z_GPS,satVel_x_GPS,satVel_y_GPS,satVel_z_GPS,satClcErr_GPS,satClcErrDot_GPS,TOWSEC_GPS]...
        = readSatobs(filename_Sateobs_GPS);
end
checkNGEO = 1;
for i = 1 : length(TOWSEC)
    if strcmp(SYST,'BDS_B1I') || strcmp(SYST,'B1I_L1CA')
        for j = 1 : length(satnum.BDS(i,:))
            if satnum.BDS(i,j) ~= 0
                activeChannel.BDS(1,j) = j;
                activeChannel.BDS(2,j) = satnum.BDS(i,j);
                satPositions.BDS(1,satnum.BDS(i,j)) = satPos_x_BDS(satnum.BDS(i,j),i);
                satPositions.BDS(2,satnum.BDS(i,j)) = satPos_y_BDS(satnum.BDS(i,j),i);
                satPositions.BDS(3,satnum.BDS(i,j)) = satPos_z_BDS(satnum.BDS(i,j),i);
                satPositions.BDS(4,satnum.BDS(i,j)) = satVel_x_BDS(satnum.BDS(i,j),i);
                satPositions.BDS(5,satnum.BDS(i,j)) = satVel_y_BDS(satnum.BDS(i,j),i);
                satPositions.BDS(6,satnum.BDS(i,j)) = satVel_z_BDS(satnum.BDS(i,j),i);
                rawP.BDS(1,satnum.BDS(i,j)) = C1.BDS(satnum.BDS(i,j), i);
                inteDopp.BDS(1,satnum.BDS(i,j)) = L1.BDS(satnum.BDS(i,j), i);
                if multipathFlag == 1
                    codeDelay.BDS(:,satnum.BDS(i,j)) = parameter(satnum.BDS(i,j)).codeDelay(i,:)'*1/2046000*299792458;
                    carriDelay.BDS(:,satnum.BDS(i,j)) = parameter(satnum.BDS(i,j)).carriDelay(i,:)';
                    mpCnr.BDS(:,satnum.BDS(i,j)) = 10.^(parameter(satnum.BDS(i,j)).CNR(i,:)'/10);
                end
                CNR.BDS(:,satnum.BDS(i,j)) = S1.BDS(satnum.BDS(i,j), i);
                satClkCorr.BDS(1,satnum.BDS(i,j)) = satClcErr_BDS(satnum.BDS(i,j),i)/299792458;
                satClkCorr.BDS(2,satnum.BDS(i,j)) = satClcErrDot_BDS(satnum.BDS(i,j),i)/299792458;
                transmitTime.BDS(1,1:32) = TOWSEC(i);
                ephemeris(1).para(satnum.BDS(i,j)).eph.Alpha0 = 2.048909664154E-08;
                ephemeris(1).para(satnum.BDS(i,j)).eph.Alpha1 = 3.799796104431E-07;
                ephemeris(1).para(satnum.BDS(i,j)).eph.Alpha2 = -3.159046173096E-06;
                ephemeris(1).para(satnum.BDS(i,j)).eph.Alpha3 = 5.960464477539E-06;
                ephemeris(1).para(satnum.BDS(i,j)).eph.Beta0 = 1.331200000000E+05;
                ephemeris(1).para(satnum.BDS(i,j)).eph.Beta1 = -5.079040000000E+05;
                ephemeris(1).para(satnum.BDS(i,j)).eph.Beta2 = 4.784128000000E+06;
                ephemeris(1).para(satnum.BDS(i,j)).eph.Beta3 = -4.325376000000E+06;
                pvtCalculator.BDS.doppSmooth(satnum.BDS(i,j),2) = 0;
                pvtCalculator.BDS.doppSmooth(satnum.BDS(i,j),4) = D1.BDS(satnum.BDS(i,j), i);      
            end
        end
        svnum.BDS = sum(satnum.BDS(i,:)~=0);
    end
    if strcmp(SYST,'GPS_L1CA') || strcmp(SYST,'B1I_L1CA')
        for j = 1 : length(satnum.GPS(i,:))
            if satnum.GPS(i,j) ~= 0
                activeChannel.GPS(1,j) = j;
                activeChannel.GPS(2,j) = satnum.GPS(i,j);
                satPositions.GPS(1,satnum.GPS(i,j)) = satPos_x_GPS(satnum.GPS(i,j),i);
                satPositions.GPS(2,satnum.GPS(i,j)) = satPos_y_GPS(satnum.GPS(i,j),i);
                satPositions.GPS(3,satnum.GPS(i,j)) = satPos_z_GPS(satnum.GPS(i,j),i);
                satPositions.GPS(4,satnum.GPS(i,j)) = satVel_x_GPS(satnum.GPS(i,j),i);
                satPositions.GPS(5,satnum.GPS(i,j)) = satVel_y_GPS(satnum.GPS(i,j),i);
                satPositions.GPS(6,satnum.GPS(i,j)) = satVel_z_GPS(satnum.GPS(i,j),i);
                rawP.GPS(1,satnum.GPS(i,j)) = C1.GPS(satnum.GPS(i,j), i);
                inteDopp.GPS(1,satnum.GPS(i,j)) = L1.GPS(satnum.GPS(i,j), i);
                
                satClkCorr.GPS(1,satnum.GPS(i,j)) = satClcErr_GPS(satnum.GPS(i,j),i)/299792458;
                satClkCorr.GPS(2,satnum.GPS(i,j)) = satClcErrDot_GPS(satnum.GPS(i,j),i)/299792458;
                transmitTime.GPS(1,1:32) = TOWSEC(i);
                ephemeris(2).para(satnum.GPS(i,j)).eph.Alpha0 = 1.396983861923E-08;
                ephemeris(2).para(satnum.GPS(i,j)).eph.Alpha1 = 2.235174179077E-08;
                ephemeris(2).para(satnum.GPS(i,j)).eph.Alpha2 = -1.192092895508E-07;
                ephemeris(2).para(satnum.GPS(i,j)).eph.Alpha3 = -1.192092895508E-07;
                ephemeris(2).para(satnum.GPS(i,j)).eph.Beta0 = 1.105920000000E+05;
                ephemeris(2).para(satnum.GPS(i,j)).eph.Beta1 = 1.638400000000E+05;
                ephemeris(2).para(satnum.GPS(i,j)).eph.Beta2 = -6.553600000000E+04;
                ephemeris(2).para(satnum.GPS(i,j)).eph.Beta3 = -5.242880000000E+05;
                pvtCalculator.GPS.doppSmooth(satnum.GPS(i,j),2) = 0;
                pvtCalculator.GPS.doppSmooth(satnum.GPS(i,j),4) = D1.GPS(satnum.GPS(i,j), i);      
            end
        end
        svnum.GPS = sum(satnum.GPS(i,:)~=0);
    end
    [BJday_1, BJhour, BJmin, BJsec] = sow2BJT(TOWSEC(i));
    recv_time.hour = BJhour;
    recv_time.min = BJmin;
    recv_time.sec = BJsec;
    recv_time.recvSOW = TOWSEC(i);
    recv_time.weeknum = 1111;
    times = times + 1;
    fprintf('%2.2dh%2.2dm%6.3fs        %05.5d\n',BJhour,BJmin,BJsec,times);
    raimFlag = 0;
    raimG = [];
    raimB = [];
    %——————————————————————
    
%     column = find(activeChannel.BDS(2,1) == 1);
%     if ~isempty(column)
%         activeChannel.BDS(:,column)=[];
%     end
%     column = find(activeChannel.BDS(2,:) == 7);
%     if ~isempty(column)
%         activeChannel.BDS(:,column)=[];
%     end
    
    %————————————————————————
    posiChannel = activeChannel;
    
    %------------------------------------------------------------%
   
%     if ~isempty(activeChannel.BDS)
%         for ii =size(activeChannel.BDS, 2) : -1 : 1
%             if rawP.BDS(activeChannel.BDS(2,ii))<30000000 || rawP.BDS(activeChannel.BDS(2,ii))>40000000    % 满足此条件认为是奇异点
%                 activeChannel.BDS(:,ii) = [];
%                 posiChannel.BDS(:,ii) = [];
%             end
%         end
%     end
%     if ~isempty(activeChannel.GPS)
%         for ii =size(activeChannel.GPS, 2) : -1 : 1
%             if rawP.GPS(activeChannel.GPS(2,ii))<9999999 || rawP.GPS(activeChannel.GPS(2,ii))>99999999    % 满足此条件认为是奇异点
%                 activeChannel.GPS(:,ii) = [];
%                 posiChannel.GPS(:,ii) = [];
%             end
%         end
%     end
  
    
    while (1)
        [raimFlag, posiChannel,activeChannel,svnum] =raim(prError, raimG, raimB, posiChannel, raimFlag, SYST, svnum, pvtCalculator, recv_time, rawP, activeChannel);
        if raimFlag == 1
            break;
        end
        if strcmp(SYST,'BDS_B1I') || (strcmp(SYST,'B1I_L1CA')&&svnum.GPS==0)
            [xyzdt,el,az,dop, raimG, raimB,prError,pvtCalculator] = leastSquarePos_BDS(satPositions.BDS, rawP.BDS+satClkCorr.BDS(1,:)*299792458, ... 
                 transmitTime.BDS,ephemeris(1).para,activeChannel.BDS, config.elevationMask, checkNGEO,satClkCorr.BDS(2,:),pvtCalculator, posiChannel.BDS,recv_time); 
        elseif strcmp(SYST,'GPS_L1CA') || (strcmp(SYST,'B1I_L1CA')&&svnum.BDS==0)
            [xyzdt,el,az,dop, raimG, raimB,prError,pvtCalculator] = leastSquarePos_GPS(satPositions.GPS, rawP.GPS+satClkCorr.GPS(1,:)*299792458, ... 
                 transmitTime.GPS, ephemeris(2).para, activeChannel.GPS, config.elevationMask,satClkCorr.GPS(2,:),pvtCalculator, posiChannel.GPS,recv_time); 
        elseif  strcmp(SYST,'B1I_L1CA')
            [xyzdt,el,az,dop, raimG, raimB,prError,pvtCalculator] = leastSquarePos_dual(satPositions, rawP, transmitTime, ephemeris, activeChannel, config.elevationMask, satClkCorr, pvtCalculator, posiChannel,recv_time); 
        end
%        raimFlag = 1;
    end
    
    if xyzdt(1) == 0
        clear activeChannel;
        clear satPositions;
        clear rawP;
        clear satClkCorr;
        clear transmitTime;
        rawP.GPS = [];
        rawP.BDS = [];
        satClkCorr.BDS = [];
        satClkCorr.GPS = [];
        satPositions.BDS = [];
        satPositions.GPS = [];
        activeChannel.GPS = [];% avaliable channels
        activeChannel.BDS = [];
        continue;
    end
    %————————————多径卡尔曼滤波算法——————————————%
%     if strcmp(posiMethod,'kalman')
%         [mpError,pvtCalculator] = kalmanMp_BDS(parameter,rawP.BDS, inteDopp.BDS,posiChannel.BDS,codeDelay.BDS,mpCnr.BDS,pvtCalculator,...
%             codeDelay.BDS,mpCnr.BDS,CNR.BDS,parameter);
%     end
    
    
  %%  ——————————————卡尔曼滤波定位算法————————————%
    if strcmp(posiMethod,'kalman')
        if pvtCalculator.kalman.preTag == 1
            if strcmp(SYST,'BDS_B1I') || (strcmp(SYST,'B1I_L1CA')&&svnum.GPS==0)
                if multipathFlag == 0 
                    [xyzdt,el,az, dop,pvtCalculator] = kalmanPosi_BDS(satPositions.BDS, rawP.BDS+satClkCorr.BDS(1,:)*299792458, ... 
                             transmitTime.BDS,ephemeris(1).para,posiChannel.BDS, config.elevationMask, ...
                             satClkCorr.BDS(2,:),pvtCalculator, posiChannel.BDS,recv_time);
                elseif multipathFlag == 1
                    [xyzdt,el,az, dop,pvtCalculator] = kalmanPosiStatic_BDS(satPositions.BDS, rawP.BDS+satClkCorr.BDS(1,:)*299792458, ... 
                             transmitTime.BDS,ephemeris(1).para,posiChannel.BDS, config.elevationMask, ...
                             satClkCorr.BDS(2,:),pvtCalculator, posiChannel.BDS,recv_time,codeDelay.BDS,mpCnr.BDS,CNR.BDS,parameter,carriDelay.BDS,inteDopp.BDS,times);
                end
            elseif strcmp(SYST,'GPS_L1CA') || (strcmp(SYST,'B1I_L1CA')&&svnum.BDS==0)
                [xyzdt,el,az, dop,pvtCalculator] = kalmanPosi_GPS(satPositions.GPS, rawP.GPS+satClkCorr.GPS(1,:)*299792458, ... 
                         transmitTime.GPS,ephemeris(2).para,posiChannel.GPS, config.elevationMask, ...
                         satClkCorr.GPS(2,:),pvtCalculator, posiChannel.GPS,recv_time);
            elseif  strcmp(SYST,'B1I_L1CA')
                [xyzdt,el,az,dop,pvtCalculator] = kalmanPosi_dual(satPositions, rawP, transmitTime, ephemeris, posiChannel, config.elevationMask, satClkCorr, pvtCalculator, posiChannel,recv_time); 
            end

        end
    end         
     %————————————跟新上次正确定位的定位时间——————————%
    if pvtCalculator.posiTag == 1
        pvtCalculator.timeLast = recv_time.recvSOW;  % 记录此次定位时间
        pvtCalculator.posiTag = 0;                   % 跟新标志位设为0
    end
    
    
%    aaa(:,i) = pvtCalculator.kalman.mp(1).state;
    %=== Convert to geodetic coordinates ==============================
    %-------save x,y,z to XYZ.txt-------------------------------------%
%     logName = strcat(config.logFilePath, config.logName, '_XYZ.txt');
%     fid = fopen(logName, 'a');
%     fprintf(fid,'%f%20f%20f\n',xyzdt(1),xyzdt(2),xyzdt(3));
%     fclose(fid);
    %-------printf results          ----------------------------------%
    [latitude,longitude,height] = cart2geo(xyzdt(1),xyzdt(2),xyzdt(3),5);
    if logFlag == 1
        %——————————输出log文件——————————%
        OutputGPFPD(recv_time, latitude, longitude, height, xyzdt(6:8), config.logFilePath, config.logName);
        if strcmp(SYST,'B1I_L1CA')
            OutputGPGGA(latitude, longitude, height, recv_time, length(posiChannel.BDS(1,:))+length(posiChannel.GPS(1,:)), config.logFilePath, config.logName,1);  % 输出GPGGA数据
        elseif strcmp(SYST,'BDS_B1I')
            OutputGPGGA(latitude, longitude, height, recv_time, length(posiChannel.BDS(1,:)), config.logFilePath, config.logName,1);  % 输出GPGGA数据
        else
            OutputGPGGA(latitude, longitude, height, recv_time, length(posiChannel.GPS(1,:)), config.logFilePath, config.logName,1);  % 输出GPGGA数据
        end
    end
    
    clear activeChannel;
    clear satPositions;
    clear rawP;
    clear satClkCorr;
    clear transmitTime;
    rawP.GPS = [];
    rawP.BDS = [];
    satClkCorr.BDS = [];
    satClkCorr.GPS = [];
    satPositions.BDS = [];
    satPositions.GPS = [];
    activeChannel.GPS = [];% avaliable channels
    activeChannel.BDS = [];
end
