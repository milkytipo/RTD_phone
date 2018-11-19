function [eph,subframeID, SOW_GPS] = ephemeris_GPS(bits,ephemeris) %NGEO 

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
eph = ephemeris.ephUpdate;

%% Decode all 5 sub-frames ================================================
% for i = 1:5

    %--- "Cut" one sub-frame's bits ---------------------------------------
%     subframe = bits(300*(i-1)+1 : 300*i);
    subframe = bits;
    %--- Decode the sub-frame id ------------------------------------------
    % For more details on sub-frame contents please refer to GPS IS.
    subframeID = bin2dec(subframe(50:52));
    SOW_GPS        = bin2dec(subframe(31:47));
    %--- Decode sub-frame based on the sub-frames id ----------------------
    % The task is to select the necessary bits and convert them to decimal
    % numbers. For more details on sub-frame contents please refer to GPS
    % ICD (IS-GPS-200D).
    switch subframeID
        case 1  %--- It is subframe 1 -------------------------------------
            % It contains WN, SV clock corrections, health and accuracy
            
            eph.weekNumber  = bin2dec(subframe(61:70)); 
            eph.health      = bin2dec(subframe(77:82));
            eph.TGD         = twosComp2dec(subframe(197:204)) * 2^(-31);
            eph.toc        = bin2dec(subframe(219:234)) * 2^4;
            eph.af2        = twosComp2dec(subframe(241:248)) * 2^(-55);
            eph.af1        = twosComp2dec(subframe(249:264)) * 2^(-43);
            eph.af0        = twosComp2dec(subframe(271:292)) * 2^(-31);
            eph.IODC       = bin2dec([subframe(83:84) subframe(211:218)]);
            
        case 2  %--- It is subframe 2 -------------------------------------
            % It contains first part of ephemeris parameters
            eph.IODE        = bin2dec(subframe(61:68));
            eph.deltan      = twosComp2dec(subframe(91:106)) * 2^(-43) * Pi;
            eph.Cuc         = twosComp2dec(subframe(151:166)) * 2^(-29);
            eph.M0          = twosComp2dec([subframe(107:114) subframe(121:144)]) * 2^(-31) * Pi;
            eph.e           = bin2dec([subframe(167:174) subframe(181:204)]) * 2^(-33);
            eph.Cus         = twosComp2dec(subframe(211:226)) * 2^(-29);
%            eph.Crc         = twosComp2dec([subframe(199:202) subframe(211:224)]) * 2^(-6);
            eph.Crs         = twosComp2dec(subframe(69:84)) * 2^(-5);
            eph.sqrtA       = bin2dec([subframe(227:234) subframe(241:264)]) * 2^(-19);
            eph.toe         = bin2dec(subframe(271:286)) * 2^4;%%!!!!!!!!

        case 3  %--- It is subframe 3 -------------------------------------
            % It contains second part of ephemeris parameters
            
            eph.IODE2     = bin2dec(subframe(271:278));
            eph.i0        = twosComp2dec([subframe(137:144) subframe(151:174)]) * 2^(-31) * Pi;
            eph.Cic       = twosComp2dec(subframe(61:76)) * 2^(-29);
            eph.omega     = twosComp2dec([subframe(197:204) subframe(211:234)]) * 2^(-31) * Pi;
            eph.Cis       = twosComp2dec(subframe(121:136)) * 2^(-29);
            eph.iDot      = twosComp2dec(subframe(279:292)) * 2^(-43) * Pi;
            eph.omega0    = twosComp2dec([subframe(77:84) subframe(91:114)]) * 2^(-31) * Pi;
            eph.omegaDot  = twosComp2dec(subframe(241:264)) * 2^(-43) * Pi;
            eph.Crc       = twosComp2dec(subframe(181:196)) * 2^(-5);
            
        case 4
            pageID = bin2dec(subframe(63:68));
            switch pageID
                case 56
                    eph.Alpha0 = twosComp2dec(subframe(69:76)) * 2^(-30);
                    eph.Alpha1 = twosComp2dec(subframe(77:84)) * 2^(-27);
                    eph.Alpha2 = twosComp2dec(subframe(91:98)) * 2^(-24);
                    eph.Alpha3 = twosComp2dec(subframe(99:106)) * 2^(-24);
                    eph.Beta0  = twosComp2dec(subframe(107:114)) * 2^11;
                    eph.Beta1  = twosComp2dec(subframe(121:128)) * 2^14;
                    eph.Beta2  = twosComp2dec(subframe(129:136)) * 2^16;
                    eph.Beta3  = twosComp2dec(subframe(137:144)) * 2^16;
                    eph.A1utc  = twosComp2dec(subframe(151:174)) * 2^(-50);
                    eph.A0utc  = twosComp2dec([subframe(181:204) subframe(211:218)]) * 2^(-30);
                    eph.tot = bin2dec(subframe(219:226)) * 2^12;
                    eph.WNt = bin2dec(subframe(227:234));
                    eph.deltaTls = twosComp2dec(subframe(241:248));
                    eph.WNlsf = bin2dec(subframe(249:256));
                    eph.DN = bin2dec(subframe(257:264));
                    eph.deltaTlsf = twosComp2dec(subframe(271:278));
            end
                
    end % switch subframeID ... 

end