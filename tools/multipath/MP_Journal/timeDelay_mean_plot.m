function timeDelay_mean_plot(X1, Y1, X2, Y2)
%CREATEFIGURE(X1, Y1, X2, Y2)
%  X1:  x 数据的矢量
%  Y1:  y 数据的矢量
%  X2:  x 数据的矢量
%  Y2:  y 数据的矢量

%  由 MATLAB 于 30-Aug-2017 21:33:13 自动生成

% 创建 figure
figure('InvertHardcopy','off','Color',[1 1 1]);

% 创建 axes
axes1 = axes;
hold(axes1,'on');

% 创建 plot
plot(X1,Y1,'DisplayName','Experimental data',...
    'MarkerFaceColor',[0 0.447058826684952 0.74117648601532],...
    'MarkerSize',10,...
    'Marker','o',...
    'LineStyle','none');

% 创建 plot
plot(X2,Y2,'DisplayName','Fitted distribution','LineWidth',3,...
    'Color',[1 0 0]);

% 创建 xlabel
xlabel({'Elevation angle (°)'});

% 创建 ylabel
ylabel({'Mean of time delay (m)'});

% 取消以下行的注释以保留坐标轴的 X 范围
xlim(axes1,[0 90]);
% 取消以下行的注释以保留坐标轴的 Y 范围
ylim(axes1,[50 400]);
% 取消以下行的注释以保留坐标轴的 Z 范围
zlim(axes1,[-1 1]);
box(axes1,'on');
% 设置其余坐标轴属性
set(axes1,'FontName','Arial','FontSize',24,'FontWeight','bold');
% 创建 legend
legend1 = legend(axes1,'show');
set(legend1,...
    'Position',[0.643193211277981 0.82816048349508 0.335640129814786 0.143707331416939],...
    'FontSize',21.6);

