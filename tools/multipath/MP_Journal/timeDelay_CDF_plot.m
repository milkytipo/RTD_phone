function timeDelay_CDF_plot(X1, YMatrix1)
%CREATEFIGURE(X1, YMATRIX1)
%  X1:  x 数据的矢量
%  YMATRIX1:  y 数据的矩阵

%  由 MATLAB 于 30-Aug-2017 21:36:05 自动生成

% 创建 figure
figure('InvertHardcopy','off','PaperSize',[20.99999864 29.69999902],...
    'Color',[1 1 1]);

% 创建 axes
axes1 = axes;
hold(axes1,'on');

% 使用 plot 的矩阵输入创建多行
plot1 = plot(X1,YMatrix1,'LineWidth',3);
set(plot1(1),'DisplayName','elevation (0,15)','Color',[0 0 0]);
set(plot1(2),'DisplayName','elevation (15,30)',...
    'Color',[0.749019622802734 0 0.749019622802734]);
set(plot1(3),'DisplayName','elevation (30,45)',...
    'Color',[0 0.447058826684952 0.74117648601532]);
set(plot1(4),'DisplayName','elevation (45,60)',...
    'Color',[0.466666668653488 0.674509823322296 0.18823529779911]);
set(plot1(5),'DisplayName','elevation (60,75)',...
    'Color',[0.929411768913269 0.694117665290833 0.125490203499794]);
set(plot1(6),'DisplayName','elevation (75,90)',...
    'Color',[0.800000011920929 0 0]);

% 创建 xlabel
xlabel({'Time delay (m)'},'Margin',2,'FontWeight','bold','FontName','Arial');

% 创建 title
title({''},'Margin',2,'FontName','Arial');

% 创建 ylabel
ylabel({'Cumulative distribution'},'Margin',2,'FontWeight','bold',...
    'FontName','Arial');

% 取消以下行的注释以保留坐标轴的 X 范围
xlim(axes1,[0 1000]);
% 取消以下行的注释以保留坐标轴的 Y 范围
ylim(axes1,[0 1]);
% 取消以下行的注释以保留坐标轴的 Z 范围
zlim(axes1,[-1 1]);
box(axes1,'on');
grid(axes1,'on');
% 设置其余坐标轴属性
set(axes1,'FontName','Arial','FontSize',24,'FontWeight','bold','XMinorGrid',...
    'on','YMinorGrid','on','YTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1],...
    'YTickLabel',...
    {'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1'},...
    'ZMinorGrid','on');
% 创建 legend
legend1 = legend(axes1,'show');
set(legend1,...
    'Position',[0.660899653979238 0.583806949823068 0.297298578395001 0.273510963939201],...
    'FontSize',18,...
    'EdgeColor',[0 0 0]);

