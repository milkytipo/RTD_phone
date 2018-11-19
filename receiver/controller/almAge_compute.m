function almanacAge = almAge_compute(timer, alm, SYST)
% 计算星历有效时间
switch SYST
    case 'BDS_B1I'
        timeDiff = timer.recvSOW_BDS - alm.toa;
        almanacAge = check_t(timeDiff);
    case 'GPS_L1CA'
        timeDiff = timer.recvSOW_GPS - alm.toa;
        almanacAge = check_t(timeDiff);
end