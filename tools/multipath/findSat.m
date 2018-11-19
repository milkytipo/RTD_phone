
fileName = 'K:\BMAW14510070R_1.17O';
SOWRange = [568641, 570241];
%[C1, L1, S1, D1, ch, TOWSEC] = read_rinex(fileName,decimate_factor);
start = find(TOWSEC == SOWRange(1));
ending = find(TOWSEC == SOWRange(2));
% 可见卫星号
PrnBDS = intersect(ch.BDS(start:ending,:), ch.BDS(start:ending,:));
% 使用通道数量
NumBDS = sum(ch.BDS(start:ending,:)~=0, 2);
PrnGPS = intersect(ch.GPS(start:ending,:), ch.GPS(start:ending,:));
NumGPS = sum(ch.GPS(start:ending,:)~=0, 2);

figure()
area(NumBDS);
title ( 'BDS  Channel');
figure()
area(NumGPS);
title ( 'GPS  Channel');

