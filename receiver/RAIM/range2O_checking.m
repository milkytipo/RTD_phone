function range2OPass = range2O_checking(SYST, eph, last_transmitime, prn)

switch SYST
    case 'GPS_L1CA'
        [satPositions, satClkCorr] = gpsl1ca_calc_OneSatPosition(last_transmitime, eph);
    case 'BDS_B1I'
        [satPositions, satClkCorr] = bdsb1i_calc_OneSatPosition(last_transmitime, eph, prn);
end


satrange = norm(satPositions(1:3));
As = (eph.sqrtA)^2;
Bs = As*sqrt(1 - (eph.e)^2);

range2OPass = 0;
if (satrange>0.95*Bs)&&(satrange<1.05*As)
    range2OPass = 1;
end