function OutputGPBPL(recv_time, path, name, carrierVar, queue)
    logName = strcat(path, name, '_GPBPL.txt');
    head = '$GPBPL';
    satSum = length(queue);
    fid = fopen(logName,'at');
    fprintf(fid,'%s,%4.4d,%010.3f,%2.2d',...
        head, recv_time.weeknum, recv_time.recvSOW,satSum); 
    for i = 1 : satSum
        fprintf(fid,',%2.2d,%12.10f',queue(i),carrierVar(queue(i)));
    end
    fprintf(fid,'\n');
    fclose(fid);
end