function [alm,subframeID, pagenum, health, WNa] = ephemeris_d1_alm(bits) %NGEO 

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
    subframeID = bin2dec(subframe(16:18));
    pagenum=0;
    %--- Decode sub-frame based on the sub-frames id ----------------------
    % The task is to select the necessary bits and convert them to decimal
    % numbers. For more details on sub-frame contents please refer to GPS
    % ICD (IS-GPS-200D).
    switch subframeID
        case 4  %--- It is subframe 1 -------------------------------------
            % It contains WN, SV clock corrections, health and accuracy
            pagenum = bin2dec(subframe(44:50)); 
            SOW        = bin2dec([subframe(19:26)  ...
                            subframe(31:42)]);
            alm.sqrtA  = bin2dec([subframe(51:52)  ...
                             subframe(61:82)])*2^(-11); 
            alm.a1        = twosComp2dec(subframe(91:101))*2^(-38);
            alm.a0        = twosComp2dec(subframe(102:112))*2^(-20);
            alm.omega0    = twosComp2dec([subframe(121:142)  ...
                             subframe(151:152)])*2^(-23) * Pi;
            alm.deltai    = twosComp2dec([subframe(170:172)  ...
                              subframe(181:193)])*2^(-19) * Pi;
            alm.e         = bin2dec(subframe(153:169))*2^(-21);
            alm.toa       = bin2dec(subframe(194:201))*2^12;
            alm.omegaDot  = twosComp2dec([subframe(202)  ...
                              subframe(211:226)])*2^(-38) * Pi;
            alm.omega     = twosComp2dec([subframe(227:232)  ...
                              subframe(241:258)])*2^(-23) * Pi;
            alm.M0        = twosComp2dec([subframe(259:262)  ...
                              subframe(271:290)])*2^(-23) * Pi;  
        case 5  %--- It is subframe 2 -------------------------------------
            % It contains first part of ephemeris parameters
            SOW        = bin2dec([subframe(19:26)  ...
                            subframe(31:42)]);
            pagenum = bin2dec(subframe(44:50));
           switch pagenum
               case {1,2,3,4,5,6}
                alm.sqrtA  = bin2dec([subframe(52:53)  ...
                                 subframe(61:82)])*2^(-11); 
                alm.a1        = twosComp2dec(subframe(91:101))*2^(-38);
                alm.a0        = twosComp2dec(subframe(102:112))*2^(-20);
                alm.omega0    = twosComp2dec([subframe(121:142)  ...
                                 subframe(151:152)])*2^(-23) * Pi;
                alm.deltai    = twosComp2dec([subframe(170:172)  ...
                                  subframe(181:193)])*2^(-19) * Pi;
                alm.e         = bin2dec(subframe(153:169))*2^(-21);
                alm.toa       = bin2dec(subframe(194:201))*2^12;
                alm.omegaDot  = twosComp2dec([subframe(202)  ...
                                  subframe(211:226)])*2^(-38) * Pi;
                alm.omega     = twosComp2dec([subframe(227:232)  ...
                                  subframe(241:258)])*2^(-23) * Pi;
                alm.M0        = twosComp2dec([subframe(259:262)  ...
                                  subframe(271:290)])*2^(-23) * Pi;  
               case 7
                 health(1) = bin2dec([subframe(51:52)  subframe(61:67)]);
                 health(2) = bin2dec(subframe(68:76));
                 health(3) = bin2dec([subframe(77:82)  subframe(91:93)]);
                 health(4) = bin2dec(subframe(94:102));
                 health(5) = bin2dec(subframe(103:111));
                 health(6) = bin2dec([subframe(112)  subframe(121:128)]);
                 health(7) = bin2dec(subframe(129:137));
                 health(8) = bin2dec([subframe(138:142)  subframe(151:154)]);
                 health(9) = bin2dec(subframe(155:163));
                 health(10)= bin2dec(subframe(164:172));
                 health(11)= bin2dec(subframe(181:189));
                 health(12)= bin2dec(subframe(190:198));
                 health(13)= bin2dec([subframe(199:202)  subframe(211:215)]);
                 health(14)= bin2dec(subframe(216:224));
                 health(15)= bin2dec([subframe(225:232)  subframe(241)]);
                 health(16)= bin2dec(subframe(242:250));
                 health(17)= bin2dec(subframe(251:259));
                 health(18)= bin2dec([subframe(260:262)  subframe(271:276)]);
                 health(19)= bin2dec(subframe(277:285));
               case 8
                 health(20)= bin2dec([subframe(51:52)  subframe(61:67)]);
                 health(21)= bin2dec(subframe(68:76));
                 health(22)= bin2dec([subframe(77:82)  subframe(91:93)]);
                 health(23)= bin2dec(subframe(94:102));
                 health(24)= bin2dec(subframe(103:111));
                 health(25)= bin2dec([subframe(112)  subframe(121:128)]);
                 health(26)= bin2dec(subframe(129:137));
                 health(27)= bin2dec([subframe(138:142)  subframe(151:154)]);
                 health(28)= bin2dec(subframe(155:163));
                 health(29)= bin2dec(subframe(164:172));
                 health(30)= bin2dec(subframe(181:189));
                 WNa  = bin2dec(subframe(190:197));
           end  %switch subframeID

    end % switch subframeID ... 

end