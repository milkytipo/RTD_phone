function [idxExp] = clusterMerge(idxExp, smoothIndex)
part_N = size(smoothIndex, 1);

for i = 1 : part_N
    st = smoothIndex(i, 1);
    ed = smoothIndex(i, 2);
    idxTemp = mode(idxExp(st:ed)); % ÕÒ³öÖÚÊý
    idxExp(st:ed) = idxTemp;
end