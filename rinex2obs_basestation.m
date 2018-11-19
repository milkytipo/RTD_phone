function [parameter, SOW] = rinex2obs_basestation(filename_RinexObs, fileNameBds, fileNameGps, decimate_factor, refPos, syst,Acc_WGS84,V_WGS84_s)
% clear;
% filename_RinexObs = 'E:\个人资料\小论文材料\ION2018\data\20180326_NanjingEastRoad.obs'; 
% fileNameBds = 'E:\个人资料\小论文材料\ION2018\data\BDS_Eph_20180324.18p';
% fileNameGps = 'E:\个人资料\小论文材料\ION2018\data\GPS_Eph_20180324.18p';

%% rinex读取
[C1, L1, S1, D1, ch, SOW] = read_rinex(filename_RinexObs, decimate_factor);
% refPos = [-2850197.286; 4655185.885; 3288382.972];  % 静态点
refPos = repmat(refPos, 1, length(SOW));
c = 299792458;

%% obs初始化
maxPrnNo = 35;      % 系统PRN号最大值
maxPath = 5;        % 每颗卫星信号最多达到路径数目
logCount = length(SOW);    % 读取总记录次数
%———————————— 参数初始化 ————————————%
parameter = struct(...
    'SYST',              '',...                         % 系统
    'prnMax',           [],...                          % 此段数据所有可见卫星信号的PRN号
    'prnNo',            nan(maxPrnNo,logCount),...      % 当前时刻可见卫星的PRN号
    'PDOP',             nan(1,logCount),...             % PDOP值 [1 × 记录时刻]
    'localClkErr',      nan(1,logCount),...             % 本地钟差 [1 × 记录时刻]
    'localClkDrift',    nan(1,logCount),...             % 本地钟漂 [1 × 记录时刻]
    'Elevation',        nan(maxPrnNo,logCount),...      % 仰角 [卫星PRN号 × 记录时刻]
    'Azimuth',          nan(maxPrnNo,logCount),...      % 方位角 [卫星PRN号 × 记录时刻]
    'Pseudorange',      nan(maxPrnNo,logCount),...      % 伪距 [卫星PRN号 × 记录时刻]
    'InteDopp',         nan(maxPrnNo,logCount),...      % 积分多普勒 [卫星PRN号 × 记录时刻]
    'TransTime',        nan(maxPrnNo,logCount),...      % 信号发射时间 [卫星PRN号 × 记录时刻]
    'carriErr',         nan(maxPrnNo,logCount),...      % 载波环估计误差方差 （°）[卫星PRN号 × 记录时刻]
    'carriPhase',       nan(maxPrnNo,logCount),...      % 载波相位值 [卫星PRN号 × 记录时刻]
    'doppFreq',         nan(maxPrnNo,logCount),...       % 多普勒频率 [卫星PRN号 × 记录时刻]
    'codePhase',        nan(maxPrnNo,logCount),...      % 扩频码相位 [卫星PRN号 × 记录时刻]
    'satPos',           '',...                          % 卫星位置
    'satClkErr',        nan(maxPrnNo,logCount),...      % 卫星钟差 [卫星PRN号 × 记录时刻]
    'satClkDrift',      nan(maxPrnNo,logCount),...      % 卫星钟差漂移 [卫星PRN号 × 记录时刻]
    'pathNum',          nan(maxPrnNo,logCount),...      % 信号路径数目 [卫星PRN号 × 记录时刻]
    'codePhaseErr',     nan(maxPrnNo,logCount),...      % 多径引起的码相位偏差 [卫星PRN号 × 记录时刻]
     'IMU_vx',           0,...
     'IMU_vy',           0,...
     'IMU_vz',           0,...
    'IMU_ax',           0,...
    'IMU_ay',               0,...
    'IMU_az',               0,...
    'pathPara',         ''...
    );
parameter(1:2,1) = parameter;
satPos = struct(...
    'position',         nan(3,logCount),...             % 卫星位置 [(X Y Z) × 记录时刻]
    'velocity',         nan(3,logCount)...              % 卫星速度 [(Vx Vy Vz) × 记录时刻]
    );
pathPara = struct(...
    'codePhaseDelay',   nan(maxPath,logCount),...             % 码相位延时 [1 × 记录时刻]
    'ampI',             nan(maxPath,logCount),...             % I路信号幅值 [1 × 记录时刻]
    'ampQ',             nan(maxPath,logCount),...             % Q路信号幅值 [1 × 记录时刻]
    'SNR',              nan(maxPath,logCount),...             % 信噪比 [1 × 记录时刻]
    'CNR',              nan(maxPath,logCount)...              % 载噪比 [1 × 记录时刻]
    );
parameter(1).SYST = 'BDS_B1I';      % 第一行记录北斗B1I信号参数
parameter(2).SYST = 'GPS_L1CA';     % 第二行记录GPS L1CA信号参数
parameter(1).satPos = satPos;
parameter(1).satPos(1:maxPrnNo,1) = parameter(1).satPos;
parameter(2).satPos = satPos;
parameter(2).satPos(1:maxPrnNo,1) = parameter(2).satPos;
parameter(1).pathPara = pathPara;
parameter(1).pathPara(1:maxPrnNo,1) = parameter(1).pathPara;
parameter(2).pathPara = pathPara;
parameter(2).pathPara(1:maxPrnNo,1) = parameter(2).pathPara;

%% —————————— 北斗卫星参数赋值 ————————————%
if strcmp(syst, 'BDS_B1I') || strcmp(syst, 'B1I_L1CA')
    sat_BDS = unique(ch.BDS);
    sat_BDS(isnan(sat_BDS)) = [];
    parameter(1).prnMax = sat_BDS(2:end)';  
    parameter(1).prnNo = ch.BDS;
    parameter(1).Pseudorange = C1.BDS;
    [row,col] = find(parameter(1).Pseudorange>6e7);
    if ~isempty(row)
        for i = 1 : length(row)
            parameter(1).prnNo(parameter(1).prnNo(:, col(i))==row(i), col(i)) = nan;
        end
    end
    parameter(1).InteDopp = L1.BDS;
    parameter(1).TransTime = repmat(SOW, maxPrnNo, 1) - 14 - parameter(1).Pseudorange/c;
    parameter(1).doppFreq = D1.BDS;
    parameter(1).pathNum = ones(maxPrnNo,logCount);
    [satPara, PrnList] = satPosVelEph(parameter(1).TransTime, parameter(1).prnNo, fileNameBds, refPos, 'BDS');
    for i = 1 : maxPrnNo
        parameter(1).Elevation(i, :) = satPara.BDS.para(i).El;
        parameter(1).Azimuth(i, :) = satPara.BDS.para(i).Az;
        parameter(1).satPos(i).position = satPara.BDS.para(i).satPos;
        parameter(1).satPos(i).velocity = satPara.BDS.para(i).satVel;
        parameter(1).satClkErr(i, :) = satPara.BDS.para(i).clkErr(1, :) * c;
        parameter(1).satClkDrift(i, :) = satPara.BDS.para(i).clkErr(2, :) * c;
        parameter(1).pathPara(i).codePhaseDelay(1, :) = zeros(1, logCount);
        parameter(1).pathPara(i).CNR(1, :) = S1.BDS(i, :);
    end%
    %——————————去除错误卫星号————————————%
    for i = 1 : length(parameter(1).prnMax)
        if ~ismember(parameter(1).prnMax(i), PrnList.BDS)
            errPrn = parameter(1).prnMax(i);
            parameter(1).prnNo(parameter(1).prnNo==errPrn) = nan;
        end
    end
end % if strcmp(syst, 'BDS_B1I') || strcmp(syst, 'B1I_L1CA')

%% —————————— GPS卫星参数赋值 ————————————%
if strcmp(syst, 'GPS_L1CA') || strcmp(syst, 'B1I_L1CA')
    sat_GPS = unique(ch.GPS);  
    sat_GPS(isnan(sat_GPS)) = [];
    parameter(2).prnMax = sat_GPS(2:end)';  
    parameter(2).prnNo = ch.GPS;
    parameter(2).Pseudorange = C1.GPS;
    [row,col] = find(parameter(2).Pseudorange>6e7);
    Acc_WGS84(:,1) = 0;
        Acc_WGS84(:,2) = 0;
            Acc_WGS84(:,3) = 0;
    parameter(2).IMU_ax = Acc_WGS84(:,1);
    parameter(2).IMU_ay = Acc_WGS84(:,2);
    parameter(2).IMU_az = Acc_WGS84(:,3);
    parameter(2).IMU_vx = V_WGS84_s(:,1);
    parameter(2).IMU_vy = V_WGS84_s(:,2);
    parameter(2).IMU_vz = V_WGS84_s(:,3);
    
    if ~isempty(row)
        for i = 1 : length(row)
            parameter(2).prnNo(parameter(2).prnNo(:, col(i))==row(i), col(i)) = nan;
        end
    end
    parameter(2).InteDopp = L1.GPS;
    parameter(2).TransTime = repmat(SOW, maxPrnNo, 1) - parameter(2).Pseudorange/c;
    parameter(2).doppFreq = D1.GPS;
    parameter(2).pathNum = ones(maxPrnNo,logCount);
    [satPara, PrnList] = satPosVelEph(parameter(2).TransTime, parameter(2).prnNo, fileNameGps, refPos, 'GPS');
    for i = 1 : maxPrnNo
        parameter(2).Elevation(i, :) = satPara.GPS.para(i).El;
        parameter(2).Azimuth(i, :) = satPara.GPS.para(i).Az;
        parameter(2).satPos(i).position = satPara.GPS.para(i).satPos;
        parameter(2).satPos(i).velocity = satPara.GPS.para(i).satVel;
        parameter(2).satClkErr(i, :) = satPara.GPS.para(i).clkErr(1, :) * c;
        parameter(2).satClkDrift(i, :) = satPara.GPS.para(i).clkErr(2, :) * c;
        parameter(2).pathPara(i).codePhaseDelay(1, :) = zeros(1, logCount);
        parameter(2).pathPara(i).CNR(1, :) = S1.GPS(i, :);
    end
    %——————————去除错误卫星号————————————%
    for i = 1 : length(parameter(2).prnMax)
        if ~ismember(parameter(2).prnMax(i), PrnList.GPS)
            errPrn = parameter(2).prnMax(i);
            parameter(2).prnNo(parameter(2).prnNo==errPrn) = nan;
        end
    end
end % if strcmp(syst, 'GPS_L1CA') || strcmp(syst, 'B1I_L1CA')

