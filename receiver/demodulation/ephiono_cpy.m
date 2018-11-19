function ephdst = ephiono_cpy(SYST, ephdst, ephsrc)

switch (SYST)
    case 'GPS_L1CA'
        ephdst = ephiono_cpy_GPS(ephdst, ephsrc);
    case 'BDS_B1I'
        ephdst = ephiono_cpy_BDS(ephdst, ephsrc);
end