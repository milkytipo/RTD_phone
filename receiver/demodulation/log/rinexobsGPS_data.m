function rinexobsGPS_data(recv_time,rawP,inte_dopp,dopplerfre,CNR,clk,queue, logName)
%%
%输入参数
recorder_identifier='>';
epoch_year=recv_time.year;
epoch_month=recv_time.month;
epoch_day=recv_time.day;
epoch_hour=recv_time.hour;
epoch_min=recv_time.min;
epoch_sec=recv_time.sec;
epoch_flag=0;
epoch_numofsat=length(queue);
receiverclock_offset=clk;


sys='G';
sat_num = queue;
pseudorange = rawP;
carrier_phase = inte_dopp;
cnr = CNR;
doppler = dopplerfre;
LLI = 0;
strength = 7;
%%
%输出
fid = fopen(logName,'at');
fprintf(fid,'%s %4d %2.2d %2.2d %2.2d %2.2d%11.7f  %1d%3d      %15.12f\n',...
    recorder_identifier,epoch_year,epoch_month,epoch_day,...
    epoch_hour,epoch_min,epoch_sec,epoch_flag,epoch_numofsat,receiverclock_offset);
for ii=1:epoch_numofsat
    fprintf(fid,'%s%2.2d%14.3f  %14.3f%1d%1d%14.3f  %14.3f\n',...
        sys,sat_num(ii),pseudorange(queue(ii)),carrier_phase(queue(ii)),LLI,strength,cnr(queue(ii)),doppler(queue(ii)));
end
fclose(fid);


