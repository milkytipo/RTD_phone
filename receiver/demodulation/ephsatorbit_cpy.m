function ephdst = ephsatorbit_cpy(SYST, ephdst, ephsrc)

switch (SYST)
    case 'GPS_L1CA'
        ephdst = ephsatorbit_cpy_GPS(ephdst, ephsrc);
    case 'BDS_B1I'
        ephdst = ephsatorbit_cpy_BDS(ephdst, ephsrc);
end