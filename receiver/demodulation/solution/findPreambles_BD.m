function [frameSync,firstSubFrame,SOW1] = findPreambles_BD(buffer,sv,recv_cfg, track_cfg)
% findPreambles finds the first preamble occurrence in the bit stream of
% each channel. The preamble is verified by check of the spacing between
% preambles (6sec) and parity checking of the first two words in a
% subframe. At the same time function returns list of channels, that are in
% tracking state and with valid preambles in the nav data stream.
%
%[firstSubFrame, activeChnList] = findPreambles(trackResults, recv_cfg)
%
%   Inputs:
%       trackResults    - output from the tracking function
%       recv_cfg        - Receiver recv_cfg.
%
%   Outputs:
%       firstSubframe   - the array contains positions of the first
%                       preamble in each channel. The position is ms count 
%                       since start of tracking. Corresponding value will
%                       be set to 0 if no valid preambles were detected in
%                       the channel.
%       activeChnList   - list of channels containing valid preambles

%--------------------------------------------------------------------------
%                           SoftGNSS v3.0
% 
% Copyright (C) Darius Plausinaitis, Peter Rinder and Nicolaj Bertelsen
% Written by Darius Plausinaitis, Peter Rinder and Nicolaj Bertelsen
%--------------------------------------------------------------------------
%
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

% CVS record:
% $Id: findPreambles.m,v 1.1.2.10 2006/08/14 11:38:22 dpl Exp $

% Preamble search can be delayed to a later point in the tracking results
% to avoid noise due to tracking loop transients 
searchStartOffset = 50;
%--- Initialize the firstSubFrame array -----------------------------------
firstSubFrame = zeros(1, recv_cfg.numberOfChannels);
frameSync = 0;
%--- Generate the preamble pattern ----------------------------------------
%preamble_bits = [1 -1 -1 -1 1 -1 1 1];
preamble_bits = [1 1 1 -1 -1 -1 1 -1 -1 1 -1];
subframeBit = 300;
% "Upsample" the preamble - make 20 vales per one bit. The preamble must be
% found with precision of a sample.
% %% decide GEO and NGEO sat
% corrPerBit_NGEO = track_cfg.NGEO.corrPerBit;
% preamble_ms_NGEO = kron(preamble_bits, ones(1, corrPerBit_NGEO));
% preambleThreshold_NGEO  = corrPerBit_NGEO * (length(preamble_bits)-0.5);
% % GEO
% corrPerBit_GEO = track_cfg.GEO.corrPerBit;
% preamble_ms_GEO = kron(preamble_bits, ones(1, corrPerBit_GEO));
% preambleThreshold_GEO  = corrPerBit_GEO * (length(preamble_bits)-0.5);
% corrPerBit_NGEO = track_cfg.NGEO.corrPerBit;
% preamble_ms_NGEO = kron(preamble_bits, ones(1, corrPerBit_NGEO));
% preambleThreshold_NGEO  = corrPerBit_NGEO * (length(preamble_bits)-0.5);
%--- Make a list of channels excluding not tracking channels --------------
% activeChnList = find([trackResults.status] ~= '-');
% activeChnList_NGEO = find([trackResults.status] ~= '-'&[trackResults.sv]>5);
% activeChnList_GEO = find([trackResults.status] ~= '-'&[trackResults.sv]<=5);
%% === For all tracking channels ...
    corrPerBit = track_cfg.corrPerBit;
    preamble_ms =  kron(preamble_bits, ones(1, corrPerBit));
    preambleThreshold = corrPerBit * (length(preamble_bits)-0.5);
%% Correlate tracking output with preamble ================================
    % Read output from tracking. It contains the navigation bits. The start
    % of record is skiped here to avoid tracking loop transients.
    allbits = buffer(1 + searchStartOffset : end);
    % Now threshold the output and convert it to -1 and +1 
    allbits(allbits > 0)  =  1;
    allbits(allbits <= 0) = -1;
    % Correlate tracking output with the preamble
    tlmXcorrResult = xcorr(allbits, preamble_ms);
%% Find all starting points off all preamble like patterns ================
    clear index
    clear index2

    xcorrLength = (length(tlmXcorrResult) +  1) /2;

    %--- Find at what index/ms the preambles start ------------------------
    index = find(...
        abs(tlmXcorrResult(xcorrLength : xcorrLength * 2 - 1)) > preambleThreshold)' + ...
        searchStartOffset;
%% Analyze detected preamble like patterns ================================
%% 1.find if BCH is rigth
for  i = 1:size(index) % For each occurrence
%--- Group every 20 or other vales of bits into columns ------------------------
    bits = buffer(index(i):index(i) + 60*track_cfg.corrPerBit -1); % cut out one word
    bits = reshape(bits, track_cfg.corrPerBit, ...
        (size(bits, 2) / track_cfg.corrPerBit));
    %--- Sum all samples in the bits to get the best estimate -------------
    navBits = sum(bits, 1);
    %--- Now threshold and make 1 and 0 -----------------------------------
    % The expression (navBits > 0) returns an array with elements set to 1
    % if the condition is met and set to 0 if it is not met.
    navBits = (navBits > 0);
    %--- Convert from decimal to binary -----------------------------------
    % The function ephemeris expects input in binary form. In Matlab it is
    % a string array containing only "0" and "1" characters.
    if( navBits(1:11) == [0 0 0 1 1 1 0 1 1 0 1])
        bits=not(navBits);
    else
        bits=navBits;
    end
    [outbits,flag] = decode_60bits(bits);
    if flag == 0; % BCH is Right
%% 2.find if FraID and SOW range is right
      bits=char(outbits+'0');
      %=== Decode FeaID of the sub-frame ====================
      FraID = bin2dec(bits(16:18));
      %=== Decode SOW of the first sub-frame ================
      SOW = bin2dec([bits(19:26) bits(31:42)]);
      if (FraID>0) && (FraID<6) && (SOW>=0) && (SOW<=604800)
%           index = index(i:end);
%% 3.find if the next subframe's pream word is rigth
          index2 = index - index(i);

        if (~isempty(find(index2 == subframeBit*corrPerBit)))

            %=== Re-read bit vales for preamble verification ==============
            % Preamble occurrence is verified by checking the parity of
            % the first two words in the subframe. Now it is assumed that
            % bit boundaries a known. Therefore the bit values over 20ms are
            % combined to increase receiver performance for noisy signals.      
            bits = buffer(index(i)-2*corrPerBit : ...
                                               index(i) + corrPerBit * 60 -1)';

            %--- Combine the 20 values of each bit ------------------------
            bits = reshape(bits, corrPerBit, (size(bits, 1) / corrPerBit));
            bits = sum(bits);
            % Now threshold and make it -1 and +1 
            bits(bits > 0)  = 1;
            bits(bits <= 0) = -1;              
            firstSubFrame = index(i);
            if sv <= 5;
                SOW1 = SOW+ (FraID - 1)*0.6;%save SOW information GEO
            else
                SOW1 = SOW;%save SOW information NGEO
            end
            break;              
        end % if (~isempty(find(index2 == subframeBit*corrPerBit)))
      end %(FraID>0) && (FraID<6) && (SOW>=0) && (SOW<=604800)
    end %flag == 0 BCH 
end %for  i = 1:size(index)
%%
    % Exclude channel from the active channel list if no valid preamble was
    % detected
    if firstSubFrame == 0        
        % Exclude channel from further processing. It does not contain any
        % valid preamble and therefore nothing more can be done for it.
%         activeChnList = setdiff(activeChnList, channelNr);
        SOW1 = 0;
        disp(['Could not find valid preambles in channel!']);
    else
        frameSync = 1;
%         frameSync = 0; %FOR TEST
    end
end %function