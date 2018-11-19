% 是否重新读取文件
clc;
close all;clear;clc;fclose all;
fileNum = 3;
fileNo = [25, 26, 27];
isWriteXls = 1;
isWritePart = 1;
isReadMat = 0;
isPlot = 0;

file = struct(...
    'logFileName', '',...
    'paraName',    '',...
    'sowName',    '',...
    'xlsName',     '',...
    'xlsName_all', ''... %总统计表格
    );
file(1:fileNum) = file;
%————————记录文件——————————————%
file_path = 'D:\数据处理结果\Lujiazui_Static_Point_v2.0';
for ii = 1: fileNum 
    num_file = num2str(fileNo(ii));
    file(ii).logFileName = strcat(file_path, '\Lujiazui_Static_Point_',...
        num_file,'\Lujiazui_Static_Point_',num_file,'_allObs.txt');
    
    file(ii).xlsName = strcat(file_path, '\Lujiazui_Static_Point_',...
        num_file, '\Lujiazui_Static_Point_',num_file,'_auto.xlsx'); 
    
    file(ii).paraName = strcat(file_path, '\Lujiazui_Static_Point_',...
        num_file, '\parameter_',num_file,'.mat'); 
    
    file(ii).sowName = strcat(file_path, '\Lujiazui_Static_Point_',...
        num_file, '\SOW_',num_file,'.mat'); 
    
    file(ii).xlsName_all = strcat(file_path, '\Lujiazui_Static_Point_all_auto_Point_25-27.xlsx'); 
end
xlsLineNum_all = struct(...
    'BDS_GEO', 3,...
    'BDS_IGSO',     3,...
    'BDS_MEO',     3,...
    'GPS', 3 ... %记录指针
    );

% ——————通用配置参数——————————%

for ii = 1 : fileNum
    num_file = num2str(fileNo(ii));
    fprintf('正在处理文件号： %d \n', fileNo(ii));
    %————————文件循环——————%
    clear parameter;
    clear SOW;
    if isReadMat
        load(file(ii).paraName);
        load(file(ii).sowName);
    else
        [parameter, SOW] = readObs(file(ii).logFileName);
        save(file(ii).paraName, 'parameter');
        save(file(ii).sowName, 'SOW');
    end
    xlsName = file(ii).xlsName;
    xlsName_all = file(1).xlsName_all;
    
    prnBDS = parameter(1).prnMax;
    prnGPS = parameter(2).prnMax;
    timeIndex = SOW(1,:) - SOW(1,1);
    
    %————————在总统计的excel中标记文件名字——————%
    if isWriteXls == 1
        xlsLineNum_all.BDS_GEO = xlsLineNum_all.BDS_GEO + 1;
        xlsLine = num2str(xlsLineNum_all.BDS_GEO);
        xlsLineNum_all.BDS_GEO = xlsLineNum_all.BDS_GEO + 1;
        xlswrite(xlsName_all, {strcat('Lujiazui_Static_Point_',num_file)}, 'BDS_GEO',strcat('A',xlsLine));

        xlsLineNum_all.BDS_IGSO = xlsLineNum_all.BDS_IGSO + 1;
        xlsLine = num2str(xlsLineNum_all.BDS_IGSO);
        xlsLineNum_all.BDS_IGSO = xlsLineNum_all.BDS_IGSO + 1;
        xlswrite(xlsName_all, {strcat('Lujiazui_Static_Point_',num_file)}, 'BDS_IGSO',strcat('A',xlsLine));

        xlsLineNum_all.BDS_MEO = xlsLineNum_all.BDS_MEO + 1;
        xlsLine = num2str(xlsLineNum_all.BDS_MEO);
        xlsLineNum_all.BDS_MEO = xlsLineNum_all.BDS_MEO + 1;
        xlswrite(xlsName_all, {strcat('Lujiazui_Static_Point_',num_file)}, 'BDS_MEO',strcat('A',xlsLine));

        xlsLineNum_all.GPS = xlsLineNum_all.GPS + 1;
        xlsLine = num2str(xlsLineNum_all.GPS);
        xlsLineNum_all.GPS = xlsLineNum_all.GPS + 1;
        xlswrite(xlsName_all, {strcat('Lujiazui_Static_Point_',num_file)}, 'GPS',strcat('A',xlsLine));
    end  %  : if isWriteXls == 1
    preSheet = 'NULL'; % 
    for sysNun = 1 : 2
        %————————系统循环——————%
        if sysNun == 1
            prnMax = length(prnBDS);
            sys = 'BDS'; % BDS / GPS
        else
            prnMax = length(prnGPS);
            sys = 'GPS'; % BDS / GPS
        end
        xlsLineNum = 3; %所有xls都是从第三行开始记录的
        %————————卫星号循环——————%
        for prnNum = 1 : prnMax
            %——————————参数初始化————————————%
            if sysNun == 1
                prn = prnBDS(prnNum);
                if prn<=5
                    sheetName = 'BDS_GEO';
                    if ~strcmp(sheetName, preSheet)
                        xlsLineNum = 3;% 换sheet记录，则重新初始化
                    end
                    preSheet = 'BDS_GEO';
                elseif prn>5 && prn<=10
                    sheetName = 'BDS_IGSO';
                    if ~strcmp(sheetName, preSheet)
                        xlsLineNum = 3;% 换sheet记录，则重新初始化
                    end
                    preSheet = 'BDS_IGSO';
                else
                    sheetName = 'BDS_MEO';
                    if ~strcmp(sheetName, preSheet)
                        xlsLineNum = 3;% 换sheet记录，则重新初始化
                    end
                    preSheet = 'BDS_MEO';
                end
            else
                prn = prnGPS(prnNum);
                sheetName = 'GPS';
                if ~strcmp(sheetName, preSheet)
                    xlsLineNum = 3;% 换sheet记录，则重新初始化
                end
                preSheet = 'GPS';
            end
            
                     
            %————————————原始数据记录————————%
            [multiPara, multipathNum] = logRead_MP(parameter, sys, prn, timeIndex);        
                         
            %——————————判断数据是否可以计算生命周期 ——————————           
            lifeTime_ALL = [1, length(timeIndex)]; % 判断数据是否可以计算生命周期
    
            %——————————自动化数据处理 ——————————
            [multiPara] = MP_process_auto(multiPara , sys, multipathNum, sheetName, timeIndex);
            
            %——————————更新需要记录的数据 ——————————
            [multiPara] = MPrecord_update(multiPara, multipathNum, lifeTime_ALL, timeIndex);
            
            %——————————画图————————————%          
            if isPlot
                plot_MP_figure(multiPara, prn, multipathNum, sys); 
            end
            
            %——————————记录excel文档 ——————————
            if isWriteXls
                if isWritePart
                %————————记录单个文件——————————%
                    xlsLine = num2str(xlsLineNum);
                    MP_xls_write(xlsName, multiPara, sheetName, multipathNum, xlsLine, sys, prn);
                    xlsLineNum = xlsLineNum + max([size(multiPara(1).pathIndex_Auto,1), size(multiPara(2).pathIndex_Auto,1), size(multiPara(3).pathIndex_Auto,1)]);
                end
                %————————记录汇总文件——————————%
                if strcmp(sheetName ,'BDS_GEO')
                    xlsLine = num2str(xlsLineNum_all.BDS_GEO);
                    xlsLineNum_all.BDS_GEO = xlsLineNum_all.BDS_GEO + max([size(multiPara(1).pathIndex_Auto,1), size(multiPara(2).pathIndex_Auto,1), size(multiPara(3).pathIndex_Auto,1)]);
                elseif strcmp(sheetName ,'BDS_IGSO')
                    xlsLine = num2str(xlsLineNum_all.BDS_IGSO);
                    xlsLineNum_all.BDS_IGSO = xlsLineNum_all.BDS_IGSO + max([size(multiPara(1).pathIndex_Auto,1), size(multiPara(2).pathIndex_Auto,1), size(multiPara(3).pathIndex_Auto,1)]);
                elseif strcmp(sheetName ,'BDS_MEO')
                    xlsLine = num2str(xlsLineNum_all.BDS_MEO);
                    xlsLineNum_all.BDS_MEO = xlsLineNum_all.BDS_MEO + max([size(multiPara(1).pathIndex_Auto,1), size(multiPara(2).pathIndex_Auto,1), size(multiPara(3).pathIndex_Auto,1)]);
                elseif strcmp(sheetName ,'GPS')
                    xlsLine = num2str(xlsLineNum_all.GPS);
                    xlsLineNum_all.GPS = xlsLineNum_all.GPS + max([size(multiPara(1).pathIndex_Auto,1), size(multiPara(2).pathIndex_Auto,1), size(multiPara(3).pathIndex_Auto,1)]);
                end
                MP_xls_write(xlsName_all, multiPara, sheetName, multipathNum, xlsLine, sys, prn);
            end
            % ————————————更新sheet的行坐标——————————%  
        end
    end
end



