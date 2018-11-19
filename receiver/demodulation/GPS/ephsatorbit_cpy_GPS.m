function ephdst = ephsatorbit_cpy_GPS(ephdst, ephsrc)

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
ephdst.TGD = ephsrc.TGD;
ephdst.IODC = ephsrc.IODC;
ephdst.toc = ephsrc.toc;
ephdst.af2 = ephsrc.af2;
ephdst.af1 = ephsrc.af1;
ephdst.af0 = ephsrc.af0;
ephdst.IODE = ephsrc.IODE;
ephdst.IODE2 = ephsrc.IODE2;
ephdst.toe = ephsrc.toe;

end