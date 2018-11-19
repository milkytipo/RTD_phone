close all;
file_index = zeros(fileNum, 2);
classNum_index = zeros(N, 1);
feature_used = [feature(:, 3), feature(:, 4), feature(:, 5), feature(:, 7), feature(:, 8)];
feature_statis_mean = zeros(fileNum, 6);
feature_statis_var = zeros(fileNum, 6);

index_temp = 0;
for i = 1 : fileNum
    file_index(i, 1) = index_temp + 1;
    file_index(i, 2) = index_temp + timeLen(i);
    classNum_index(file_index(i,1) : file_index(i,2)) = i;
    index_temp = index_temp + timeLen(i);
    for j = 1 : 5
        feature_statis_mean(i, j) = mean(feature_used(file_index(i,1):file_index(i,2), j));
        feature_statis_var(i, j) = var(feature_used(file_index(i,1):file_index(i,2), j));
    end
end




cnrMean_1 = feature(file_index(1,1):file_index(1,2), 3);
cnrVar_1 = feature(file_index(1,1):file_index(1,2), 4);
cnrFluc_1 = feature(file_index(1,1):file_index(1,2), 5);
blockProp_1 = feature(file_index(1,1):file_index(1,2), 7);
GDOP_ratio_1 = feature(file_index(1,1):file_index(1,2), 8);
ENU_error_6 = feature(file_index(6,1):file_index(6,2), 9);

























if 0   
    for i = 1 : 5
        figure();
        axes1 = axes;
        boxplot(feature_used(:,i), classNum_index);
        title(predictorNames{i});
    %     % 创建 ylabel
    %     ylabel('Fluctuation of power (dB)');
    %     % 创建 xlabel
        xlabel('Environment type');
    %     % 取消以下行的注释以保留坐标区的 X 范围
        xlim(axes1,[0.5 6.5]);
    %     % 取消以下行的注释以保留坐标区的 Y 范围
    %     % ylim(axes1,[-0.42085136649166 11.4119157246851]);
    %     box(axes,'on');
    %     % 设置其余坐标区属性
        box(axes1,'on');
        set(axes1,'FontName','Arial','FontSize',16,'FontWeight','bold',...
            'TickLabelInterpreter','none','XTick',[1 2 3 4 5 6],'XTickLabel',...
            {'canyon','urban','suburb','viaduct-up','viaduct-down','boulevard'});

    end
 end

if 0
    scene = {'canyon', 'urban', 'surburb', 'viaduct_up', 'viaduct_down', 'boulevard'};
    for i = 1 : fileNum
        figure();
        plot(Predi_SVM_bin(file_index(i,1):file_index(i,2)));
        title(scene(i));

    end
end


% featureFile_canyon = feature(file_index(1,1):file_index(1,2), :);
% featureFile_urban = feature(file_index(2,1):file_index(2,2), :);
% featureFile_surburb = feature(file_index(3,1):file_index(3,2), :);
% featureFile_viaduct_up = feature(file_index(4,1):file_index(4,2), :);
% featureFile_viaduct_down = feature(file_index(5,1):file_index(5,2), :);
% featureFile_boulevard = feature(file_index(6,1):file_index(6,2), :);