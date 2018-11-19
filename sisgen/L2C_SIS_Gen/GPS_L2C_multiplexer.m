

function [L2C, WN, TOW, SFNav, SFNav_Posi, Register_FEC] = GPS_L2C_multiplexer...
                            (PRNID, L2CM, L2CL, WN, TOW, SFNav, SFNav_Posi, typeID, Register_FEC)

global Constants; 

L2CM_sum = zeros(Constants.Len_CL,1);

L2C = zeros(Constants.Len_mul,1);

L2C(2:2:Constants.Len_mul,1) = L2CL(1:Constants.Len_CL,1);

for i = 1:75
        
    L2CM_sum((i-1)*Constants.Len_CM+1:i*Constants.Len_CM,1) = L2CM .* SFNav(SFNav_Posi);
    
    SFNav_Posi = SFNav_Posi + 1;
    
    if SFNav_Posi > Constants.NBIT_in_Message
        
        SFNav_Posi = 1;
        
        TOW = TOW + 6;
        
        if TOW >= Constants.WEEKLONGSEC
            
            TOW = TOW -  Constants.WEEKLONGSEC;
            
            WN = WN + 1;
        end
          
        [SFNav, Register_FEC] = CNAV_Gen(PRNID, typeID, TOW, Register_FEC);
        
    end
    
end


L2C(1:2:Constants.Len_mul-1,1) = L2CM_sum(1:Constants.Len_CL,1);



