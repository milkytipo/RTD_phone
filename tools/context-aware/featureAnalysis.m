

file_index = zeros(fileNum, 2);
feature_statis_mean = zeros(fileNum, 5);
feature_statis_var = zeros(fileNum, 5);
feature_used = [feaCluster.paraRaw(:, 3), feaCluster.paraRaw(:, 4), feaCluster.paraRaw(:, 5), ...
    feaCluster.paraRaw(:, 7), feaCluster.paraRaw(:, 8)];
index_temp = 0;
classNum_index = zeros(sum(timeLen), 1);
classNum_name = categorical(sum(timeLen), 1);
for i = 1 : fileNum
    file_index(i, 1) = index_temp + 1;
    file_index(i, 2) = index_temp + timeLen(i);
    classNum_index(file_index(i,1) : file_index(i,2), 1) = i;
    classNum_name(file_index(i,1) : file_index(i,2), 1) = class_name_all(i);
    index_temp = index_temp + timeLen(i);
    for j = 1 : 5
        feature_statis_mean(i, j) = mean(feature_used(file_index(i,1):file_index(i,2), j));
        feature_statis_var(i, j) = var(feature_used(file_index(i,1):file_index(i,2), j));
    end
end

feaClass = table(classNum_name,feature_used(:,1),feature_used(:,2),feature_used(:,3),feature_used(:,4),feature_used(:,5),...
'VariableNames',{'className','cnrMean','cnrVar','cnrFluc','blockProp', 'GDOP_ratio'});
rm = fitrm(feaClass,'cnrMean-GDOP_ratio~className');
manovatbl = manova(rm);



figure()
boxplot(feature_used(:, 1), classNum_index);
figure()
boxplot(feature_used(:, 2), classNum_index);
figure()
boxplot(feature_used(:, 3), classNum_index);
figure()
boxplot(feature_used(:, 4), classNum_index);
figure()
boxplot(feature_used(:, 5), classNum_index);