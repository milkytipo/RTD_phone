function [Acc_WGS84,V_WGS84]=readIMU(fileName_R,fileName_Acc,factor)
% [time_R_raw,R0,R1,R2,R3,R4,R5,R6,R7,R8,time_acc_raw,acc_x_raw,acc_y_raw,acc_z_raw] =textread(fileName_R_Acc,'%s %f %f %f %f %f %f %f %f %f %s %f %f %f','delimiter',',');  
[time_acc_raw,acc_x_raw,acc_y_raw,acc_z_raw] =textread(fileName_Acc,'%s %f %f %f ','delimiter',',');  
[time_R_raw,R0,R1,R2,R3,R4,R5,R6,R7,R8] =textread(fileName_R,'%s %f %f %f %f %f %f %f %f %f','delimiter',','); 
% [acc_x,acc_y,acc_z] = imu_filter(acc_x_raw,acc_y_raw,acc_z_raw);%¿¨¶ûÂüÂË²¨Æ÷
[acc_z] = acc_filter(acc_z_raw',50,3);  %µÈ²¨ÎÆFIRÂË²¨Æ÷
[acc_x] = acc_filter(acc_x_raw',50,3);
[acc_y] = acc_filter(acc_y_raw',50,3);

[time_acc,acc_x,acc_y,acc_z,time_R,R0,R1,R2,R3,R4,R5,R6,R7,R8] = imu_cal_collection(time_acc_raw,acc_x,acc_y,acc_z,time_R_raw,R0,R1,R2,R3,R4,R5,R6,R7,R8);
Acc_body=zeros(length(acc_x),3);
Acc_ENU=zeros(length(acc_x),3);
Acc_WGS84=zeros(length(acc_x),3);
% Acc_WGS84_s=zeros(round(length(acc_x)/50),3);
% V_WGS84_s=zeros(round(length(acc_x)/50),3);
V_body = zeros(length(acc_x),3);
X_body = zeros(length(acc_x),3);
V_ENU = zeros(length(acc_x),3);
X_ENU = zeros(length(acc_x),3);
V_WGS84 = zeros(length(acc_x),3);
X_WGS84 = zeros(length(acc_x),3);

for i=1:length(acc_x)
    R = zeros(3,3);
    R(1,1)=R0(i);
    R(1,2)=R1(i);
    R(1,3)=R2(i);
    R(2,1)=R3(i);
    R(2,2)=R4(i);
    R(2,3)=R5(i);
    R(3,1)=R6(i);
    R(3,2)=R7(i);
    R(3,3)=R8(i);
    if factor ==1 
        Acc_body(i,1)=acc_x(i);
        Acc_body(i,2)=acc_y(i);
        Acc_body(i,3)=acc_z(i);
    else
        Acc_body(i,1)=0;
        Acc_body(i,2)=0;
        Acc_body(i,3)=0;
    end
    V_body(i+1,:)=V_body(i,:)+Acc_body(i,1);
    X_body(i,:)=  X_body(i,:)+V_body(i,:);
    Acc_ENU(i,:)= R*Acc_body(i,:)';                         %BODY2ENU
    V_ENU(i+1,1)=V_ENU(i,1)+Acc_ENU(i,1);
    V_ENU(i+1,2)=V_ENU(i,2)+Acc_ENU(i,2);
%     V_ENU(3)(i+1)=V_ENU(3)(i)+ACC_ENU(i,3);
%     V_ENU(i+1,3)=0;
%     Acc_ENU(:,3)=0;
    X_ENU(i,:)=X_ENU(i,:)+V_ENU(i,:);
     
    refPos = [-2853679; 4667034; 3268624];  % ENU2ECF
    xyz = enu2xyz(Acc_ENU(i,:),refPos);
    Acc_WGS84(i,:)=xyz - refPos;
    V_WGS84 (i+1,:)=V_WGS84(i,:)+Acc_WGS84(i,:);
    X_WGS84(i,:)=X_WGS84(i,:)+ V_WGS84 (i,:);
end

% for n=1:length(acc_x)/50
%     for m=1:50
%         Acc_WGS84_s(n,:) =Acc_WGS84_s(n,:) + Acc_WGS84((n-1)*50+m,:)/50;
%     end
%     V_WGS84_s(n+1,:)=V_WGS84_s(n,:)+Acc_WGS84_s(n,:) ;
% end
end
function [time_acc,acc_x,acc_y,acc_z,time_R,R0,R1,R2,R3,R4,R5,R6,R7,R8] = imu_cal_collection(time_acc_raw,acc_x,acc_y,acc_z,time_R_raw,R0,R1,R2,R3,R4,R5,R6,R7,R8)
    [~,acc_x] = imu_calibration(time_acc_raw,acc_x);
    [~,acc_y] = imu_calibration(time_acc_raw,acc_y);
    [time_acc,acc_z] = imu_calibration(time_acc_raw,acc_z);
    [~,R0] = imu_calibration(time_R_raw,R0);
    [~,R1] = imu_calibration(time_R_raw,R1);
    [~,R2] = imu_calibration(time_R_raw,R2);
    [~,R3] = imu_calibration(time_R_raw,R3);
    [~,R4] = imu_calibration(time_R_raw,R4);
    [~,R5] = imu_calibration(time_R_raw,R5);
    [~,R6] = imu_calibration(time_R_raw,R6);
    [~,R7] = imu_calibration(time_R_raw,R7);
    [time_R,R8] = imu_calibration(time_R_raw,R8);
end
