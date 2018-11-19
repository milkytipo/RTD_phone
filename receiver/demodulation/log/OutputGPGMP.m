function OutputGPGMP(recv_time,channels,activeChannel, path, name)
%%
%输入参数
logName = strcat(path, name, '_GPGMP.txt');
epoch_hour=recv_time.hour;
epoch_min=recv_time.min;
epoch_sec=recv_time.sec;
queue=[];
num_mp=0;
pathSum = 0;    % 到达径的总数量
for i=1:length(activeChannel(1,:))
    if length(channels(activeChannel(1,i)).CH_B1I) > 0
        num_mp=num_mp+1;
        queue(:,num_mp)=activeChannel(:,i);
        pathSum = pathSum + length(channels(activeChannel(1,i)).CH_B1I);
    end
end
if isempty(queue)==0
    queue_mp=sortrows(queue',2);   % 转置，排序
    epoch_numofsat=length(queue_mp(:,1));
    fid=fopen(logName,'at');
    for ii=1:epoch_numofsat
        sat_num = queue_mp(ii,2);
        MP_num = length(channels(queue_mp(ii,1)).CH_B1I);       % 到达径的数量
        fprintf(fid,'$GPBMP,%2.2d%2.2d%06.3f,%2.2d,%2.2d,%2.2d,%2.2d,',...
            epoch_hour,epoch_min,epoch_sec,epoch_numofsat,ii,sat_num,MP_num);
        for iii=1:MP_num
                code_delay = channels(queue_mp(ii,1)).CH_B1I(1).LO_CodPhs - channels(queue_mp(ii,1)).CH_B1I(iii).LO_CodPhs;
                if code_delay < 0 
                    code_delay = code_delay + 2046;
                end
                Ip = channels(queue_mp(ii,1)).ALL(iii).ai_v(1);
                Qp = channels(queue_mp(ii,1)).ALL(iii).aq_v(1);
                snr = channels(queue_mp(ii,1)).ALL(iii).SNR;
                cnr=channels(queue_mp(ii,1)).CH_B1I(iii).CN0_Estimator.CN0;            
                fprintf(fid,'%2.2d,%6.4f,%6.4f,%6.4f,%5.2f,%5.2f,',...
                    iii,code_delay,Ip,Qp,snr,cnr);        
        end
        fprintf(fid,'\n');   
    end
    fclose(fid);
end


