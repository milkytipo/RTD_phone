
function [year,month,day]=calculate_yymmdd(weeknum)
% 通过北斗整周数计算日期

yy1=2006;
kk=0;
all_day=weeknum*7+1;
 zz=0;
for ii=yy1:10000
     run_year=0;
     
     if mod(ii,100)==0
        if mod(ii,400)==0
            run_year=1;
         end
     else
         if  mod(ii,4)==0
            run_year=1;
         end
                
     end
       zz=zz+run_year;
       kk=kk+1;
       n_year_day=365*kk+zz;
       rem_day=365+run_year-(n_year_day-all_day);
       if rem_day>=0 && rem_day<=365+run_year
       break
       end
end


year=ii;
flog=run_year;
A=[31, 59+flog, 90+flog, 120+flog, 151+flog, 181+flog, 212+flog, 243+flog, 273+flog, 304+flog,  334+flog,  365+flog];

for i=1:12
   if rem_day<A(i)+1
   month=i;
   break
   end
end
if i>1
   day=rem_day-A(i-1);
else
   day=rem_day;
end






      
