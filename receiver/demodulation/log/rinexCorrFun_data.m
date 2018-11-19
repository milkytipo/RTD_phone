function rinexCorrFun_data(x, y)
fid=fopen('.\logfile\rinex302.15CF','a');
fprintf(fid,'%1.3f  ',x);
fprintf(fid,'\n');
fprintf(fid,'%5.3f  ',y);
fprintf(fid,'\n');
fclose(fid);