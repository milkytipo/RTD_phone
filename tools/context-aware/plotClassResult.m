function [valPredi_Num, standard_Num] = plotClassResult(valPredi, class_name, N, class_name_all)
% 蛍窃潤惚�塋�
fNum = 6;
valPredi_Num = zeros(N, 1);
standard_Num = zeros(N, 1);
valPredi_plot = zeros(fNum, N);
standard_plot = zeros(fNum, N);

for j = 1 : fNum
    index_1 = valPredi == class_name_all(j);
    valPredi_Num(index_1) = j;
    valPredi_plot(j, index_1) = 1;
    index_2 = class_name == class_name_all(j);
    standard_Num(index_2) = j;
    standard_plot(j, index_2) = 1;
end



% 
% for j = 1 : N
%     switch valPredi(j)
%         case categorical({'canyon'})
%             valPredi_Num(j) = 1;
%             valPredi_plot(1, j) = 1;
%         case categorical({'urban'})
%             valPredi_Num(j) = 2;
%             valPredi_plot(2, j) = 1;
%         case categorical({'surburb'})
%             valPredi_Num(j) = 3;
%             valPredi_plot(3, j) = 1;
%         case categorical({'viaduct_up'})
%             valPredi_Num(j) = 4;
%             valPredi_plot(4, j) = 1;
%         case categorical({'viaduct_down'})
%             valPredi_Num(j) = 5;
%             valPredi_plot(5, j) = 1;
%         case categorical({'boulevard'})
%             valPredi_Num(j) = 6;
%             valPredi_plot(6, j) = 1;
%     end % switch valPredi(j)
%     
%     switch class_name(j)
%         case categorical({'canyon'})
%             standard_Num(j) = 1;
%             standard_plot(1, j) = 1;
%         case categorical({'urban'})
%             standard_Num(j) = 2;
%             standard_plot(2, j) = 1;
%         case categorical({'surburb'})
%             standard_Num(j) = 3;
%             standard_plot(3, j) = 1;
%         case categorical({'viaduct_up'})
%             standard_Num(j) = 4;
%             standard_plot(4, j) = 1;
%         case categorical({'viaduct_down'})
%             standard_Num(j) = 5;
%             standard_plot(5, j) = 1;
%         case categorical({'boulevard'})
%             standard_Num(j) = 6;
%             standard_plot(6, j) = 1;
%     end  % switch class_name(j) 
% end % for j = 1 : N

%% ！！！！！！！！！！ 鮫夕 ！！！！！！！！！！！！！！% 

% figure();
% plot(enuMap(1, :), enuMap(2, :), '.');
% scatter(enuMap(1, :), enuMap(2, :), 7, standard_Num, 'filled');
% title('standard')
% colormap(jet(fNum));
% 
% figure();
% plot(enuMap(1, :), enuMap(2, :), '.');
% scatter(enuMap(1, :), enuMap(2, :), 7, valPredi_Num, 'filled');
% title(Name)
% colormap(jet(fNum));

figure();
plotconfusion(standard_plot, valPredi_plot);

end % function