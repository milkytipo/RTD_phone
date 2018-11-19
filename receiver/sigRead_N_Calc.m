function [N, receiver, signal] = sigRead_N_Calc(receiver, signal)
global GSAR_CONSTANTS

if signal.Tunit > receiver.pvtCalculator.pvtT
    signal.Tunit = receiver.pvtCalculator.pvtT;
end

Tunit = signal.Tunit;
if receiver.timer.recvSOW ~= -1
%    Tres = receiver.pvtCalculator.pvtT - mod(receiver.timer.recvSOW, receiver.pvtCalculator.pvtT);
    
    if receiver.pvtCalculator.dataNum == 0   
        round_check = mod(receiver.timer.recvSOW, receiver.pvtCalculator.pvtT);
        if round_check >= receiver.pvtCalculator.pvtT/2
            timeAdd = 2 * receiver.pvtCalculator.pvtT - round_check;    % 如果到下一个整秒数时间小于pvtT/2，则加一个pvtT时间
        else
            timeAdd = receiver.pvtCalculator.pvtT - round_check;
        end 
        % 防止剩余时间不足(dataLoopNum-1) * signal.Tunit的时间，即最后一个循环N会小于0
        dataLoopNum = round(timeAdd/Tunit); % 自适应改变dataLoopNum的数值
        receiver.pvtCalculator.dataNum = dataLoopNum;
        receiver.timer.tNext = receiver.timer.recvSOW + timeAdd;
    end
    if receiver.pvtCalculator.dataNum == 1 
        Tunit = receiver.timer.tNext - receiver.timer.recvSOW;
    end
    
    receiver.pvtCalculator.dataNum = receiver.pvtCalculator.dataNum - 1;
end
N = ceil(GSAR_CONSTANTS.STR_RECV.fs * Tunit); 
