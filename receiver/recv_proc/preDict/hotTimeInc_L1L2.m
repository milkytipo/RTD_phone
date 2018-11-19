function ch = hotTimeInc_L1L2(ch, timeLen)

% timeLen = -100;
% ch = struct( ...
%     'LO_Fcode_fd', 2, ...
%     'LO_CodPhs',   0.1, ...
%     'LO_CodPhs_L2', 0.2, ...
%     'T1ms_N',     0, ...
%     'Bit_N',       0, ...
%     'CM_in_CL',    0, ...
%     'bitInMessage', 0, ...
%     'Word_N',     0,...
%     'SubFrame_N',  0, ...
%     'TOW_6SEC',  0, ...
%     'WN', 1000 ...
%     );

%向前或向后L1L2通道的时间戳
global GSAR_CONSTANTS;

elapseTime = timeLen / GSAR_CONSTANTS.STR_RECV.fs; % 推算时长
codPhsAll = (ch.LO_Fcode_fd + GSAR_CONSTANTS.STR_L1CA.Fcode0) * elapseTime; %推算码片数

ch.LO_CodPhs_L2 = mod(ch.LO_CodPhs_L2 + codPhsAll, 1534500);

codPhs_Num = codPhsAll + ch.LO_CodPhs; %总码片数，余数做为码相位，商作为进位
ch.LO_CodPhs = mod(codPhs_Num, 1023);
T1ms_N_Num = ch.T1ms_N + floor(codPhs_Num/1023);
ch.T1ms_N = mod(T1ms_N_Num, 20);

bit_Num = ch.CM_in_CL + floor(T1ms_N_Num/20);
ch.CM_in_CL = mod(bit_Num, 75);
bit_Num = ch.bitInMessage + floor(T1ms_N_Num/20);
ch.bitInMessage = mod(bit_Num, 600);
bit_Num = ch.Bit_N + floor(T1ms_N_Num/20);
ch.Bit_N = mod(bit_Num, 30);

word_Num = ch.Word_N + floor(bit_Num/30);
ch.Word_N = mod(word_Num, 10);
subFrame_Num = ch.SubFrame_N + floor(word_Num/10);
ch.SubFrame_N = mod(subFrame_Num, 5);
TOW_6SEC_Num = ch.TOW_6SEC + floor(word_Num/10);
ch.TOW_6SEC = mod(TOW_6SEC_Num, 100800);
ch.WN = ch.WN + floor(TOW_6SEC_Num/100800);



