%% Update receiver according to channels' info
function [receiver] = UpdateReceiver_new(receiver, N)

%------------ satelliteTable info updating -------------
receiver = satelliteTable_Updating(receiver, N);

%------------ channel info updating -------------
receiver = channel_Updating(receiver, N);

%------------ environment info recording -------------
receiver = environment_Updating(receiver);

%------------ channel scheduler -------------
receiver = channel_scheduler(receiver, N);
end