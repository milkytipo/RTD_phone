function fadFreq_mean(X1, YMatrix1, Y1)
%CREATEFIGURE(X1, YMATRIX1, Y1)
%  X1:  x 数据的矢量
%  YMATRIX1:  y 数据的矩阵
%  Y1:  y 数据的矢量

%  由 MATLAB 于 31-Aug-2017 17:18:07 自动生成

% 创建 figure
figure('InvertHardcopy','off','Color',[1 1 1]);

% 创建 axes
axes1 = axes;
hold(axes1,'on');

% 激活坐标轴的 left 侧
yyaxis(axes1,'left');
% 使用 plot 的矩阵输入创建多行
plot1 = plot(X1,YMatrix1,'LineWidth',3);
set(plot1(1),'DisplayName','MEO');
set(plot1(2),'DisplayName','IGSO','Color',[0 0.498039215803146 0]);

% 创建 ylabel
ylabel('Mean of NGEO satellite (Hz)');

% 设置其余坐标轴属性
set(axes1,'YColor',[0 0.447 0.741]);
% 取消以下行的注释以保留坐标轴的 Y 范围
ylim(axes1,[0 0.12]);
% 激活坐标轴的 right 侧
yyaxis(axes1,'right');
% 创建 plot
plot(X1,Y1,'DisplayName','GEO','LineWidth',3,'Color',[1 0 0]);

% 创建 ylabel
ylabel('Mean of GEO satellite (Hz)','FontSize',26.4);

% 设置其余坐标轴属性
set(axes1,'YColor',[0.85 0.325 0.098]);
% 取消以下行的注释以保留坐标轴的 Y 范围
ylim(axes1,[0 0.0012]);
% 取消以下行的注释以保留坐标轴的 X 范围
xlim(axes1,[0 90]);
% 取消以下行的注释以保留坐标轴的 Z 范围
zlim(axes1,[-1 0]);
box(axes1,'on');
% 设置其余坐标轴属性
set(axes1,'FontName','Arial','FontSize',24,'FontWeight','bold');
% 创建 legend
legend1 = legend(axes1,'show');
set(legend1,...
    'Position',[0.749094043703852 0.760667164506039 0.127340821700447 0.170825331087534],...
    'FontSize',18);

