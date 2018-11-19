function equalYes = ephSatOrbitPara_equalcheck(SYST, eph1, eph2)

switch (SYST)
    case 'GPS_L1CA'
        equalYes = isequal_ephGPSatOrbit(eph1, eph2);
    case 'BDS_B1I'
        equalYes = isequal_ephBDSatOrbit(eph1, eph2);
end