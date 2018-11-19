function rinexCorrFun_header(prnid,time,num)
%%
fid=fopen('.\logfile\rinex302.15CF','a');
fprintf(fid,'%2.2d  %2.2d  %2.2d\n',prnid,num,time.recvSOW);
fclose(fid);
end