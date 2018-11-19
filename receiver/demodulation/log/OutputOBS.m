function OutputOBS(time, svNum, channels, el, az, dop, activeChannel, pvtCalculator, logName, SYST)

%%
global GSAR_CONSTANTS;   
C = 299792458;      % 光速
%—————— 输入参数 ————————%
recorder_identifier='>';
epoch_year=time.year;
epoch_month=time.month;
epoch_day=time.day;
epoch_hour=time.hour;
epoch_min=time.min;
epoch_sec=time.sec;
activeChannel_BDS = activeChannel.BDS;
activeChannel_GPS = activeChannel.GPS;
el_BDS = el.BDS;
el_GPS = el.GPS;
az_BDS = az.BDS;
az_GPS = az.GPS;
rawP_BDS = pvtCalculator.logOutput.rawP.BDS;
rawP_GPS = pvtCalculator.logOutput.rawP.GPS;

inteDoppler_BDS = pvtCalculator.BDS.doppSmooth(:,1);
inteDoppler_GPS = pvtCalculator.GPS.doppSmooth(:,1);
tranTime_BDS = pvtCalculator.logOutput.transmitTime.BDS;
tranTime_GPS = pvtCalculator.logOutput.transmitTime.GPS;
satPositions_BDS = pvtCalculator.logOutput.satPos.BDS;
satPositions_GPS = pvtCalculator.logOutput.satPos.GPS;
satClkErr_BDS = pvtCalculator.logOutput.satClkErr.BDS * C;
satClkErr_GPS = pvtCalculator.logOutput.satClkErr.GPS * C;
clkErr_BDS = pvtCalculator.clkErr(1,1);
clkDrift_BDS = pvtCalculator.clkErr(1,2) * GSAR_CONSTANTS.STR_B1I.B0/GSAR_CONSTANTS.C;
clkErr_GPS = pvtCalculator.clkErr(2,1);
clkDrift_GPS = pvtCalculator.clkErr(2,2) * GSAR_CONSTANTS.STR_L1CA.L0/GSAR_CONSTANTS.C;
switch SYST
    case 'BDS_B1I'
        activeChannel_BDS = sortrows(activeChannel_BDS',2)';
    case 'GPS_L1CA'
        activeChannel_GPS = sortrows(activeChannel_GPS',2)';
    case 'B1I_L1CA'
        activeChannel_BDS = sortrows(activeChannel_BDS',2)';
        activeChannel_GPS = sortrows(activeChannel_GPS',2)';
end

if strcmp(time.timeType, 'GPST')
    
elseif strcmp(time.timeType, 'BDST')
    
end




epoch_numofsat = svNum.BDS + svNum.GPS;
%%
fid = fopen(logName,'at');
fprintf(fid,'%s %4d %2.2d %2.2d %2.2d %2.2d %10.7f %2.2d %6.3f %15.3f %8.3f %15.3f %8.3f\n',...
    recorder_identifier,epoch_year,epoch_month,epoch_day,...
    epoch_hour,epoch_min,epoch_sec,epoch_numofsat,dop(1),clkErr_BDS,clkDrift_BDS,clkErr_GPS,clkDrift_GPS);
% ————————————BDS——————————————%
for i = 1 : svNum.BDS
    prn = activeChannel_BDS(2,i); % 卫星PRN号
    chm = activeChannel_BDS(1,i); % 卫星通道号
    carriErr = channels(chm).CH_B1I(1).lockDect.sigma_lock;
    carriPhase = channels(chm).CH_B1I(1).LO2_CarPhs;
    carriFrq = channels(chm).CH_B1I(1).LO2_fd + GSAR_CONSTANTS.STR_B1I.B0;
    codePhase = channels(chm).CH_B1I(1).LO_CodPhs;
    pathNum = length(channels(chm).CH_B1I);
    elevation = el_BDS(prn);
    rawP = rawP_BDS(prn);
    if elevation < 0
        elevation = 0;
    end
    if abs(rawP) > 999999999
        rawP = 999999999;
    end
    if abs(inteDoppler_BDS(prn)) > 999999999
        inteDoppler_BDS(prn) = 999999999;
    end
    if abs(satPositions_BDS(1,prn)) > 99999999
        satPositions_BDS(1,prn) = 99999999;
    end
    if abs(satPositions_BDS(2,prn)) > 99999999
        satPositions_BDS(2,prn) = 99999999;
    end
    if abs(satPositions_BDS(3,prn)) > 99999999
        satPositions_BDS(3,prn) = 99999999;
    end
    if abs(satPositions_BDS(4,prn)) > 9999
        satPositions_BDS(4,prn) = 9999;
    end
    if abs(satPositions_BDS(5,prn)) > 9999
        satPositions_BDS(5,prn) = 9999;
    end
    if abs(satPositions_BDS(6,prn)) > 9999
        satPositions_BDS(6,prn) = 9999;
    end
    if abs(satClkErr_BDS(1,prn)) > 99999999
        satClkErr_BDS(1,prn) = 99999999;
    end
    fprintf(fid,'C%2.2d %5.2f %6.2f %14.3f %14.3f %19.12f %8.5f %8.5f %13.2f %10.5f %14.4f %14.4f %14.4f %10.4f %10.4f %10.4f %14.4f %8.4f %2.2d',...
        prn, elevation, az_BDS(prn), rawP, inteDoppler_BDS(prn), tranTime_BDS(prn), carriErr,...
        carriPhase, carriFrq, codePhase, satPositions_BDS(1,prn), satPositions_BDS(2,prn), satPositions_BDS(3,prn), ...
        satPositions_BDS(4,prn), satPositions_BDS(5,prn), satPositions_BDS(6,prn), satClkErr_BDS(1,prn), satClkErr_BDS(2,prn), pathNum);
    for ii = 1 : pathNum
        if ii == 1
            code_delay = channels(chm).CH_B1I(1).codePhaseErr;
        else
            code_delay = channels(chm).CH_B1I(1).LO_CodPhs - channels(chm).CH_B1I(ii).LO_CodPhs;
            if code_delay < 0 
                code_delay = code_delay + 2046;
            end
        end
        
        Ip = channels(chm).ALL(ii).ai_v(1);
        Qp = channels(chm).ALL(ii).aq_v(1);
        snr = channels(chm).ALL(ii).SNR;
        cnr=channels(chm).CH_B1I(ii).CN0_Estimator.CN0; 
        insertNum = channels(chm).CH_B1I(ii).preUnitNum + 1;    % C中从0开始计数
        fprintf(fid,' %2.2d %8.5f %11.8f %11.8f %5.2f %5.2f',...
            insertNum,code_delay,Ip,Qp,snr,cnr);
    end
    fprintf(fid,'\n');
end
%——————————————GPS——————————————————%
for i = 1 : svNum.GPS
    prn = activeChannel_GPS(2,i); % 卫星PRN号
    chm = activeChannel_GPS(1,i); % 卫星通道号
    carriErr = channels(chm).CH_L1CA(1).lockDect.sigma_lock;
    carriPhase = channels(chm).CH_L1CA(1).LO2_CarPhs;
    carriFrq = channels(chm).CH_L1CA(1).LO2_fd + GSAR_CONSTANTS.STR_L1CA.L0;
    codePhase = channels(chm).CH_L1CA(1).LO_CodPhs;
    pathNum = length(channels(chm).CH_L1CA);
    elevation = el_GPS(prn);
    rawP = rawP_GPS(prn);
    if elevation < 0
        elevation = 0;
    end
    if abs(rawP) > 999999999
        rawP = 999999999;
    end
    if abs(inteDoppler_GPS(prn)) > 999999999
        inteDoppler_GPS(prn) = 999999999;
    end
    if abs(satPositions_GPS(1,prn)) > 99999999
        satPositions_GPS(1,prn) = 99999999;
    end
    if abs(satPositions_GPS(2,prn)) > 99999999
        satPositions_GPS(2,prn) = 99999999;
    end
    if abs(satPositions_GPS(3,prn)) > 99999999
        satPositions_GPS(3,prn) = 99999999;
    end
    if abs(satPositions_GPS(4,prn)) > 9999
        satPositions_GPS(4,prn) = 9999;
    end
    if abs(satPositions_GPS(5,prn)) > 9999
        satPositions_GPS(5,prn) = 9999;
    end
    if abs(satPositions_GPS(6,prn)) > 9999
        satPositions_GPS(6,prn) = 9999;
    end
    if abs(satClkErr_GPS(1,prn)) > 99999999
        satClkErr_GPS(1,prn) = 99999999;
    end
    fprintf(fid,'G%2.2d %5.2f %6.2f %14.3f %14.3f %19.12f %8.5f %8.5f %10.2f %10.5f %14.4f %14.4f %14.4f %10.4f %10.4f %10.4f %14.4f %8.4f %2.2d',...
        prn, elevation, az_GPS(prn), rawP, inteDoppler_GPS(prn), tranTime_GPS(prn), carriErr,...
        carriPhase, carriFrq, codePhase, satPositions_GPS(1,prn), satPositions_GPS(2,prn), satPositions_GPS(3,prn), ...
        satPositions_GPS(4,prn), satPositions_GPS(5,prn), satPositions_GPS(6,prn), satClkErr_GPS(1,prn), satClkErr_GPS(2,prn), pathNum);
    for ii = 1 : pathNum
        if ii == 1
            code_delay = channels(chm).CH_L1CA(1).codePhaseErr;
        else
            code_delay = channels(chm).CH_L1CA(1).LO_CodPhs - channels(chm).CH_L1CA(ii).LO_CodPhs;
            if code_delay < 0 
                code_delay = code_delay + 1023;
            end
        end
        Ip = channels(chm).ALL(ii).ai_v(1);
        Qp = channels(chm).ALL(ii).aq_v(1);
        snr = channels(chm).ALL(ii).SNR;
        cnr=channels(chm).CH_L1CA(ii).CN0_Estimator.CN0;
        insertNum = channels(chm).CH_L1CA(ii).preUnitNum + 1;    % C中从0开始计数
        fprintf(fid,' %2.2d %8.5f %11.8f %11.8f %5.2f %5.2f',...
            insertNum,code_delay,Ip,Qp,snr,cnr);
    end
    fprintf(fid,'\n');
end
fclose(fid);

    



