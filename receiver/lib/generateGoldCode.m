function code = generateGoldCode(system, PRN)
if strcmp(system, 'GPS_L1CA') 
    code = generateCAcode(PRN);
elseif strcmp(system, 'BDS_B1I') 
    code = generateB1ICode(PRN);
end
