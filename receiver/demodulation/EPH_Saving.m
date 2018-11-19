function [eph_para_out] = EPH_Saving(receiver, n) 
% Because of some parameters in Matlab channel struct are not used in C
% program, like eph , ephReady and so on, this function is for saving these
% parameters.

    switch receiver.SYST
            case 'BD_B1I'
                CH_B1I_in = receiver.channels(n).CH_B1I(1);
                eph_para_out.ephReady = CH_B1I_in.ephReady;
                eph_para_out.eph = CH_B1I_in.eph;
                eph_para_out.subframeID = CH_B1I_in.subframeID;

                switch CH_B1I_in.navType
                    case 'B1I_D1'
                        eph_para_out.toel = CH_B1I_in.toel;
                        eph_para_out.toeh = CH_B1I_in.toeh;
                    case 'B1I_D2'
                        eph_para_out.a1h = CH_B1I_in.a1h;
                        eph_para_out.a1m = CH_B1I_in.a1m;
                        eph_para_out.a1l = CH_B1I_in.a1l;
                        eph_para_out.Cuch = CH_B1I_in.Cuch;
                        eph_para_out.Cucl = CH_B1I_in.Cucl;
                        eph_para_out.eh = CH_B1I_in.eh;
                        eph_para_out.em = CH_B1I_in.em;
                        eph_para_out.el = CH_B1I_in.el;
                        eph_para_out.Cich = CH_B1I_in.Cich;
                        eph_para_out.Cicm = CH_B1I_in.Cicm;
                        eph_para_out.Cicl = CH_B1I_in.Cicl;
                        eph_para_out.i0h = CH_B1I_in.i0h;
                        eph_para_out.i0m1 = CH_B1I_in.i0m1;
                        eph_para_out.i0m2 = CH_B1I_in.i0m2;
                        eph_para_out.i0l = CH_B1I_in.i0l;
                        eph_para_out.wh = CH_B1I_in.wh;
                        eph_para_out.wm = CH_B1I_in.wm;
                        eph_para_out.wl = CH_B1I_in.wl;
                        eph_para_out.omegah = CH_B1I_in.omegah;
                        eph_para_out.omegam = CH_B1I_in.omegam;
                        eph_para_out.omegal = CH_B1I_in.omegal;
                end
        case 'GPS_L1CA'
            CH_L1CA_in = receiver.channels(n).CH_L1CA(1);
            eph_para_out.ephReady = CH_L1CA_in.ephReady;
            eph_para_out.eph = CH_L1CA_in.eph;
            eph_para_out.subframeID = CH_L1CA_in.subframeID;
    end

end