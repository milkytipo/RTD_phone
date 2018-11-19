function extentPass = ephPara_extentChecking(SYST, gpsat_ephUpdate)

% This function to be finalized!
extentPass = 1;

switch (SYST)
    case 'GPS_L1CA'
        IODC = gpsat_ephUpdate.IODC;
        IODClsb8 = bitand(int16(IODC), int16(255));
        IODE = gpsat_ephUpdate.IODE;
        IODE2 = gpsat_ephUpdate.IODE2;
        
        if (IODE~=IODE2) || (IODE~=IODClsb8)
            extentPass = 0;
        end
        
    case 'BDS_B1I'
        % Nothing to do for BDS_B1I
end