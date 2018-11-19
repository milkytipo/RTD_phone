function delta_phs = GPS_L1L2_codPhsDiff( channel_spc )

%计算码相位延时校正量(m),以L1伪距为基准

% delta_phs = (codPhs_L1 - codPhs_L2)*c/1.023MHz = rho2 - rho1; 


c = 299792458;

delta_phs = mod( channel_spc.LO_CodPhs - channel_spc.LO_CodPhs_L2, 1023 );
if (delta_phs>511.5)
    delta_phs = delta_phs - 1023;
end
delta_phs = delta_phs*c/1.023e6;
