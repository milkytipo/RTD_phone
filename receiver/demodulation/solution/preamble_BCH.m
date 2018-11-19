function [ outbits,flag ] = preamble_BCH( bits )
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
if (bits(1:11)==[0 0 0 1 1 1 0 1 1 0 1]) | ( bits(1:11) == [1 1 1 0 0 0 1 0 0 1 0])
    preamble_flag = 0;
    if (bits(1:11) == [0 0 0 1 1 1 0 1 1 0 1])
        bits = not(bits);
    end
    % decode BCH
    [outbits,BCH_flag] = decode_onesubframe(bits(1:300));
    if BCH_flag == 1;
        disp('NAVBIT have wrong bits,need BCH correction');
    end
else
    preamble_flag = 1;
    disp('preamble is wrong!');
end

flag = preamble_flag | BCH_flag;

if flag == 1
    disp('preamble or BCH verification is failed!');
end

end

