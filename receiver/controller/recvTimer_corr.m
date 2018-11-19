function recv_timer = recvTimer_corr(SYST, recv_timer, dtu)

switch SYST
    case 'GPS_L1CA'
        recv_timer.recvSOW_GPS = recv_timer.recvSOW_GPS - dtu;
        if strcmp(recv_timer.timeType, 'GPST')
            recv_timer.recvSOW = recv_timer.recvSOW_GPS;
            recv_timer.weeknum = recv_timer.weeknum_GPS;
            [day_1, hour, min, sec] = sow2BJT(recv_timer.recvSOW);
            [year,month,day] = calculateGPS_yymmdd(recv_timer.weeknum, day_1);
        elseif strcmp(recv_timer.timeType, 'BDST')
            recv_timer.recvSOW = recv_timer.recvSOW_GPS - recv_timer.BDT2GPST(1);
            recv_timer.weeknum = recv_timer.weeknum_GPS - recv_timer.BDT2GPST(2);
            [day_1, hour, min, sec] = sow2BJT(recv_timer.recvSOW);
            [year,month,day] = calculate_yymmdd(recv_timer.weeknum, day_1);
        else
            error('time type no found');
        end
        
    case 'BDS_B1I'
        recv_timer.recvSOW_BDS = recv_timer.recvSOW_BDS - dtu;   
        if strcmp(recv_timer.timeType, 'BDST')
            recv_timer.recvSOW = recv_timer.recvSOW_BDS;
            recv_timer.weeknum = recv_timer.weeknum_BDS;
            [day_1, hour, min, sec] = sow2BJT(recv_timer.recvSOW);
            [year,month,day] = calculate_yymmdd(recv_timer.weeknum, day_1);
        elseif strcmp(recv_timer.timeType, 'GPST')
            recv_timer.recvSOW = recv_timer.recvSOW_BDS + recv_timer.BDT2GPST(1);
            recv_timer.weeknum = recv_timer.weeknum_BDS + recv_timer.BDT2GPST(2);
            [day_1, hour, min, sec] = sow2BJT(recv_timer.recvSOW);
            [year,month,day] = calculateGPS_yymmdd(recv_timer.weeknum, day_1);
        else
            error('time type no found');
        end
        
    case 'B1I_L1CA'
        recv_timer.recvSOW_BDS = recv_timer.recvSOW_BDS - dtu(1);
        recv_timer.recvSOW_GPS = recv_timer.recvSOW_GPS - dtu(2);
        if strcmp(recv_timer.timeType, 'BDST')
            recv_timer.recvSOW = recv_timer.recvSOW_BDS;
            recv_timer.weeknum = recv_timer.weeknum_BDS;
            [day_1, hour, min, sec] = sow2BJT(recv_timer.recvSOW);
            [year,month,day] = calculate_yymmdd(recv_timer.weeknum, day_1);
        elseif strcmp(recv_timer.timeType, 'GPST')
            recv_timer.recvSOW = recv_timer.recvSOW_GPS;
            recv_timer.weeknum = recv_timer.weeknum_GPS;
            [day_1, hour, min, sec] = sow2BJT(recv_timer.recvSOW);
            [year,month,day] = calculateGPS_yymmdd(recv_timer.weeknum, day_1);
        else
            error('time type no found');
        end        
end

%！！！！！！！！！！！！柴麻扮蛍昼佚連！！！！！！！！！！！！！！！！%
recv_timer.year = year;
recv_timer.month = month;
recv_timer.day = day;
recv_timer.hour = hour;
recv_timer.min = min;
recv_timer.sec = sec;