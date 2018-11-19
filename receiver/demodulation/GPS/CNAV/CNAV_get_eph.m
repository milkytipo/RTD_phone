function eph = CNAV_get_eph(eph, bits, Type)

switch Type
    case 10
        eph.WN            = bin2dec(bits(39:51));
        eph.L1_health     = bin2dec(bits(52));
        eph.L2_health     = bin2dec(bits(53));
        eph.L5_health     = bin2dec(bits(54));
        eph.t_op          = bin2dec(bits(55:65))*300;
        eph.t_oe_10       = bin2dec(bits(71:81))*300;
        eph.Delta_A       = twosComp2dec(bits(82:107))*2^(-9);
        eph.A_dot         = twosComp2dec(bits(108:132))*2^(-21);
        eph.Delta_n0      = twosComp2dec(bits(133:149))*2^(-44);
        eph.Delta_n0_dot  = twosComp2dec(bits(150:172))*2^(-57);
        eph.M_0n          = twosComp2dec(bits(173:205))*2^(-32);
        eph.e_n           = bin2dec(bits(206:238))*2^(-34);
        eph.omega_n       = twosComp2dec(bits(239:271))*2^(-32);
        eph.integrityFlag = bin2dec(bits(272));
        eph.L2C_phasing   = bin2dec(bits(273));
        tmp = twosComp2dec(bits(66:70));
        if (tmp == -16)
            eph.URA_ED = -1; %no accuracy prediction available - use at own risk
        elseif (tmp<=6)
            eph.URA_ED = 2^(1+tmp/2);
        elseif (tmp<15)
            eph.URA_ED = 2^(tmp-2);
        else
            eph.URA_ED = 9999; %URA_ED>6144 or no accuracy predicion is available
        end
        
    case 11
        eph.t_oe_11         = bin2dec(bits(39:49))*300;
        eph.Omega_0n        = twosComp2dec(bits(50:82))*2^(-32);
        eph.i_0n            = twosComp2dec(bits(83:115))*2^(-32);
        eph.Delta_Omega_dot = twosComp2dec(bits(116:132))*2^(-44);
        eph.i_0n_dot        = twosComp2dec(bits(133:147))*2^(-44);
        eph.Cis_n           = twosComp2dec(bits(148:163))*2^(-30);
        eph.Cic_n           = twosComp2dec(bits(164:179))*2^(-30);
        eph.Crs_n           = twosComp2dec(bits(180:203))*2^(-8);
        eph.Crc_n           = twosComp2dec(bits(204:227))*2^(-8);
        eph.Cus_n           = twosComp2dec(bits(228:248))*2^(-30);
        eph.Cuc_n           = twosComp2dec(bits(249:269))*2^(-30);
        
    case {30,31,32,33,34,35,36,37}  % ±÷”
        tmp = twosComp2dec(bits(50:54));
        if (tmp == -16)
            eph.URA_NED0 = -1; %no accuracy prediction available - use at own risk
        elseif (tmp<=6)
            eph.URA_NED0 = 2^(1+tmp/2);
        elseif (tmp<15)
            eph.URA_NED0 = 2^(tmp-2);
        else
            eph.URA_NED0 = 9999; %URA_NED0>6144 or no accuracy predicion is available
        end
        tmp = bin2dec(bits(55:57));
        eph.URA_NED1 = 2^(-14-tmp);
        tmp = bin2dec(bits(58:60));
        eph.URA_NED2 = 2^(-28-tmp);

        eph.t_oc     = bin2dec(bits(61:71))*300;
        eph.a_f0n    = twosComp2dec(bits(72:97))*2^(-35);
        eph.a_f1n    = twosComp2dec(bits(98:117))*2^(-48);
        eph.a_f2n    = twosComp2dec(bits(118:127))*2^(-60);
        
end