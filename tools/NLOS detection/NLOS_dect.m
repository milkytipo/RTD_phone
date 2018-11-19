
clear; clc; fclose all; 

syst = 'GPS_L1CA';
maxNum = 35;
fileName_Base = 'E:\个人资料\小论文材料\ION2018\data\20180324_NanjjingEastRoad_baseStation.18O'; 
fileName_Move = 'E:\个人资料\小论文材料\ION2018\data\20180324_NanjingEastRoad_GPS&GLONASS.18O'; 
fileNameBds = 'E:\个人资料\小论文材料\ION2018\data\BDS_Eph_20180324.18p';
fileNameGps = 'E:\个人资料\小论文材料\ION2018\data\GPS_Eph_20180324.18p';
filenameIE = 'E:\个人资料\小论文材料\ION2018\data\20180324_NanjingEastRoad_calibration.txt';
refPos = [-2853445.926; 4667466.476; 3268291.272];
[paraRef, sowRef] = rinex2obs(fileName_Base, fileNameBds, fileNameGps, 2, refPos, syst); 
[paraMov, sowMov] = rinex2obs(fileName_Move, fileNameBds, fileNameGps, 1, refPos, syst); 
[movPosIE, ~, sowIE, HMS_IE] = readIE(filenameIE, '20180324');
sowIE = sowIE + 18; % UTC时间转换为GPS时间

timeLen = length(sowMov);
prErrGPS = nan(maxNum, timeLen);

if strcmp(syst, 'GPS_L1CA')
    for i = 1 : timeLen
        satNo = paraMov(2).prnNo(:, i); % 此处假设移动站可见卫星全部在基准站监测范围内
        satNo(isnan(satNo)) = [];
        for j = 1 : length(satNo)
            prn = satNo(j);
            % 基准站
            prRefPredict = norm(paraRef(2).satPos(prn).position(:, i) - refPos);
            prRefErr = prRefPredict - paraRef(2).Pseudorange(prn, i);
            % 移动站
            [~, col] = ismember(sowMov(i), sowIE);           
            prMovPredict = norm(paraMov(2).satPos(prn).position(:, i) - movPosIE(:, col));
            prMovErr = prMovPredict - paraMov(2).Pseudorange(prn, i);
            % 误差
            prErrGPS(prn, i) = prMovErr - prRefErr;
        end
    end
end

% 找到仰角最高的卫星号
[row, col] = find(paraMov(2).Elevation == max(max(paraMov(2).Elevation)));
%—————————— 去除接收机钟差的影响 ——————————————%
x_t = 1 : timeLen;
prErr_temp = prErrGPS(row, :); % 选择仰角最高的作为参考卫星号
% 首先利用多项式拟合做粗去除
[fitresult, ~] = createFitPoly4(x_t, prErr_temp);
errResi = prErrGPS - (fitresult(x_t))';
clkErrResi = errResi(row, :);
% 其次做sin拟合做精去除
[fitresult, ~] = createFitSin8(x_t, clkErrResi);
errNoise = errResi - (fitresult(x_t))';



