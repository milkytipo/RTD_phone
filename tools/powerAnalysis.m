clc; clear all; close all;
fileName = 'H:\课题数据\课题数据\模块数据\20151225\SIM3#_RxRec20151225_091250.dat';
YYMMDD =  '20151225';
timeLength = 36000;
[satePara_BDS,satePara_GPS, Position, Time] = readGSV(fileName, YYMMDD, timeLength);
