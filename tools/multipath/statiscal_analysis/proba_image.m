function proba_image(x_grid, y_grid, x_value, y_value, gridNum)

total_num = length(x_value);

xx = zeros(length(x_grid)*length(x_grid), 1);
yy = zeros(length(x_grid)*length(x_grid), 1);
zz = zeros(length(x_grid)*length(x_grid), 1);

index = 0;
for i = 1 : length(x_grid)-1
    for j = 1 : length(y_grid)-1
        x_line = find(x_value>=x_grid(i) & x_value<=x_grid(i+1));
        y_line = find(y_value>=y_grid(j) & y_value<=y_grid(j+1));
        xy_line = intersect(x_line, y_line);
        grid_num = length(xy_line);
        if i > 30 && i < 600
            if j >0 && j < 20
                if grid_num == 0
                    %continue;
                end
            end
        end
        index = index + 1;
        xx(index) = x_grid(i);
        yy(index) = y_grid(j);
        zz(index) = grid_num / total_num;
    end
end
xx = xx(1:index);
yy = yy(1:index);
zz = zz(1:index);
[xx_grid, yy_grid] = meshgrid(linspace(min(xx),max(xx), gridNum),linspace(min(yy),max(yy), gridNum)); 
zz_grid = griddata(xx, yy, zz, xx_grid, yy_grid, 'cubic');
figure()
imagesc([xx_grid(1), xx_grid(end)], [yy_grid(1), yy_grid(end)], zz_grid);
hold on
colorbar ;