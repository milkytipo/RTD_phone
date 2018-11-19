function [ outbits,flag ] = preable_OddEven( bits )
% this fuction is to verify the trackresults after TOWsync

%input : bits from tracking results,size is 300bits,one subframe
%putput:
%flag: when flag is 0 , then preamble and BCH is rigth
%output the BCH decode bits
%outbits,size is 300
outbits = zeros(1,300);
%  change trackresults into bits stream
bits = (bits>0);
% preamble verification
if (bits(1:8)==[0 1 1 1 0 1 0 0]) | ( bits(1:8) == [1 0 0 0 1 0 1 1])
    preamble_flag = 0;
    if (bits(1:8) == [0 1 1 1 0 1 0 0])
        bits = not(bits);
    end
    % decode BCH
    [outbits, GPS_flag] = decode_GPS(bits(1:300));
    if GPS_flag == 1;
        disp('NAVBIT have wrong bits,need correction');
    end
else
    preamble_flag = 1;
    disp('preamble is wrong!');
end

flag = preamble_flag | GPS_flag;

if flag == 1
    disp('preamble or GPS verification is failed!');
end

end

