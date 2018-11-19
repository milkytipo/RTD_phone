function [predictResult, Predi_SVM_bin] = resultAnalysis(valPredi_SVM_Num, standard_Num, fileNum, timeLen)
file_index = zeros(fileNum, 2);
predictResult = zeros(fileNum, fileNum+2);
Predi_SVM_bin = -1*ones(length(valPredi_SVM_Num), 1);
index_temp = 0;
for i = 1 : fileNum
    file_index(i, 1) = index_temp + 1;
    file_index(i, 2) = index_temp + timeLen(i);
    index_temp = index_temp + timeLen(i);
end

for i = 1 : fileNum
    k_1 = file_index(i, 1);
    k_2 = file_index(i, 2);
    for j = 1 : fileNum
        totalNum = k_2 - k_1 + 1;
        ture_index = find(valPredi_SVM_Num(k_1:k_2) == j);
        ture_index = ture_index + k_1 - 1;
        if i == j
            Predi_SVM_bin(ture_index) = 1;
        end
        classNum = length(ture_index);
        predictResult(i, j) = classNum / totalNum;
    end
    predictResult(i, fileNum+1) = predictResult(i, i);
    predictResult(i, fileNum+2) = 1- predictResult(i, i);
end
predictResult = predictResult';

end
