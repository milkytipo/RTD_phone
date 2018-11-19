 function  [prsmref,TOWSEC] = Range_corr
%%%%%通过RINEX计算伪距差分信息
filename='G:\trunk\roof_rinex\803739006u.15O';
decimate_factor = 1;
[C1I, L1I,ch,TOWSEC] = read_rinex(filename,decimate_factor);
prref = C1I;%观测伪距
adrref = L1I*299792458/1561098000;%积分多普勒乘以波长
smint = 50;%平滑时长
%refxyz = [-2853445.340,4667464.957,3268291.032];%参考系坐标
%prc = 0*ones(24,length(TOWSEC));%伪距差分量
value_rinex = zeros(30,2);
prsmref = zeros(30, length(TOWSEC));
    for i = 1:length(TOWSEC)
       svidref = ch(i,:);
       [prsmref(:,i),value_rinex] = ...
           hatch_BD(prref(:,i),adrref(:,i),svidref,smint,value_rinex);%载波相位平滑滤波
    end
 end
      
   
    