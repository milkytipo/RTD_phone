function time = modifyText(time, N_log)
% 文件处理
i = 1;
while 1
    if i >= N_log-10
        break;
    end
    if isequal(time(i, 4), time(i+1, 4), time(i+2, 4), time(i+3, 4), time(i+4, 4))
        time(i:(i+4), 3) = time(i:(i+4), 3) + [0; 0.2; 0.4; 0.6; 0.8];
        time(i:(i+4), 4) = time(i:(i+4), 4) + [0; 0.2; 0.4; 0.6; 0.8];
        i = i + 5;
        continue;
    else
        if isequal(time(i, 4), time(i+1, 4), time(i+2, 4), time(i+3, 4)) && ...
                isequal(time(i+4, 4), time(i+5, 4), time(i+6, 4), time(i+7, 4), time(i+8, 4), time(i+9, 4))
            time(i+4, :) = time(i+3, :);
            time(i:(i+4), 3) = time(i:(i+4), 3) + [0; 0.2; 0.4; 0.6; 0.8];
            time(i:(i+4), 4) = time(i:(i+4), 4) + [0; 0.2; 0.4; 0.6; 0.8];
            i = i + 5;
            continue;
        elseif isequal(time(i+1, 4), time(i+2, 4), time(i+3, 4), time(i+4, 4)) && ...
                isequal(floor(time(i, 4)), floor(time(i-1, 4)), floor(time(i-2, 4)), floor(time(i-3, 4)), floor(time(i-4, 4)), floor(time(i-5, 4)))
            time(i, :) = time(i+1, :);
            time(i:(i+4), 3) = time(i:(i+4), 3) + [0; 0.2; 0.4; 0.6; 0.8];
            time(i:(i+4), 4) = time(i:(i+4), 4) + [0; 0.2; 0.4; 0.6; 0.8];
            i = i + 5;
            continue;
        elseif isequal(time(i, 4), time(i+1, 4), time(i+2, 4), time(i+3, 4))
            time(i:(i+3), 3) = time(i:(i+3), 3) + [0; 0.2; 0.4; 0.6];
            time(i:(i+3), 4) = time(i:(i+3), 4) + [0; 0.2; 0.4; 0.6];
            i = i + 4;
            continue;
        elseif isequal(time(i, 4), time(i+1, 4), time(i+2, 4))
            time(i:(i+2), 3) = time(i:(i+2), 3) + [0; 0.4; 0.8];
            time(i:(i+2), 4) = time(i:(i+2), 4) + [0; 0.4; 0.8];
            i = i + 3;
            continue;
        elseif isequal(time(i, 4), time(i+1, 4))
            time(i:(i+1), 3) = time(i:(i+1), 3) + [0; 0.4];
            time(i:(i+1), 4) = time(i:(i+1), 4) + [0; 0.4];
            i = i + 2;
            continue;
        else
            i = i + 1;
            continue;
        end % if isequal
        
    end% if isequal
end % while 1