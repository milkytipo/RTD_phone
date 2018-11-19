function trk_results_plot_1(h, figure_num, timeaxis, plottingresults_mt, unit_active_mt, CadUnitMax, IsSubplot,...
                            xlabel_name, ylabel_name, title_name, legend_str, colors)
% INPUT:
% h:                  -current figure handle.
% figure_num:         -subplot number, also corresponding to number of curves.
% timeaxis:           -time axis (x-axis) sequence.
% plottingresults_mt: -the aimed curve to plot, a matrix type means several curves to be plotted;
%                      the row-wise is along the unit direction, and the column-wise is along the
%                      time sequence direction.
% unit_active_mt:     -units active flag matrix; the row-wise is along the unit direction, and the 
%                      column-wise is along the time sequence direction.
% CadUnitMax:         -maximal supported number of units.
% IsSubplot:          -subplot flag, IsSubplot==1 means that all curves are plotted in different
%                      subplots.
% xlabel_name:        - x axis label name.
% ylabel_name:        - y axis label name.
% title_name:         - titile name.
% colors:             - for plot

%% Error checking
if size(plottingresults_mt,1)~=size(unit_active_mt,1)
    error('trk_results_plot: the row of plottingresults_mt is not matched with the row of unit_active_mt');
end

[r,c]=size(timeaxis);
if r~=1 && c~=1
    error('trk_results_plot: timeaxis is not a vector');
elseif r>c
    timeaxis = reshape(timeaxis, 1, r);
end
if size(plottingresults_mt,2)~=size(timeaxis,2)
    error('trk_results_plot: the col of plottingresults_mt is not matched with the col of timeaxis');
end

units_num = size(plottingresults_mt,1);
if units_num<CadUnitMax
    error('trk_results_plot: Units number is smaller than subfignum or CadUnitMax');
end

trk_num = size(timeaxis, 2);

%set a array of colors
hx_vt = [];

%% Plotting
if IsSubplot
    for i = 1:CadUnitMax
        if sum( unit_active_mt(i,:) )
            subplot(figure_num,1,i);
            
            indx = 0;
            while 1
                indtmp1 = find(unit_active_mt(i, indx+1:end)==1, 1, 'first');
                if isempty(indtmp1)
                    break;
                end
                indx = indx + indtmp1;
                
                indtmp2 = find(unit_active_mt(i, indx+1:end)==0, 1, 'first');
                if isempty(indtmp2)
                    indtmp2 = trk_num - indx +1;
                end
                plot(timeaxis(indx : indx+indtmp2-1), plottingresults_mt(i, indx : indx+indtmp2-1), 'color', colors(i + 1, :));
                hold on;
                
                indx = indx+indtmp2-1;
                if indx>=trk_num
                    break;
                end
            end
            xlim([timeaxis(1) timeaxis(trk_num)]);
            ylabel(ylabel_name)
            title(strcat(title_name, num2str(i-1)));
        end
    end
    xlabel(xlabel_name)
    
else
    
    for i = 1:CadUnitMax
        flag = 1;
        if sum( unit_active_mt(i,:) )
            indx = 0;
            while 1
                indtmp1 = find(unit_active_mt(i, indx+1:end)==1, 1, 'first');
                if isempty(indtmp1)
                    break;
                end
                indx = indx + indtmp1;
                
                indtmp2 = find(unit_active_mt(i, indx+1:end)==0, 1, 'first');
                if isempty(indtmp2)
                    indtmp2 = trk_num - indx +1;
                end
                hx = plot(h, timeaxis(indx : indx+indtmp2-1), plottingresults_mt(i, indx : indx+indtmp2-1), 'color', colors(i + 1, :));
                if flag
                    hx_vt(i)=hx;
                end
                flag = 0;
                hold on;
                
                indx = indx+indtmp2-1;
                if indx>=trk_num
                    break;
                end
            end%EOF "while 1"
        end%EOF "sum( unit_active_mt(i,:) )"
    end%EOF "i = 1:CadUnitMax"
    xlim(h, [timeaxis(1) timeaxis(trk_num)]);
    ylabel(h, ylabel_name), xlabel(xlabel_name)
    title(h, title_name);
    if ~isempty(legend_str)
        len1 = length(hx_vt);
        len2 = length(legend_str);
        len = min(len1,len2);
        legend(hx_vt(1:len),legend_str(1:len));
    end
end%EOF "if figure_num>0"


end%EOF function