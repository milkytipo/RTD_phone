function rinexmp_data(recv_time,channels,activeChannel,logName)
%%
%输入参数
recorder_identifier='>';
epoch_year=recv_time.year;
epoch_month=recv_time.month;
epoch_day=recv_time.day;
epoch_hour=recv_time.hour;
epoch_min=recv_time.min;
epoch_sec=round(recv_time.sec);
epoch_flag=0;
queue=[];
num_mp=0;
pathSum = 0;    % 到达径的总数量
for i=1:length(activeChannel(1,:))
    if length(channels(activeChannel(1,i)).CH_B1I)>1
        num_mp=num_mp+1;
        queue(:,num_mp)=activeChannel(:,i);
        pathSum = pathSum + length(channels(activeChannel(1,i)).CH_B1I);
    end
end
if isempty(queue)==0
    queue_mp=sortrows(queue',2);   % 转置，排序
    epoch_numofsat=length(queue_mp(:,1));
    sys='C';
    fid=fopen(logName,'at');
    fprintf(fid,'%s %4d %2.2d %2.2d %2.2d %2.2d%11.7f  %1d%3d  %2d\n',...
        recorder_identifier,epoch_year,epoch_month,epoch_day,...
        epoch_hour,epoch_min,epoch_sec,epoch_flag,epoch_numofsat,pathSum);  

    for ii=1:epoch_numofsat
        sat_num = queue_mp(ii,2);
        MP_num = length(channels(queue_mp(ii,1)).CH_B1I);       % 到达径的数量

        for iii=1:MP_num
                code_delay = channels(queue_mp(ii,1)).CH_B1I(1).LO_CodPhs - channels(queue_mp(ii,1)).CH_B1I(iii).LO_CodPhs;
                if code_delay < 0 
                    code_delay = code_delay + 2046;
                end
                Ip = channels(queue_mp(ii,1)).ALL(iii).ai_v(1);
                Qp = channels(queue_mp(ii,1)).ALL(iii).aq_v(1);
                snr = channels(queue_mp(ii,1)).ALL(iii).SNR;
                cnr=channels(queue_mp(ii,1)).CH_B1I(iii).CN0_Estimator.CN0;
                insertNum = channels(queue_mp(ii,1)).CH_B1I(iii).preUnitNum + 1;    % C中从0开始计数
                fprintf(fid,'%s%2.2d %2.2d %2.2d %11.8f  %11.8f  %11.8f  %11.8f  %11.8f\n',...
                    sys,sat_num, MP_num,insertNum,code_delay,Ip,Qp,snr,cnr);        
        end
    end
    fclose(fid);
end


