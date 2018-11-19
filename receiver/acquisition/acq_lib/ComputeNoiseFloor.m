function [NsFloor]=ComputeNoiseFloor(Accum_Mag, window, DispFlag)
%Function discription: compute the noise floor using the results of
%correlation vector.
%Input:
% Accum_Mag            -the magnitude of the correlation results,a vector;
% window               -the window at both sides of the peak to be masked;
% DispFlag             -plotting flag.

Len = length(Accum_Mag);

MAX =max(Accum_Mag);

Pos=find(Accum_Mag==MAX, 1, 'first');

N = Len;

if Pos<=window
    
    Accum_Mag(1:Pos+window)=0;
    Accum_Mag(N-window+Pos:N)=0;
    
elseif Pos>N-window

    Accum_Mag(Pos-window:N)=0;
    Accum_Mag(1:window-N+Pos)=0;

else
    
    Accum_Mag(Pos-window:Pos+window)=0;
    
end

N=N-2*window-1;

NsFloor = sum(Accum_Mag)/N;

if NsFloor==0
    NsFloor = eps;
end

if strcmp(DispFlag,'DispYes')
    
    figure,plot(Accum_Mag);
    title('Noise Floor Plotting');
    
end


