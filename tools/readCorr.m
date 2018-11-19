close all;
filename='D:\数据处理结果\Lujiazui_static_point_11\Lujiazui_static_point_11_Corr_BDS.txt';
plotFigPrn = 6;    % 要画卫星的prn号
smoothCons = 25;    % 平滑系数
readfile = 0; % 读文件
if readfile == 1
    %————————————read file————————————————%
    fid = fopen(filename);
    if fid==-1
       error('RINEX Navigation message data file not found or permission denied');
    end
    maxPathnum = 0;
    frewind(fid)
    POSITION_XYZ=NaN; ANTDELTA=NaN; OBSINT=NaN;
    linecount = 0;
    %  Loop through the file
    k = 0;  breakflag = 0;
    while 1     % this is the numeral '1'
           k = k + 1;    % 'k' is keeping track of our time steps
           line = fgetl(fid);
           if ~ischar(line), breakflag = 1; break, end
           linecount = linecount + 1;
           len = length(line);
           year(k) = str2double(line(3:6));
           month(k) = str2double(line(8:9));
           day(k) = str2double(line(11:12));
           hour(k) = str2double(line(14:15));
           minute(k) = str2double(line(17:18));
           second(k) = str2double(line(19:29));

           todsec(k) = 3600*hour(k) + 60*minute(k) + second(k);  % time of day in seconds

           daynum = dayofweek(year(k),month(k),day(k));
           TOWSEC(k) = todsec(k) + 86400*daynum;      
           sumSat(k) = str2double(line(31:33));
           sumPath(k) = str2double(line(35:37));
    %        CLOCKOFFSET(k) = str2double(line(69:80));
    %        SVID_MAT(ch(1:numsvs(k)),k) = 1;

           for i = 1:sumPath(k)
               line = fgetl(fid);
               if ~ischar(line), break, end
               linecount = linecount + 1;

               len = length(line);
    %            if len < 80,
    %               line(len+1:80) = '0';
    %            end
               sys = line(1);           % 判断系统
               ch(k,i)=str2double(line(2:3));
               pathNum = str2double(line(8:9));
               corrM_Spacing = str2double(line(11:13));
               corrM_Num = str2double(line(15:17));
               codeDelay = str2double(line(19:27));
               corrM_spacing = (-(corrM_Num-1)/2:1:(corrM_Num-1)/2)*corrM_Spacing*2046000/62000000 + codeDelay;     % 横坐标
               if pathNum > maxPathnum
                    maxPathnum = pathNum;
               end
               for ii = 1:corrM_Num
                   ob(ch(k,i),k,pathNum,1,ii) = corrM_spacing(ii);       % 横坐标
                   ob(ch(k,i),k,pathNum,2,ii) = str2double(line(28+1+11*(ii-1):28+9+11*(ii-1)));       % 纵坐标
                   ob(ch(k,i),k,pathNum,3,ii) = str2double(line(5:6));       % 总共曲线数量
               end

           end   % End the "for i = 1:numsvs(k)" Loop

       if breakflag == 1, break, end
    %    waitbar(linecount/numlines,bar1)
    end  % End the WHILE 1 Loop
    fclose(fid);
    %———————————————————read file———————————————————————%
end

colors = ['k','b','r','g','c','m','y'];
picNum = k-1-mod(k-1,10);
for y = 1 : smoothCons : picNum-smoothCons
    figure('Name','CorrShapes'); 
    hold on; grid on;
    pathNumAll = ob(plotFigPrn, y, 2, 3, 1);
    for yy = 1 : pathNumAll
        x_axis = ob(plotFigPrn, y:(y+smoothCons-1), yy, 1, :);
        x_axis = reshape(x_axis,smoothCons,corrM_Num);
        x_axis = mean(x_axis, 1);
        y_axis = ob(plotFigPrn, y:(y+smoothCons-1), yy, 2, :);
        y_axis = reshape(y_axis,smoothCons,corrM_Num);
        y_axis = mean(y_axis, 1);
        plot(x_axis, y_axis, ['-' colors(yy)]);
    end
    xlabel('Tc'); title('Correlation Functions');
    hold off
end
