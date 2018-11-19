% The file is to generate the intermediate frequency signal 
 
function [IFSig, STR_SV]=SV_SIS_Gen(SYST, STR_SV, fs, N, Flag_Call)
% Output:
% 
% Input:
% SYST              - GPS_CA / GPS_L2C / BD_B1I
% STR_SV            - the SV stations 
% fs                - sampling frequency
% N                 - sampling number
% Flag_Call         - CallinMex / CallinMatlab

global STR_Constants

if strcmp(SYST,'GPS_L2C') && strcmp(Flag_Call, 'CallinMex')
    
    [IFSig, STR_SV.L2C_SV] = mx_Discrete_Signal_Gen(SYST, STR_SV.L2C_SV, STR_Constants.STR_RECV.IF, STR_Constants.STR_RECV.RFGAIN, fs, N, ...
        STR_SV.STR_MP, STR_SV.navbit_ctrl, STR_SV.multipath_ctrl, STR_SV.accel_ctrl);
    
end

if strcmp(SYST,'BD_B1I') && strcmp(Flag_Call, 'CallinMex')
   
    [IFSig, STR_SV.B1I_SV] = mx_Discrete_Signal_Gen(SYST, STR_SV.B1I_SV, STR_Constants.STR_RECV.IF, STR_Constants.STR_RECV.RFGAIN, fs, N, ...
        STR_SV.STR_MP, STR_SV.navbit_ctrl, STR_SV.multipath_ctrl, STR_SV.accel_ctrl);
    
end

if strcmp(STR_Constants.STR_RECV.IQForm,'Real')
    IFSig = real(IFSig);
end

% noise generator
noise = zeros(N,1);

if STR_SV.noise_ctrl==1
    
    noise = noise_gen(fs/2, STR_Constants.STR_RECV.N0, STR_Constants.STR_RECV.RFGAIN, 0, N,...
        STR_Constants.STR_RECV.IF, fs, STR_Constants.STR_RECV.IQForm);
%     if strcmp(STR_Constants.STR_RECV.IQForm,'Complex')
%         
%         noise_i = noise_gen(fs,N);
%         noise_q = noise_gen(fs,N);
%         
%         noise = noise_i + 1i*noise_q;
%     else
%         
%         noise =noise_gen(fs,N);
%         
%     end   
end


IFSig = IFSig + noise;
% IFSig = noise;

% ADC
if STR_SV.ADC_ctrl==1
    
    IFSig = mx_ADC(IFSig, N, STR_Constants.STR_RECV.Xm, STR_Constants.STR_RECV.B, STR_Constants.STR_RECV.IQForm);
    
end

    