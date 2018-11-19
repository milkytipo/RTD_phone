function delPrelog(receiver)
% 删除以前保存的log文件

logFilePath = receiver.config.logConfig.logFilePath;
logName = receiver.pvtCalculator.logOutput.logName;
file = dir(logFilePath);
for i = 1 : size(file,1)
     if strncmp(file(i).name, logName, length(logName))
         fileName = strcat(logFilePath, file(i).name);
            delete(fileName);
     end
end