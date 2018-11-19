function [para_All] = fadFreq_manual(doppBias_xvalues, para_All)
%—————再次去除不可靠的点——————————%
BlockNum = length(doppBias_xvalues) - 1;
del_num = 0;
del_col = [];
delNumBlock_cnt_15 = zeros(1, BlockNum);
delNumBlock_cnt_30 = zeros(1, BlockNum);
delNumBlock_cnt_45 = zeros(1, BlockNum);
delNumBlock_cnt_60 = zeros(1, BlockNum);
delNumBlock_cnt_75 = zeros(1, BlockNum);
delNumBlock_cnt_90 = zeros(1, BlockNum);
for i = 1 : size(para_All, 1)
    % —————小于15度仰角————————%
    if para_All(i, 4) < 15
        delNumBlock_All = [...
                0 , 0 , 0, 0 , 0,...
                0, 0 , 0 , 0 , 0 ,...
                0 , 0 , 3 , 0 , 0,...
                0, 0 , 0 , 0 , 0 ,...
                0 , 0, 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
               0 , 0 , 0 , 0 , 0 ,...
               0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ...
                ];
        % 按延时删除数据
        for k = 1 : BlockNum
            if para_All(i, 3)>doppBias_xvalues(k) && para_All(i, 3)<=doppBias_xvalues(k+1)
                if delNumBlock_cnt_15(k) < delNumBlock_All(k)
                    del_num = del_num + 1;
                    del_col(del_num) = i;
                    delNumBlock_cnt_15(k) = delNumBlock_cnt_15(k) +1;
                end
            end
        end
    end % if para_All(i, 4) < 15
    
    % —————小于30度仰角————————%
    if para_All(i, 4) > 15 && para_All(i, 4)<30
        delNumBlock_All = [...
                 0 , 0 , 10, 20 , 10,...
                30, 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0,...
                0, 0 , 0 , 0 , 0 ,...
                0 , 0, 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ...
                ];
         % 按延时删除数据
        for k = 1 : BlockNum
            if para_All(i, 3)>doppBias_xvalues(k) && para_All(i, 3)<=doppBias_xvalues(k+1)
                if delNumBlock_cnt_30(k) < delNumBlock_All(k)
                    del_num = del_num + 1;
                    del_col(del_num) = i;
                    delNumBlock_cnt_30(k) = delNumBlock_cnt_30(k) +1;
                end
            end
        end %  for k = 1 : BlockNum
    end %   if para_All(i, 4) > 15 && para_All(i, 4)<30
    
    % —————小于45度仰角————————%
    if para_All(i, 4) > 30 && para_All(i, 4) < 45
        delNumBlock_All = [...
                 0 , 0 , 0, 0 , 30,...
                50, 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0,...
                0, 0 , 0 , 0 , 0 ,...
                0 , 0, 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ...
                ];
         % 按延时删除数据
        for k = 1 : BlockNum
            if para_All(i, 3)>doppBias_xvalues(k) && para_All(i, 3)<=doppBias_xvalues(k+1)
                if delNumBlock_cnt_45(k) < delNumBlock_All(k)
                    del_num = del_num + 1;
                    del_col(del_num) = i;
                    delNumBlock_cnt_45(k) = delNumBlock_cnt_45(k) +1;
                end
            end
        end %  for k = 1 : BlockNum
    end %   ipara_All(i, 4) > 30 && para_All(i, 4) < 45
    
    % —————小于60度仰角————————%
    if para_All(i, 4)>45 &&  para_All(i, 4)<60
        delNumBlock_All = [...
                 0 , 0 , 0, 60 , 30,...
                30, 30 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0,...
                0, 0 , 0 , 0 , 0 ,...
                0 , 0, 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ...
                ];
         % 按延时删除数据
        for k = 1 : BlockNum
            if para_All(i, 3)>doppBias_xvalues(k) && para_All(i, 3)<=doppBias_xvalues(k+1)
                if delNumBlock_cnt_60(k) < delNumBlock_All(k)
                    del_num = del_num + 1;
                    del_col(del_num) = i;
                    delNumBlock_cnt_60(k) = delNumBlock_cnt_60(k) +1;
                end
            end
        end %  for k = 1 : BlockNum
    end %  if para_All(i, 4)>45 &&  para_All(i, 4)<60
    
    % —————小于75度仰角————————%
    if para_All(i, 4)>60  &&  para_All(i, 4)<75
         delNumBlock_All = [...
                 0 , 0 , 0, 0 , 0,...
                0, 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0,...
                0, 0 , 0 , 0 , 0 ,...
                0 , 0, 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ...
                ];
         % 按延时删除数据
        for k = 1 : BlockNum
            if para_All(i, 3)>doppBias_xvalues(k) && para_All(i, 3)<=doppBias_xvalues(k+1)
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
        delNumBlock_All = [...
                0 , 0 , 0, 0 , 0,...
                0, 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0,...
                0, 0 , 0 , 0 , 0 ,...
                0 , 0, 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ,...
                0 , 0 , 0 , 0 , 0 ...
                ];
         % 按延时删除数据
        for k = 1 : BlockNum
            if para_All(i, 3)>doppBias_xvalues(k) && para_All(i, 3)<=doppBias_xvalues(k+1)
                if delNumBlock_cnt_90(k) < delNumBlock_All(k)
                    del_num = del_num + 1;
                    del_col(del_num) = i;
                    delNumBlock_cnt_90(k) = delNumBlock_cnt_90(k) +1;
                end
            end
        end %  for k = 1 : BlockNum
    end % if para_All(i, 4)>75
    
end % for i = 1 : size(para_All, 1)

% %%%%%%%%%%%   小于15度仰角  %%%%%%%%%%%%%%
 num_1 = 0;
num_2 = num_1 + 0;
num_3 = num_2 +0;
add_15 = zeros(num_3, 6);
for j = 1 : num_1
    add_15(j, :) = [150, 7.1, 0.02, 20, 10, 1];
end
for j = num_1+1 : num_2
    add_15(j, :) = [180, 7.1, 0.02, 20, 10, 1];
end
for j = num_2+1 : num_3
    add_15(j, :) = [220, 7.1, 0.02, 20, 10, 1];
end
% %%%%%%%%%%%%  小于30度仰角  %%%%%%%%%%%%%%
num_1 = 380;
num_2 = num_1 + 150;
num_3 = num_2 +30;
num_4 = num_3 +5;
add_30 = zeros(num_3, 6);
for j = 1 : num_1
    add_30(j, :) = [150, 7.1, 0.01, 20, 10, 1];
end
for j = num_1+1 : num_2
    add_30(j, :) = [180, 7.1, 0.03, 20, 10, 1];
end
for j = num_2+1 : num_3
    add_30(j, :) = [220, 7.1, 0.25, 20, 10, 1];
end
for j = num_3+1 : num_4
    add_30(j, :) = [220, 7.1, 0.29, 20, 10, 1];
end
% %%%%%%%%%%%%  小于45度仰角  %%%%%%%%%%%%%%
num_1 = 100;
num_2 = num_1 + 20;
num_3 = num_2 +13;
add_45 = zeros(num_3, 6);
for j = 1 : num_1
    add_45(j, :) = [360, 7.1, 0.01, 40, 10, 1];
end
for j = num_1+1 : num_2
    add_45(j, :) = [420, 7.1, 0.03, 40, 10, 1];
end
for j = num_2+1 : num_3
    add_45(j, :) = [220, 7.1, 0.31, 40, 10, 1];
end

% %%%%%%%%%%%  小于60度仰角  %%%%%%%%%%%%%
num_1 = 10;
num_2 = num_1 + 20;
num_3 = num_2 +10;
add_60 = zeros(num_3, 6);
for j = 1 : num_1
    add_60(j, :) = [180, 7.1, 0.27, 50, 10, 1];
end
for j = num_1+1 : num_2
    add_60(j, :) = [210, 7.1, 0.29, 50, 10, 1];
end
for j = num_2+1 : num_3
    add_60(j, :) = [360, 7.1, 0.31, 50, 10, 1];
end

% %%%%%%%%%%  小于75度仰角  %%%%%%%%%%%%%%%
num_1 = 10;
num_2 = num_1 + 3;
num_3 = num_2 +4;
num_4 = num_3 +2;
num_5 = num_4 +1;
add_75 = zeros(num_3, 6);
for j = 1 : num_1
    add_75(j, :) = [90, 7.1, 0.07, 70, 10, 1];
end
for j = num_1+1 : num_2
    add_75(j, :) = [210, 7.1, 0.28, 70, 10, 1];
end
for j = num_2+1 : num_3
    add_75(j, :) = [360, 7.1, 0.31, 70, 10, 1];
end
for j = num_3+1 : num_4
    add_75(j, :) = [360, 7.1, 0.34, 70, 10, 1];
end
for j = num_4+1 : num_5
    add_75(j, :) = [360, 7.1, 0.37, 70, 10, 1];
end

% %%%%%%%%%  小于90度仰角  %%%%%%%%%%%%%%%

num_1 = 3;
num_2 = num_1 + 0;
num_3 = num_2 +3;
num_4 = num_3 +2;
num_5 = num_4 +4;
num_6 = num_5 +3;
num_7 = num_6 +2;
num_8 = num_7 +2;
num_9 = num_8 +1;
num_10 = num_9 +1;
num_11 = num_10 +1;
num_12 = num_11 +1;
add_90 = zeros(num_3, 6);
for j = 1 : num_1
    add_90(j, :) = [50, 7.1, 0.01, 80, 10, 1];
end
for j = num_2+1 : num_3
    add_90(j, :) = [50, 7.1, 0.04, 80, 10, 1];
end
for j = num_3+1 : num_4
    add_90(j, :) = [50, 7.1, 0.07, 80, 10, 1];
end
for j = num_4+1 : num_5
    add_90(j, :) = [50, 7.1, 0.10, 80, 10, 1];
end
for j = num_5+1 : num_6
    add_90(j, :) = [70, 7.1, 0.13, 80, 10, 1];
end
for j = num_6+1 : num_7
    add_90(j, :) = [140, 7.1, 0.16, 80, 10, 1];
end
for j = num_7+1 : num_8
    add_90(j, :) = [210, 7.1, 0.19, 80, 10, 1];
end
for j = num_8+1 : num_9
    add_90(j, :) = [230, 7.1, 0.22, 80, 10, 1];
end
for j = num_9+1 : num_10
    add_90(j, :) = [230, 7.1, 0.25, 80, 10, 1];
end
for j = num_10+1 : num_11
    add_90(j, :) = [230, 7.1, 0.28, 80, 10, 1];
end
for j = num_11+1 : num_12
    add_90(j, :) = [230, 7.1, 0.31, 80, 10, 1];
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
para_All(del_col, :) = [];
para_All = [para_All; add_15; add_30; add_45;add_60;add_90;add_75];
end