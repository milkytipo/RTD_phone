function [table, result] = Pass2UI(receiver)

table = 2e10 * ones(receiver.config.numberOfChannels, 8);
result = 2e10 * ones(3, 6);
switch receiver.syst
    case 'BD_B1I'
        table(:,1) = 1;
        for n = 1:receiver.config.numberOfChannels
            table(n,2) = receiver.channels(n).CH_B1I(1).PRNID;
            if strcmp(receiver.channels(n).CH_B1I(1).CH_STATUS, 'IDLE')
                table(n,3) = 1;
            elseif strcmp(receiver.channels(n).CH_B1I(1).CH_STATUS, 'COLD_ACQ')
                table(n,3) = 2;
            elseif strcmp(receiver.channels(n).CH_B1I(1).CH_STATUS, 'WARM_ACQ')
                table(n,3) = 3;
            elseif strcmp(receiver.channels(n).CH_B1I(1).CH_STATUS, 'PULLIN')
                table(n,3) = 4;
            elseif strcmp(receiver.channels(n).CH_B1I(1).CH_STATUS, 'TRACK')
                table(n,3) = 5;
            elseif strcmp(receiver.channels(n).CH_B1I(1).CH_STATUS, 'SUBFRAME_SYNCED')
                table(n,3) = 6;
            end
            table(n,4) = receiver.pvtCalculator.sateStatus(1, table(n,2));
            table(n,5) = receiver.pvtCalculator.sateStatus(2, table(n,2));
            table(n,6) = receiver.pvtCalculator.sateStatus(3, table(n,2));
            table(n,7) = receiver.channels(n).CH_B1I(1).LO2_fd;
        end
    case 'GPS_L1CA'
        table(:,1) = 2;
        for n = 1:receiver.config.numberOfChannels
            table(n,2) = receiver.channels(n).CH_L1CA(1).PRNID;
            if strcmp(receiver.channels(n).CH_L1CA(1).CH_STATUS, 'IDLE')
                table(n,3) = 1;
            elseif strcmp(receiver.channels(n).CH_L1CA(1).CH_STATUS, 'COLD_ACQ')
                table(n,3) = 2;
            elseif strcmp(receiver.channels(n).CH_L1CA(1).CH_STATUS, 'WARM_ACQ')
                table(n,3) = 3;
            elseif strcmp(receiver.channels(n).CH_L1CA(1).CH_STATUS, 'PULLIN')
                table(n,3) = 4;
            elseif strcmp(receiver.channels(n).CH_L1CA(1).CH_STATUS, 'TRACK')
                table(n,3) = 5;
            elseif strcmp(receiver.channels(n).CH_L1CA(1).CH_STATUS, 'SUBFRAME_SYNCED')
                table(n,3) = 6;
            end
            table(n,4) = receiver.pvtCalculator.sateStatus(1, table(n,2));
            table(n,5) = receiver.pvtCalculator.sateStatus(2, table(n,2));
            table(n,6) = receiver.pvtCalculator.sateStatus(3, table(n,2));
            table(n,7) = receiver.channels(n).CH_L1CA(1).LO2_fd;
        end
end

for n = 1:receiver.config.numberOfChannels
%     table(n,3) = receiver.channels(n).STATUS;
    table(n,8) = receiver.channels(n).ALL.SNR;
end

result(1,1) = receiver.pvtCalculator.positionXYZ(1);
result(2,1) = receiver.pvtCalculator.positionXYZ(2);
result(3,1) = receiver.pvtCalculator.positionXYZ(3);
result(1,2) = receiver.pvtCalculator.positionLLH(1);
result(2,2) = receiver.pvtCalculator.positionLLH(2);
result(3,2) = receiver.pvtCalculator.positionLLH(3);
result(1,3) = receiver.pvtCalculator.positionVelocity(1);
result(2,3) = receiver.pvtCalculator.positionVelocity(2);
result(3,3) = receiver.pvtCalculator.positionVelocity(3);
result(1,4) = receiver.pvtCalculator.positionTime(1);
result(2,4) = receiver.pvtCalculator.positionTime(2);
result(3,4) = receiver.pvtCalculator.positionTime(3);
result(1,5) = receiver.pvtCalculator.positionTime(4);
result(2,5) = receiver.pvtCalculator.positionTime(5);
result(3,5) = receiver.pvtCalculator.positionTime(6);
result(1,6) = receiver.pvtCalculator.positionDOP;
result(2,6) = receiver.fileSize;
result(3,6) = receiver.elapseTime;
end