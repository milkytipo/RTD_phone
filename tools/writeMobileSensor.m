function [] = writeMobileSensor(year, month, day, time_acc_modi, time_gyro_modi, time_mag_modi, para_acc, para_gyro, para_mag, fid_4)

timeStart = time_acc_modi(1, 4);
timeEnd = time_acc_modi(end-10, 4);
i = 0;
while 1
    time = timeStart + i * 0.2;
    i = i + 1;
    flag = 0;
    if time > timeEnd
        break;
    end
    % 加速度计
    k = find(time_acc_modi(:, 4) == time);
    if length(k) == 1
        flag = 1;
        time_use = time_acc_modi(k, :);
        acc(1) = para_acc(k, 1);
        acc(2) = para_acc(k, 2);
        acc(3) = para_acc(k, 3);
    elseif isempty(k)
        acc = [];
    elseif length(k) > 1
        error('time_acc is wrong : k > 1');
    end
    
    % 陀螺仪
    k = find(time_gyro_modi(:, 4) == time);
    if length(k) == 1
        flag = 1;
        time_use = time_gyro_modi(k, :);
        gyro(1) = para_gyro(k, 1);
        gyro(2) = para_gyro(k, 2);
        gyro(3) = para_gyro(k, 3);
    elseif isempty(k)
        gyro = [];
    elseif length(k) > 1
        error('time_gyro is wrong : k > 1');
    end

     % 磁力计
    k = find(time_mag_modi(:, 4) == time);
    if length(k) == 1
        flag = 1;
        time_use = time_mag_modi(k, :);
        mag(1) = para_mag(k, 1);
        mag(2) = para_mag(k, 2);
        mag(3) = para_mag(k, 3);
    elseif isempty(k)
        mag = [];
    elseif length(k) > 1
        error('time_mag is wrong : k > 1');
    end
     
     
    if flag == 1
        fprintf(fid_4, '%4.4d-%2.2d-%2.2d   %2.2d:%2.2d:%04.1f', ...
            year, month, day, time_use(1), time_use(2), time_use(3));
        if isempty(acc)
            fprintf(fid_4, '                              ');
        else
            fprintf(fid_4, '   %7.3f   %7.3f   %7.3f', acc(1), acc(2), acc(3));
        end
        if isempty(gyro)
            fprintf(fid_4, '                              ');
        else
            fprintf(fid_4, '   %7.3f   %7.3f   %7.3f', gyro(1), gyro(2), gyro(3));
        end
        if isempty(mag)
            fprintf(fid_4, '                              \n');
        else
            fprintf(fid_4, '   %7.3f   %7.3f   %7.3f\n', mag(1), mag(2), mag(3));
        end

    end
end