function fadFreq_GEO(xvector1, yvector1, X1, Y1)
%CREATEFIGURE(XVECTOR1, YVECTOR1, X1, Y1)
%  XVECTOR1:  bar xvector
%  YVECTOR1:  bar yvector
%  X1:  x 数据的矢量
%  Y1:  y 数据的矢量

%  由 MATLAB 于 01-Sep-2017 13:36:06 自动生成

% 创建 figure
figure('InvertHardcopy','off','PaperSize',[20.99999864 29.69999902],...
    'Color',[1 1 1]);

% 创建 axes
axes1 = axes;
hold(axes1,'on');

% 创建 bar
bar1 = bar(xvector1,yvector1,'DisplayName','Experomental data');
baseline1 = get(bar1,'BaseLine');
set(baseline1,'Color',[0 0 0]);

% 创建 plot
plot(X1,Y1,'ZDataSource','','DisplayName','Fitted distribution',...
    'LineWidth',3,...
    'Color',[1 0 0]);

% 创建 xlabel
xlabel('Fading frequency (Hz)');

% 创建 ylabel
ylabel('Probability density');

% 取消以下行的注释以保留坐标轴的 X 范围
xlim(axes1,[0 0.003]);
% 取消以下行的注释以保留坐标轴的 Y 范围
ylim(axes1,[0 1600]);
% 取消以下行的注释以保留坐标轴的 Z 范围
zlim(axes1,[-1 1]);
box(axes1,'on');
% 设置其余坐标轴属性
set(axes1,'FontName','Arial','FontSize',24,'FontWeight','bold');
% 创建 legend
legend1 = legend(axes1,'show');
set(legend1,...
    'Position',[0.731401270262578 0.860171412425591 0.197607313843613 0.0859826787981089],...
    'FontSize',18);

