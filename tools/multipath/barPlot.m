function [pool_norm, delay_x, pool_Num] = barPlot(xvalues, hist_step, paraValue)

pool_index_pre = 0;
pool_Num = zeros(1, length(xvalues)-1); % 直方图总统计个数
for j = 1 : length(paraValue)
    if ~isnan(paraValue(j)) && paraValue(j)>xvalues(1) && paraValue(j)<=xvalues(end)
        pool_index = ceil((paraValue(j) - xvalues(1))/hist_step);
        if pool_index<=length(pool_Num) && pool_index~=pool_index_pre
            pool_Num(pool_index) = pool_Num(pool_index) + 1;  % 统计值加1
        end
    end
    %pool_index_pre = pool_index;
end
pool_norm = pool_Num / sum(pool_Num) / hist_step;
delay_x = xvalues(2:end) - hist_step/2 ;
bar(delay_x, pool_norm);
