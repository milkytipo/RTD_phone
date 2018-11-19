clc;clear;
obj = get(gca,'children');
x_data = get(obj(1), 'xdata')';
y_data = get(obj(1), 'ydata')';
figure()
for i = 1 : length(obj)
    x(i).data = get(obj(i), 'xdata')';
    y(i).data = get(obj(i), 'ydata')';

    x(i).data = x(i).data(2:2:(end-1));
    y(i).data = y(i).data(2:2:(end-1));

%     if i == 3
%         x_err = -180:1:180;
%         aa = 3;
%         bb = 50;
%         err = aa*(exp(-(power(x_err,2))/(2*bb^2)))/(bb*sqrt(2*pi));
%         y(i).data(100:460) = y(i).data(100:460) - err';
%         
%     end
    
    hold on;
    plot(x(i).data, y(i).data);

end





