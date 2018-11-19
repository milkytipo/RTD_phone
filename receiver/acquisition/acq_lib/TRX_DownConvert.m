
function [DNCSig,LO1_CarPhs] = TRX_DownConvert(IFSig,LO1_IF0,LO1_CarPhs,fs)

N = length(IFSig);

indx = mod(LO1_CarPhs + (0:N-1)'*LO1_IF0/fs, 1);

i_lo = cos(2*pi*indx);

q_lo = -sin(2*pi*indx);

LO1_CarPhs = mod(LO1_CarPhs + N*LO1_IF0/fs, 1);

DNCSig = IFSig.*(i_lo + 1i*q_lo);