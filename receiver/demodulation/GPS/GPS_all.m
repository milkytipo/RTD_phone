function [almanac, ephemeris, GPS_L1CA_in] = GPS_all(bits, almanac, ephemeris, GPS_L1CA_in)
%UNTITLED5 Summary of this function goes here
%%
%    calculate ephemeris
%   Detailed explanation goes here
[eph, ID, SOW] = ephemeris_GPS(bits, ephemeris);
% GPS_L1CA_in.TOW_6SEC = SOW;


% to decide if the ID is run all the case
% TD_flag = 1;
for i = 1:5
    if ID == ephemeris.subframeID(i)
        ephemeris.subframeID(i) = 11;
    end
end
ephemeris.ephUpdate = eph;
% decide whether all the parameters all decode from navbits
if ephemeris.subframeID(1:3) == [11 11 11]
    %     ephemeris.ephReady = 1;
    ephemeris.updateReady = 1; % Here, the updateReady indicate a set of subframe is received, but not checked yet.
end

% get almanac
[alma, subframeID, pagenum, health, WNa] = AlmanacGPS(bits);
if subframeID==4 && pagenum>=25 && pagenum<=32
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
    almanac.dect(pagenum) = 1;
elseif subframeID==5 && pagenum>=1 && pagenum<=24
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
    almanac.dect(pagenum) = 1;
elseif subframeID==4 && pagenum==63
    almanac.hea(25:32) = health(25:32);
elseif subframeID==5 && pagenum==51
    almanac.hea(1:24) = health(1:24);
    almanac.WNa = WNa;
end
if almanac.dect==ones(1,32)
    almanac.almAllReady=1;
end

end

