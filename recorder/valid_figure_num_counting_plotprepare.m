function [fign]=valid_figure_num_counting_plotprepare(unit_active_mt, CadUnitMax)
%INPUT:
% unit_active_mt:     -units active flag matrix, Unit_MAX_N(maximal supported units in Mex) x
%                      Trk_N(stored tracking data number);
% CadUnitMax:         -maximal units specified in matlab (CadUnitMax<=Unit_MAX_N)
%OUTPUT:
% fign:               -currently and previously actived number of units

[r,c]=size(unit_active_mt);
if r < CadUnitMax
    error('CadUnitMax should be no greater than Unit_MAX_N in unit_active_mt');
end

fign = 0;

for i = 1:CadUnitMax
    if sum( unit_active_mt(i,:) )
       fign = fign+1;
    end
end
