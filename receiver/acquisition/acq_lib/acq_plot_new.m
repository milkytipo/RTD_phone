function acq_plot_new(SYST,array,fd_search,peak_freq_idx, peak_code_idx, sv)
% 冷捕获结果绘图

if strcmp(SYST,'BDS_B1I')
    Title = ['Acq BDS_B1I PRN=',num2str(sv)];
    %Len = 2046;
elseif strcmp(SYST,'GPS_L1CA')
    Title = ['Acq GPS_L1CA PRN=',num2str(sv)];
    %Len = 1023;
end
[~, sampN] = size(array);

figure('Name',Title,'NumberTitle','off');

% subplot(2,1,1);
% plot(Len*(0:sampN-1)/sampN, array(peak_freq_idx,:));
% xlabel('码片/samples');ylabel('相关值');
% set(gca,'FontSize',14); % 设置文字大小，同时影响坐标轴标注、图例、标题等。
% set(get(gca,'XLabel'),'FontSize',14);%图上文字为8 point或小5号
% set(get(gca,'YLabel'),'FontSize',14);

subplot(2,1,1);
plot((0:sampN-1), array(peak_freq_idx,:));
xlabel('码相位/samples');ylabel('相关值')
set(gca,'FontSize',14); % 设置文字大小，同时影响坐标轴标注、图例、标题等。
set(get(gca,'XLabel'),'FontSize',14);%图上文字为8 point或小5号
set(get(gca,'YLabel'),'FontSize',14);

subplot(2,1,2);
plot(fd_search,array(:,peak_code_idx));

xlabel('多普勒频移 [Hz]');ylabel('相关值')
set(get(gca,'XLabel'),'FontSize',14);%图上文字为8 point或小5号
set(get(gca,'YLabel'),'FontSize',14);

