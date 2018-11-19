function [day,hour,min,sec]=sow2BJT(sow)
% 输入： sow       北斗周内秒（周内秒定义为每周的周日上午0时为0秒，开始计数）
% 输出： day    	一周中的天数
%       hour       时
%       min        分
%       sec        秒
bjsow=sow;
day=floor(bjsow/86400);
hour=floor((bjsow-day*86400)/3600);
min=floor((bjsow-day*86400-hour*3600)/60);
sec=bjsow-day*86400-hour*3600-min*60;
end