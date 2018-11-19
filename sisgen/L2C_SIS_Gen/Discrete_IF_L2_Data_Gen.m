
function [SigVct, WN, TOW, SFNav, SFNav_Posi, Register_FEC, L2C, CodPhs, CarPhs] = Discrete_IF_L2_Data_Gen( ...
            PRNID, IF, Fcode, WN, TOW, L2CM, L2CL, SFNav, SFNav_Posi, typeID, Register_FEC, ...
            L2C, CodPhs, CarPhs, fs, N)
        
global Constants;


CodeVct = zeros(N,1);
SigVct = zeros(N,1);


L2C_L = Constants.Len_mul;
  
Num_Code = floor(N*Fcode/fs);

if L2C_L-CodPhs+1 >= Num_Code
    
    N0 = N;   
    codindx = CodPhs + (0:N0-1)*Fcode/fs;
    codindx = floor(mod(codindx,L2C_L));
    
    CodeVct(1:N0) = L2C(codindx);
    
    CodPhs = CodPhs + N0*Fcode/fs;

    CodPhs = floor(mod(CodPhs,L2C_L));
    
else
    
    N0 = ceil((L2C_L - CodPhs)*fs/Fcode);
    
    codindx = CodPhs + (0:N0-1)*Fcode/fs;
    codindx = floor(mod(codindx,L2C_L));
    
    CodeVct(1:N0) = L2C(codindx);
    
    CodPhs = CodPhs + N0*Fcode/fs;

    CodPhs = floor(mod(CodPhs,L2C_L));    
        
    TOW = TOW + 6;

    if TOW >= Constants.WEEKLONGSEC
    
        TOW = TOW - Constants.WEEKLONGSEC;
        WN = WN + 1; 
    end

    [L2C, WN, TOW, SFNav, SFNav_Posi, Register_FEC] = GPS_L2C_multiplexer(PRNID, ...
        L2CM, L2CL, WN, TOW, SFNav, SFNav_Posi, typeID, Register_FEC);

    
    Nr = N - N0; 
    
    codindx = CodPhs + (0:Nr-1)*Fcode/fs;
    codindx = floor(mod(codindx,L2C_L));
    
    CodeVct(N-Nr+1:N) = L2C(codindx);

    CodPhs = CodPhs + Nr*Fcode/fs;

    CodPhs = floor(mod(CodPhs,L2C_L));
    
end


% 载频(实际是加上中频)
AReiv = Constants.ampc;

SigVct(1:N) = AReiv.*cos(2*pi*(0:N-1)'*IF/fs + 2*pi*CarPhs).*CodeVct;

CarPhs = CarPhs + N*IF/fs;

CarPhs = mod(CarPhs, 1); 




