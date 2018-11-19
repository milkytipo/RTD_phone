function equalYes = isequal_ephBDSiono(eph1, eph2)

equal_Alpha0 = (eph1.Alpha0 == eph2.Alpha0);
equal_Alpha1 = (eph1.Alpha1 == eph2.Alpha1);
equal_Alpha2 = (eph1.Alpha2 == eph2.Alpha2);
equal_Alpha3 = (eph1.Alpha3 == eph2.Alpha3);
equal_Beta0 = (eph1.Beta0 == eph2.Beta0);
equal_Beta1 = (eph1.Beta1 == eph2.Beta1);
equal_Beta2 = (eph1.Beta2 == eph2.Beta2);
equal_Beta3 = (eph1.Beta3 == eph2.Beta3);

equalYes = equal_Alpha0 & equal_Alpha1 & equal_Alpha2 & equal_Alpha3 ...
    & equal_Beta0 & equal_Beta1 & equal_Beta2 & equal_Beta3;
end