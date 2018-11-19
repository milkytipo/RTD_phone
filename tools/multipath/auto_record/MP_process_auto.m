function [multiPara] = MP_process_auto(multiPara , sys, multipathNum, sheetName, timeIndex)


%%%%%%%%%%%%%%%%%%%%%%%%% 自动化检测参数配置  %%%%%%%%%%%%%%%%%%%%
%%% 以下参数的基础都是timeInterval = 0.1; %%%%
grad_start_1 = 6; % 起始检测斜率门限1
grad_start_2 = 1.5; % 起始检测斜率门限1
var_start = 0.15; % 起始检测斜率门限
endRange = 25; % 最大(小)值不超过均值的范围
grad_conti = 2; % 连续增大或减小的数据段删除
var_conti = 0.2; % 按斜率的倍数来判断
grad_less1s = 1.2; % 1s数据的延时斜率门限
var_less1s = 0.2; % 按斜率的倍数来判断

%——————去除载波在0和180度附近波动的疑似误检测点————————%
dopp_time_len = 30; % 载波相位判断的有效时长
dopp_grad = 25; % 载波斜率
dopp_range = 33; % 在180度左右的波动范围
proba_dopp = 0.8; % 只要百分之proba的点数满足要求即可
proba_rang = 28; %由于取概率，要求严格些
%——————去除载波能量很低的多径————————%
power_atten = 30;
%——————去除短时间的GEO多径——————————%
GEO_time_len = 100;
%————————去除延时过小的点——————————%
time_Delay = 18;
proba_delay = 0.75; % 只要百分之proba的点数满足要求即可


%%%%%%%%%%%%%%%%%%%%%%%%% 自动化检测参数配置  %%%%%%%%%%%%%%%%%%%%
timeDiv = 7; % 数据按照timeDiv/10秒分割
%—————————————————————自动化处理数据——————————————————%
% —————————数据按0.5s分割——————————%
for i = 1 : multipathNum
    path_Num_1s = 0;
    for j = 1 : size(multiPara(i).pathIndex, 1)
        if (multiPara(i).pathIndex(j,2) - multiPara(i).pathIndex(j,1)) >= 10 % 删除小于1s的数据
            for k = (multiPara(i).pathIndex(j,1)+1):timeDiv:(multiPara(i).pathIndex(j,2)-timeDiv+1) % 跳过0.2秒数据，防止载波相位突变
                path_Num_1s = path_Num_1s + 1;
                multiPara(i).pathIndex_1s(path_Num_1s,1) = k; %
                multiPara(i).pathIndex_1s(path_Num_1s,2) = k + timeDiv - 1;
            end
        end
    end
end
%————————————数据合并——————————% pathIndex_Auto
for i = 1:multipathNum
    auto_Num = 0; % 处理后的多径数量
    running = 0; % 判断是否正在记录多径数据
    conti_flag = 0; % 判断原始数据中下一秒是否连续
    dopp_flag = 0; % 判断多径衰落频率是否通过校验
    log_flag = 0; % 判断是否记录多径数
    power_flag = 0; % 判断能量衰落
    GEO_flag = 0; % 判断GEO持续时间 / 去除小于n秒的数据
    delay_flag = 0; % 删除延时过小的数据点
    grad_conti_sign = [0, 0]; % 码相位梯度符号[上一秒， 本秒]
    for j = 1:size(multiPara(i).pathIndex_1s, 1) % 1s数据的循环操作
        x_1s = multiPara(i).pathIndex_1s(j, 1);
        y_1s = multiPara(i).pathIndex_1s(j, 2);
        grads_1s = polyfit(timeIndex(x_1s:y_1s), multiPara(i).codeDelay(x_1s:y_1s), 1); % 1s数据的斜率
        delay_fit_1s = grads_1s(1)*timeIndex(x_1s:y_1s) + grads_1s(2); %延时的拟合值
        delay_fit_err_1s = multiPara(i).codeDelay(x_1s:y_1s) - delay_fit_1s;
        grad_conti_sign(1) = grad_conti_sign(2); % 保存上一秒值
        if grads_1s(1) > 0
            grad_conti_sign(2) = 1;
        else
            grad_conti_sign(2) = -1;
        end
        max_1s = max(multiPara(i).codeDelay(x_1s:y_1s)); % 1s数据中码相位延时最大值
        min_1s = min(multiPara(i).codeDelay(x_1s:y_1s)); % 1s数据中码相位延时最小值
        mean_1s = mean(multiPara(i).codeDelay(x_1s:y_1s)); % 1s数据中码相位延时平均值
        var_fitErr_1s = var(delay_fit_err_1s) / (max_1s - min_1s);
        % 判断原始数据中下一秒是否连续
        if j < size(multiPara(i).pathIndex_1s, 1) % 不是最后一秒数据
            if y_1s == (multiPara(i).pathIndex_1s(j+1,1)-1) % 下一秒数据连续
                conti_flag = 1;
            else
                conti_flag = 0;
            end
        else
            conti_flag = 0;
        end
        
        % 开始检测多径数据
        if running == 0
            % 开始监测，初始化参数
            x_start = 0; % 此轮检测的起始点
            y_end = 0; % 终点
            y_end_temp = 0; % 临时终点
%             y_end_temp_1 = 0; % 临时终点的临时点
            log_flag = 0;
            dopp_flag = 0;
            power_flag = 0;
            GEO_flag = 0; % 判断GEO持续时间 / 去除小于n秒的数据
            grad_delay_flag = 0 ; %判断仅有1s的数据的码相位斜率
            delay_flag = 0; % 删除延时过小的数据点
            grad_conti_sign(1) = 0; % 码相位梯度符号[上一秒， 本秒]
            % 监测逻辑：1、当梯度值小于阈值开始记录
            if (abs(grads_1s(1))<grad_start_1 && var_fitErr_1s>var_start) || (abs(grads_1s(1))<grad_start_2)
                x_start = x_1s;
                y_end_temp = y_1s;
                running = 1;
            end
        end
       %————————————————————开始各类条件判断————————————————————% pathIndex_Auto
        if running == 1
            max_temp = max(multiPara(i).codeDelay(x_start:y_end_temp)); % 临时数据中码相位延时最大值
            min_temp = min(multiPara(i).codeDelay(x_start:y_end_temp)); % 临时数据中码相位延时最小值
            mean_temp = mean(multiPara(i).codeDelay(x_start:y_end_temp)); % 临时数据中码相位延时平均值
            % 监测逻辑：2、当前秒的幅值与总均值的差不大于阈值，则记录y_end_temp_1
            if (abs(max_1s - mean_temp)<endRange) && (abs(min_1s - mean_temp)<endRange)
                % 监测逻辑：3、删除连续递增或递减的值，认为是过渡状态，此处判断过渡状态的条件有2条：
                % 1、连续递增（减）的斜率大于定值。     2、与拟合值差的方差小于定值
                if ~((abs(grads_1s(1))>=grad_conti) && (var_fitErr_1s<abs(var_conti*grads_1s(1))) &&...
                        ((grad_conti_sign(1)*grad_conti_sign(2)==1)||(grad_conti_sign(1)==0)))
                    y_end_temp = y_1s;
                end
                % 监测逻辑：2、大于阈值，则停止记录，并启动下一次检测
            else
                y_end = y_end_temp;
                log_flag = 1;% 启动下一次检测
                running = 0; % 启动下一次检测
            end
            % 原始数据中断
            if conti_flag == 0
                y_end = y_end_temp;
                log_flag = 1;
                running = 0; % 启动下一次检测
            end
        end % if start == 1
        
        % 数据记录
        if log_flag == 1 && y_end~=0
            % ——————————多径衰落频率门限检测：步骤1————————————
            if y_end - x_start > dopp_time_len
                % 多径载波相位的斜率
                dopp_fad_temp = polyfit(timeIndex(x_start:y_end), multiPara(i).contiPhase(x_start:y_end), 1);
                % 多径载波相位的整周数
                N_cycle = round(mean(abs(multiPara(i).contiPhase(x_start:y_end))) / 180);
                % 多径载波相位的极值
                contiPhase_max = max(abs(multiPara(i).contiPhase(x_start:y_end)));
                contiPhase_min = min(abs(multiPara(i).contiPhase(x_start:y_end)));
                % 多径载波相位的极值与180整周的差值的最大值
                contiPhase_N_cycle = max(abs(contiPhase_max-N_cycle*180), abs(contiPhase_min-N_cycle*180));
                if (dopp_fad_temp(1)<dopp_grad) && (contiPhase_N_cycle<dopp_range)
                    % 多径衰落频率校验未通过
                    dopp_flag = 1;
                end
            end
            % ———————————多径衰落频率门限检测：步骤2————————————
            if dopp_flag == 0
                % 多径载波相位的整周数
                contiPhase_mean = mean(abs(multiPara(i).contiPhase(x_start:y_end)));
                N_cycle = round(contiPhase_mean / 180);
                contiPhase_minus = abs(multiPara(i).contiPhase(x_start:y_end)) - 180 * N_cycle;
                target_Num = sum(abs(contiPhase_minus)<proba_rang); % 在180附近抖动的数量
                proba_dopp_real = target_Num/(y_end - x_start + 1);
                if proba_dopp_real >= proba_dopp
                    % 多径衰落频率校验未通过
                    dopp_flag = 1;
                end
            end
            
            % ———————————————GEO时间判断——————————————
            if ((y_end-x_start)<GEO_time_len) && strcmp(sheetName, 'BDS_GEO')
                GEO_flag = 1;
            end
            
            % ———————————————对1s钟数据做二次检测——————————————
            if (y_end-x_start) < 15
                grads_temp = polyfit(timeIndex(x_start:y_end), multiPara(i).codeDelay(x_start:y_end), 1);
                delay_fit_temp = grads_temp(1)*timeIndex(x_start:y_end) + grads_temp(2); %延时的拟合值
                delay_fit_err_temp = multiPara(i).codeDelay(x_start:y_end) - delay_fit_temp;
                var_fitErr_temp = var(delay_fit_err_temp);
                if (abs(grads_temp(1))>grad_less1s) && (var_fitErr_temp<abs(var_less1s*grads_temp(1)))
                    grad_delay_flag = 1;
                end
            end
            
            %————————————删除延时低于15米的多径————————————
            if strcmp(sys, 'BDS')
                time_Delay_thre = time_Delay;
            else
                time_Delay_thre = time_Delay * 1.7; % 考虑到GPS码片更长
            end
            proba_delay_real = sum(multiPara(i).codeDelay(x_start:y_end)<time_Delay_thre) / (y_end-x_start+1);
            if proba_delay_real >= proba_delay
                delay_flag = 1;
            end
            
            % —————————————多径能量衰落门限检测————————————
            if mean(multiPara(i).attenu(x_start:y_end))> power_atten
                power_flag = 1; %未通过
            end
            if dopp_flag == 0 && power_flag == 0 && GEO_flag == 0 && delay_flag == 0 && grad_delay_flag == 0
                % 数据记录
                auto_Num = auto_Num + 1;
                multiPara(i).pathIndex_Auto(auto_Num , 1) = x_start;
                multiPara(i).pathIndex_Auto(auto_Num , 2) = y_end;
            end
            log_flag = 0;
            
        end % if log_flag == 1 && y_end~=0
    end % for j = 1:size(multiPara(i).pathIndex_1s, 1) % 1s数据的循环操作
end % for i = 1:3