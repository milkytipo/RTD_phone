clear; close all;
%ProcessGnssMeasScript.m, script to read GnssLogger output, compute and plot:
% pseudoranges, C/No, and weighted least squares PVT solution
%
% you can run the data in pseudoranges log files provided for you: 
prFile = 'xuhui-mobile'; %with duty cycling, no carrier phase
prFileName = strcat(prFile, '.txt'); %with duty cycling, no carrier phase
% prFileName = 'pseudoranges_log_2016_08_22_14_45_50.txt'; %no duty cycling, with carrier phase
% as follows
% 1) copy everything from GitHub google/gps-measurement-tools/ to 
%    a local directory on your machine
% 2) change 'dirName = ...' to match the local directory you are using:
dirName = 'D:\20180415\mobile';
% 3) run ProcessGnssMeasScript.m script file 
param.llaTrueDegDegM = [];

%Author: Frank van Diggelen
%Open Source code for processing Android GNSS Measurements

%% data
%To add your own data:
% save data from GnssLogger App, and edit dirName and prFileName appropriately
%dirName = 'put the full path for your directory here';
%prFileName = 'put the pseuoranges log file name here';

%% parameters
%param.llaTrueDegDegM = [];
%enter true WGS84 lla, if you know it:
param.llaTrueDegDegM = [37.422578, -122.081678, -28];%Charleston Park Test Site

%% Set the data filter and Read log file
dataFilter = SetDataFilter;
[gnssRaw,gnssAnalysis] = ReadGnssLogger(dirName,prFileName,dataFilter);
if isempty(gnssRaw), return, end

%% Get online ephemeris from Nasa ftp, first compute UTC Time from gnssRaw:
fctSeconds = 1e-3*double(gnssRaw.allRxMillis(end));
utcTime = Gps2Utc([],fctSeconds);
allGpsEph = GetNasaHourlyEphemeris(utcTime,dirName);
if isempty(allGpsEph), return, end

%% process raw measurements, compute pseudoranges:
[gnssMeas] = ProcessGnssMeas(gnssRaw);

%% plot pseudoranges and pseudorange rates
h1 = figure;
[colors] = PlotPseudoranges(gnssMeas,prFileName);
h2 = figure;
PlotPseudorangeRates(gnssMeas,prFileName,colors);
h3 = figure;
PlotCno(gnssMeas,prFileName,colors);

%% compute WLS position and velocity
gpsPvt = GpsWlsPvt(gnssMeas,allGpsEph);

%！！！！！！！！！！！！！！ added by Yuze Wang ！！！！！！！！！！！！！！%
epochNum = length(gpsPvt.FctSeconds);
gpsPvt.utcTime = zeros(epochNum, 7);
for i = 1 : epochNum
    gpsPvt.utcTime(i, 1:6) = Gps2Utc([],gpsPvt.FctSeconds(i));
    year = gpsPvt.utcTime(i, 1);
    dayNumber = DayOfYear(gpsPvt.utcTime(i, 1:6));
    yearStart = [2017, 17167];
    dayAddedList = [365, 365, 365, 366, 365, 365]; % 蛍艶葎2017,2018,2019,2020,2021,2022
    dayAdded = sum(dayAddedList(1 : (year-yearStart(1))));
    dayAdded = dayAdded + dayNumber - 1; % 
    gpsPvt.utcTime(i, 7) = (yearStart(2)+dayAdded)*86400 + gpsPvt.utcTime(i, 4)*3600 + gpsPvt.utcTime(i, 5)*60 + gpsPvt.utcTime(i, 6);
end

epochRawNum = length(gnssRaw.allRxMillis);
gnssRaw.utcTime = zeros(epochRawNum, 6);
for i = 1 : epochRawNum
    gnssRaw.utcTime(i, :) = Gps2Utc([], 1e-3*double(gnssRaw.allRxMillis(i)));
end
%！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！%

%% plot Pvt results
h4 = figure;
ts = 'Raw Pseudoranges, Weighted Least Squares solution';
PlotPvt(gpsPvt,prFileName,param.llaTrueDegDegM,ts); drawnow;
h5 = figure;
PlotPvtStates(gpsPvt,prFileName);

%% Plot Accumulated Delta Range 
if any(any(isfinite(gnssMeas.AdrM) & gnssMeas.AdrM~=0))
    [gnssMeas]= ProcessAdr(gnssMeas);
    h6 = figure;
    PlotAdr(gnssMeas,prFileName,colors);
    [adrResid]= GpsAdrResiduals(gnssMeas,allGpsEph,param.llaTrueDegDegM);drawnow
    h7 = figure;
    PlotAdrResids(adrResid,gnssMeas,prFileName,colors);
end

for i = 1 : epochNum
    recv_time.hour = gpsPvt.utcTime(i, 4);
    recv_time.min = gpsPvt.utcTime(i, 5);
    recv_time.sec = gpsPvt.utcTime(i, 6);
    OutputGPGGA(gpsPvt.allLlaDegDegM(i,1), gpsPvt.allLlaDegDegM(i,2), gpsPvt.allLlaDegDegM(i,3),...
        recv_time, gpsPvt.numSvs(i), dirName, strcat('\', prFile), 1);
end
%% end of ProcessGnssMeasScript
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2016 Google Inc.
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
% 
%     http://www.apache.org/licenses/LICENSE-2.0
% 
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
