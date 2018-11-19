function equalYes = ephionoPara_equalcheck(SYST, eph1, eph2)

switch SYST
    case 'GPS_L1CA'
        equalYes = isequal_ephGPSiono(eph1, eph2);
    case 'BDS_B1I'
        equalYes = isequal_ephBDSiono(eph1, eph2);
end