function [ephemeris,toe,SOW,subframeID] = ephemeris_d1(bits,ephemeris) %NGEO 

%% Check if there is enough data ==========================================

if length(bits) < 300
    error('The parameter BITS must contain 300 bits!');
end

%% Check if the parameters are strings ====================================
if ~ischar(bits)
    error('The parameter BITS must be a character array!');
end
% Pi used in the GPS coordinate system
Pi = 3.1415926535898; 

toe = [];
SOW = -1;
%% Decode all 5 sub-frames ================================================
% for i = 1:5

    %--- "Cut" one sub-frame's bits ---------------------------------------
%     subframe = bits(300*(i-1)+1 : 300*i);
    subframe = bits;
    %--- Decode the sub-frame id ------------------------------------------
    % For more details on sub-frame contents please refer to GPS IS.
    subframeID = bin2dec(subframe(16:18));
    %--- Decode sub-frame based on the sub-frames id ----------------------
    % The task is to select the necessary bits and convert them to decimal
    % numbers. For more details on sub-frame contents please refer to GPS
    % ICD (IS-GPS-200D).
    switch subframeID
        case 1  %--- It is subframe 1 -------------------------------------
            % It contains WN, SV clock corrections, health and accuracy
            SOW        = bin2dec([subframe(19:26)  ...
                            subframe(31:42)]);
            ephemeris.ephUpdate.weekNumber  = bin2dec(subframe(61:73)); % + 1024;%WN
            %eph.accuracy    = bin2dec(subframe(52:55));
            ephemeris.ephUpdate.health      = bin2dec(subframe(43));
            ephemeris.ephUpdate.TGD1        = twosComp2dec(subframe(99:108)) * 10^(-10);
%             eph.TGD2        = twosComp2dec([subframe(109:112) ...
%                               subframe(121:126)]) * 10^(-10);
            ephemeris.ephUpdate.IODC        = bin2dec(subframe(44:48)); %% not sure
            ephemeris.ephUpdate.toc        = bin2dec([subframe(74:82)  ...
                             subframe(91:98)]) * 2^3;
            ephemeris.ephUpdate.a2        = twosComp2dec(subframe(215:225)) * 2^(-66);
            ephemeris.ephUpdate.a1        = twosComp2dec([subframe(258:262)  ...
                            subframe(271:287)]) * 2^(-50);
            ephemeris.ephUpdate.a0        = twosComp2dec([subframe(226:232)  ...
                            subframe(241:257)]) * 2^(-33);
            ephemeris.ephUpdate.IODE        = bin2dec(subframe(288:292)); %% not sure
            ephemeris.ephUpdate.Alpha0=twosComp2dec(subframe(127:134))* 2^(-30);
            ephemeris.ephUpdate.Alpha1=twosComp2dec(subframe(135:142))* 2^(-27);
            ephemeris.ephUpdate.Alpha2=twosComp2dec(subframe(151:158))* 2^(-24);
            ephemeris.ephUpdate.Alpha3=twosComp2dec(subframe(159:166))* 2^(-24);
            ephemeris.ephUpdate.Beta0=twosComp2dec([subframe(167:172)  ...
                             subframe(181:182)]) * 2^11;
            ephemeris.ephUpdate.Beta1=twosComp2dec(subframe(183:190))* 2^14;
            ephemeris.ephUpdate.Beta2=twosComp2dec(subframe(191:198))* 2^16;
            ephemeris.ephUpdate.Beta3=twosComp2dec([subframe(199:202)  ...
                             subframe(211:214)]) * 2^16;
            
        case 2  %--- It is subframe 2 -------------------------------------
            % It contains first part of ephemeris parameters
            SOW        = bin2dec([subframe(19:26)  ...
                            subframe(31:42)]);
            ephemeris.ephUpdate.deltan      = ...
                twosComp2dec([subframe(43:52) subframe(61:66)]) ...
                * 2^(-43) * Pi;
            ephemeris.ephUpdate.Cuc        = ...
                twosComp2dec([subframe(67:82) subframe(91:92)]) * 2^(-31);
            ephemeris.ephUpdate.M0         = ...
                twosComp2dec([subframe(93:112) subframe(121:132)]) ...
                * 2^(-31) * Pi;
            ephemeris.ephUpdate.e           = ...
                bin2dec([subframe(133:142) subframe(151:172)]) ...
                * 2^(-33);
            ephemeris.ephUpdate.Cus        = twosComp2dec(subframe(181:198)) * 2^(-31);
            ephemeris.ephUpdate.Crc        = ...
                twosComp2dec([subframe(199:202) subframe(211:224)]) * 2^(-6);
            ephemeris.ephUpdate.Crs        = ...
                twosComp2dec([subframe(225:232) subframe(241:250)]) * 2^(-6);
            ephemeris.ephUpdate.sqrtA       = ...
                bin2dec([subframe(251:262) subframe(271:290)]) ...
                * 2^(-19);
            toe.h=subframe(291:292);%%!!!!!!!!

        case 3  %--- It is subframe 3 -------------------------------------
            % It contains second part of ephemeris parameters
            SOW        = bin2dec([subframe(19:26)  ...
                            subframe(31:42)]);
            toe.l=[subframe(43:52) subframe(61:65)];%!!!!!!!!!
            ephemeris.ephUpdate.i0         = ...
                twosComp2dec([subframe(66:82) subframe(91:105)]) ...
                * 2^(-31) * Pi;
            ephemeris.ephUpdate.Cic        = ...
                twosComp2dec([subframe(106:112) subframe(121:132)]) * 2^(-31);
            ephemeris.ephUpdate.omegaDot   = ...
                twosComp2dec([subframe(132:142) subframe(151:163)]) ...
                * 2^(-43) * Pi;
            ephemeris.ephUpdate.Cis        = ...
                twosComp2dec([subframe(164:172) subframe(181:189)]) * 2^(-31);
            ephemeris.ephUpdate.iDot        = twosComp2dec([subframe(190:202) ...
                subframe(211)]) * 2^(-43) * Pi;
            ephemeris.ephUpdate.omega0     = ...
                twosComp2dec([subframe(212:232) subframe(241:251)]) ...
                * 2^(-31) * Pi;
            ephemeris.ephUpdate.omega      = ...
                twosComp2dec([subframe(252:262) subframe(271:291)]) * 2^(-31) * Pi;
        case 4  %--- It is subframe 4 -------------------------------------
             SOW        = bin2dec([subframe(19:26)  ...
                            subframe(31:42)]);
            % Almanac, ionospheric model, UTC parameters.
            % SV health (PRN: 25-32).
            % Not decoded at the moment.

        case 5  %--- It is subframe 5 -------------------------------------
             SOW        = bin2dec([subframe(19:26)  ...
                            subframe(31:42)]);
             Pnum = bin2dec(subframe(44:50));
             switch Pnum
                 case 9
                     ephemeris.ephUpdate.A0gps = twosComp2dec(subframe(97:110)) * 0.1 * 10^(-8);
                     ephemeris.ephUpdate.A1gps = twosComp2dec([subframe(111:112) subframe(121:134)]) * 0.1 * 10^(-8);
                 case 10
                     ephemeris.ephUpdate.deltaTls = twosComp2dec([subframe(51:52) subframe(61:66)]);
                     ephemeris.ephUpdate.deltaTlsf = twosComp2dec(subframe(67:74));
                     ephemeris.ephUpdate.WNlsf = bin2dec(subframe(75:82));
                     ephemeris.ephUpdate.A0utc = twosComp2dec([subframe(91:112) subframe(121:130)]) * 2^(-30);
                     ephemeris.ephUpdate.A1utc = twosComp2dec([subframe(131:142) subframe(151:162)]) * 2^(-50);
                     ephemeris.ephUpdate.DN = bin2dec(subframe(163:170));
             end
            % SV almanac and health (PRN: 1-24).
            % Almanac reference week number and time.
            % Not decoded at the moment.

    end % switch subframeID ... 

end