
function [year,month,day]=calculateGPS_yymmdd(weeknum, daySOW)
% 通过GPS整周数计算日期
yearBegin = 2000;
yearnum = 0;
allDay = (weeknum-19)*7 + 2 + daySOW;    %减去1999年8月21日后面的周数
leapyearDay = 0;
for ii = yearBegin:10000
    leapYear = 0;
    if mod(ii,100)==0          %判断是否为闰年
        if mod(ii,400)==0
            leapYear=1;
        end
    else
        if  mod(ii,4)==0
            leapYear=1;
        end
    end
    leapyearDay = leapyearDay + leapYear;    %闰年总天数
    yearnum = yearnum + 1;
    n_year_day = 365*yearnum + leapyearDay;
    rem_day = 365 + leapYear - (n_year_day - allDay);    %剩余天数
    if rem_day>=0 && rem_day<=365+leapYear
        break
    end
end


year=ii;
flog = leapYear;
A=[31, 59+flog, 90+flog, 120+flog, 151+flog, 181+flog, 212+flog, 243+flog, 273+flog, 304+flog,  334+flog,  365+flog];

for i=1:12
    if rem_day<A(i)+1
        month = i;
        break
    end
end
if i>1
    day = rem_day-A(i-1);
else
    day = rem_day;
end







