function receiver = demodulation(receiver)

channels = receiver.channels;
recvConfig = receiver.config.recvConfig;
naviMsg = receiver.naviMsg;
pvtCalculator = receiver.pvtCalculator;
timer = receiver.timer;
actvPvtChannels = receiver.actvPvtChannels;

posiLast = [];
transmitimeLast = [];
if (pvtCalculator.positionValid == 1) && (pvtCalculator.posiCheck == 1)
    posiLast = pvtCalculator.posiLast;
    transmitimeLast = pvtCalculator.timeLast;
end

% check SOW and subFrame ID
[channels, pvtCalculator] = sowCheck(channels, recvConfig, pvtCalculator, timer, actvPvtChannels);

for n = 1:recvConfig.numberOfChannels(1).channelNumAll
    
    if strcmp(channels(n).STATUS, 'SUBFRAME_SYNCED')
        
        % Epheremis demodulation and decoding
        [channels(n), naviMsg] = demodulation_proc( channels(n), naviMsg ); 
        
        % If updateReady = 1, check if update it into the eph.
        switch channels(n).SYST
            case 'GPS_L1CA'
                prnNum = channels(n).CH_L1CA(1).PRNID;
                if naviMsg.GPS_L1CA.ephemeris(prnNum).updateReady==1
                    % perform the step 1 checking procedure
                    [naviMsg.GPS_L1CA.ephemeris(prnNum), updateSuccess, ionoUpdate] = ...
                        ephUpdate_checkingStep1('GPS_L1CA', naviMsg.GPS_L1CA.ephemeris(prnNum), posiLast, transmitimeLast, prnNum);
                    
                    if updateSuccess ==1
                        if (naviMsg.GPS_L1CA.ephemeris(prnNum).ephReady ==1)
                            naviMsg.GPS_L1CA.ephemeris(prnNum).eph = ...
                                ephsatorbit_cpy('GPS_L1CA', naviMsg.GPS_L1CA.ephemeris(prnNum).eph, naviMsg.GPS_L1CA.ephemeris(prnNum).ephUpdate);
                            naviMsg.GPS_L1CA.ephemeris(prnNum).ephTrustLevel = naviMsg.GPS_L1CA.ephemeris(prnNum).ephUpdateTrustLevel;
                        else % ( naviMsg.GPS_L1CA.ephemeris.ephReady ==0)
                            % ephupdate checking step 1 pass. if there is no previsou eph
                            % available and there is no posiLast available, the
                            % further raim checking cannot be performed, so we
                            % update the ephupdate into eph and use it into the
                            % first PVT calculation.
                            % 首次保存星历数据
                            naviMsg.GPS_L1CA.ephemeris(prnNum).eph = naviMsg.GPS_L1CA.ephemeris(prnNum).ephUpdate;
                            naviMsg.GPS_L1CA.ephemeris(prnNum).ephRaid = naviMsg.GPS_L1CA.ephemeris(prnNum).ephUpdate;
                            naviMsg.GPS_L1CA.ephemeris(prnNum).ephTrustLevel = naviMsg.GPS_L1CA.ephemeris(prnNum).ephUpdateTrustLevel;
                            naviMsg.GPS_L1CA.ephemeris(prnNum).ephReady = 1;
                        end %EOF "if ( naviMsg.GPS_L1CA.ephemeris(prnNum).ephReady ==1)"
                        pvtCalculator.logOutput.GPSephUpdate(prnNum) = 1;   % eph 有更新
                    end %EOF "if updateSuccess ==1"
                    if ionoUpdate == 1
                        pvtCalculator.logOutput.GPSionoUpdate(prnNum) = 1;   % iono 有更新
                    end
                    %凡是接收完一次数据帧，不管成功更新与否，均需要重新将subframeID置成1:10.
                    naviMsg.GPS_L1CA.ephemeris(prnNum).subframeID(1:10) = 1:10;
                    naviMsg.GPS_L1CA.ephemeris(prnNum).updateReady = 0;
                    naviMsg.GPS_L1CA.ephemeris(prnNum).ephUpdateTrustLevel = 0;    
                end %EOF "if  naviMsg.GPS_L1CA.ephemeris(prnNum).updateReady==1"
            
            case 'GPS_L1CA_L2C' 
                if (strcmp(channels(n).CH_L1CA_L2C(1).Frame_Sync,'SYNCED'))  %检查L1电文更新.额外判断Frame_Sync状态
                    prnNum = channels(n).CH_L1CA_L2C(1).PRNID;
                    if naviMsg.GPS_L1CA.ephemeris(prnNum).updateReady==1

                        [naviMsg.GPS_L1CA.ephemeris(prnNum), updateSuccess, ionoUpdate] = ...
                            ephUpdate_checkingStep1('GPS_L1CA', naviMsg.GPS_L1CA.ephemeris(prnNum), posiLast, transmitimeLast, prnNum);

                        if updateSuccess ==1
                            if (naviMsg.GPS_L1CA.ephemeris(prnNum).ephReady ==1)
                                naviMsg.GPS_L1CA.ephemeris(prnNum).eph = ...
                                    ephsatorbit_cpy('GPS_L1CA', naviMsg.GPS_L1CA.ephemeris(prnNum).eph, naviMsg.GPS_L1CA.ephemeris(prnNum).ephUpdate);
                                naviMsg.GPS_L1CA.ephemeris(prnNum).ephTrustLevel = naviMsg.GPS_L1CA.ephemeris(prnNum).ephUpdateTrustLevel;
                            else
                                naviMsg.GPS_L1CA.ephemeris(prnNum).eph = naviMsg.GPS_L1CA.ephemeris(prnNum).ephUpdate;
                                naviMsg.GPS_L1CA.ephemeris(prnNum).ephRaid = naviMsg.GPS_L1CA.ephemeris(prnNum).ephUpdate;
                                naviMsg.GPS_L1CA.ephemeris(prnNum).ephTrustLevel = naviMsg.GPS_L1CA.ephemeris(prnNum).ephUpdateTrustLevel;
                                naviMsg.GPS_L1CA.ephemeris(prnNum).ephReady = 1;
                            end
                            pvtCalculator.logOutput.GPSephUpdate(prnNum) = 1;   % eph 有更新
                        end
                        if ionoUpdate == 1
                            pvtCalculator.logOutput.GPSionoUpdate(prnNum) = 1;   % iono 有更新
                        end
                        %凡是接收完一次数据帧，不管成功更新与否，均需要重新将subframeID置成1:10.
                        naviMsg.GPS_L1CA.ephemeris(prnNum).subframeID(1:10) = 1:10;
                        naviMsg.GPS_L1CA.ephemeris(prnNum).updateReady = 0;
                        naviMsg.GPS_L1CA.ephemeris(prnNum).ephUpdateTrustLevel = 0;    
                    end 
                end %EOF: if (strcmp(channels(n).CH_L1CA_L2C(1).Frame_Sync,'SYNCED'))
                
                if (strcmp(channels(n).CH_L1CA_L2C(1).Frame_Sync_CNAV,'SYNCED'))
                    %检查CNAV更新
                end
                
            case 'BDS_B1I'
                prnNum = channels(n).CH_B1I(1).PRNID;
                if naviMsg.BDS_B1I.ephemeris(prnNum).updateReady==1
                    % perform the step 1 checking procedure for BDS_B1I
                    [naviMsg.BDS_B1I.ephemeris(prnNum), updateSuccess, ~] = ...
                        ephUpdate_checkingStep1('BDS_B1I', naviMsg.BDS_B1I.ephemeris(prnNum), posiLast, transmitimeLast, prnNum);
                    
                    if updateSuccess ==1
                        if (naviMsg.BDS_B1I.ephemeris(prnNum).ephReady ==1)
                            naviMsg.BDS_B1I.ephemeris(prnNum).eph = ...
                                ephsatorbit_cpy('BDS_B1I', naviMsg.BDS_B1I.ephemeris(prnNum).eph, naviMsg.BDS_B1I.ephemeris(prnNum).ephUpdate);
                            naviMsg.BDS_B1I.ephemeris(prnNum).ephTrustLevel = naviMsg.BDS_B1I.ephemeris(prnNum).ephUpdateTrustLevel;
                        else % (naviMsg.BDS_B1I.ephemeris(prnNum).ephReady ==0)
                            % ephupdate checking step 1 pass. if there is no previsou eph
                            % available and there is no posiLast available, the
                            % further raim checking cannot be performed, so we
                            % update the ephupdate into eph and use it into the
                            % first PVT calculation.
                            % 首次保存星历数据
                            naviMsg.BDS_B1I.ephemeris(prnNum).eph = naviMsg.BDS_B1I.ephemeris(prnNum).ephUpdate;
                            naviMsg.BDS_B1I.ephemeris(prnNum).ephRaid = naviMsg.BDS_B1I.ephemeris(prnNum).ephUpdate;
                            naviMsg.BDS_B1I.ephemeris(prnNum).ephTrustLevel = naviMsg.BDS_B1I.ephemeris(prnNum).ephUpdateTrustLevel;
                            naviMsg.BDS_B1I.ephemeris(prnNum).ephReady = 1;
                        end %EOF "if (naviMsg.BDS_B1I.ephemeris(prnNum).ephReady ==1)"
                        pvtCalculator.logOutput.BDSephUpdate(prnNum) = 1;   % eph 有更新
                    end %EOF "if updateSuccess ==1"
                    
                    %凡是接收完一次数据帧，不管成功更新与否，均需要重新将subframeID置成1:10.
                    naviMsg.BDS_B1I.ephemeris(prnNum).subframeID(1:10) = 1:10;
                    naviMsg.BDS_B1I.ephemeris(prnNum).updateReady = 0;
                    naviMsg.BDS_B1I.ephemeris(prnNum).ephUpdateTrustLevel = 0;
                end %EOF "if naviMsg.BDS_B1I.ephemeris(prnNum).updateReady==1"
        end %EOF "switch receiver.channels(n).SYST"
    end %EOF "if strcmp(receiver.channels(n).STATUS, 'SUBFRAME_SYNCED')"
end %EOF "for n = 1:receiver.config.recvConfig.numberOfChannels(1).channelNumAll"

receiver.channels = channels;
receiver.naviMsg = naviMsg;
receiver.pvtCalculator = pvtCalculator;
