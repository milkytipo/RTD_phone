
feature_NewData = table(cnrMean, cnrVar, cnrFluc, blockProp, GDOP_ratio);
yfit = trainedModel.predictFcn(feature_NewData);
yfit_Num = zeros(N, 1);
for j = 1 : 6
    index_1 = yfit == class_name_all(j);
    yfit_Num(index_1) = j;
end
figure();
scatter(feaCluster.pos_enu(:, 1), feaCluster.pos_enu(:, 2), 6, yfit_Num, 'filled');
title('NewDataPrediction');
colormap(hsv(6));
colorbar;