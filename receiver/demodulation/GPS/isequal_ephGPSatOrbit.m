function equalYes = isequal_ephGPSatOrbit(eph1,eph2)
% This function will check if the parameters related to the satellite orbits
% computation of the two eph inputs are equal.
equal_deltan = (eph1.deltan == eph2.deltan);
equal_Cuc = (eph1.Cuc == eph2.Cuc);
equal_M0 = (eph1.M0 == eph2.M0);
equal_e = (eph1.e == eph2.e);
equal_Cus = (eph1.Cus == eph2.Cus);
equal_Crc = (eph1.Crc == eph2.Crc);
equal_Crs = (eph1.Crs == eph2.Crs);
equal_sqrtA = (eph1.sqrtA == eph2.sqrtA);
equal_i0 = (eph1.i0 == eph2.i0);
equal_Cic = (eph1.Cic == eph2.Cic);
equal_omegaDot = (eph1.omegaDot == eph2.omegaDot);
equal_Cis = (eph1.Cis == eph2.Cis);
equal_iDot = (eph1.iDot == eph2.iDot);
equal_omega0 = (eph1.omega0 == eph2.omega0);
equal_omega = (eph1.omega == eph2.omega);
equal_weekNumber = (eph1.weekNumber == eph2.weekNumber);
equal_health = (eph1.health == eph2.health);
equal_TGD = (eph1.TGD == eph2.TGD);
equal_IODC = (eph1.IODC == eph2.IODC);
equal_toc = (eph1.toc == eph2.toc);
equal_af2 = (eph1.af2 == eph2.af2);
equal_af1 = (eph1.af1 == eph2.af1);
equal_af0 = (eph1.af0 == eph2.af0);
equal_IODE = (eph1.IODE == eph2.IODE);
equal_IODE2 = (eph1.IODE2 == eph2.IODE2);
equal_toe = (eph1.toe == eph2.toe);

equalYes = equal_deltan & equal_Cuc & equal_M0 & equal_e & equal_Cus & equal_Crc & equal_Crs ...
    & equal_sqrtA & equal_i0 & equal_Cic & equal_omegaDot & equal_Cis & equal_iDot & equal_omega0 ...
    & equal_omega & equal_weekNumber & equal_health & equal_TGD & equal_IODC & equal_toc ...
    & equal_af2 & equal_af1 & equal_af0 & equal_IODE & equal_IODE2 & equal_toe;

end