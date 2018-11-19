

function [IFSig, GPSyst] = GPS_Satellite_SigGen(GPSyst, fs, N)


global Constants;
global flag;

% MATLAB
if strcmp(flag,'matlab')    
[IFSig, GPSyst.WN, GPSyst.TOW, GPSyst.SFNav, GPSyst.SFNav_Posi, GPSyst.Register_FEC, GPSyst.L2C, GPSyst.Codphs, GPSyst.Carphs] ...
    = Discrete_IF_L2_Data_Gen(GPSyst.PRNID, Constants.IF, Constants.Fcode, GPSyst.WN, GPSyst.TOW, ...
     GPSyst.L2CM, GPSyst.L2CL, GPSyst.SFNav, GPSyst.SFNav_Posi, GPSyst.typeID, GPSyst.Register_FEC, ...
      GPSyst.L2C, GPSyst.Codphs, GPSyst.Carphs, fs, N);
end
            

% MEX 
if strcmp(flag,'mex')
[IFSig, GPSyst.WN, GPSyst.TOW, GPSyst.SFNav, GPSyst.SFNav_Posi, GPSyst.Register_FEC, GPSyst.L2C, GPSyst.Codphs, GPSyst.Carphs] ...
    = mx_Discrete_l2c_IF_Gen(GPSyst.PRNID, Constants.IF, Constants.Fcode, GPSyst.WN, GPSyst.TOW, ...
      GPSyst.SFNav, GPSyst.SFNav_Posi, GPSyst.typeID, GPSyst.Register_FEC, ...
      GPSyst.L2C, GPSyst.Codphs, GPSyst.Carphs, Constants.ampc, fs, N);
end


noise = Constants.sigma_n * randn(N,1);  % noise simulator


IFSig = IFSig + noise;

if strcmp(flag,'matlab')  
    IFSig = ADC(IFSig);
end

if strcmp(flag,'mex')
    
    IFSig = mx_ADC(IFSig , N, Constants.Xm, Constants.B,  Constants.IQForm);
     
end
    
    