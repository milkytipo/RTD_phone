function [almanac, ephemeris,CH_B1I_in] = ephemeris_d2_all(bits, almanac, ephemeris,CH_B1I_in)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
[ephemeris,a1,Cuc,e,Cic,i0,omega,omegaDot,pagenum, ID,SOW] = ephemeris_d2(bits,ephemeris); %GEO
% CH_B1I_in.SOW = SOW;
if ID == 1
    switch pagenum
        case 0 %do noithing
            
        case 1
            ephemeris.subframeID(pagenum) = 11;
        case 2
            ephemeris.subframeID(pagenum) = 11;
        case 3
            ephemeris.rawEph.a1h = a1.h;
            ephemeris.subframeID(pagenum) = 11;
        case 4
            ephemeris.rawEph.a1m = a1.m;
            ephemeris.rawEph.a1l = a1.l;
            ephemeris.rawEph.Cuch = Cuc.h;
            ephemeris.subframeID(pagenum) = 11;
        case 5
            ephemeris.rawEph.Cucl = Cuc.l;
            ephemeris.rawEph.eh = e.h;
            ephemeris.subframeID(pagenum) = 11;
        case 6
            ephemeris.rawEph.em  = e.m;
            ephemeris.rawEph.el = e.l;
            ephemeris.rawEph.Cich = Cic.h;
            ephemeris.subframeID(pagenum) = 11;
        case 7
            ephemeris.rawEph.Cicm = Cic.m;
            ephemeris.rawEph.Cicl = Cic.l;
            ephemeris.rawEph.i0h  = i0.h;
            ephemeris.rawEph.i0m1  = i0.m1;
            ephemeris.subframeID(pagenum) = 11;
        case 8
            ephemeris.rawEph.i0m2 = i0.m2;
            ephemeris.rawEph.i0l =i0.l;
            ephemeris.rawEph.omegaDoth  = omegaDot.h;
            ephemeris.rawEph.omegaDotm = omegaDot.m;
            ephemeris.subframeID(pagenum) = 11;
        case 9
            ephemeris.rawEph.omegaDotl = omegaDot.l;
            ephemeris.rawEph.omegah = omega.h;
            ephemeris.rawEph.omegam = omega.m;
            ephemeris.subframeID(pagenum) = 11;
        case 10
            ephemeris.rawEph.omegal = omega.l;
            ephemeris.subframeID(pagenum) = 11;
    end
end
% to decide if the ID is run all the case
% TD_flag = 1;
% for i = 1:10
%     if pagenum == ephemeris.subframeID(i)
%         ephemeris.subframeID(i) = 11;
%     end
% end
% channel.SOW = SOW; %
% decide whether all the parameters all decode from navbits
if ephemeris.subframeID == 11*ones(1,10)
    %     ephemeris.ephReady = 1;
    ephemeris.updateReady = 1;
    %     channel.eph.toe = bin2dec([channel.toeh channel.toel]) * 2^3;
    ephemeris.ephUpdate.a1  =  twosComp2dec([ephemeris.rawEph.a1h ephemeris.rawEph.a1m ephemeris.rawEph.a1l]) * 2^(-50);
    ephemeris.ephUpdate.Cuc =  twosComp2dec([ephemeris.rawEph.Cuch ephemeris.rawEph.Cucl]) * 2^(-31);
    ephemeris.ephUpdate.e   =  bin2dec([ephemeris.rawEph.eh ephemeris.rawEph.em ephemeris.rawEph.el])* 2^(-33);
    ephemeris.ephUpdate.Cic =  twosComp2dec([ephemeris.rawEph.Cich ephemeris.rawEph.Cicm ephemeris.rawEph.Cicl]) * 2^(-31);
    ephemeris.ephUpdate.i0  =  twosComp2dec([ephemeris.rawEph.i0h ephemeris.rawEph.i0m1 ...
        ephemeris.rawEph.i0m2 ephemeris.rawEph.i0l])* 2^(-31) * pi;
    ephemeris.ephUpdate.omega   =  twosComp2dec([ephemeris.rawEph.omegah ephemeris.rawEph.omegam ephemeris.rawEph.omegal]) * 2^(-31) * pi;
    ephemeris.ephUpdate.omegaDot = twosComp2dec([ephemeris.rawEph.omegaDoth ephemeris.rawEph.omegaDotm ...
        ephemeris.rawEph.omegaDotl ])* 2^(-43) * pi;
end



%%
%  calculate almanac
% if almanac.almReady~=1
[alma, ID_alm, pnum,health, WNa] = ephemeris_d2_alm(bits);
if ID_alm==5 && pnum>=37 && pnum<=60
    almanac.alm(pnum-36).a0 = alma.a0;
    almanac.alm(pnum-36).a1 = alma.a1;
    almanac.alm(pnum-36).toa = alma.toa;
    almanac.alm(pnum-36).omega = alma.omega;
    almanac.alm(pnum-36).omega0 = alma.omega0;
    almanac.alm(pnum-36).omegaDot = alma.omegaDot;
    almanac.alm(pnum-36).sqrtA = alma.sqrtA;
    almanac.alm(pnum-36).e = alma.e;
    almanac.alm(pnum-36).M0 = alma.M0;
    almanac.alm(pnum-36).deltai = alma.deltai;
    almanac.dect(pnum-36)=1;
elseif ID_alm==5 && pnum>=95 && pnum<=100
    almanac.alm(pnum-70).a0 = alma.a0;
    almanac.alm(pnum-70).a1 = alma.a1;
    almanac.alm(pnum-70).toa = alma.toa;
    almanac.alm(pnum-70).omega = alma.omega;
    almanac.alm(pnum-70).omega0 = alma.omega0;
    almanac.alm(pnum-70).omegaDot = alma.omegaDot;
    almanac.alm(pnum-70).sqrtA = alma.sqrtA;
    almanac.alm(pnum-70).e = alma.e;
    almanac.alm(pnum-70).M0 = alma.M0;
    almanac.alm(pnum-70).deltai = alma.deltai;
    almanac.dect(pnum-70)=1;
elseif ID_alm==5 && pnum==35
    almanac.hea(1:19) = health(1:19);
elseif ID_alm==5 && pnum==36
    almanac.hea(20:30) = health(20:30);
    almanac.WNa = WNa;
end
if almanac.dect(1:30)==ones(1,30)
    almanac.almAllReady=1;
end
% end

end

