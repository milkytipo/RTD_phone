function [recv_channel] = bitSync_proc(config, recv_channel, sis, N)
global GSAR_CONSTANTS;

if strcmp(recv_channel.SYST, 'GPS_L1CA')
    
    [recv_channel.CH_L1CA, recv_channel.CH_L1CA.bitSync.bitSyncResults] = bitSyncGPS(config.logConfig, recv_channel.CH_L1CA, sis{GSAR_CONSTANTS.STR_RECV.dataSource_L1}, recv_channel.CH_L1CA.bitSync.bitSyncResults);  
    
    if (recv_channel.CH_L1CA.bitSync.bitSyncResults.synced==1)
        if recv_channel.CH_L1CA.bitSync.bitSyncID == 0
                recv_channel.CH_L1CA.LO2_fd = recv_channel.CH_L1CA.LO2_fd + recv_channel.CH_L1CA.bitSync.bitSyncResults.doppler;
                recv_channel.CH_L1CA.LO_Fcode_fd = recv_channel.bpSampling_OddFold * recv_channel.CH_L1CA.LO2_fd / GSAR_CONSTANTS.STR_L1CA.L0Fc0_R;
                recv_channel.CH_L1CA.LO_CodPhs = 0;
                recv_channel.CH_L1CA.Samp_Posi = recv_channel.CH_L1CA.Samp_Posi + round((recv_channel.CH_L1CA.bitSync.bitSyncResults.bitIdx - 1) * ...
                    GSAR_CONSTANTS.STR_L1CA.ChipNum / (recv_channel.CH_L1CA.LO_Fcode0 + recv_channel.CH_L1CA.LO_Fcode_fd) * GSAR_CONSTANTS.STR_RECV.fs);
                recv_channel.CH_L1CA.bitSync.TimeLen = recv_channel.CH_L1CA.bitSync.TimeLen + round((recv_channel.CH_L1CA.bitSync.bitSyncResults.bitIdx - 1) * ...
                    GSAR_CONSTANTS.STR_L1CA.ChipNum / (recv_channel.CH_L1CA.LO_Fcode0 + recv_channel.CH_L1CA.LO_Fcode_fd) * GSAR_CONSTANTS.STR_RECV.fs);
                recv_channel.CH_L1CA.Samp_Posi = recv_channel.CH_L1CA.Samp_Posi - recv_channel.CH_L1CA.bitSync.resiN;      % 扣除resiData中的数据点数
                recv_channel.CH_L1CA.bitSync.resiN = 0;
                recv_channel.CH_L1CA.bitSync.bitSyncID = 1;
        end
        if recv_channel.CH_L1CA.Samp_Posi > N
            if strcmp(recv_channel.STATUS, 'BIT_SYNC')
                recv_channel.STATUS = 'BIT_SYNC';
                recv_channel.CH_L1CA.Samp_Posi =  recv_channel.CH_L1CA.Samp_Posi - N;
            elseif strcmp(recv_channel.STATUS, 'HOT_BIT_SYNC')
                recv_channel.STATUS = 'HOT_BIT_SYNC';
                recv_channel.CH_L1CA.Samp_Posi =  recv_channel.CH_L1CA.Samp_Posi - N;
            end
        else
            if strcmp(recv_channel.STATUS, 'BIT_SYNC')
                recv_channel.STATUS = 'PULLIN';
                recv_channel.CH_L1CA.CH_STATUS = recv_channel.STATUS;
                % pull-in initialize
                recv_channel = pullin_ini(recv_channel);
                recv_channel = phase_ini(recv_channel);
            elseif strcmp(recv_channel.STATUS, 'HOT_BIT_SYNC')
                recv_channel.CH_L1CA.CH_STATUS = recv_channel.STATUS;
                % pull-in initialize
                recv_channel = track_ini(recv_channel);
                % 帧信息推算和校验
                [verify, recv_channel.CH_L1CA] = hotInfoCheck(recv_channel.CH_L1CA, recv_channel.CH_L1CA.bitSync.TimeLen, recv_channel.SYST,'BITSYNC');               
                % 各信息推算至数据头处
                recv_channel = track_phase_ini(recv_channel);
            end
            fprintf('                    GPS PRN%d bitSyncResults -- CodeIndx: %d ; bitIdx: %d ; Doppler: %.2fHz \n\n', ...
                recv_channel.CH_L1CA.PRNID, recv_channel.CH_L1CA.Samp_Posi, recv_channel.CH_L1CA.bitSync.bitSyncResults.bitIdx-1, recv_channel.bpSampling_OddFold*recv_channel.CH_L1CA.LO2_fd);
        end
    elseif (recv_channel.CH_L1CA.bitSync.bitSyncResults.synced == -1)
        recv_channel.STATUS = 'BIT_SYNC_FAIL';
        recv_channel.CH_L1CA.CH_STATUS = recv_channel.STATUS;
        recv_channel.CH_L1CA.Samp_Posi = 0;
    end

elseif strcmp(recv_channel.SYST, 'BDS_B1I')
    [recv_channel.CH_B1I, recv_channel.CH_B1I.bitSync.bitSyncResults] = bitSyncCOMPASS(config.logConfig, recv_channel.CH_B1I, sis{GSAR_CONSTANTS.STR_RECV.dataSource_B1}, recv_channel.CH_B1I.bitSync.bitSyncResults);  
    if (recv_channel.CH_B1I.bitSync.bitSyncResults.synced==1)
        if recv_channel.CH_B1I.bitSync.bitSyncID == 0       % 判断是否已计算出比特同步信息
            recv_channel.CH_B1I.LO2_fd = recv_channel.CH_B1I.LO2_fd + recv_channel.CH_B1I.bitSync.bitSyncResults.doppler;
            recv_channel.CH_B1I.LO_Fcode_fd = recv_channel.bpSampling_OddFold * recv_channel.CH_B1I.LO2_fd / GSAR_CONSTANTS.STR_B1I.L0Fc0_R;
            recv_channel.CH_B1I.LO_CodPhs = 0;
            recv_channel.CH_B1I.Samp_Posi = recv_channel.CH_B1I.Samp_Posi + round((recv_channel.CH_B1I.bitSync.bitSyncResults.bitIdx - 1) * ...
                GSAR_CONSTANTS.STR_B1I.ChipNum / (recv_channel.CH_B1I.LO_Fcode0 + recv_channel.CH_B1I.LO_Fcode_fd) * GSAR_CONSTANTS.STR_RECV.fs);
            recv_channel.CH_B1I.bitSync.TimeLen = recv_channel.CH_B1I.bitSync.TimeLen + round((recv_channel.CH_B1I.bitSync.bitSyncResults.bitIdx - 1) * ...
                    GSAR_CONSTANTS.STR_B1I.ChipNum / (recv_channel.CH_B1I.LO_Fcode0 + recv_channel.CH_B1I.LO_Fcode_fd) * GSAR_CONSTANTS.STR_RECV.fs);
            recv_channel.CH_B1I.Samp_Posi = recv_channel.CH_B1I.Samp_Posi - recv_channel.CH_B1I.bitSync.resiN;      % 扣除resiData中的数据点数
            recv_channel.CH_B1I.bitSync.resiN = 0;
            recv_channel.CH_B1I.bitSync.bitSyncID = 1;      % 已计算过上述信息则下次循环无需再次计算
        end
        if recv_channel.CH_B1I.Samp_Posi > N                % 判断采样点位置是否超出了总采样点数
            if strcmp(recv_channel.STATUS, 'BIT_SYNC')
                recv_channel.STATUS = 'BIT_SYNC';
                recv_channel.CH_B1I.Samp_Posi =  recv_channel.CH_B1I.Samp_Posi - N;
            elseif strcmp(recv_channel.STATUS, 'HOT_BIT_SYNC')
                recv_channel.STATUS = 'HOT_BIT_SYNC';
                recv_channel.CH_B1I.Samp_Posi =  recv_channel.CH_B1I.Samp_Posi - N;
            end
        else
            if strcmp(recv_channel.STATUS, 'BIT_SYNC')
                recv_channel.STATUS = 'PULLIN';
                recv_channel.CH_B1I.CH_STATUS = recv_channel.STATUS;
                % pull-in initialize
                recv_channel = pullin_ini(recv_channel);
                recv_channel = phase_ini(recv_channel);
            elseif strcmp(recv_channel.STATUS, 'HOT_BIT_SYNC')
                recv_channel.CH_B1I.CH_STATUS = recv_channel.STATUS;
                % pull-in initialize
                recv_channel = track_ini(recv_channel);
                % 帧信息推算和校验
                [verify, recv_channel.CH_B1I] = hotInfoCheck(recv_channel.CH_B1I, recv_channel.CH_B1I.bitSync.TimeLen, recv_channel.SYST,'BITSYNC');       
                % 各信息推算至数据头处
                recv_channel = track_phase_ini(recv_channel);
            end
            fprintf('                    BDS PRN%d bitSyncResults -- CodeIndx: %d ; bitIdx: %d ; Doppler: %.2fHz \n\n', ...
                recv_channel.CH_B1I.PRNID, recv_channel.CH_B1I.Samp_Posi, recv_channel.CH_B1I.bitSync.bitSyncResults.bitIdx -1, recv_channel.bpSampling_OddFold*recv_channel.CH_B1I.LO2_fd);
        end
    elseif (recv_channel.CH_B1I.bitSync.bitSyncResults.synced == -1)
        recv_channel.STATUS = 'BIT_SYNC_FAIL';
        recv_channel.CH_B1I.CH_STATUS = recv_channel.STATUS;
        recv_channel.CH_B1I.Samp_Posi = 0;
    end
end

