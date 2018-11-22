function [timestamp]=readGPStimestamp(fileName_timestamp)
fid = fopen(fileName_timestamp);
[timerlength,~]=textread(fileName_timestamp,'%s %s ','delimiter',',');  
timer =strings(length(timerlength),1);
numlines =1;
%%
%把日期转化成数字字符
while 1     
    line = fgetl(fid);
    if ~ischar(line), break, end
    year= (line(1:4));
    month = (line(6:7));
    day= (line(9:10));
    hour= (line(14:15));
    minute= (line(17:18));
    second= (line(20:21));        
    timer(numlines)= strcat(year,month,day,hour,minute,second);
    numlines =numlines +1;
end

%%
%剔除重复日期
k=1;
timestamp(1) =str2double( timer(1) );
for i = 2:length(timer)
    if  ~isequal (timer(i) , timer(i-1))
    timestamp(k) =str2double( timer(i-1) );
    k=k+1;
    end
end
timestamp(k) = str2double(timer(i));
timestamp = timestamp';
end
