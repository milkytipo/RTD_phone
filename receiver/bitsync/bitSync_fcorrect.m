function [ fcorrect] = bitSync_fcorrect(array,bitSync, bitSyncResults )
%BITSYNC_FCORRECT 
%   Detailed explanation goes here
frange = bitSync.frange;
fbin = bitSync.fbin; 
fnum = frange/fbin + 1;
bitIdx = bitSyncResults.bitIdx;
freq_idx = bitSyncResults.freqIdx;
if freq_idx > 1 && freq_idx < (fnum)
 a = array(bitIdx,freq_idx-1);
 c = array(bitIdx,freq_idx);
 b = array(bitIdx,freq_idx+1);
 if a>=b
     x = (c - a)/(c - b)*fbin;
     fcorrect = (x - fbin)/2;
 else
     x = (c - b)/(c - a)*fbin;
    fcorrect = (fbin - x)/2;
 end
else
    fcorrect = 0;
end
end

