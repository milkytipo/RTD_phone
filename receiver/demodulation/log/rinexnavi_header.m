function rinexnavi_header(logName)
%%
rinex_version=3.02;
file_type='N';
sat_sys='C';
software_name='GSARx-mm';
group_name='SJTU';
create_date='20150122   ';

%%
fid=fopen(logName,'at');
fprintf(fid,'%9.2f           %s                   %s                   RINEX VERSION / TYPE\n',rinex_version,file_type,sat_sys);
fprintf(fid,'%20s%20s%20sPGM / RUN BY / DATE\n',software_name,group_name,create_date);
fprintf(fid,'                                                            END OF HEADER\n');
fclose(fid);
end