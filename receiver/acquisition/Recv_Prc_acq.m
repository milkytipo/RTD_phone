function [] = Recv_Prc_acq(SYST, IFSig, STR_RECV, fs, N)
%Functio Discription: Acquisition engine.
%Input:
% SYST            -Signal system definition
% BsSig           -baseband signal
% STR_RECV        -receiver channel struct
% fs              -sampling frequency
% N               -number of samples in BsSig
%Output:
%

switch SYST
    case 'GPS_L2C'
        L2C_acq(IFSig, STR_RECV.CH_L2C, fs, N);
end