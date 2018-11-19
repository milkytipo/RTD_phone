% File: SV System signal generation file
clear;
clc;
close all;

addpath('.\sisgen\');
addpath('.\sisgen\L2C_SIS_Gen');
%addpath('..\cpp\mex\');
%addpath('.\CNAV\');

SYST = 'GPS_L2C';               % GPS_CA / GPS_L2C /

Flag_Call = 'CallinMex';        % CallinMex / CallinMatlab

global STR_Constants;
STR_Constants = SV_Constants();


STR_SV = SV_Initializing(SYST, Flag_Call);


fs = STR_Constants.STR_RECV.fs;        % sampling frequency,[Hz]

T = 2;                                 %


file = struct( ...
    'fname',           '..\GPS_L2C_IF_Data.bin', ...
    'fid',               0, ...
    're_cm',             STR_Constants.STR_RECV.IQForm, ...   % Complex / Real
    'data_type',         'double', ...                         % double / single / schar / int16 / int8 / bit4
    'nbyte',             1 ...
);

file.fid = fopen(file.fname,'w+');


Tr = T;

% time control
TBITCount = 0;
msCount = 0;
SecondCount = 0;
MinuteCount = 0;
HourCount = 0;
disp(['# ' num2str(HourCount) 'h:' num2str(MinuteCount) 'm:' num2str(SecondCount+msCount*0.1) 's']);

 
while Tr>=STR_Constants.STR_L2C.TBIT
    
    N = round(fs*STR_Constants.STR_L2C.TBIT);
    
    [IFSig, STR_SV] = SV_SIS_Gen(SYST, STR_SV, fs, N, Flag_Call);    

    if strcmp(file.re_cm,'Complex')
        IFSig_temp = reshape([real(IFSig)';imag(IFSig)'],[],1);
    end
    
    fwrite(file.fid, IFSig_temp, file.data_type);
   
%     %=================================================
%     % check
%     fclose(file.fid);
%    
%     SigSegment_N = 6;
%     fid = fopen(file.fname,'r');
%     IFData = fread(fid, SigSegment_N, file.data_type);
%    
%     if strcmp(file.re_cm,'Complex')
%         IFData_r = IFData(1:2:SigSegment_N-1);
%         IFData_i = IFData(2:2:SigSegment_N);
% 
%         IFData = IFData_r + 1i*IFData_i;
%     end
%     fclose(fid);
%     %==================================================

    Tr = Tr - STR_Constants.STR_L2C.TBIT;
    
    TBITCount = TBITCount +1;
    if TBITCount == 5
        TBITCount = 0;
        msCount = msCount + 1;
        disp(['# ' num2str(HourCount) 'h:' num2str(MinuteCount) 'm:' num2str(SecondCount+msCount*0.1) 's']);
    end
    if msCount==10
        msCount = 0;
        SecondCount = SecondCount +1;
    end
    if SecondCount==60
        SecondCount = 0;
        MinuteCount = MinuteCount + 1;
    end
    if MinuteCount==60
        MinuteCount = 0;
        HourCount = HourCount + 1;
    end 
end

if round(fs*Tr)>0
    
    N = round(fs*Tr);
    
    [IFSig, STR_SV] = SV_SIS_Gen(SYST, STR_SV, fs, N, Flag_Call);
    
    if strcmp(file.re_cm,'Complex')
        IFSig_temp = reshape([real(IFSig)';imag(IFSig)'],[],1);
    end
    
    fwrite(file.fid, IFSig_temp, file.data_type);

end

fclose(file.fid);







