function OutputPDR(timestamp, positionXYZ, enuVel, path, name)
    logName = strcat(path, name, '_GNSS_PDR.txt');
    head = '$GNSS_PDR';
    X=positionXYZ(1);
        Y=positionXYZ(2);
            Z=positionXYZ(3);
    if isnan(positionXYZ)
        X = 0;
        Y = 0;
        Z = 0;
    end
    fid = fopen(logName,'a');
    fprintf(fid,'%s,%9.4f,%9.4f,%9.4f,%9.4f,%9.4f,%9.4f\n',int64(timestamp),X,Y,Z,enuVel(1),enuVel(2),enuVel(3)); 
%     fprintf(fid,'%s,\n',head, timestamp); 

    fclose(fid);