%% Receiver start up operations according to the start mode.
function [receiver] = StartReceiver(receiver)
% Inout
% receiver             - the receiver structure

switch receiver.config.recvConfig.startMode
    case 'COLD_START'
        receiver = ColdStartIni(receiver);
    case 'WARM_START'
        receiver = WarmStartIni(receiver); % TODO
    case 'HOT_START'
        receiver = HotStartIni(receiver); % Haven't defined    
    otherwise
        error('Start mode is not defined yet!');
end