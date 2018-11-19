function [acqCHTable, channels] = acquireCHTable_scheduler(config, acqCHTable, channels, N)
%-------------------实现北斗捕获列表调度-------------------------%
for n = 1:config.recvConfig.numberOfChannels(1).channelNum
    switch channels(n).STATUS
        case {'COLD_ACQ', 'COLD_ACQ_AGAIN'}
            if ~ismember(n, acqCHTable(1).coldAcqCHWaitList)
%                 acqCHTable(1).acqCHWaitNum = acqCHTable(1).acqCHWaitNum + 1;
%                 acqCHTable(1).acqCHWaitList(acqCHTable(1).acqCHWaitNum) = n;
                  acqCHTable(1).coldAcqCHWaitNum = acqCHTable(1).coldAcqCHWaitNum + 1;
                  acqCHTable(1).coldAcqCHWaitList(acqCHTable(1).coldAcqCHWaitNum) = n;
            end
        case {'HOT_ACQ'}
            if ~ismember(n, acqCHTable(1).hotAcqCHWaitList)
%                 acqCHTable(1).acqCHWaitNum = acqCHTable(1).acqCHWaitNum + 1;
%                 acqCHTable(1).acqCHWaitList = circshift(acqCHTable(1).acqCHWaitList,1,2);
%                 acqCHTable(1).acqCHWaitList(1) = n;
                  acqCHTable(1).hotAcqCHWaitNum = acqCHTable(1).hotAcqCHWaitNum + 1;
                  acqCHTable(1).hotAcqCHWaitList(acqCHTable(1).hotAcqCHWaitNum) = n;
            end
        case {'HOT_ACQ_WAIT'}
            channels(n).CH_B1I.acq.TimeLen = N;
    end
end

%-------------------实现GPS捕获列表调度-------------------------%
for n = config.recvConfig.numberOfChannels(1).channelNum+1 : config.recvConfig.numberOfChannels(1).channelNumAll
    switch channels(n).STATUS
        case {'COLD_ACQ', 'COLD_ACQ_AGAIN'}
            if ~ismember(n, acqCHTable(2).coldAcqCHWaitList)
%                 acqCHTable(2).acqCHWaitNum = acqCHTable(2).acqCHWaitNum + 1;
%                 acqCHTable(2).acqCHWaitList(acqCHTable(2).acqCHWaitNum) = n;
                  acqCHTable(2).coldAcqCHWaitNum = acqCHTable(2).coldAcqCHWaitNum + 1;
                  acqCHTable(2).coldAcqCHWaitList(acqCHTable(2).coldAcqCHWaitNum) = n;
            end
        case {'HOT_ACQ'}
            if ~ismember(n, acqCHTable(2).hotAcqCHWaitList)
%                 acqCHTable(2).acqCHWaitNum = acqCHTable(2).acqCHWaitNum + 1;
%                 acqCHTable(2).acqCHWaitList = circshift(acqCHTable(2).acqCHWaitList,1,2);
%                 acqCHTable(2).acqCHWaitList(1) = n;
                  acqCHTable(2).hotAcqCHWaitNum = acqCHTable(2).hotAcqCHWaitNum + 1;
                  acqCHTable(2).hotAcqCHWaitList(acqCHTable(2).hotAcqCHWaitNum) = n;
            end
        case {'HOT_ACQ_WAIT'}
            switch channels(n).SYST
                case 'GPS_L1CA'
                    channels(n).CH_L1CA.acq.TimeLen = N;
                case 'GPS_L1CA_L2C'
                    channels(n).CH_L1CA_L2C.acq.TimeLen = N;
            end
    end
end
