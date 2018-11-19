function OutputCorr_GPS(channels, recv_time, activeChannel, path, name)

%%
%输入参数
logName = strcat(path, name, '_Corr_GPS.txt');
recorder_identifier='>';
epoch_year=recv_time.year;
epoch_month=recv_time.month;
epoch_day=recv_time.day;
epoch_hour=recv_time.hour;
epoch_min=recv_time.min;
epoch_sec=recv_time.sec;
epoch_numofsat=length(activeChannel(1,:));
%corrM_Spacing = channels.channels;
%corrM_Num = channels.corrM_Num;
pathSum = 0;    % 总共有多少曲线
%%
%输出
for i=1:epoch_numofsat
    if length(channels(activeChannel(1,i)).CH_L1CA)>1
        pathSum = pathSum + length(channels(activeChannel(1,i)).CH_L1CA) + 1;
    else
        pathSum = pathSum + 1;
    end
end
fid = fopen(logName,'at');
fprintf(fid,'%s %4d %2.2d %2.2d %2.2d %2.2d%11.7f %3d %3d\n',...
    recorder_identifier,epoch_year,epoch_month,epoch_day,...
    epoch_hour,epoch_min,epoch_sec,epoch_numofsat,pathSum);
for ii=1:epoch_numofsat
        queue_mp=sortrows(activeChannel',2);   % 转置，排序
        sat_num = queue_mp(ii,2);
        MP_num = length(channels(queue_mp(ii,1)).CH_L1CA);       % 到达径的数量
        corrM_Spacing = channels(queue_mp(ii,1)).CH_L1CA(1).CorrM_Bank.corrM_Spacing;
        corrM_Num = channels(queue_mp(ii,1)).CH_L1CA(1).CorrM_Bank.corrM_Num;
        corrM = abs(channels(queue_mp(ii,1)).CH_L1CA(1).CorrM_Bank.uncancelled_corrM_I_vt_Save + ...
            1i*channels(queue_mp(ii,1)).CH_L1CA(1).CorrM_Bank.uncancelled_corrM_Q_vt_Save);
        corrM2 = corrM(2:2:corrM_Num-1);
        corrM3 = corrM(3:2:corrM_Num);
        corrM = [flipud(corrM2); corrM(1); corrM3];
        code_delay = 0;
        if MP_num > 1
            line_num = MP_num + 1;
        else
            line_num = 1;
        end
        fprintf(fid,'G%2.2d %2.2d %2.2d %3d %3d %9.6f ',...
                    sat_num,line_num,1,corrM_Spacing,corrM_Num,code_delay);
        fprintf(fid,'%9.2f  ',corrM);
        fprintf(fid,'\n');
        if MP_num > 1
            for iii=1:MP_num
                code_delay = channels(queue_mp(ii,1)).CH_L1CA(1).LO_CodPhs - channels(queue_mp(ii,1)).CH_L1CA(iii).LO_CodPhs;
                if code_delay < 0 
                    code_delay = code_delay + 2046;
                end
                corrM_Spacing = channels(queue_mp(ii,1)).CH_L1CA(iii).CorrM_Bank.corrM_Spacing;
                corrM_Num = channels(queue_mp(ii,1)).CH_L1CA(iii).CorrM_Bank.corrM_Num;
                corrM = abs(channels(queue_mp(ii,1)).CH_L1CA(iii).CorrM_Bank.corrM_I_vt_Save + ...
                    1i*channels(queue_mp(ii,1)).CH_L1CA(iii).CorrM_Bank.corrM_Q_vt_Save); 
                corrM2 = corrM(2:2:corrM_Num-1);
                corrM3 = corrM(3:2:corrM_Num);
                corrM = [flipud(corrM2); corrM(1); corrM3];
                fprintf(fid,'G%2.2d %2.2d %2.2d %3d %3d %9.6f ',...
                    sat_num,line_num,iii+1,corrM_Spacing,corrM_Num,code_delay);
                fprintf(fid,'%9.2f  ',corrM);
                fprintf(fid,'\n');
            end
        end
end
fclose(fid);

 