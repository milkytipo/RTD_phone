function rinexobs_data_dual(recv_time,rawP,inte_dopp,dopplerfre,CNR,clk,queue,logName)
%%
%输入参数
recorder_identifier = '>';
epoch_year = recv_time.year;
epoch_month = recv_time.month;
epoch_day = recv_time.day;
epoch_hour = recv_time.hour;
epoch_min = recv_time.min;
epoch_sec = recv_time.sec;
epoch_flag = 0;
receiverclock_offset = clk;

epoch_numofsat.BDS = length(queue.BDS);
epoch_numofsat.GPS = length(queue.GPS);
sys.BDS = 'C';
sys.GPS = 'G';
sat_num.BDS = queue.BDS;
sat_num.GPS = queue.GPS;
pseudorange.BDS = rawP.BDS;
pseudorange.GPS = rawP.GPS;
carrier_phase.BDS = inte_dopp.BDS;
carrier_phase.GPS = inte_dopp.GPS;
cnr.BDS = CNR.BDS;
cnr.GPS = CNR.GPS;
doppler.BDS = dopplerfre.BDS;
doppler.GPS = dopplerfre.GPS;
LLI = 0;
strength = 7;
%%
%输出
fid = fopen(logName,'at');
fprintf(fid,'%s %4d %2.2d %2.2d %2.2d %2.2d%11.7f  %1d%3d      %15.12f\n',...
    recorder_identifier,epoch_year,epoch_month,epoch_day,...
    epoch_hour,epoch_min,epoch_sec,epoch_flag,epoch_numofsat.BDS+epoch_numofsat.GPS,receiverclock_offset);
for ii=1:epoch_numofsat.GPS
    fprintf(fid,'%s%2.2d%14.3f  %14.3f%1d%1d%14.3f  %14.3f\n',...
        sys.GPS,sat_num.GPS(ii),pseudorange.GPS(queue.GPS(ii)),carrier_phase.GPS(queue.GPS(ii)),LLI,strength,cnr.GPS(queue.GPS(ii)),doppler.GPS(queue.GPS(ii)));
end
for ii=1:epoch_numofsat.BDS
    fprintf(fid,'%s%2.2d%14.3f  %14.3f%1d%1d%14.3f  %14.3f\n',...
        sys.BDS,sat_num.BDS(ii),pseudorange.BDS(queue.BDS(ii)),carrier_phase.BDS(queue.BDS(ii)),LLI,strength,cnr.BDS(queue.BDS(ii)),doppler.BDS(queue.BDS(ii)));
end
fclose(fid);


