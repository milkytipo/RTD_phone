% 是否重新读取文件
clc;
close all;clear;clc;fclose all;
fileNum = 26;
fileNo = [1:23, 25, 26, 27];

file = struct(...
    'logFileName', '',...
    'paraName',    '',...
    'sowName',    '',...
    'xlsName',     '',...
    'xlsName_all', ''... %总统计表格
    );
file(1:fileNum) = file;
%————————记录文件——————————————%
file_path = 'E:\数据处理结果\Lujiazui_Static_Point_v2';
for ii = 1: fileNum 
    num_file = num2str(fileNo(ii));
    file(ii).logFileName = strcat(file_path, '\Lujiazui_Static_Point_',...
        num_file,'\Lujiazui_Static_Point_',num_file,'_allObs.txt');
    
    file(ii).paraName = strcat(file_path, '\Lujiazui_Static_Point_',...
        num_file, '\parameter_',num_file,'.mat'); 
    
    file(ii).sowName = strcat(file_path, '\Lujiazui_Static_Point_',...
        num_file, '\SOW_',num_file,'.mat'); 
    
end


% ——————通用配置参数——————————%

for ii = 1 : fileNum
    num_file = num2str(fileNo(ii));
    fprintf('正在处理文件号： %d \n', fileNo(ii));
    %————————文件循环——————%
    clear parameter;
    clear SOW;

    [parameter, SOW] = readObs(file(ii).logFileName);
    save(file(ii).paraName, 'parameter');
    save(file(ii).sowName, 'SOW');
 
end



