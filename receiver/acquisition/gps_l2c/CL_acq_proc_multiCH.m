function channelList = CL_acq_proc_multiCH(channelList, listNum, config, sis, N)
% 多通道CL码捕获程序（CM码捕获结果辅助）

% 采用简化版星间辅助方式，当多个通道同时进入CL捕获时，第一颗成功捕获的卫星记录CL的相位信息，可以加速其他卫星的捕获进程。
% 加速的条件是当前数据足够完成捕获进程。不适用于GPU并行捕获。
% CL_time记录的是当前数据块起始沿对应的CL码时间（0~1.5s），初始-1代表无效。
% 星间辅助加强版需要维护一个整个接收机可见的CL_time变量，只要有任意一颗完成CL码捕获的卫星，或者子帧同步的卫星，即可实现加速。目前未采用。
CL_time = -1;  

for i = 1:listNum    
        
    switch channelList(i).STATUS
        case 'HOT_ACQ'
            break; %热捕不需要
        case {'COLD_ACQ', 'COLD_ACQ_AGAIN'}
            if (channelList(i).CH_L1CA_L2C.acq.ACQ_STATUS == 3 )  %判断捕获子状态
                [channelList(i).CH_L1CA_L2C, channelList(i).STATUS, CL_time] = acq_l2cl_aid( ...
                    channelList(i).CH_L1CA_L2C, config, sis, N, channelList(i).bpSampling_OddFold, CL_time);
            end
    end
    
    if (strcmp('PULLIN',channelList(i).STATUS))  %对于CL码捕获完成的通道，在此处进入跟踪初始化
        channelList(i) = pullin_ini(channelList(i));
        channelList(i) = phase_ini(channelList(i));
    end            
    
end