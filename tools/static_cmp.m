% clear;
% filename = 'C:\Users\wyz\Desktop\ttd_logfile_0830\logfile\The_Three_Towers_GPFPD.txt';
% YYMMDD = '20150525';    % 年月日
% format = 'GPFPD';       % 文件格式
% basePos = [-2852104.75, 4654050.36, 3288351.12];
% if strcmp(format, 'GPGGA')
%     [XYZ, TOW] = readGPGGA(filename, YYMMDD);
% elseif strcmp(format, 'GPFPD')
%     [XYZ, TOW] = readGPFPD(filename);
% end
% % XYZ = XYZ(800:end,:);
% % TOW = TOW(800:end);
% timeLen = length(TOW);
% TOW = [1:timeLen];
% ENU = zeros(3,timeLen);
% for i = 1:timeLen
%     if  XYZ(i,2) ~= 0
%         ENU(:,i) = xyz2enu(XYZ(i,:),basePos);
%     end
% end

clear;
ENU = normrnd(0, 0.5, 2, 2000);

figure();
aa = plot(ENU(1,:),ENU(2,:),'+');
hold on;
plot([0,0],[100,-100],'k','LineWidth',1);
hold on;
plot([100,-100],[0,0],'k','LineWidth',1);
hold on;
zero = [0,0];
bb= plot(zero(1),zero(2),'r.','MarkerSize',10);
legend([aa,bb],'Positioning Point','Real Point');
hold on

%% 画圆
alpha = 0:2*pi/40:2*pi;
R = 1;
X = R*cos(alpha);
Y = R*sin(alpha);
plot(X,Y,'--k','LineWidth',1);
hold on

alpha = 0:2*pi/40:2*pi;
R = 2;
X = R*cos(alpha);
Y = R*sin(alpha);
plot(X,Y,'--k','LineWidth',1);
hold on

alpha = 0:2*pi/40:2*pi;
R = 3;
X = R*cos(alpha);
Y = R*sin(alpha);
plot(X,Y,'--k','LineWidth',1);
hold on

% alpha = 0:2*pi/40:2*pi;
% R = 90;
% X = R*cos(alpha);
% Y = R*sin(alpha);
% plot(X,Y,'--k','LineWidth',1);
% hold off;

axis('equal')
axis('square')
axis([-3 3 -3 3])
grid
title('Horizontal Positioning Error')
ylabel('North Error (m)')
xlabel('East Error (m)')


% ------------------ ENU -------------------%
figure();
plot(TOW-TOW(1)+1,ENU(1,:),'b');
hold on
plot(TOW-TOW(1)+1,ENU(2,:),'g');
hold on
plot(TOW-TOW(1)+1,ENU(3,:),'r');
title ( 'Coordinates Error');
legend( 'E', 'N', 'U');
xlabel( 'Measurement period (s)');
ylabel( 'Error (m)');