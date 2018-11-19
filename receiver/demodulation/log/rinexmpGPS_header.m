function rinexmpGPS_header(recv_time,logName)
%%
%rinex√˚≥∆ ‰»Î
rinex_version=3.02;
file_type='MP';
sat_sys='G';
software_name='GSARx-mm';
group_name='SJTU';
create_date='20150120   ';
marker_name='weidianzilou   ';
obs_type_sys='G';
obs_type_num=4;
obs_type_descri=' code_delay  phase_delay  CNR';
interval=1;
first_obs_time_year=recv_time.year;
first_obs_time_mon=recv_time.month;
first_obs_time_day=recv_time.day;
first_obs_time_hour=recv_time.hour;
first_obs_time_min=recv_time.min;
first_obs_time_sec=recv_time.sec;
first_obs_time_sys='GPS';



%%
%write header section
fid=fopen(logName,'at');
fprintf(fid,'%9.2f           %s                   %s                  RINEX VERSION / TYPE\n',rinex_version,file_type,sat_sys);
fprintf(fid,'%20s%20s%20sPGM / RUN BY / DATE\n',software_name,group_name,create_date);
fprintf(fid,'%60sMARKER NAME\n',marker_name);
fprintf(fid,'%s  %3d%36s                  SYS / # / OBS TYPES\n',obs_type_sys,obs_type_num,obs_type_descri);
fprintf(fid,'%10.3f                                                  INTERVAL\n',interval);
fprintf(fid,'%6d%6d%6d%6d%6d%13.7f     %3s         TIME OF FIRST OBS\n',first_obs_time_year,first_obs_time_mon,first_obs_time_day,first_obs_time_hour,first_obs_time_min,first_obs_time_sec,first_obs_time_sys);
fprintf(fid,'                                                            END OF HEADER\n');
fclose(fid);

end
