function [verify, CH_PARA] = hotInfoCheck(CH_PARA, TimeLen, SYST,mode)
global GSAR_CONSTANTS;
% 若推算正确则置为1；
verify = 0;
lockDect = CH_PARA.lockDect;
predictInfo = framePredict(lockDect, TimeLen, CH_PARA.LO_Fcode_fd, CH_PARA.LO2_fd, SYST, CH_PARA.PRNID, mode);% 推算子帧信息
% 推算后对通道参数赋值
if strcmp(SYST, 'BDS_B1I')
    CH_PARA.SOW = predictInfo.SOW;
    CH_PARA.lockDect.SOW = CH_PARA.SOW;
    CH_PARA.Frame_N = predictInfo.Frame_N;
    CH_PARA.lockDect.Frame_N = CH_PARA.Frame_N;
    % 判断码相位推算结果和实际结果是否一致（通过码相位预测验证）
    if (predictInfo.codePhase<=GSAR_CONSTANTS.STR_B1I.ChipNum/4)||(predictInfo.codePhase>=GSAR_CONSTANTS.STR_B1I.ChipNum*3/4)
        verify = 1;
    end
elseif strcmp(SYST, 'GPS_L1CA')
    CH_PARA.TOW_6SEC = predictInfo.SOW;
    CH_PARA.lockDect.SOW = CH_PARA.TOW_6SEC;
    % 判断码相位推算结果和实际结果是否一致（通过码相位预测验证）
    if (predictInfo.codePhase<=GSAR_CONSTANTS.STR_L1CA.ChipNum/4)||(predictInfo.codePhase>=GSAR_CONSTANTS.STR_L1CA.ChipNum*3/4)
        verify = 1;
    end
end

CH_PARA.WN = predictInfo.WN;
CH_PARA.SubFrame_N = predictInfo.SubFrame_N;
CH_PARA.Word_N = predictInfo.Word_N;
CH_PARA.Bit_N = predictInfo.Bit_N;
if strcmp(mode,'NORM')
    CH_PARA.T1ms_N = predictInfo.T1ms_N;    
    CH_PARA.LO_CodPhs = predictInfo.codePhase;
    CH_PARA.LO2_CarPhs = predictInfo.carriPhase;
elseif strcmp(mode,'ACQ')   % 捕获成功结束后时码相位应该为0，所以此处不需要更新码相位
    CH_PARA.T1ms_N = predictInfo.T1ms_N;
    CH_PARA.LO_CodPhs = 0;
    CH_PARA.LO2_CarPhs = 0;
elseif strcmp(mode,'BITSYNC') % bit同步成功T1ms和codePhase无需做任何更新
    CH_PARA.T1ms_N = 0;
    CH_PARA.LO_CodPhs = 0;
    CH_PARA.LO2_CarPhs = 0;
end
 
% 跟新lockDect中各项参数的值
CH_PARA.lockDect.WN = CH_PARA.WN;
CH_PARA.lockDect.SubFrame_N = CH_PARA.SubFrame_N;
CH_PARA.lockDect.Word_N = CH_PARA.Word_N;
CH_PARA.lockDect.Bit_N = CH_PARA.Bit_N;
CH_PARA.lockDect.T1ms_N = CH_PARA.T1ms_N;
CH_PARA.lockDect.carriDopp = CH_PARA.LO2_fd;
CH_PARA.lockDect.carriPhase = CH_PARA.LO2_CarPhs;
CH_PARA.lockDect.codeDopp = CH_PARA.LO_Fcode_fd;
CH_PARA.lockDect.codePhase = CH_PARA.LO_CodPhs;



end % EOF：function




