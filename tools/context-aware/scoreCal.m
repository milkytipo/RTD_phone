function [ValiIndex] = scoreCal(ValiIndex, ValiIndex_temp, Num)

% 迭代求均值法
ValiIndex.JC = ValiIndex.JC*(Num-1)/Num + ValiIndex_temp.JC/Num;
ValiIndex.FMI = ValiIndex.FMI*(Num-1)/Num + ValiIndex_temp.FMI/Num;
ValiIndex.RI = ValiIndex.RI*(Num-1)/Num + ValiIndex_temp.RI/Num;
ValiIndex.DBI = ValiIndex.DBI*(Num-1)/Num + ValiIndex_temp.DBI/Num;
ValiIndex.DI = ValiIndex.DI*(Num-1)/Num + ValiIndex_temp.DI/Num;