function Samp_Posi = bitEdge(channel, SYST)
% 根据先验信息将采样点位置推算至bit边缘位置
global GSAR_CONSTANTS;

switch SYST
    case {'GPS_L1CA','GPS_L1CA_L2C'}
        time = ((GSAR_CONSTANTS.STR_L1CA.ChipNum-channel.LO_CodPhs) + (GSAR_CONSTANTS.STR_L1CA.NT1ms_in_bit-channel.T1ms_N-1)*GSAR_CONSTANTS.STR_L1CA.ChipNum)...
            / (channel.LO_Fcode0 + channel.LO_Fcode_fd); % 推算到bit边缘处所需的时间
    case 'BDS_B1I'
        if strcmp(channel.navType, 'B1I_D1')
            time = ((GSAR_CONSTANTS.STR_B1I.ChipNum-channel.LO_CodPhs) + (GSAR_CONSTANTS.STR_B1I.NT1ms_in_D1-channel.T1ms_N-1)*GSAR_CONSTANTS.STR_B1I.ChipNum)...
                / (channel.LO_Fcode0 + channel.LO_Fcode_fd); % 推算到bit边缘处所需的时间
        else
            time = ((GSAR_CONSTANTS.STR_B1I.ChipNum-channel.LO_CodPhs) + (GSAR_CONSTANTS.STR_B1I.NT1ms_in_D2-channel.T1ms_N-1)*GSAR_CONSTANTS.STR_B1I.ChipNum)...
                / (channel.LO_Fcode0 + channel.LO_Fcode_fd); % 推算到bit边缘处所需的时间
        end
end

Samp_Posi = round(time * GSAR_CONSTANTS.STR_RECV.fs);%计算采样点数

