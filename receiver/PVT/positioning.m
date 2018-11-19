function receiver = positioning(receiver)

if receiver.pvtCalculator.dataNum <= 0 % Only at initial phase, dataNum is equal to -1
    
    % Carrier-phase measurements obtainment
    receiver.pvtCalculator = integDopObs_Obtain(receiver.pvtCalculator, receiver.channels, receiver.actvPvtChannels, receiver.config);
    
    % Using Kalman Filter to predict the last position
    [receiver.pvtCalculator, pvtForecast_Succ] = pvt_forecast_filt(receiver.syst, receiver.pvtCalculator, receiver.timer, receiver.config);
    
    switch receiver.config.recvConfig.positionType
        case {00, 01, 02} % least-square / kalman single point positioning
            receiver = pointPos_1(receiver, pvtForecast_Succ);
        case {100,101,102} %Ë«Æµ¶¨Î»µ÷ÊÔ +100
            receiver = pointPos_new(receiver, pvtForecast_Succ); 
    end
    
    if receiver.pvtCalculator.positionValid == 1
        fprintf('/********************************* PVT solutions **********************************/\n');
        fprintf('    PVT Confidentce: %d\n', receiver.pvtCalculator.posiCheck);
        fprintf('    LLH:      Lat: %.6fdeg; Lon: %.6fdeg; Height: %.2fm\n', receiver.pvtCalculator.positionLLH(1), receiver.pvtCalculator.positionLLH(2), receiver.pvtCalculator.positionLLH(3));
        fprintf('    ECEF:     %.2f   %.2f  %.2f\n',receiver.pvtCalculator.positionXYZ(1), receiver.pvtCalculator.positionXYZ(2), receiver.pvtCalculator.positionXYZ(3));
        fprintf('    Velocity: %f  %f  %f\n',  receiver.pvtCalculator.positionVelocity(1), receiver.pvtCalculator.positionVelocity(2), receiver.pvtCalculator.positionVelocity(3));
        fprintf('    DOP:      GDOP: %.1f; PDOP: %.1f; HDOP: %.f; VDOP: %.f; TDOP: %.f\n', receiver.pvtCalculator.positionDOP(1), receiver.pvtCalculator.positionDOP(2), receiver.pvtCalculator.positionDOP(3), receiver.pvtCalculator.positionDOP(4), receiver.pvtCalculator.positionDOP(5));
        
        if strcmp(receiver.syst, 'BDS_B1I') || strcmp(receiver.syst, 'B1I_L1CA')
            fprintf('    ClkErr2BDS:   %.2fm; %.2fm/s\n', receiver.pvtCalculator.clkErr(1,1), receiver.pvtCalculator.clkErr(1,2));
            fprintf('    BDS %d Sats used in PVT: PRN [%s]\n', receiver.pvtCalculator.pvtSats(1).pvtS_Num, num2str(receiver.pvtCalculator.pvtSats(1).pvtS_prnList(1:receiver.pvtCalculator.pvtSats(1).pvtS_Num)));
            fprintf('    BDS %d Sats Ready:  PRN [%s]\n', receiver.pvtCalculator.pvtReadySats(1).pvtS_Num, num2str(receiver.pvtCalculator.pvtReadySats(1).pvtS_prnList(1:receiver.pvtCalculator.pvtReadySats(1).pvtS_Num)));
        end
        if strcmp(receiver.syst, 'GPS_L1CA') || strcmp(receiver.syst, 'B1I_L1CA')
            fprintf('    ClkErr2GPS:   %.2fm; %.2fm/s\n', receiver.pvtCalculator.clkErr(2,1), receiver.pvtCalculator.clkErr(2,2));
            fprintf('    GPS %d Sats used in PVT: PRN [%s]\n', receiver.pvtCalculator.pvtSats(2).pvtS_Num, num2str(receiver.pvtCalculator.pvtSats(2).pvtS_prnList(1:receiver.pvtCalculator.pvtSats(2).pvtS_Num)));
            fprintf('    GPS %d Sats Ready:  PRN [%s]\n', receiver.pvtCalculator.pvtReadySats(2).pvtS_Num, num2str(receiver.pvtCalculator.pvtReadySats(2).pvtS_prnList(1:receiver.pvtCalculator.pvtReadySats(2).pvtS_Num)));
        end
        if strcmp(receiver.syst, 'L1CA_L2C')
            fprintf('\tClkErr2GPS:   %.2fm; %.2fm/s\n', receiver.pvtCalculator.clkErr(2,1), receiver.pvtCalculator.clkErr(2,2));
            fprintf('\tGPS %d Sats used in PVT: PRN [%s]\n', receiver.pvtCalculator.pvtSats(2).pvtS_Num, num2str(receiver.pvtCalculator.pvtSats(2).pvtS_prnList(1:receiver.pvtCalculator.pvtSats(2).pvtS_Num)));
            fprintf('\tGPS %d Sats Ready:  PRN [%s]\n', receiver.pvtCalculator.pvtReadySats(2).pvtS_Num, num2str(receiver.pvtCalculator.pvtReadySats(2).pvtS_prnList(1:receiver.pvtCalculator.pvtReadySats(2).pvtS_Num)));
            fprintf('\tVTEC in GPS_L1: %fm\tL2toL1 device delay: %fm\n',...
                receiver.pvtCalculator.VTEC_L1,receiver.pvtCalculator.L2toL1_devDelay);
        end
        fprintf('  \n');
    end
    
end