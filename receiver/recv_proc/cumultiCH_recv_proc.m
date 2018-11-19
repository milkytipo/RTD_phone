function receiver = cumultiCH_recv_proc(receiver, sis, N)

%！！！！！！！！！！！！！！  嬉咫寮佛彜蓑佚連  ！！！！！！！！！！！！！！%
fid_0 = fopen(receiver.recvRecor.recvStatuslogName, 'at');
fprintf('/----------------------------------------------------------------------------------------------/\n');
fprintf('CHANNELS RUNNING INFO: RunLoop: #%d, DataTime: %fsec, recvSOW: %fsec, Time: %2.2d:%2.2d:%f\n', ...
    receiver.Loop, receiver.Trun, receiver.timer.recvSOW, receiver.timer.hour, receiver.timer.min, receiver.timer.sec);

fprintf(fid_0, '/----------------------------------------------------------------------------------------------/\n');
fprintf(fid_0,'CHANNELS RUNNING INFO: RunLoop: #%d, DataTime: %fsec, recvSOW: %fsec, Time: %2.2d:%2.2d:%f\n', ...
    receiver.Loop, receiver.Trun, receiver.timer.recvSOW, receiver.timer.hour, receiver.timer.min, receiver.timer.sec);

for i = 1:receiver.config.recvConfig.numberOfChannels(1).channelNumAll
    switch receiver.channels(i).SYST
        case 'BDS_B1I'
            channel = receiver.channels(i).CH_B1I(1);
        case 'GPS_L1CA'
            channel = receiver.channels(i).CH_L1CA(1);
        case 'GPS_L1CA_L2C'
            channel = receiver.channels(i).CH_L1CA_L2C(1);
    end
    fprintf('  CH%2.2d:  %-12s,  PRN%2.2d,  %-15s,  FrameS:%-22s,  CN0:%5.2fdB,  UnitNum:%d\n', i, receiver.channels(i).SYST, channel.PRNID, receiver.channels(i).STATUS, ...
        channel.Frame_Sync, channel.CN0_Estimator.CN0(1), receiver.channels(i).STR_CAD.CadUnit_N);
    
    %Write receiver status logFile
    fprintf(fid_0, '  CH%2.2d:  %-12s,  PRN%2.2d,  %-15s,  FrameS:%-22s,  CN0:%5.2fdB,  UnitNum:%d\n', i, receiver.channels(i).SYST, channel.PRNID, receiver.channels(i).STATUS, ...
        channel.Frame_Sync, channel.CN0_Estimator.CN0(1), receiver.channels(i).STR_CAD.CadUnit_N);
end
fprintf('  \n');
fprintf(fid_0, '  \n');
fclose(fid_0);


%！！！！！！！！！！！！！！！ 俺資庁翠 ！！！！！！！！！！！！！！%
[receiver.acqCHTable, receiver.channels] = acquire(receiver.config, receiver.acqCHTable, receiver.channels, receiver.satelliteTable, sis, N, receiver.device.usingMatlabAcq, receiver.device.acq_gpuExist);

%！！！！！！！！！！！！！！！ 俺資潤惚紙夕 ！！！！！！！！！！！！！！%
if (receiver.config.logConfig.isAcqPlotMesh == 1)&&(receiver.device.usingMatlabAcq == 0)
    
    allChannel_acq_plot(receiver,receiver.device.acq_gpuExist);
    
end

% ！！！！！！！！！！！！！！！曳蒙揖化庁翠！！！！！！！！！！！！！！！%
receiver.channels = bitSync(receiver.config, receiver.channels, sis, N);

% ！！！！！！！！！！！！！！！！効忸庁翠！！！！！！！！！！！！！！%
receiver.channels = tracking(receiver.config, receiver.channels, receiver.recorder, sis, N, receiver.device.gpuExist, receiver.pvtCalculator, receiver.Trun);

% ！！！！！！！！！！！！！！！擬砂窮猟盾距！！！！！！！！！！！！%
receiver = demodulation(receiver);

% ！！！！！！！！！！！！！！！！鮫夕！！！！！！！！！！！！！！！！%
for n = 1:receiver.config.recvConfig.numberOfChannels(1).channelNumAll
    if receiver.config.logConfig.isTrackPlot
        if strcmp(receiver.channels(n).STATUS, 'PULLIN') || ...
                strcmp(receiver.channels(n).STATUS, 'TRACK') || ...
                strcmp(receiver.channels(n).STATUS, 'SUBFRAME_SYNCED') || ...
                strcmp(receiver.channels(n).STATUS, 'HOT_PULLIN')
            PlotTrackResults(receiver.recorder(n), receiver.channels(n).SYST, receiver.channels(n), receiver.timer);   
        end
    end
end

% ！！！！！！ 厚仟辛喘噐協了潤麻議嗤丼宥祇双燕！！！！！！！！！！！！%
receiver = actvChns_get(receiver);

% ！！！！！！俊辺字云仇扮嶝厚仟！！！！！！！！！！！！！！！！！！%
receiver = timer_Updating(receiver, N);

% ！！！！！！！！！！！！！！！PVT盾麻！！！！！！！！！！！！！！！！%
receiver = positioning(receiver);

% ！！！！！！！！！！！！！！宥祇彜蓑厚仟！！！！！！！！！！！！！！%
[receiver] = UpdateReceiver_new(receiver, N);

%！！！！！！！！！！！！！！嬉咫LOG佚連！！！！！！！！！！！！！！%
receiver = logFileOutput(receiver);

% if receiver.pvtCalculator.dataNum == 0
%     if receiver.config.recvConfig.positionType == 1
%         [receiver.timer, receiver.ephemeris, receiver.pvtCalculator, receiver.config] = ...
%             pointPos(receiver.syst, receiver.channels, receiver.config, receiver.timer, receiver.ephemeris, receiver.pvtCalculator, receiver.actvPvtChannels);
%     end
% end

end % EOF: function




