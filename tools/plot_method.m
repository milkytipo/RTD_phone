
% —————————— 将多张图合成子图形式 ————————————
h0=figure;
hf=open('D:\个人论文材料\Journal\图\NEW\fadingFrequency\IGSO_hist_90.fig'); 
h=findobj(hf);
figure(h0);hs=subplot(2,3,6); 
copyobj(h(3:end),hs) 
close(hf) 


fig = findall(gca,'type','line');
ydata_1 = get(fig, 'ydata');
y_2(1,:) = ydata_1{1};
y_2(2,:) = ydata_1{2};
y_2(3,:) = ydata_1{3};
y_2(4,:) = ydata_1{4};
y_2(5,:) = ydata_1{5};
x = 0 : 86400;

figure();
yyaxis left
plot(x, y_1(1,:))
yyaxis right
plot(x, y_2(1,:))
hold on

%————— 读图像 ——————%
open('figname.fig');
lh = findall(gca, 'type', 'hist');% 如果图中有多条曲线，lh为一个数组
xc = get(lh, 'xdata');            % 取出x轴数据，xc是一个元胞数组
yc = get(lh, 'ydata');            % 取出y轴数据，yc是一个元胞数组
%如果想取得第2条曲线的x，y坐标
x2=xc{2};
y2=yc{2};

%—————— 另一种读法 ——————
h_line=get(gca,'Children');%get line handles
xdata=get(h_line,'Xdata');
ydata=get(h_line,'Ydata');

