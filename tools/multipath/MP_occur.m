isRead = 0; clc;
if isRead
    clear;clc;fclose all;
    filename = '';
    %fileName_O = 'D:\数据处理结果\Lujiazui_static_2_2016-5-18_18-55-19\Lujiazui_static_2_2016-5-18_18-55-19.15O';
    % filename_Sateobs_BDS = 'C:\Users\wyz\Desktop\logfile+m\logfile\The_Three_Towers_SateObs_BDS.txt';
    % [el_BDS,az_BDS,SNR_BDS,CNR_BDS,carriVar_BDS,satPos_x_BDS,satPos_y_BDS,satPos_z_BDS,satVel_x_BDS,satVel_y_BDS,satVel_z_BDS,satClcErr_BDS,satClcErrDot_BDS,TOWSEC_BDS]...
    %      = readSatobs(filename_Sateobs_BDS);
    %     [parameter,prnNum,prnMax,TOWSEC_1] = readMP(fileName_MP);
    [parameter, SOW] = readObs(filename);
    prnBDS = parameter(1).prnMax;
    prnGPS = parameter(2).prnMax;
    xlsName = '';
end


xlsLine = '2';
sheetName = 'occurance';
timeInterval = 0.1;
column{1} = {strcat('A',xlsLine),strcat('B',xlsLine),strcat('C',xlsLine),strcat('D',xlsLine)};
column{2} = {strcat('H',xlsLine),strcat('I',xlsLine),strcat('J',xlsLine),strcat('K',xlsLine)};
if ~isempty(prnBDS)
    for i = 1:length(prnBDS)
        prn_BDS(i,1) = prnBDS(i);
        interval_BDS = 1:size(SOW, 2);
        path_pool_BDS = parameter(1).pathNum(prn_BDS(i,1), interval_BDS);
        path_pool_BDS(isnan(path_pool_BDS)) = [];
        elev_BDS = parameter(1).Elevation(prn_BDS(i,1), interval_BDS);
        elev_BDS(isnan(elev_BDS)) = [];
        total_BDS(i,1) = length(path_pool_BDS);
        no_multipath_BDS = length(find(path_pool_BDS==1));
        prabality_BDS(i,1) = 1 - no_multipath_BDS/total_BDS(i,1);
        ave_elev_BDS(i,1) = mean(elev_BDS);
    end
    total_BDS = total_BDS * timeInterval;
    xlswrite(xlsName, prn_BDS, sheetName, column{1,1}{1,1});
    xlswrite(xlsName, prabality_BDS, sheetName, column{1,1}{1,2});
    xlswrite(xlsName, ave_elev_BDS, sheetName, column{1,1}{1,3});
    xlswrite(xlsName, total_BDS, sheetName, column{1,1}{1,4});
end
if ~isempty(prnGPS)
    for i = 1:length(prnGPS)
        prn_GPS(i,1) = prnGPS(i);
        interval_GPS = 1:size(SOW, 2);
        path_pool_GPS = parameter(2).pathNum(prn_GPS(i,1), interval_GPS);
        path_pool_GPS(isnan(path_pool_GPS)) = [];
        elev_GPS = parameter(2).Elevation(prn_GPS(i,1), interval_GPS);
        elev_GPS(isnan(elev_GPS)) = [];
        total_GPS(i,1) = length(path_pool_GPS);
        no_multipath_GPS = length(find(path_pool_GPS==1));
        prabality_GPS(i,1) = 1 - no_multipath_GPS/total_GPS(i,1);
        ave_elev_GPS(i,1) = mean(elev_GPS);
    end
    total_GPS = total_GPS * timeInterval;
    xlswrite(xlsName, prn_GPS, sheetName, column{1,2}{1,1});
    xlswrite(xlsName, prabality_GPS, sheetName, column{1,2}{1,2});
    xlswrite(xlsName, ave_elev_GPS, sheetName, column{1,2}{1,3});
    xlswrite(xlsName, total_GPS, sheetName, column{1,2}{1,4});
end



