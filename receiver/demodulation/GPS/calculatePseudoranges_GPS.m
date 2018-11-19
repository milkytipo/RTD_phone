function pseudoranges = calculatePseudoranges_GPS(transmitTime,rxTime,channelList)
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
% Copyright (C) D.M.Akos
% Written by Darius Plausinaitis
% Modified by Xiaofan Li at University of Colorado at Boulder
%--------------------------------------------------------------------------
%This program is free software; you can redistribute it and/or
%modify it under the terms of the GNU General Public License
%as published by the Free Software Foundation; either version 2
%of the License, or (at your option) any later version.
%
%This program is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.
%
%You should have received a copy of the GNU General Public License
%along with this program; if not, write to the Free Software
%Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
%USA.
%--------------------------------------------------------------------------
%--- Set initial travel time to infinity ----------------------------------
% Later in the code a shortest pseudorange will be selected. Therefore
% pseudoranges from non-tracking channels must be the longest - e.g.
% infinite.
travelTime = zeros(1, 32);
c = 299792458;    % The speed of light, [m/s]
    
%--- For all channels in the list ...
for i = 1:32
    
    %--- Compute the travel times -----------------------------------------
    if transmitTime(i)~=0
        travelTime(i) = rxTime-transmitTime(i);
    end
end

%--- Convert travel time to a distance ------------------------------------
% The speed of light must be converted from meters per second to meters
% per millisecond.
pseudoranges    = travelTime * c;