function OutputGPFPD(recv_time, latitude, longitude, height, enuVel, path, name)
    logName = strcat(path, name, '_GPFPD.txt');
    head = '$GPFPD';
    if isnan(latitude)
        latitude = 0;
        longitude = 0;
        height = 0;
    end
    fid = fopen(logName,'at');
    fprintf(fid,'%s,%4.4d,%010.3f,00,00,00,%10.7f,%11.7f,%9.3f,%9.3f,%9.3f,%9.3f,00\n',...
        head, recv_time.weeknum, recv_time.recvSOW,latitude,longitude,height,enuVel(1),enuVel(2),enuVel(3)); 
    fclose(fid);