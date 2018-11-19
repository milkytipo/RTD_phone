function [ephemeris,a1,Cuc,e,Cic,i0,omega,omegaDot,pagenum, subframeID,SOW] = ephemeris_d2(bits,ephemeris) %GEO 

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
%% initial
SOW = -1;
pagenum = 0;
a1=[];
Cuc=[];
e=[];
Cic=[];
i0=[];
omega=[];
omegaDot=[];


%% Decode all 5 sub-frames ================================================
% for j = 1:10
%     mainframe = bits(1500*(j-1)+1 : 1500*j);
% for i = 1:5
    %--- "Cut" one sub-frame's bits ---------------------------------------
    subframe = bits;
%     subframe = mainframe(300*(i-1)+1 : 300*i);
    %subframe = bits(300*(i-1)+1 : 300*i);
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
            pagenum = bin2dec(subframe(43:46));%pages
            switch pagenum
                case 1
                    SOW        = bin2dec([subframe(19:26)  ...
                            subframe(31:42)]);
%                     eph.SOW        = bin2dec([subframe(19:26)  ...
%                             subframe(31:42)]);
                    ephemeris.ephUpdate.health      = bin2dec(subframe(47));
                    ephemeris.ephUpdate.IODC        = bin2dec(subframe(48:52)); %% not sure
%                     eph.URAI        = bin2dec(subframe(61:64));
                    ephemeris.ephUpdate.weekNumber  = bin2dec(subframe(65:77)); %+ 1024;%WN
                    ephemeris.ephUpdate.toc         = bin2dec([subframe(78:82)  ...
                             subframe(91:102)]) * 2^3;
                    ephemeris.ephUpdate.TGD1        = twosComp2dec(subframe(103:112)) * 10^(-10);
%                     eph.TGD2        = twosComp2dec(subframe(121:130)) * 10^(-10);
%                     eph.A1          = bin2dec(subframe(131:134));
                case 2
                    SOW        = bin2dec([subframe(19:26)  ...
                            subframe(31:42)]);
                    ephemeris.ephUpdate.Alpha0=twosComp2dec([subframe(47:52)  ...
                                     subframe(61:62)]) * 2^(-30);
                    ephemeris.ephUpdate.Alpha1=twosComp2dec(subframe(63:70))* 2^(-27);
                    ephemeris.ephUpdate.Alpha2=twosComp2dec(subframe(71:78))* 2^(-24);
                    ephemeris.ephUpdate.Alpha3=twosComp2dec([subframe(79:82)  ...
                                     subframe(91:94)]) * 2^(-24);
                    ephemeris.ephUpdate.Beta0=twosComp2dec(subframe(95:102)) * 2^11;
                    ephemeris.ephUpdate.Beta1=twosComp2dec(subframe(103:110))* 2^14;
                    ephemeris.ephUpdate.Beta2=twosComp2dec([subframe(111:112)  ...
                                     subframe(121:126)])* 2^16;
                    ephemeris.ephUpdate.Beta3=twosComp2dec(subframe(127:134)) * 2^16;
                case 3
                    SOW        = bin2dec([subframe(19:26)  ...
                            subframe(31:42)]);
                    ephemeris.ephUpdate.a0 = twosComp2dec([subframe(101:112)  ...
                                    subframe(121:132)]) * 2^(-33);
                    a1.h           = subframe(133:136);
                case 4
                    SOW        = bin2dec([subframe(19:26)  ...
                            subframe(31:42)]);
                    a1.m           = subframe(47:52);
                    a1.l           = subframe(61:72);
                    ephemeris.ephUpdate.a2        = twosComp2dec([subframe(73:82)  ...
                                    subframe(91)]) * 2^(-66);
                    ephemeris.ephUpdate.IODE      = bin2dec(subframe(92:96)); %% not sure
                    ephemeris.ephUpdate.deltan    = ...
                                twosComp2dec(subframe(97:112)) ...
                                * 2^(-43) * Pi;
                    Cuc.h          = subframe(121:134);       
                case 5
                    SOW        = bin2dec([subframe(19:26)  ...
                            subframe(31:42)]);
                    Cuc.l          = subframe(47:50);
                    ephemeris.ephUpdate.M0        = ...
                                    twosComp2dec([subframe(51:52) subframe(61:82) ...
                                    subframe(91:98)])* 2^(-31) * Pi;
                    ephemeris.ephUpdate.Cus       = twosComp2dec([subframe(99:112) ...
                                    subframe(121:124)]) * 2^(-31);
                    e.h            = subframe(125:134);
                case 6
                    SOW        = bin2dec([subframe(19:26)  ...
                            subframe(31:42)]);
                    e.m            = subframe(47:52);
                    e.l            = subframe(61:76);
                    ephemeris.ephUpdate.sqrtA     = ...
                                  bin2dec([subframe(77:82) subframe(91:112) ...
                                  subframe(121:124)])* 2^(-19);
                    Cic.h          = subframe(125:134);         
                case 7
                    SOW        = bin2dec([subframe(19:26)  ...
                            subframe(31:42)]);
                    Cic.m          = subframe(47:52); 
                    Cic.l          = subframe(61:62); 
                    ephemeris.ephUpdate.Cis       = twosComp2dec(subframe(63:80)) * 2^(-31);
                    ephemeris.ephUpdate.toe       = bin2dec([subframe(81:82) subframe(91:105)]) * 2^3;
                    i0.h           = subframe(106:112);
                    i0.m1          = subframe(121:134);               
                case 8
                    SOW        = bin2dec([subframe(19:26)  ...
                            subframe(31:42)]);
                    i0.m2          = subframe(47:52); 
                    i0.l           = subframe(61:65); 
                    ephemeris.ephUpdate.Crc       = twosComp2dec([subframe(66:82) ...
                    subframe(91)]) * 2^(-6);
                    ephemeris.ephUpdate.Crs       = twosComp2dec(subframe(92:109)) * 2^(-6);
                    omegaDot.h    = subframe(110:112);
                    omegaDot.m    = subframe(121:136);   
                case 9
                    SOW        = bin2dec([subframe(19:26)  ...
                            subframe(31:42)]);
                    omegaDot.l    = subframe(47:51);
                    ephemeris.ephUpdate.omega0    = ...
                      twosComp2dec([subframe(52) subframe(61:82) subframe(91:99)]) ...
                      * 2^(-31) * Pi;
                    omega.h            = subframe(100:112);
                    omega.m            = subframe(121:134);
                case 10
                    SOW        = bin2dec([subframe(19:26)  ...
                            subframe(31:42)]);
                    omega.l            = subframe(47:51);
                    ephemeris.ephUpdate.iDot      = twosComp2dec([subframe(52) ...
                        subframe(61:73)]) * 2^(-43) * Pi;
            end

        case 2  %--- It is subframe 2 -------------------------------------
            SOW        = bin2dec([subframe(19:26)  ...
                            subframe(31:42)]);
        case 3  %--- It is subframe 3 -------------------------------------   
            SOW        = bin2dec([subframe(19:26)  ...
                            subframe(31:42)]);
        case 4  %--- It is subframe 4 -------------------------------------
            SOW        = bin2dec([subframe(19:26)  ...
                            subframe(31:42)]);
            % Almanac, ionospheric model, UTC parameters.
            % SV health (PRN: 25-32).
            % Not decoded at the moment.
        case 5  %--- It is subframe 5 -------------------------------------
            SOW        = bin2dec([subframe(19:26)  ...
                            subframe(31:42)]);
            pagenum = bin2dec(subframe(44:50));%pages
            switch pagenum
                case 101
                    ephemeris.ephUpdate.A0gps = twosComp2dec(subframe(97:110)) * 0.1 * 10^(-8);
                    ephemeris.ephUpdate.A1gps = twosComp2dec([subframe(111:112) subframe(121:134)]) * 0.1 * 10^(-8);
                case 102
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
end % for all 5 sub-frames ...

