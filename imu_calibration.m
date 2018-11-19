function  [time,acc_cal] = imu_calibration(time_raw,acc_raw)
n = 1;
flag = 1;
acc =acc_raw;
j = 1 ;
acc_cal = zeros(length(acc),1); 
time= cell(length(acc),1);
for  i =1:length(acc)
    timer = time_raw(i);
        if   i < length(acc) && isequal (timer,time_raw(i+1) ) 
                n = n + 1;
        else
            time (j) = time_raw(i-1);
            for m = flag :flag+n-1
                acc_cal(j) =acc_cal(j)  + acc(m)/n;
            end
            j = j +1;
            n = 1;
            flag = i+1;
        end
end
time(cellfun(@isempty,time))=[];
acc_cal(length(time)+1:length(acc_cal)) = [];


