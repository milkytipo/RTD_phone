function [PEAK, PEAK_INDX] = Peak_srch(Accum, Ratio, NsFlr, Srh_span)
%Function discription: finding the peak from the correlation results
%Input
% Accum           -the magnitude vector of the correlation results;
% Ratio           -acquisition threshold;
% NsFlr           -noise floor;
% Srh_span        -foward search span in the case of non-return-to-zero
%                  local codes.
%Output
% PEAK            -Peak value;
% PEAK_INDX       -the peak value index.

PEAK = -1;
PEAK_INDX = -1;

[peak, index] = max(Accum);   % find out the maximum peak and its index

%if the peak/NsFlr is smaller than the Ratio, no signal is acquired
if (peak<Ratio*NsFlr)
    return
end

while( (Srh_span>0)&&(index>1) )
    
    Srh_span = Srh_span-1; 
    
    if ( Accum(index-1)>=Ratio*NsFlr )
        
        index = index - 1;
    else
        break;    
    end
end

PEAK_INDX = index;
PEAK = Accum(PEAK_INDX);
return;

