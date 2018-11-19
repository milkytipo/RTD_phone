function [prsm_new,value]=hatch_BD(pr,adr,svid,smint,value)
%HATCH		Perform carrier-smoothing of the pseudorange measurements
%               via the Hatch filter
%
%	[prsm,prmat,adrmat]=HATCH(pr,adr,svid,smint,prmat,adrmat)
%
%   INPUTS
%       pr = vector of measured pseudoranges for the current epoch
%	adr = vector of measured integrated Doppler for the current epoch
%	svid = vector of satellite id's corresponding to the measurements
%              in PR and ADR
%       smint = smoothing interval in seconds (must be an integer)
%       prmat = matrix of previous pseudorange values for all satellites.
%               When HATCH is first called, PRMAT and ADRMAT are set to [].
%               These matrices are updated by HATCH and output to the user
%               who must input them at the next epoch
%       adrmat = matrix of previous integrated Doppler values for
%                all satellites
%
%   OUTPUTS
%	prsm = vector of carrier-smoothed pseudoranges
%       prmat = updated matrix of previous pseudoranges
%       adrmat = updated matrix of previous integrated Doppler

%   Reference:  "The Synergism of GPS Code and Carrier Measurements,"
%               by Ron Hatch, Proceedings of the Third International
%               Geodetic Symposium on Satellite Doppler Positioning,
%               Las Cruces, NM, February 1982.
%
%	M. & S. Braasch 12-96
%	Copyright (c) 1996 by GPSoft
%	All Rights Reserved.
    prsm_new = zeros(30,1);
    for i = 1:length(svid)
        if value(svid(i),1)==0
            prsm_new(svid(i)) = pr(svid(i));
        else
            prsm_new(svid(i)) = pr(svid(i))/smint + ...
                (smint-1)/smint*(value(svid(i),1)+adr(svid(i))-value(svid(i),2)); 
        end
        value(svid(i),1) = prsm_new(svid(i));
        value(svid(i),2) = adr(svid(i));
    end
end