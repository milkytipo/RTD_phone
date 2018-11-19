
clear; 
% PosData1 = load('G:\多径研究项目\sv_cadll\branch\branch_wangyz\m\logfile\sensitive_test_XYZ.txt');
filename = 'E:\软件接收机备份\陆家嘴代码_v2.0\m\logfile\Lujiazui_Static_Point_22_allObs_GPFPD_NLOS.txt';
[XYZ, TOWSEC] = readGPFPD(filename);
enuR1 = zeros(3, size(XYZ,1));
for i=1:size(XYZ,1)
    TurePos = [-2852104.75, 4654050.36, 3288351.12];
    enuR1(:, i) = xyz2enu(XYZ(i,:),TurePos);
    if sum(enuR1(:,i).^2) > 1e5
        enuR1(:,i) = NaN;
    end
end
figure();
aa = plot(enuR1(1,:),enuR1(2,:),'+');
hold on;
plot([0,0],[100,-100],'k','LineWidth',2);
hold on;
plot([100,-100],[0,0],'k','LineWidth',2);
hold on;
zero = [0,0];
bb= plot(zero(1),zero(2),'r.','MarkerSize',20);
legend([aa,bb],'Positioning Point','Real Point');
hold off;
axis('equal')
axis('square')
axis([-100 100 -100 100])
grid
title('Positioning Error without Multipath Mitigation')
ylabel('North Error (m)')
xlabel('East Error (m)')
figure();
plot(enuR1(1,:),'b');
hold on
plot(enuR1(2,:),'g');
hold on
plot(enuR1(3,:),'r');
title ( 'Coordinates Error');
legend( 'E', 'N', 'U');
xlabel( 'Measurement period (s)');
ylabel( 'Error (m)');
enuR1(:, isnan(enuR1(1,:))) = [];
error_3D = sqrt(enuR1(1, :).^2 + enuR1(2, :).^2 + enuR1(3, :).^2);
error_3D = sort(error_3D);
err_90prob = error_3D(round(length(error_3D)*0.9));
MeanValue(1) = mean(enuR1(1,:));
MeanValue(2) = mean(enuR1(2,:));
MeanValue(3) = mean(enuR1(3,:));
VarValue(1) = var(enuR1(1,:));
VarValue(2) = var(enuR1(2,:));
VarValue(3) = var(enuR1(3,:));

