function [receiver] = EPH_Initializing(receiver, eph_para_saved, n)
    switch receiver.SYST
        case 'BD_B1I'
            receiver.channels(n).CH_B1I(1).ephReady = eph_para_saved.ephReady;
            receiver.channels(n).CH_B1I(1).eph = eph_para_saved.eph;
            receiver.channels(n).CH_B1I(1).subframeID = eph_para_saved.subframeID;

            switch receiver.channels(n).CH_B1I(1).navType
                case 'B1I_D1'
                    receiver.channels(n).CH_B1I(1).toel = eph_para_saved.toel;
                    receiver.channels(n).CH_B1I(1).toeh = eph_para_saved.toeh;
                case 'B1I_D2'
                    receiver.channels(n).CH_B1I(1).a1h = eph_para_saved.a1h;
                    receiver.channels(n).CH_B1I(1).a1m = eph_para_saved.a1m;
                    receiver.channels(n).CH_B1I(1).a1l = eph_para_saved.a1l;
                    receiver.channels(n).CH_B1I(1).Cuch = eph_para_saved.Cuch;
                    receiver.channels(n).CH_B1I(1).Cucl = eph_para_saved.Cucl;
                    receiver.channels(n).CH_B1I(1).eh = eph_para_saved.eh;
                    receiver.channels(n).CH_B1I(1).em = eph_para_saved.em;
                    receiver.channels(n).CH_B1I(1).el = eph_para_saved.el;
                    receiver.channels(n).CH_B1I(1).Cich = eph_para_saved.Cich;
                    receiver.channels(n).CH_B1I(1).Cicm = eph_para_saved.Cicm;
                    receiver.channels(n).CH_B1I(1).Cicl = eph_para_saved.Cicl;
                    receiver.channels(n).CH_B1I(1).i0h = eph_para_saved.i0h;
                    receiver.channels(n).CH_B1I(1).i0m1 = eph_para_saved.i0m1;
                    receiver.channels(n).CH_B1I(1).i0m2 = eph_para_saved.i0m2;
                    receiver.channels(n).CH_B1I(1).i0l = eph_para_saved.i0l;
                    receiver.channels(n).CH_B1I(1).wh = eph_para_saved.wh;
                    receiver.channels(n).CH_B1I(1).wm = eph_para_saved.wm;
                    receiver.channels(n).CH_B1I(1).wl = eph_para_saved.wl;
                    receiver.channels(n).CH_B1I(1).omegah = eph_para_saved.omegah;
                    receiver.channels(n).CH_B1I(1).omegam = eph_para_saved.omegam;
                    receiver.channels(n).CH_B1I(1).omegal = eph_para_saved.omegal;
            end
        case 'GPS_L1CA'
            receiver.channels(n).CH_L1CA(1).ephReady = eph_para_saved.ephReady;
            receiver.channels(n).CH_L1CA(1).eph = eph_para_saved.eph;
            receiver.channels(n).CH_L1CA(1).subframeID = eph_para_saved.subframeID;    
    end
end