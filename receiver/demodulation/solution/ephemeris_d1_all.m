function [almanac, ephemeris,CH_B1I_in] = ephemeris_d1_all(bits, almanac, ephemeris,CH_B1I_in)
%UNTITLED5 Summary of this function goes here
%%
%    calculate ephemeris
%   Detailed explanation goes here
[ephemeris, toe, SOW, ID] = ephemeris_d1(bits, ephemeris);
% CH_B1I_in.SOW = SOW;
if ID == 2
    ephemeris.rawEph.toeh = toe.h;
elseif ID == 3
    ephemeris.rawEph.toel = toe.l;
end
 % to decide if the ID is run all the case
% TD_flag = 1;
for i = 1:5
    if ID == ephemeris.subframeID(i)
        ephemeris.subframeID(i) = 11;
    end
end
%  fprintf('SOW is : %f\n',SOW); % 
% decide whether all the parameters all decode from navbits
if ephemeris.subframeID(1:3) == [11 11 11]
%     ephemeris.ephReady = 1;
    ephemeris.updateReady = 1;
    ephemeris.ephUpdate.toe = bin2dec([ephemeris.rawEph.toeh ephemeris.rawEph.toel]) * 2^3;
end

%%
%  calculate almanac
% if almanac.almReady~=1
     [alma, ID_alm, pagenum,health, WNa] = ephemeris_d1_alm(bits);
        if ID_alm==4 && pagenum>=1 && pagenum<=24
            almanac.alm(pagenum).a0 = alma.a0;
            almanac.alm(pagenum).a1 = alma.a1;
            almanac.alm(pagenum).toa = alma.toa;
            almanac.alm(pagenum).omega = alma.omega;
            almanac.alm(pagenum).omega0 = alma.omega0;
            almanac.alm(pagenum).omegaDot = alma.omegaDot;
            almanac.alm(pagenum).sqrtA = alma.sqrtA;
            almanac.alm(pagenum).e = alma.e;
            almanac.alm(pagenum).M0 = alma.M0;
            almanac.alm(pagenum).deltai = alma.deltai;
            almanac.dect(pagenum)=1;
        elseif ID_alm==5 && pagenum>=1 && pagenum<=6
            almanac.alm(pagenum+24).a0 = alma.a0;
            almanac.alm(pagenum+24).a1 = alma.a1;
            almanac.alm(pagenum+24).toa = alma.toa;
            almanac.alm(pagenum+24).omega = alma.omega;
            almanac.alm(pagenum+24).omega0 = alma.omega0;
            almanac.alm(pagenum+24).omegaDot = alma.omegaDot;
            almanac.alm(pagenum+24).sqrtA = alma.sqrtA;
            almanac.alm(pagenum+24).e = alma.e;
            almanac.alm(pagenum+24).M0 = alma.M0;
            almanac.alm(pagenum+24).deltai = alma.deltai;
            almanac.dect(pagenum+24)=1;
        elseif ID_alm==5 && pagenum==7
            almanac.hea(1:19) = health(1:19);
        elseif ID_alm==5 && pagenum==8
            almanac.hea(20:30) = health(20:30);
            almanac.WNa = WNa;
        end
        if almanac.dect(1:30)==ones(1,30)
            almanac.almAllReady=1;
        end
% end


end

