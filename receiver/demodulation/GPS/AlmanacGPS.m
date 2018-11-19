function [alm,subframeID, pagenum, health, WNa] = AlmanacGPS(bits) %NGEO

%% Check if there is enough data ==========================================

if length(bits) < 300
    error('The parameter BITS must contain 300 bits!');
end

%% Check if the parameters are strings ====================================
if ~ischar(bits)
    error('The parameter BITS must be a character array!');
end
alm = [];
health = [];
WNa = [];
Pi = 3.1415926535898;
%% Decode all 5 sub-frames ================================================
% for i = 1:5

%--- "Cut" one sub-frame's bits ---------------------------------------
%     subframe = bits(300*(i-1)+1 : 300*i);
subframe = bits;
%--- Decode the sub-frame id ------------------------------------------
% For more details on sub-frame contents please refer to GPS IS.
subframeID = bin2dec(subframe(50:52));
pagenum=0;
%--- Decode sub-frame based on the sub-frames id ----------------------
% The task is to select the necessary bits and convert them to decimal
% numbers. For more details on sub-frame contents please refer to GPS
% ICD (IS-GPS-200D).
switch subframeID
    case 4  %--- It is subframe 1 -------------------------------------
        % It contains WN, SV clock corrections, health and accuracy
        pagenum = bin2dec(subframe(63:68));
        switch pagenum
            case {25,26,27,28,29,30,31,32}
                alm.sqrtA     = bin2dec(subframe(151:174))*2^(-11);
                alm.a1        = twosComp2dec(subframe(279:289))*2^(-38);
                alm.a0        = twosComp2dec([subframe(271:278) subframe(290:292)])*2^(-20);
                alm.omega0    = twosComp2dec(subframe(181:204))*2^(-23) * Pi;
                alm.deltai    = twosComp2dec(subframe(99:114))*2^(-19) * Pi;
                alm.e         = bin2dec(subframe(69:84))*2^(-21);
                alm.toa       = bin2dec(subframe(91:98))*2^12;
                alm.omega     = twosComp2dec(subframe(211:234))*2^(-23) * Pi;
                alm.omegaDot  = twosComp2dec(subframe(121:136))*2^(-38) * Pi;
                alm.M0        = twosComp2dec(subframe(241:264))*2^(-23) * Pi;
            case 63
                health(25)= bin2dec(subframe(229:234));
                health(26)= bin2dec(subframe(241:246));
                health(27)= bin2dec(subframe(247:252));
                health(28)= bin2dec(subframe(253:258));
                health(29)= bin2dec(subframe(259:264));
                health(30)= bin2dec(subframe(271:276));
                health(31)= bin2dec(subframe(277:282));
                health(32)= bin2dec(subframe(283:288));
        end
    case 5  %--- It is subframe 2 -------------------------------------
        % It contains first part of ephemeris parameters
        pagenum = bin2dec(subframe(63:68));
        switch pagenum
            case {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24}
                alm.sqrtA     = bin2dec(subframe(151:174))*2^(-11);
                alm.a1        = twosComp2dec(subframe(279:289))*2^(-38);
                alm.a0        = twosComp2dec([subframe(271:278) subframe(290:292)])*2^(-20);
                alm.omega0    = twosComp2dec(subframe(181:204))*2^(-23) * Pi;
                alm.deltai    = twosComp2dec(subframe(99:114))*2^(-19) * Pi;
                alm.e         = bin2dec(subframe(69:84))*2^(-21);
                alm.toa       = bin2dec(subframe(91:98))*2^12;
                alm.omega     = twosComp2dec(subframe(211:234))*2^(-23) * Pi;
                alm.omegaDot  = twosComp2dec(subframe(121:136))*2^(-38) * Pi;
                alm.M0        = twosComp2dec(subframe(241:264))*2^(-23) * Pi;
            case 51
                health(1) = bin2dec(subframe(91:96));
                health(2) = bin2dec(subframe(97:102));
                health(3) = bin2dec(subframe(103:108));
                health(4) = bin2dec(subframe(109:114));
                health(5) = bin2dec(subframe(121:126));
                health(6) = bin2dec(subframe(127:132));
                health(7) = bin2dec(subframe(133:138));
                health(8) = bin2dec(subframe(139:144));
                health(9) = bin2dec(subframe(151:156));
                health(10)= bin2dec(subframe(157:162));
                health(11)= bin2dec(subframe(163:168));
                health(12)= bin2dec(subframe(169:174));
                health(13)= bin2dec(subframe(181:186));
                health(14)= bin2dec(subframe(187:192));
                health(15)= bin2dec(subframe(193:198));
                health(16)= bin2dec(subframe(199:204));
                health(17)= bin2dec(subframe(211:216));
                health(18)= bin2dec(subframe(217:222));
                health(19)= bin2dec(subframe(223:228));
                health(20)= bin2dec(subframe(229:234));
                health(21)= bin2dec(subframe(241:246));
                health(22)= bin2dec(subframe(247:252));
                health(23)= bin2dec(subframe(253:258));
                health(24)= bin2dec(subframe(259:264));
                WNa = bin2dec(subframe(77:84));
                
        end  %switch subframeID
        
end % switch subframeID ...

end