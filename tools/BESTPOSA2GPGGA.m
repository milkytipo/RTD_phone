clear all;
filenameBESTPOSA = 'L:\20150803\20150803novatel\0803test2.ASC';
filenameGPGGA = 'L:\20150803\20150803novatel\0803test2GPGGA.txt';
[XYZ, LLH, TOWSEC] = readBESTPOSA(filenameBESTPOSA);

Num = length(TOWSEC);
head = '$GPGGA';
BJhour = 00;
BJmin = 00;
BJsec = 00;
useful = 1;
satnum = 00;

fid = fopen(filenameGPGGA,'at');
for i = 1:Num
    latitude = LLH(i,1);
    longitude = LLH(i,2);
    height = LLH(i,3);
    [BJday_1, BJhour, BJmin, BJsec] = sow2BJT(TOWSEC(i));
    latitude = (latitude-fix(latitude))*60 + fix(latitude)*100;
    longitude = (longitude-fix(longitude))*60 + fix(longitude)*100; 
    fprintf(fid,'%s,%2.2d%2.2d%06.3f,%09.4f,N,%010.4f,E,%1.1d,%2.2d,%09.3f,M \n',...
        head, BJhour, BJmin, BJsec, latitude, longitude, useful, satnum, height); 
end
fclose(fid);