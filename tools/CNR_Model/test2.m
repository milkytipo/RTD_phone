CNR_GPS = 45*ones(1, 90);
for i = 1 : 32
    for j = 1 : length(TOWSEC)
        if CNR.GPS(i, j) > 1
            elevation = round(satPara.GPS(i).El(j));
            CNR_GPS(elevation) = 0.5*(CNR_GPS(elevation) + CNR.GPS(i, j));
        end
    end
end

figure();
plot(CNR_GPS);

sim_x = 6 : 44;
sim_y = CNR_GPS(sim_x);
P = polyfit(sim_x, sim_y, 3);
CNR_X = 1 : 44;
CNR_Y = polyval(P, CNR_X);
CNR_GPS(CNR_X) = CNR_Y;
CNR_GPS(45 : 90) = 51;

hold on;
plot(CNR_GPS);