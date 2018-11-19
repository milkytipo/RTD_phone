function rinexobs_header(pos,recv_time, logName)
%%
%rinex√˚≥∆ ‰»Î
rinex_version=3.02;
file_type='O';
sat_sys='C';
software_name='GSARx-mm';
group_name='SJTU';
create_date='20150120   ';
marker_name='weidianzilou   ';
observer='wangyuze';
agency='sjtu   ';
receiver_num='12345';
receiver_type='software';
receiver_version='1.01   ';
antenna_num='123';
antenna_type='novatel';
approx_pos_x=pos(1);
approx_pos_y=pos(2);
approx_pos_z=pos(3);
antenna_delta_H=0;
antenna_delta_E=0;
antenna_delta_N=0;
obs_type_sys='C';
obs_type_num=4;
obs_type_descri=' C1I L1I S1I D1I';
interval=1;
first_obs_time_year=recv_time.year;
first_obs_time_mon=recv_time.month;
first_obs_time_day=recv_time.day;
first_obs_time_hour=recv_time.hour;
first_obs_time_min=recv_time.min;
first_obs_time_sec=recv_time.sec;
first_obs_time_sys=recv_time.timeType;



%%
%write header section
fid=fopen(logName, 'at');
fprintf(fid,'%9.2f           %s                   %s                   RINEX VERSION / TYPE\n',rinex_version,file_type,sat_sys);
fprintf(fid,'%20s%20s%20sPGM / RUN BY / DATE\n',software_name,group_name,create_date);
fprintf(fid,'%60sMARKER NAME\n',marker_name);
fprintf(fid,'%20s%40sOBSERVER / AGENCY\n',observer,agency);
fprintf(fid,'%20s%20s%20sREC # / TYPE / VERS \n',receiver_num,receiver_type,receiver_version);
fprintf(fid,'%20s%20s                    ANT # / TYPE\n',antenna_num,antenna_type);
fprintf(fid,'%14.4f%14.4f%14.4f                  APPROX POSITION XYZ\n',approx_pos_x,approx_pos_y,approx_pos_z);
fprintf(fid,'%14.4f%14.4f%14.4f                  ANTENNA: DELTA H/E/N\n',antenna_delta_H,antenna_delta_E,antenna_delta_N);
fprintf(fid,'%s  %3d%16s                                      SYS / # / OBS TYPES\n',obs_type_sys,obs_type_num,obs_type_descri);
fprintf(fid,'%10.3f                                                  INTERVAL\n',interval);
fprintf(fid,'%6d%6d%6d%6d%6d%13.7f     %3s         TIME OF FIRST OBS\n',first_obs_time_year,first_obs_time_mon,first_obs_time_day,first_obs_time_hour,first_obs_time_min,first_obs_time_sec,first_obs_time_sys);
fprintf(fid,'                                                            END OF HEADER\n');
fclose(fid);

end
