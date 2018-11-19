function [doubleDiff, pr_raw ,activeChannel, pvtCalculator] = PseudorangesofcarrDiff...
    (transmitTime, rxTime, activeChannel, inteDoppler, pvtCalculator, el)
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
    HatchValue = pvtCalculator.hatchValue;
    Diff_time = pvtCalculator.towSec;
    carri_error = pvtCalculator.carriError;
    travelTime = zeros(1, 30);
    carrierDiff = zeros(1, 30);
    doubleDiff = zeros(1, 30);
    c = 299792458;    % The speed of light, [m/s]  
    [~, column] = max(el(1,:));
    basePrn = el(2, column);    % 将仰角最高的卫星作为参考卫星
    pvtCalculator.doubleDiff.basePrn = basePrn;    % 保存参考卫星的卫星号    
    %--- For all channels in the list ...
    for i = 1:30
        %--- Compute the travel times -----------------------------------------
        if transmitTime(i)~=0
            travelTime(i) = rxTime-transmitTime(i);
        end
    end

    %--- Convert travel time to a distance ------------------------------------
    % The speed of light must be converted from meters per second to meters
    % per millisecond.
    pr_raw = travelTime * c;

    %% -------------------hatch滤波-------------------------
    
%     smint = 2;
%     if HatchValue(1,3) < 99999
%        HatchValue(1,3) = HatchValue(1,3) + 1;
%        pseudoranges = pr_diff;
%     else
%        [pseudoranges,HatchValue] = hatch_BD(pr_diff,InteDoppler,PRNList,smint,HatchValue);%载波相位平滑滤波
%     end    
%     DiffPara.HatchValue = HatchValue;
    
    %
%      pseudoranges = pr_diff; 
    %% -------------------减去误差-------------------------------------
    [~, column]=min(abs(Diff_time - rxTime));%计算离接收机接收时间最近的时间
      for ii = length(activeChannel(2,:)):-1:1
          if carri_error(column, activeChannel(2,ii)) == 0
              activeChannel(:,ii) = [];    %去除RINEX观测文件中没有的卫星
          end
      end
      PRNList = activeChannel(2,:);     
      for ii = 1:length(PRNList)
          carrierDiff(PRNList(ii)) = inteDoppler(PRNList(ii)) - carri_error(column, PRNList(ii));   % 计算载波相位站间单差
      end   
      for ii = 1:length(PRNList)
          if PRNList(ii) ~= basePrn
              doubleDiff(PRNList(ii)) = carrierDiff(PRNList(ii)) - carrierDiff(basePrn);    % 计算载波相位双差
          end
      end
 
 
end
