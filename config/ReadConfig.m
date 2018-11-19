%% Read config from external .conf file.
% Config file should accord with definite format requirements, this function corresponds to version 0.2.
function [constants, receiver] = ReadConfig(fileName, constants, receiver)

fid = fopen(fileName);
if fid == -1
    error('Config file isn''t existed!');
end

% Format check
configHeader = '######### CONFIGURATION FILE FOR GSARX #########';
configFooter = '######### END OF CONFIG #########';
line = fgetl(fid);
if ~strcmp(line, configHeader)
    error('Config file''s format is wrong!');
end

lineNo = 89; % Realated with config file format

for lineCnt = 2:lineNo
    
    line = fgetl(fid);
     
    if line == -1
        error('Config file''s format is wrong!'); % Config file is incomplete
    end
    
    switch lineCnt
        % Basic config
        case 12
            receiver.syst = line;
        case 15
            receiver.config.startMode = line;
        case 18
            receiver.config.positionType = str2double(line);
        case 21
            receiver.pvtCalculator.diffFile = line;
        % Signal file config
        case 25
            constants.STR_RECV.datafilename = line;
        case 28
            constants.STR_RECV.IF = str2double(line);
        case 31
            constants.STR_RECV.RECV_fs0 = str2double(line);
            constants.STR_RECV.fs = constants.STR_RECV.RECV_fs0 + constants.STR_RECV.RECV_fs_offset;
        case 34
            constants.STR_RECV.dataType = line;
        case 37
            constants.STR_RECV.IQForm = line;
        case 40
            constants.STR_RECV.bpSampling_OddFold = str2double(line);
        % Receiver config
        case 44
            receiver.config.skipTime = str2double(line);
        case 47
            receiver.config.runTime = str2double(line);
        case 50
            receiver.config.isStoreResult = str2double(line);
        case 53
            receiver.config.logFilePath = line;
        case 56
            receiver.config.visibleSatellites = str2num(line);
        case 59
            receiver.config.numberOfChannels = str2double(line);
        % Multipath detection config
        case 63
            receiver.channels.STR_CAD.CADLL_MODE = line;
        case 66
            receiver.channels.STR_CAD.CadUnitMax = str2double(line);
        case 69
            receiver.channels.STR_CAD.MONI_TYPE = line;
        % Multipath detection threshold config
        case 73
            receiver.channels.STR_CAD.CodPhsLagThre2 = str2double(line);
        case 76
            receiver.channels.STR_CAD.SNRThre1 = str2double(line);
        case 77
            receiver.channels.STR_CAD.SNRThre2 = str2double(line);
        case 78
            receiver.channels.STR_CAD.SNRThre3 = str2double(line);
        case 79
            receiver.channels.STR_CAD.SNRThre4 = str2double(line);
        case 82
            receiver.channels.STR_CAD.ADevThre = str2double(line);
        case 85
            receiver.channels.STR_CAD.AThreLow1 = str2double(line);
        case 86
            receiver.channels.STR_CAD.AThreLow2 = str2double(line);
        case 87
            receiver.channels.STR_CAD.AThreLow3 = str2double(line);
    end
    
end

if ~strcmp(line, configFooter)
    error('Config file''s format is wrong!');
end

fclose(fid);

end