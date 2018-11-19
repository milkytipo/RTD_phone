function [idxExp] = idxSort(idxExp_raw, cnrMeanRaw)
% 将类别标号重新排序
Num = max(idxExp_raw); % 总类别数
idxMod = zeros(Num, 2); % [num, cnr]
idxExp = zeros(length(idxExp_raw), 1);

for i = 1 : Num
    idxMod(i, 1) = i;
    line = idxExp_raw==i;
    idxMod(i, 2) = mean(cnrMeanRaw(line));
end
idxMod = sortrows(idxMod, 2);% 标号调整方式

for i = 1 : Num
   line = idxExp_raw==i;
   idxExp(line) = find(idxMod(:, 1)==i);
end