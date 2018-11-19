function ephdst = ephiono_cpy_GPS(ephdst, ephsrc)

ephdst.Alpha0 = ephsrc.Alpha0;
ephdst.Alpha1 = ephsrc.Alpha1;
ephdst.Alpha2 = ephsrc.Alpha2;
ephdst.Alpha3 = ephsrc.Alpha3;
ephdst.Beta0 = ephsrc.Beta0;
ephdst.Beta1 = ephsrc.Beta1;
ephdst.Beta2 = ephsrc.Beta2;
ephdst.Beta3 = ephsrc.Beta3;

end