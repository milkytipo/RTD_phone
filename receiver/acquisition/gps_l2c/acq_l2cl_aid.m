function [channel_spc, STATUS, CL_time] = acq_l2cl_aid(channel_spc, config, sis, N, ~, CL_time)

%bpSampling_oddFold暂未使用
%在CL捕获中，只有一个频率，且75个位置的积分进程是同步的，跳采样可以比较方便地处理，本函数直接在码相位生成时考虑了多普勒的累积效应；
%不过最后Samp_Posi的校正仍在积分结束后进行,由于不存在比特跳变，因此没有积分损失。
%和CM码不同，CL码捕获时需要用到时长1500ms的本地采样码，在MATLAB中如果用double类型内存消耗较大，因此采用每毫秒即时生成的方式；
%这种方式在积分时间为1*20ms的情况下不会带来额外的计算量，而且使用星间辅助时处理更方便。

global GSAR_CONSTANTS;

%设定默认返回值
STATUS = channel_spc.CH_STATUS; 
 
%由于CM捕获后进行了多毫秒的推算，需要检查数据是否溢出
if (channel_spc.Samp_Posi >= N)
    channel_spc.Samp_Posi = channel_spc.Samp_Posi - N;
    return;
end

%如果有剩余数据，先合并
if (channel_spc.acq.resiN > 0 )
    sis = [channel_spc.acq.resiData sis];  
    N = N + channel_spc.acq.resiN;
    channel_spc.acq.resiData = [];
end

N_1ms = GSAR_CONSTANTS.STR_RECV.fs * 0.001;  %1ms数据对应的采样点数  (sampPerCode)
if (channel_spc.Samp_Posi + N_1ms > N) %如数据不足，留到下回, 无跳采样，用大于号
    channel_spc.acq.resiData = sis(channel_spc.Samp_Posi+1:N);
    channel_spc.acq.resiN = N - channel_spc.Samp_Posi;
    channel_spc.Samp_Posi = 0;
    return;
end

if (channel_spc.acq.processing ~= 1) %第一次进来要初始化
    if (CL_time>=0)  %其他通道捕获过CL码，那么搜索范围可以缩小。
        %计算当前采样点对应的CL时间
        CL_time_prompt = mod( CL_time+(channel_spc.Samp_Posi-channel_spc.acq.resiN)/GSAR_CONSTANTS.STR_RECV.fs, 1.5);
        CL_phase = floor(50*CL_time_prompt)+1; %CL相位1~75
        if (CL_phase==75)
            channel_spc.acq.CL_search = [1,75];
        else
            channel_spc.acq.CL_search = [CL_phase,CL_phase+1];
        end      
    else
        channel_spc.acq.CL_search = 1:75;
    end
        
    channel_spc.acq.accum = 0; %非相干累加次数
    channel_spc.acq.CL_corr = zeros(1,75); %总积分结果
    channel_spc.acq.CL_corrtmp  = zeros(1,75); %每次相干积分结果
    channel_spc.acq.carriPhase = 0; %保存载波相位信息,0~1归一化  
    
    channel_spc.acq.processing = 1;
end

l2c_acq_config = config.recvConfig.configPage.acqConfig.GPS_L2C_aid;
fd0 = channel_spc.LO2_fd_L2; %多普勒频率
IF_search = GSAR_CONSTANTS.STR_RECV.IF_L2C + fd0; %实际搜索频率位置
Tc = round(l2c_acq_config.tcoh*1000); %相干积分毫秒数
Nc = l2c_acq_config.ncoh; %累加次数
CL_code = GSAR_CONSTANTS.PRN_CODE.RZCL_code(channel_spc.PRNID,:); %取出对应扩频码 0CL
t_1ms = (0:N_1ms-1)/GSAR_CONSTANTS.STR_RECV.fs;  %1ms时间戳

fprintf('\t\tAcquire GPS L2CL PRN%2.2d:  Coherent time: %d*%.3fs ; FreqCenter: %.2fHz\n', ...
    channel_spc.PRNID, Nc, l2c_acq_config.tcoh, fd0);

%1ms主循环
while 1
    sis_seg = sis( channel_spc.Samp_Posi + (1:N_1ms) );    
    sis_seg_swpt = sis_seg.*exp( -1j*2*pi*( IF_search.*t_1ms+channel_spc.acq.carriPhase ) ); %载波剥离
    channel_spc.acq.carriPhase = mod(channel_spc.acq.carriPhase+ IF_search*0.001,1); %相位推进,每次模1可减小量化误差
    
    %码剥离和相关
    for i = channel_spc.acq.CL_search
        codePhase = mod( floor( (i-1)*20460+channel_spc.acq.accum*(1023+fd0/1200000)+t_1ms*(1.023e6+fd0/1200) ), 1534500)+1;
        channel_spc.acq.CL_corrtmp(i) = channel_spc.acq.CL_corrtmp(i) + sum(sis_seg_swpt.*CL_code(codePhase)); 
    end
    
    channel_spc.Samp_Posi = channel_spc.Samp_Posi + N_1ms;
    channel_spc.acq.accum = channel_spc.acq.accum + 1;
    
    %达到相干积分时间
    if (channel_spc.acq.accum>=Tc) 
        channel_spc.acq.CL_corr = channel_spc.acq.CL_corr + abs(channel_spc.acq.CL_corrtmp);
        channel_spc.acq.CL_corrtmp = zeros(1,75);
    end
    
    %达到设定的累加次数，积分结束
    if (channel_spc.acq.accum>=Tc*Nc)
        [peak_nc_corr, peak_code_phase] = max(channel_spc.acq.CL_corr);
        th = peak_nc_corr / channel_spc.acq.CM_peak;
        if (th>l2c_acq_config.thre_CL) %捕获成功  
            if config.logConfig.isAcqPlotMesh
                Title = ['Acq GPS_L2CL PRN=',num2str(channel_spc.PRNID)];
                figure('Name',Title,'NumberTitle','off');
                plot(channel_spc.acq.CL_corr);
                xlabel('Code position');
                ylabel('Corr');
            end
            STATUS = 'PULLIN';
            channel_spc.STATUS = 'PULLIN';
            channel_spc.acq.ACQ_STATUS = 4;   %4级时需要进入跟踪初始化
            %Samp_Posi推算
            skipNperCode = N_1ms * channel_spc.LO_Fcode_fd / GSAR_CONSTANTS.STR_L1CA.Fcode0;
            skipNumOfSamples = round(skipNperCode*Tc*Nc);
            channel_spc.Samp_Posi = channel_spc.Samp_Posi - skipNumOfSamples - channel_spc.acq.resiN;
            %计算Samp_Posi=0位置的CL时间
            CL_time = mod( (peak_code_phase-1)*0.02 + Tc*Nc*0.001 - channel_spc.Samp_Posi/GSAR_CONSTANTS.STR_RECV.fs, 1.5);
            channel_spc.CL_time = CL_time;
            
            fprintf('\t\t\tSucceed!Samp_pos: %d ; CM_in_CL: %d corrPeakRatio: %.4f \n', ...
                channel_spc.Samp_Posi, peak_code_phase, th);           
        else %捕获失败
            %此处可参照以往做法，如判断卫星可见，捕获两次，现在暂时只捕获一次
            STATUS = 'ACQ_FAIL';
            channel_spc.CH_STATUS = 'ACQ_FAIL';
            channel_spc.acq.ACQ_STATUS = 0;
            fprintf('\t\t\tFailed!corrPeakRatio: %.4f \n',th);
        end
        
        channel_spc.acq.CL_corr = [];
        channel_spc.acq.CL_corrtmp = [];
        channel_spc.acq.accum = 0;
        channel_spc.acq.resiN = 0;
        channel_spc.acq.resiData = [];
        channel_spc.acq.carriPhase = 0;
        channel_spc.acq.processing = 0;
        return;
    end
    
    %判断数据余量
    if (channel_spc.Samp_Posi + N_1ms > N) %如数据不足，留到下回  无跳采样，用大于号
        channel_spc.acq.resiData = sis(channel_spc.Samp_Posi+1:N);
        channel_spc.acq.resiN = N - channel_spc.Samp_Posi;
        channel_spc.Samp_Posi = 0;
        return;
    end  
    
end
