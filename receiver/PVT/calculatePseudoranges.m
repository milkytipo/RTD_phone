function pseudoranges = calculatePseudoranges(transmitTime, rxTime, channelList)
%calculatePseudoranges finds relative pseudoranges for all satellites
%listed in CHANNELLIST at the specified millisecond of the processed
%signal. The pseudoranges contain unknown receiver clock offset. It can be
%found by the least squares position search procedure.
%
% function pseudoranges = calculatePseudoranges(...
%                         transmitTime,rxTime,channelList,settings)
%
%   Inputs:
%       transmitTime    - transmitting time all satellites on the list
%       rxTime          - receiver time 
%       channelList     - list of channels to be processed
%       settings        - receiver settings
%
%   Outputs:
%       pseudoranges    - relative pseudoranges to the satellites.
%--------------------------------------------------------------------------
%--- Set initial travel time to infinity ----------------------------------
% Later in the code a shortest pseudorange will be selected. Therefore
% pseudoranges from non-tracking channels must be the longest - e.g.
% infinite.
travelTime = zeros(1, 32);
c = 299792458;    % The speed of light, [m/s]
    
for Nr = 1:length(channelList(2,:))
     %--- Compute the travel times ----
    travelTime_Nr = rxTime - transmitTime(channelList(2, Nr));
    travelTime(channelList(2, Nr)) = check_t(travelTime_Nr);
end


%--- Convert travel time to a distance ------------------------------------
% The speed of light must be converted from meters per second to meters
% per millisecond.
pseudoranges    = travelTime * c;