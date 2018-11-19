function tag_cell = ADD_Tag_1(curve_num,Counting_U0)
if 0 == Counting_U0
    if 1 == curve_num
        tag_cell = {'unit1'};
    elseif 2 == curve_num
        tag_cell= {'unit1','unit2'};
    elseif 3 == curve_num
        tag_cell = {'unit1','unit2','unit3'};
    elseif 4 == curve_num
        tag_cell = {'unit1','unit2','unit3','unit4'};
    elseif 5 == curve_num
        tag_cell = {'unit1','unit2','unit3','unit4','unit5'};
    elseif 6 == curve_num
        tag_cell = {'unit1','unit2','unit3','unit4','unit5','unit6'};
    elseif 7 == curve_num
        tag_cell = {'unit1','unit2','unit3','unit4','unit5','unit6','unit7'};
    elseif 8 == curve_num
        tag_cell = {'unit1','unit2','unit3','unit4','unit5','unit6','unit7','unit8'};
    elseif 9 == curve_num
        tag_cell = {'unit1','unit2','unit3','unit4','unit5','unit6','unit7','unit8','unit9'};
    end
elseif 1 == Counting_U0
    if 1 == curve_num
        tag_cell = {'unit0'};
    elseif 2 == curve_num
        tag_cell = {'unit0','unit1'};
    elseif 3 == curve_num
        tag_cell = {'unit0','unit1','unit2'};
    elseif 4 == curve_num
        tag_cell = {'unit0','unit1','unit2','unit3'};
    elseif 5 == curve_num
        tag_cell = {'unit0','unit1','unit2','unit3','unit4'};
    elseif 6 == curve_num
        tag_cell = {'unit0','unit1','unit2','unit3','unit4','unit5'};
    elseif 7 == curve_num
        tag_cell = {'unit0','unit1','unit2','unit3','unit4','unit5','unit6'};
    elseif 8 == curve_num
        tag_cell = {'unit0','unit1','unit2','unit3','unit4','unit5','unit6','unit7'};
    elseif 9 == curve_num
        tag_cell = {'unit0','unit1','unit2','unit3','unit4','unit5','unit6','unit7','unit8'};
    elseif 10 == curve_num
        tag_cell = {'unit0','unit1','unit2','unit3','unit4','unit5','unit6','unit7','unit8','unit9'};
    end
end