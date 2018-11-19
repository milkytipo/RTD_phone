function [pvtCalculator, pvtForecast_Succ] = pvt_forecast_filt(SYST, pvtCalculator, recv_timer, config,parameter, Loop)

pvtForecast_Succ = 0;

% 计算当前接收机时间和上次定位时刻的时间差值，执行该步骤的前提是接收机本地时间已经
if (recv_timer.recvSOW ~= -1) && (pvtCalculator.timeLast ~= -1) && (pvtCalculator.posiCheck > 0)
    timeDiff = recv_timer.recvSOW - pvtCalculator.timeLast;
    
    if timeDiff > pvtCalculator.maxInterval %距离上次定位时刻已经超过预设值，则认为通过预测获得的位置信息已经无效
        pvtCalculator.positionValid = -1;
        pvtCalculator.posiCheck = -1;
        pvtCalculator.kalman.preTag = 0; %如果长时间无法获得足够数量的观测信息，则预测的位置结果将发散允许阈值之外，因此将重置Kalman滤波器标志
    end
end

if (pvtCalculator.positionValid == 1) && (pvtCalculator.posiCheck >0)
    switch config.recvConfig.positionType
        case {00,100} % single-point least-square positioning mode
            pvtCalculator.posForecast(1:3) = pvtCalculator.posiLast(1:3) + pvtCalculator.positionVelocity(1:3) * timeDiff; % vector 3x1
            % Considering the accumulated clk error caused by the drifting
            % for both GPS and BDS systems
            pvtCalculator.clkErrForecast(1:2) = pvtCalculator.clkErr(1:2, 2) * timeDiff;
            
        case {01,101} % single-point Kalman positioning mode
            if pvtCalculator.kalman.preTag == 2 % preTag==2: the code ready for initialization
                % For the first time, we need initialize Kalman filter,
                % when both positionValid and posiCheck are 1.
                [pvtCalculator] = pvtEKF_init(SYST, pvtCalculator);
                pvtCalculator.kalman.preTag = 1;
            end
            
            if pvtCalculator.kalman.preTag == 1
                % Predict the positions and velocities
                pvtCalculator.kalman = pvtEKF_prediction(SYST, pvtCalculator.kalman,parameter, Loop);
                pvtCalculator.posForecast(1:3) = [pvtCalculator.kalman.stt_x(1), pvtCalculator.kalman.stt_y(1), pvtCalculator.kalman.stt_z(1)]';
                pvtCalculator.clkErrForecast(1:2) = pvtCalculator.kalman.stt_dtf(1, 1:2)';
%             nxtState = pvtCalculator.kalman.PHI * pvtCalculator.kalman.state;
%             pvtCalculator.posForecast(1:3) = nxtState(1:3);
%             pvtCalculator.kalman.state = nxtState;
%             pvtCalculator.kalman.P = pvtCalculator.kalman.PHI * pvtCalculator.kalman.P * (pvtCalculator.kalman.PHI).' + pvtCalculator.kalman.Qw;
            else
                pvtCalculator.posForecast(1:3) = pvtCalculator.posiLast(1:3) + pvtCalculator.positionVelocity(1:3) * timeDiff; % vector 3x1
                pvtCalculator.clkErrForecast(1:2) = pvtCalculator.clkErr(1:2, 2) * timeDiff;
            end
    end
    
    pvtForecast_Succ = 1;
end