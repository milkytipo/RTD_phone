function ephdst = ephsatorbit_cpy_BDS(ephdst, ephsrc)

ephdst.deltan = ephsrc.deltan;
ephdst.Cuc = ephsrc.Cuc;
ephdst.M0 = ephsrc.M0;
ephdst.e = ephsrc.e;
ephdst.Cus = ephsrc.Cus;
ephdst.Crc = ephsrc.Crc;
ephdst.Crs = ephsrc.Crs;
ephdst.sqrtA = ephsrc.sqrtA;
ephdst.i0 = ephsrc.i0;
ephdst.Cic = ephsrc.Cic;
ephdst.omegaDot = ephsrc.omegaDot;
ephdst.Cis = ephsrc.Cis;
ephdst.iDot = ephsrc.iDot;
ephdst.omega0 = ephsrc.omega0;
ephdst.omega = ephsrc.omega;
ephdst.weekNumber = ephsrc.weekNumber;
ephdst.health = ephsrc.health;
ephdst.TGD1 = ephsrc.TGD1;
ephdst.IODC = ephsrc.IODC;
ephdst.toc = ephsrc.toc;
ephdst.a2 = ephsrc.a2;
ephdst.a1 = ephsrc.a1;
ephdst.a0 = ephsrc.a0;
ephdst.IODE = ephsrc.IODE;
ephdst.A0utc = ephsrc.A0utc;
ephdst.A1utc = ephsrc.A1utc;
ephdst.deltaTls = ephsrc.deltaTls;
ephdst.deltaTlsf = ephsrc.deltaTlsf;
ephdst.WNlsf = ephsrc.WNlsf;
ephdst.DN = ephsrc.DN;
ephdst.A0gps = ephsrc.A0gps;
ephdst.A1gps = ephsrc.A1gps;
ephdst.toe = ephsrc.toe;

end