function  [parameter] = ephStateCal(parameter, fileNameBds, fileNameGps)
% 根据事后星历文件，计算卫星状态参数

[satPara, ~] = satellite_status_cal(parameter.SOW(1,:), fileNameBds, fileNameGps, parameter.pos_xyz);
% 计算被遮挡卫星的数目
parameter.blockNum = satPara.GPS.sys.prnVisNum - parameter.satNum;
parameter.GDOP_ratio = parameter.GDOP./ satPara.GPS.sys.GDOP;

    
