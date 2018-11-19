%% Read info from almanac struct in receiver struct
function [visibleList, dopFreq] = ReadAlmanac(almanac, syst, config, elapseTime)

visibleList = [];
dopFreq = [];

% 3 priori informations are needed: position, time, almanac
if ~isempty(config.truePosition) && (config.trueTime ~= -1)

    prePos = config.truePosition'; % Reference position
    recvRefTime = config.skipTime + config.trueTime + elapseTime; % Reference time

    % Calculate satellites' position and velocity
    [satPos, satEl] = calSatPos2(syst, prePos, recvRefTime, almanac); % 
    visibleList = find(satEl > config.elevationMask); % Get PRN ID of visible satellites
    if ~isempty(visibleList)
        satPosVisible = satPos(visibleList,:);
        dopFreq = calcfrerange(syst, satPosVisible', prePos, visibleList); % An array
    end
end

end