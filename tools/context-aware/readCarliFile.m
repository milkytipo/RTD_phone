function [XYZ, LLH, TOWSEC, HHMMSS]=readCarliFile(filename)
fid=fopen(filename);
if fid==-2
   error('PB Error: File cannot be found or permission denied!');
end
frewind(fid);
commaIndex = zeros(1,34);
tmpArray = zeros(1,8);
k = 0;
while ~feof(fid)
    line=fgetl(fid);
    if ~ischar(line)
        break; 
    end
    
    head=line(1:7);
    if strcmp(head,'$JCCALI')
        k = k + 1;
        commaNum=0;
        len=length(line);    
        for i=1:len 
            if strcmp(line(i), ',')
                commaNum=commaNum+1;
                if commaNum<=34
                    commaIndex(commaNum)=i;
                end
            end
        end
        
        st = commaIndex(2);
        en = commaIndex(3);
        TOWSEC(k) = str2double(line(st+1:en-1));
        
        st=commaIndex(6);
        en=commaIndex(7);
        HHMMSS(1, k) = str2double(line(st+1:st+2));
        HHMMSS(2, k) = str2double(line(st+3:st+4));
        HHMMSS(3, k) = str2double(line(st+5:en-1));
        
        st=commaIndex(22);
        en=commaIndex(23);
        latitude=str2double(line(st+1:st+2))+str2double(line(st+3:en-1))/60;
        st=commaIndex(25);
        en=commaIndex(26);
        longitude=str2double(line(st+1:st+3))+str2double(line(st+4:en-1))/60;                    
        st=commaIndex(28);
        en=commaIndex(29);
        height=str2double(line(st+1:en-1));
        
        LLH(k,:) = [latitude, longitude, height];
        XYZ(k,:) = llh2xyz(LLH(k,:));  % 转化为xyz坐标   
    end
end
fclose(fid);

end