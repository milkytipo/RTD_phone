function [para_All] = codeDelay_manual(delay_xvalues, para_All)
%—————再次去除不可靠的点——————————%
BlockNum = length(delay_xvalues) - 1;
del_num = 0;
del_col = [];
delNumBlock_cnt = zeros(1, BlockNum);
delNumBlock_cnt_75 = zeros(1, BlockNum);
delNumBlock_cnt_90 = zeros(1, BlockNum);
for i = 1 : size(para_All, 1)
    % —————小于15度仰角————————%
    if para_All(i, 4) < 15
        delNumBlock_All = [...
                5 , 5 , 24, 0 , 5,...
                25, 0 , 0 , 0 , 8 ,...
                0 , 0 , 5 , 5 , 13,...
                9, 3 , 0 , 0 , 0 ,...
                5 , 15, 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ...
                ];
        % 按延时删除数据
        for k = 1 : BlockNum
            if para_All(i, 1)>delay_xvalues(k) && para_All(i, 1)<=delay_xvalues(k+1)
                if delNumBlock_cnt(k) < delNumBlock_All(k)
                    del_num = del_num + 1;
                    del_col(del_num) = i;
                    delNumBlock_cnt(k) = delNumBlock_cnt(k) +1;
                end
            end
        end
        
        
       
        
        
    end
    % —————小于30度仰角————————%
    if para_All(i, 4) > 15 && para_All(i, 4)<30
        delNumBlock_All = [...
                 0 , 50 , 0, 0 , 0,...
                0, 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 00,...
                0, 45 , 50 , 30 , 0 ,...
                0 , 0, 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 ,0,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ...
                ];
         % 按延时删除数据
        for k = 1 : BlockNum
            if para_All(i, 1)>delay_xvalues(k) && para_All(i, 1)<=delay_xvalues(k+1)
                if delNumBlock_cnt(k) < delNumBlock_All(k)
                    del_num = del_num + 1;
                    del_col(del_num) = i;
                    delNumBlock_cnt(k) = delNumBlock_cnt(k) +1;
                end
            end
        end %  for k = 1 : BlockNum
    end %   if para_All(i, 4) > 15 && para_All(i, 4)<30
    
    % —————小于45度仰角————————%
    if para_All(i, 4) > 30 && para_All(i, 4) < 45
        delNumBlock_All = [...
                 15 , 0 , 0, 0 , 0,...
                35, 40 , 0 , 0 , 40 ,...
                0 , 0 , 0 , 0 , 0,...
                30, 60 , 50 , 0 , 40 ,...
                0 , 0, 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 ,0,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ...
                ];
         % 按延时删除数据
        for k = 1 : BlockNum
            if para_All(i, 1)>delay_xvalues(k) && para_All(i, 1)<=delay_xvalues(k+1)
                if delNumBlock_cnt(k) < delNumBlock_All(k)
                    del_num = del_num + 1;
                    del_col(del_num) = i;
                    delNumBlock_cnt(k) = delNumBlock_cnt(k) +1;
                end
            end
        end %  for k = 1 : BlockNum
    end %   ipara_All(i, 4) > 30 && para_All(i, 4) < 45
    
    % —————小于60度仰角————————%
    if para_All(i, 4)>45 &&  para_All(i, 4)<60
        delNumBlock_All = [...
                 100 , 0 , 0, 40 ,20,...
                0, 0 , 0 , 0 , 70 ,...
                0 , 00 , 0 , 0 , 30,...
                0, 0 , 0 , 30 , 0 ,...
                0 , 0, 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 ,0,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ...
                ];
         % 按延时删除数据
        for k = 1 : BlockNum
            if para_All(i, 1)>delay_xvalues(k) && para_All(i, 1)<=delay_xvalues(k+1)
                if delNumBlock_cnt(k) < delNumBlock_All(k)
                    del_num = del_num + 1;
                    del_col(del_num) = i;
                    delNumBlock_cnt(k) = delNumBlock_cnt(k) +1;
                end
            end
        end %  for k = 1 : BlockNum
    end %  if para_All(i, 4)>45 &&  para_All(i, 4)<60
    % —————小于75度仰角————————%
    if para_All(i, 4)>60  &&  para_All(i, 4)<75
         delNumBlock_All = [...
                 100 , 28 , 0, 0 ,0,...
                0, 0 , 0 , 0 , 0 ,...
                0 , 00 , 0 , 0 , 0,...
                0, 0 , 0 , 0 , 0 ,...
                0 , 0, 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 ,0,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ...
                ];
         % 按延时删除数据
        for k = 1 : BlockNum
            if para_All(i, 1)>delay_xvalues(k) && para_All(i, 1)<=delay_xvalues(k+1)
                if delNumBlock_cnt_75(k) < delNumBlock_All(k)
                    del_num = del_num + 1;
                    del_col(del_num) = i;
                    delNumBlock_cnt_75(k) = delNumBlock_cnt_75(k) +1;
                end
            end
        end %  for k = 1 : BlockNum
    end  %  if para_All(i, 4)>60  &&  para_All(i, 4)<75
    % —————————  小于90度仰角  ——————————%
    
    if para_All(i, 4)>75
        if para_All(i, 1)>350
            del_num = del_num + 1;
            del_col(del_num) = i;
        end
        delNumBlock_All = [...
                 0 , 8 , 0, 0 ,0,...
                0, 0 , 0 , 1 , 0 ,...
                0 , 1 , 0 , 1 , 1,...
                0, 0 , 0 , 0 , 0 ,...
                0 , 0, 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 ,0,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ...
                ];
         % 按延时删除数据
        for k = 1 : BlockNum
            if para_All(i, 1)>delay_xvalues(k) && para_All(i, 1)<=delay_xvalues(k+1)
                if delNumBlock_cnt_90(k) < delNumBlock_All(k)
                    del_num = del_num + 1;
                    del_col(del_num) = i;
                    delNumBlock_cnt_90(k) = delNumBlock_cnt_90(k) +1;
                end
            end
        end %  for k = 1 : BlockNum
    end % if para_All(i, 4)>75
    
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 add_15 = [250, 7.1, 0.02, 10, 10, 1;
            250, 7.1, 0.02, 10, 10, 1;
            250, 7.1, 0.02, 10, 10, 1;
            250, 7.1, 0.02, 10, 10, 1;
            250, 7.1, 0.02, 10, 10, 1;
            250, 7.1, 0.02, 10, 10, 1;
            250, 7.1, 0.02, 10, 10, 1;
            250, 7.1, 0.02, 10, 10, 1;
            250, 7.1, 0.02, 10, 10, 1;
            250, 7.1, 0.02, 10, 10, 1;
            250, 7.1, 0.02, 10, 10, 1;
            250, 7.1, 0.02, 10, 10, 1;
            250, 7.1, 0.02, 10, 10, 1;
            250, 7.1, 0.02, 10, 10, 1;
            250, 7.1, 0.02, 10, 10, 1;
            250, 7.1, 0.02, 10, 10, 1;
            250, 7.1, 0.02, 10, 10, 1;
            250, 7.1, 0.02, 10, 10, 1;
            250, 7.1, 0.02, 10, 10, 1;
            250, 7.1, 0.02, 10, 10, 1;
            250, 7.1, 0.02, 10, 10, 1;
            290, 7.1, 0.02, 10, 10, 1;
            290, 7.1, 0.02, 10, 10, 1;
            290, 7.1, 0.02, 10, 10, 1;
            290, 7.1, 0.02, 10, 10, 1;
            110, 7.1, 0.02, 10, 10, 1;
            110, 7.1, 0.02, 10, 10, 1;
            110, 7.1, 0.02, 10, 10, 1;
            110, 7.1, 0.02, 10, 10, 1];
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num_1 = 30;
num_2 = num_1 + 100;
num_3 = num_2 +10;
add_30 = zeros(num_3, 6);
for j = 1 : num_1
    add_30(j, :) = [150, 7.1, 0.02, 20, 10, 1];
end
for j = num_1+1 : num_2
    add_30(j, :) = [180, 7.1, 0.02, 20, 10, 1];
end
for j = num_2+1 : num_3
    add_30(j, :) = [220, 7.1, 0.02, 20, 10, 1];
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num_1 = 5;
num_2 = num_1 + 45;
num_3 = num_2 +0;
add_45 = zeros(num_3, 6);
for j = 1 : num_1
    add_45(j, :) = [360, 7.1, 0.02, 40, 10, 1];
end
for j = num_1+1 : num_2
    add_45(j, :) = [420, 7.1, 0.02, 40, 10, 1];
end
for j = num_2+1 : num_3
    add_45(j, :) = [220, 7.1, 0.02, 40, 10, 1];
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num_1 = 30;
num_2 = num_1 + 40;
num_3 = num_2 +10;
add_60 = zeros(num_3, 6);
for j = 1 : num_1
    add_60(j, :) = [180, 7.1, 0.02, 50, 10, 1];
end
for j = num_1+1 : num_2
    add_60(j, :) = [210, 7.1, 0.02, 50, 10, 1];
end
for j = num_2+1 : num_3
    add_60(j, :) = [360, 7.1, 0.02, 50, 10, 1];
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num_1 = 8;
num_2 = num_1 + 0;
num_3 = num_2 +0;
add_75 = zeros(num_3, 6);
for j = 1 : num_1
    add_75(j, :) = [90, 7.1, 0.02, 70, 10, 1];
end
for j = num_1+1 : num_2
    add_75(j, :) = [210, 7.1, 0.02, 70, 10, 1];
end
for j = num_2+1 : num_3
    add_75(j, :) = [360, 7.1, 0.02, 70, 10, 1];
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

num_1 = 4;
num_2 = num_1 + 4;
num_3 = num_2 +3;
num_4 = num_3 +1;
num_5 = num_4 +1;
add_90 = zeros(num_3, 6);
for j = 1 : num_1
    add_90(j, :) = [50, 7.1, 0.02, 80, 10, 1];
end
for j = num_1+1 : num_2
    add_90(j, :) = [70, 7.1, 0.02, 80, 10, 1];
end
for j = num_2+1 : num_3
    add_90(j, :) = [140, 7.1, 0.02, 80, 10, 1];
end
for j = num_3+1 : num_4
    add_90(j, :) = [210, 7.1, 0.02, 80, 10, 1];
end
for j = num_4+1 : num_5
    add_90(j, :) = [230, 7.1, 0.02, 80, 10, 1];
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
para_All(del_col, :) = [];
para_All = [para_All; add_15; add_30; add_45;add_60;add_90;add_75];
end