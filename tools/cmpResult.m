
clear;
filenameGPGGA = 'D:\20180324\caohejin\rawData\test\rawData_GNSS_NovAtel.pos';
filenameIE = 'D:\20180324\caohejin\calibration_NovAtelSpan_IE_test.txt';
YYMMDD = '20180324';
if 1
%     [xyzGPGGA, towGPGGA] = readGPGGA(filenameGPGGA, YYMMDD);
    
    [xyzGPGGA, towGPGGA] = readRTKlib(filenameGPGGA);
    
%     load('D:\20180324\caohejin\rawData\test\ublox.mat', 'X_KAL', 'Y_KAL', 'Z_KAL', 'tow');
%     xyzGPGGA = [X_KAL, Y_KAL, Z_KAL];
%     towGPGGA = tow;
    towGPGGA = towGPGGA - 18;
    
    [xyzIE, llhIE, towIE, HHMMSS] = readIE(filenameIE, YYMMDD);  
end



[SOW, idx_a, idx_b] = intersect(towGPGGA, towIE);
Time = SOW(1):SOW(end);  % 令时间连续
enuR1 = NaN(4,length(Time));
for k = 1 : length(SOW)
    numTime = SOW(k) - SOW(1) + 1; % 
    if xyzGPGGA(idx_a(k), 2) ~= 0 
        enuR1(1:3,numTime) = xyz2enu(xyzGPGGA(idx_a(k),:),xyzIE(idx_b(k),:));
        enuR1(4,numTime) = sqrt(enuR1(1,numTime)^2 + enuR1(2,numTime)^2);
    end
    
end


% figure();
% aa = plot(enuR1(1,:),enuR1(2,:),'+');
% hold on;
% plot([0,0],[100,-100],'k','LineWidth',2);
% hold on;
% plot([100,-100],[0,0],'k','LineWidth',2);
% hold on;
% zero = [0,0];
% bb= plot(zero(1),zero(2),'r.','MarkerSize',20);
% legend([aa,bb],'Positioning Point','Real Point');
% hold off;
% axis('equal')
% axis('square')
% axis([-100 100 -100 100])
% grid
% title('Positioning Error without Multipath Mitigation')
% ylabel('North Error (m)')
% xlabel('East Error (m)')
% 
% 
% figure();
% plot(Time-Time(1)+1,enuR1(1,:),'b');
% hold on
% plot(Time-Time(1)+1,enuR1(2,:),'g');
% hold on
% plot(Time-Time(1)+1,enuR1(3,:),'r');
% title ( 'Coordinates Error');
% legend( 'E', 'N', 'U');
% xlabel( 'Measurement period (s)');
% ylabel( 'Error (m)');

hold on;
plot(Time-Time(1)+1,enuR1(4,:),'b');
title ( 'Coordinates Error');
legend( 'horizontal');
xlabel( 'Measurement period (s)');
ylabel( 'Error (m)');


MeanValue(1) = mean(enuR1(1,:));
MeanValue(2) = mean(enuR1(2,:));
MeanValue(3) = mean(enuR1(3,:));
VarValue(1) = var(enuR1(1,:));
VarValue(2) = var(enuR1(2,:));
VarValue(3) = var(enuR1(3,:));