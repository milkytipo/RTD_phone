function [channel_spc, STATUS] = acq_l2cm_aid(channel_spc, config, sis, N, ~)

%bpSampling_OddFold 待修改
%CM码捕获需要多个频率，且20个相位积分开始时间各不相同，跳采样处理较繁琐，
%为了简化，本函数在积分过程中不进行跳采样，而是在整个捕获结束后统一跳采样。由于CM码捕获时间较短一般为39ms或59ms，积分损失较小。
%相干积分时间固定为20ms

global GSAR_CONSTANTS;
STATUS = channel_spc.CH_STATUS;  %设定默认返回值

if (channel_spc.acq.resiN > 0 )
    sis = [channel_spc.acq.resiData sis];  %如果有剩余数据，先合并
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

l2c_acq_config = config.recvConfig.configPage.acqConfig.GPS_L2C_aid;
fd0 = GSAR_CONSTANTS.STR_L2C.L2L1_FreqRatio * channel_spc.LO2_fd; %频率搜索中心
freqN = round( l2c_acq_config.freqRange / l2c_acq_config.freqBin )+1; %频率搜索数
fd_search = fd0 + ( -l2c_acq_config.freqRange/2 : l2c_acq_config.freqBin : l2c_acq_config.freqRange/2 ); %多普勒搜索位置
IF_search = GSAR_CONSTANTS.STR_RECV.IF_L2C + fd_search; %实际搜索频率位置
Tc = round(l2c_acq_config.tcoh*1000); %相干积分毫秒数
Nc = l2c_acq_config.ncoh; %累加次数

if (channel_spc.acq.processing ~= 1) %第一次进来要初始化
    channel_spc.acq.accum = 0; %非相干累加次数
    channel_spc.acq.CM_corr = zeros(freqN,20); %总积分结果
    channel_spc.acq.CM_corrtmp  = zeros(freqN,20); %每次相干积分结果
    channel_spc.acq.carriPhase_vt = zeros(freqN,1); %保存个频点的载波相位信息,0~1归一化  
    channel_spc.acq.processing = 1;
end

fprintf('\t\tAcquire GPS L2CM PRN%2.2d:  Coherent time: %d*%.3fs ; FreqBin: %.0fHz ; FreqRange: %.2f~%.2fHz\n', ...
    channel_spc.PRNID, Nc, l2c_acq_config.tcoh, l2c_acq_config.freqBin, fd_search(1), fd_search(freqN));

t_1ms = (0:N_1ms-1)/GSAR_CONSTANTS.STR_RECV.fs;  %1ms时间戳
t_20ms = (0:20*N_1ms-1)/GSAR_CONSTANTS.STR_RECV.fs;  %20ms时间戳
CM_code = GSAR_CONSTANTS.PRN_CODE.RZCM_code(channel_spc.PRNID,:); %取出对应扩频码

%先生成20ms本地采样码，每路积分会从中截取一段使用，这样避免了循环中的重复计算
 %CM0 码率1.023M 码长20460 周期20ms 码片上载波周期数：1200
codeTable = CM_code( mod( floor( (1.023e6 + fd0/1200)*t_20ms ), 20460 ) + 1 );  %本地采样CM0码


%积分主循环
while 1
    sis_seg = sis( channel_spc.Samp_Posi + (1:N_1ms) );
    Phase = mod(channel_spc.acq.accum,20)+1; %1~20,从积分开始经过的毫秒数，1代表0~1ms,依次类推
    
    for i=1:freqN
        sis_seg_swpt = sis_seg.*exp( -1j*2*pi*( IF_search(i).*t_1ms+channel_spc.acq.carriPhase_vt(i) ) ); %载波剥离
        channel_spc.acq.carriPhase_vt(i) = mod(channel_spc.acq.carriPhase_vt(i)+ IF_search(i)*0.001,1); %相位推进,每次模1可减小量化误差
        
        if (channel_spc.acq.accum<19) %0~19ms:启动阶段
            for k = 1:Phase
                channel_spc.acq.CM_corrtmp(i,k) = channel_spc.acq.CM_corrtmp(i,k) + sum( sis_seg_swpt.*codeTable( (Phase-k)*N_1ms+(1:N_1ms)) );
            end     
            
        elseif (channel_spc.acq.accum<20*Nc)  %19~20n ms:平稳阶段       
            for k = 1:20
                channel_spc.acq.CM_corrtmp(i,k) = channel_spc.acq.CM_corrtmp(i,k) + sum( sis_seg_swpt.*codeTable( (mod(Phase-k,20))*N_1ms+(1:N_1ms)) );
            end
                      
        else %20n~20n+19 ms:收尾阶段           
            for k = Phase+1:20
                channel_spc.acq.CM_corrtmp(i,k) = channel_spc.acq.CM_corrtmp(i,k) + sum( sis_seg_swpt.*codeTable( (mod(Phase-k,20))*N_1ms+(1:N_1ms)) );
            end           
        end
    end
    
    channel_spc.Samp_Posi = channel_spc.Samp_Posi + N_1ms;
    channel_spc.acq.accum = channel_spc.acq.accum + 1;
    if (channel_spc.acq.accum>=Tc) %到了20ms的相干积分时间，就取模，加到最终的累加结果里去
        Pos = mod(Phase,20)+1;
        channel_spc.acq.CM_corr(:,Pos) = channel_spc.acq.CM_corr(:,Pos) + abs(channel_spc.acq.CM_corrtmp(:,Pos));
        channel_spc.acq.CM_corrtmp(:,Pos) = 0;
    end
    
    %达到设定的累加次数，积分结束
    if (channel_spc.acq.accum>=Tc*Nc+19)
        [peak_nc_corr, peak_freq_idx, peak_code_phase, th] = find2DPeakWithThre(channel_spc.acq.CM_corr, 'CM');
        if (th>l2c_acq_config.thre_CM) %捕获成功
            if config.logConfig.isAcqPlotMesh
                Title = ['Acq GPS_L2CM PRN=',num2str(channel_spc.PRNID)];
                figure('Name',Title,'NumberTitle','off');
                mesh(1:20,fd_search,channel_spc.acq.CM_corr);
                xlabel('Code position');
                ylabel('Freq doppler / Hz');
                zlabel('Corr');
            end
            STATUS = 'COLD_ACQ';
            channel_spc.acq.ACQ_STATUS = 3;   
            %更新多普勒
            freqBias = freqCorrect( channel_spc.acq.CM_corr(:,peak_code_phase), peak_freq_idx, l2c_acq_config.freqBin); %估计精确多普勒
            channel_spc.LO2_fd_L2 = fd_search(peak_freq_idx) + freqBias;
            channel_spc.LO_Fcode_fd = channel_spc.LO2_fd_L2 / 1200;
            channel_spc.LO2_fd = channel_spc.LO2_fd_L2 / GSAR_CONSTANTS.STR_L2C.L2L1_FreqRatio;
            %推算下一个比特沿,最多可推算20ms,因此CL捕获时需要先判断数据是否溢出
            skipNperCode = N_1ms * channel_spc.LO_Fcode_fd / GSAR_CONSTANTS.STR_L1CA.Fcode0;
            timeLen = peak_code_phase + channel_spc.acq.accum; %推算的毫秒数
            skipNumOfSamples = round(skipNperCode*timeLen);
            channel_spc.Samp_Posi = channel_spc.Samp_Posi + peak_code_phase*N_1ms - skipNumOfSamples - channel_spc.acq.resiN;
            %记录峰值，作为CL码捕获时的参考
            channel_spc.acq.CM_peak = peak_nc_corr;            
            fprintf('\t\t\tSucceed!Samp_pos: %d ; Doppler: %.2fHz Strength: %.4f \n', ...
                channel_spc.Samp_Posi, channel_spc.LO2_fd_L2, th);           
        else %捕获失败
            %此处可参照以往做法，如判断卫星可见，捕获两次，现在暂时只捕获一次
            STATUS = 'ACQ_FAIL';
            channel_spc.CH_STATUS = 'ACQ_FAIL';
            channel_spc.acq.ACQ_STATUS = 0;
            fprintf('\t\t\tFailed!Strength: %.4f \n',th);
        end
        
        channel_spc.acq.carriPhase_vt = [];
        channel_spc.acq.CM_corr = [];
        channel_spc.acq.CM_corrtmp = [];
        channel_spc.acq.accum = 0;
        channel_spc.acq.resiN = 0;
        channel_spc.acq.resiData = [];
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
    
end %EOF while(1)
    