% calcRelativeCEP.m
% 
% Author: Lugia Liu
% Version: 0.2
% Date: 2016/12/10
% -----------------------------------------------------
function [CEP2D,CEP3D]=calcRelativeCEP(ENU,ratio,range,range3)
% -----------------------------------------------------
% --------------------Input---------------------------
% ENU: ENU position,3XN
%            row 1: East Error
%            row 2: North Error
%            row 3: Height Error
% ratio: from 0.00 to 1.00,step is 0.01
% range: maximum range of East-North Plane
% range3: maximum range of East-North-Height Plane
% -------------------Output-------------------------
% CEP2D: RCEP of East-North Plane
% CEP3D: RCEP of East-North-Height Plane
% -------------------Example-----------------------
% [CEP2D,CEP3D]=calcRelativeCEP(ENUdata,0.95,4,6);
% -----------------------------------------------------
len=size(ENU,2);
enuM=mean(ENU,2);
enuR=ENU-repmat(enuM,[1,len]);
dvec=zeros(1,len);
dvec3=zeros(1,len);
for j=1:len
    dvec(j)=sqrt(enuR(1,j)^2+enuR(2,j)^2);
    dvec3(j)=sqrt(enuR(1,j)^2+enuR(2,j)^2+enuR(3,j)^2);
end

bins=floor(100*min(dvec))/100:0.01:ceil(100*max(dvec))/100;
h=hist(dvec,bins);
bl=length(bins);
cnt=round(len*(1-ratio));
for j=bl:-1:1
    if sum(h(j:bl))>=cnt
        break;
    end
end
CEP2D=bins(j);

bins=floor(100*min(dvec3))/100:0.01:ceil(100*max(dvec3))/100;
h=hist(dvec3,bins);
bl=length(bins);
cnt=round(len*(1-ratio));
for j=bl:-1:1
    if sum(h(j:bl))>=cnt
        break;
    end
end
CEP3D=bins(j);

% 
figure;
plot([0,0],[100,-100],'k','LineWidth',2);hold on;
plot([100,-100],[0,0],'k','LineWidth',2);hold on;
basePos=plot(0,0,'r.','MarkerSize',20);
axis('equal');axis('square');
axis([-range range -range range]);grid on;
xlabel('East Error (m)');   
ylabel('North Error (m)');
plot(ENU(1,:),ENU(2,:),'+b');hold on;

theta=0:pi/20:2*pi;
cirx=enuM(1)+CEP2D*cos(theta);
ciry=enuM(2)+CEP2D*sin(theta);
plot(cirx,ciry,'-r');hold on;

legend(basePos,'Real Point');hold on;
title(sprintf('CEP2D=%.4f m',CEP2D));

% 
figure;
plot3([0,0],[100,-100],[0,0],'k','LineWidth',2);hold on;
plot3([100,-100],[0,0],[0,0],'k','LineWidth',2);hold on;
plot3([0,0],[0,0],[100,-100],'k','LineWidth',2);hold on;
plot3(0,0,0,'r.','MarkerSize',20);
axis('equal');axis('square');
axis([-range3 range3 -range3 range3 -range3 range3]);grid on;
xlabel('East Error (m)');   
ylabel('North Error (m)');
zlabel('Height Error (m)');
plot3(ENU(1,:),ENU(2,:),ENU(3,:),'+b');hold on;

% [x,y,z]=ellipsoid(enuM(1),enuM(2),enuM(3),CEP3D,CEP3D,CEP3D);
% surf(x,y,z);hold on;
% alpha(.5);
title(sprintf('CEP3D=%.4f m',CEP3D));

end