%% Read config from external .conf file.
% Configuration file should accord with definite format requirements.
% this function corresponds to version 0.1, please use the latest version.
function [strConstants, strReceiver] = ReadConfigv01(fileName, strConstants, strReceiver, level)

% fileName = '.\GSARx_v0.1.conf';

fid = fopen(fileName);
if fid == -1
    error('Configuration file is wrong!');
end

switch level
    case 1
        while 1
            line = fgetl(fid); % Get each line of configuration file.
            if line == -1
                break; % All lines have been read.
            end

            len = length(line);

            if len >= 8 && strcmp(line(1:4), 'SYST')
                strReceiver.syst = line(8:end);
            end

            if len >= 30 && strcmp(line(1:26), 'STR_Constants.STR_RECV.IF2')
                strConstants.STR_RECV.IF2 = str2double(line(30:end));
            end

            if len >= 35 && strcmp(line(1:31), 'STR_Constants.STR_RECV.RECV_fs0')
                strConstants.STR_RECV.RECV_fs0 = str2double(line(35:end));
            end

            if len >= 35 && strcmp(line(1:31), 'STR_Constants.STR_RECV.datatype')
                strConstants.STR_RECV.datatype = line(35:end);
            end

            if len >= 33 && strcmp(line(1:29), 'STR_Constants.STR_RECV.IQForm')
                strConstants.STR_RECV.IQForm = line(33:end);
            end

            if len >= 45 && strcmp(line(1:41), 'STR_Constants.STR_RECV.bpSampling_OddFold')
                strConstants.STR_RECV.bpSampling_OddFold = str2double(line(45:end));
            end

            if len >= 39 && strcmp(line(1:35), 'STR_Constants.STR_RECV.datafilename')
                strConstants.STR_RECV.datafilename = line(39:end);
            end
            
            if len >= 21 && strcmp(line(1:17), 'receiver.skipTime')
                strReceiver.skipTime = str2double(line(21:end));
            end
        end
    case 2
        while 1
            line = fgetl(fid); % Get each line of configuration file.
            if line == -1
                break; % All lines have been read.
            end

            len = length(line);

            if len >= 20 && strcmp(line(1:16), 'receiver.posType')
                strReceiver.recv_cfg.posType = str2double(line(20:end));
            end

            if len >= 35 && strcmp(line(1:31), 'receiver.recv_cfg.isStoreResult')
                strReceiver.recv_cfg.isStoreResult = str2double(line(35:end));
            end

            if len >= 17 && strcmp(line(1:13), 'debugfilepath')
                strReceiver.debugFilePath = line(17:end);
            end

            if len >= 23 && strcmp(line(1:19), 'receiver.runTimeLen')
                strReceiver.runTime = str2double(line(23:end));
            end

            if len >= 30 && strcmp(line(1:26), 'receiver.acq_cfg.svVisible')
                strReceiver.visibleSatellites = str2num(line(30:end));
            end

            if len >= 38 && strcmp(line(1:34), 'receiver.recv_cfg.numberOfChannels')
                strReceiver.recv_cfg.numberOfChannels = str2double(line(38:end));
            end
        end
    case 3
        while 1
            line = fgetl(fid); % Get each line of configuration file.
            if line == -1
                break; % All lines have been read.
            end

            len = length(line);

            if len >= 40 && strcmp(line(1:36), 'receiver.channels.STR_CAD.CADLL_MODE')
                strReceiver.channels(:).STR_CAD.CADLL_MODE = line(40:end);
            end

            if len >= 40 && strcmp(line(1:36), 'receiver.channels.STR_CAD.CadUnitMax')
                strReceiver.channels(:).STR_CAD.CadUnitMax = line(40:end);
            end

            if len >= 39 && strcmp(line(1:35), 'receiver.channels.STR_CAD.MONI_TYPE')
                strReceiver.channels(:).STR_CAD.MONI_TYPE = line(39:end);
            end
        end
end

fclose(fid);

end