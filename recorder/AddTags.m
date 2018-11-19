function AddTags(temp,num)
if 1 == num
    if 1 == temp
        legend('unit1');
    elseif 2 == temp
        legend('unit1','unit2');
    elseif 3 == temp
        legend('unit1','unit2','unit3');
    elseif 4 == temp
        legend('unit1','unit2','unit3','unit4');
    elseif 5 == temp
        legend('unit1','unit2','unit3','unit4','unit5');
    elseif 6 == temp
        legend('unit1','unit2','unit3','unit4','unit5','unit6');
    elseif 7 == temp
        legend('unit1','unit2','unit3','unit4','unit5','unit6','unit7');
    elseif 8 == temp
        legend('unit1','unit2','unit3','unit4','unit5','unit6','unit7','unit8');
    elseif 9 == temp
        legend('unit1','unit2','unit3','unit4','unit5','unit6','unit7','unit8','unit9');
    end
elseif 0 == num
    if 1 == temp
        legend('unit0');
    elseif 2 == temp
        legend('unit0','unit1');
    elseif 3 == temp
        legend('unit0','unit1','unit2');
    elseif 4 == temp
        legend('unit0','unit1','unit2','unit3');
    elseif 5 == temp
        legend('unit0','unit1','unit2','unit3','unit4');
    elseif 6 == temp
        legend('unit0','unit1','unit2','unit3','unit4','unit5');
    elseif 7 == temp
        legend('unit0','unit1','unit2','unit3','unit4','unit5','unit6');
    elseif 8 == temp
        legend('unit0','unit1','unit2','unit3','unit4','unit5','unit6','unit7');
    elseif 9 == temp
        legend('unit0','unit1','unit2','unit3','unit4','unit5','unit6','unit7','unit8');
    elseif 10 == temp
        legend('unit0','unit1','unit2','unit3','unit4','unit5','unit6','unit7','unit8','unit9');
    end
end