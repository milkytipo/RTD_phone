function [filename, fileCalib, fileEphBds, fileEphGps, YYMMDD, TYPE] = fileNameInitial()



folderName = 'E:\个人资料\小论文材料\Receiver test database\ubx\';

filename{1} = strcat(folderName, 'xuhui.txt');
fileCalib{1} = strcat(folderName, '\ublox data\20160316_SH-Xuhui_jizhun.txt');
fileEphBds{1} = strcat(folderName, 'Eph_BDS_20180415.txt');
fileEphGps{1} = strcat(folderName, 'Eph_GPS_20180415.txt');
YYMMDD{1} = '20180415';

filename{2} = strcat(folderName, 'caohejin.txt');
fileCalib{2} = strcat(folderName, '\ublox data\20160220_SH_Fenxian_Moving_playback_jizhun.txt');
fileEphBds{2} = strcat(folderName, 'Eph_BDS_20180324.txt');
fileEphGps{2} = strcat(folderName, 'Eph_GPS_20180324.txt');
YYMMDD{2} = '20180324';


filename{3} = strcat(folderName, 'sjtu.txt');
fileCalib{3} = strcat(folderName, '\ublox data\20150712_SH_DonghaiBridge_jizhun.txt');
fileEphBds{3} = strcat(folderName, 'Eph_BDS_20180415.txt');
fileEphGps{3} = strcat(folderName, 'Eph_GPS_20180415.txt');
YYMMDD{3} = '20180415';

filename{4} = strcat(folderName, 'boulevard.txt');
fileCalib{4} = strcat(folderName, '\ublox data\20160422-SH-NeihuanGaojiaxia_Palyback_jizhun.txt');
fileEphBds{4} = strcat(folderName, 'Eph_BDS_20180415.txt');
fileEphGps{4} = strcat(folderName, 'Eph_GPS_20180415.txt');
YYMMDD{4} = '20180415';


filename{5} = strcat(folderName, 'viaduct-down.txt');
fileCalib{5} = strcat(folderName, '\ublox data\20171122_SH_chongming_tree_jizhun.txt');
fileEphBds{5} = strcat(folderName, 'Eph_BDS_20180415.txt');
fileEphGps{5} = strcat(folderName, 'Eph_GPS_20180415.txt');
YYMMDD{5} = '20180415';

filename{6} = strcat(folderName, '\ublox data\20171126_SH_SJTU_suburb.txt');
fileCalib{6} = strcat(folderName, '\ublox data\20171126_SH_SJTU_suburb_jizhun.txt');
fileEphBds{6} = strcat(folderName, 'Eph_BDS_20180415.txt');
fileEphGps{6} = strcat(folderName, 'Eph_GPS_20180415.txt');
YYMMDD{6} = '20180415';


TYPE{1} = 'canyon';
TYPE{2} = 'urban';
TYPE{3} = 'surburb';
TYPE{4} = 'boulevard';
TYPE{5} = 'viaduct_down';
TYPE{6} = 'boulevard';

% —————————— 用以作场景识别验证数据 ————————————%
filename{7} = strcat(folderName, '\ublox data\20180222_NJ_all.txt');
fileCalib{7} = strcat(folderName, '\ublox data\20180222_NJ_all.txt');
fileEphBds{7} = strcat(folderName, '\Eph\Eph_BDS_20180222.txt');
fileEphGps{7} = strcat(folderName, '\Eph\Eph_GPS_20180222.txt');
YYMMDD{7} = '20180222';
TYPE{7} = 'all';

% filename{7} = strcat(folderName, '\ublox data\20180228_SH_predict.txt');
% fileCalib{7} = strcat(folderName, '\ublox data\20180228_SH_predict.txt');
% fileEphBds{7} = strcat(folderName, '\Eph\Eph_BDS_20180228.txt');
% fileEphGps{7} = strcat(folderName, '\Eph\Eph_GPS_20180228.txt');
% YYMMDD{7} = '20180228';
% TYPE{7} = 'all';

end 