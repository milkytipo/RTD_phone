function OutputSateObsGPS(el,az,dop,recv_time,satNo, path, name, carrierVar, SNR, CNR, satPositions,satClkCorr)

%%
%输入参数
logName = strcat(path, name, '_SateObs_GPS.txt');
recorder_identifier='>';
epoch_year=recv_time.year;
epoch_month=recv_time.month;
epoch_day=recv_time.day;
epoch_hour=recv_time.hour;
epoch_min=recv_time.min;
epoch_sec=recv_time.sec;
epoch_flag=0;
epoch_numofsat=length(satNo);
sys = 'G';      % GPS系统
C = 299792458;      % 光速
%%
%输出
fid = fopen(logName,'at');
fprintf(fid,'%s %4d %2.2d %2.2d %2.2d %2.2d%11.7f %1d%3d %8.5f %8.5f\n',...
    recorder_identifier,epoch_year,epoch_month,epoch_day,...
    epoch_hour,epoch_min,epoch_sec,epoch_flag,epoch_numofsat,dop(1),dop(2));
for ii=1:epoch_numofsat
    fprintf(fid,'%s%2.2d%12.3f%12.3f%12.3f%12.3f %12.10f %14.4f %14.4f %14.4f %14.4f %14.4f %14.4f %14.4f %14.4f\n',...
        sys,satNo(ii),el(satNo(ii)),az(satNo(ii)),SNR(satNo(ii)), CNR(satNo(ii)), carrierVar(satNo(ii)), satPositions(1,satNo(ii)), ...
        satPositions(2,satNo(ii)), satPositions(3,satNo(ii)), satClkCorr(1,satNo(ii))*C, satClkCorr(2,satNo(ii))*C...
        , satPositions(4,satNo(ii)), satPositions(5,satNo(ii)), satPositions(6,satNo(ii)));
end
fclose(fid);

 