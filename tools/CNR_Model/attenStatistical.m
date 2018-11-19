clc; clear;close all


mean_urban_GPS = [-6.08, -6.86, -1.89];
mean_urban_BDS = -5.74;
bolck_urban_GPS = [0.607, 0.257, 0.068];
bolck_urban_BDS = 0.389;

mean_suburb_GPS = [-4.29, -3.26, -1.53];
mean_suburb_BDS = -2.83;
bolck_suburb_GPS = [0.238, 0.065, 0.004];
bolck_suburb_BDS = 0.091;

mean_viaductDown_GPS = [-7.30, -9.58, -9.66];
mean_viaductDown_BDS = -5.26;
bolck_viaductDown_GPS = [0.665, 0.613, 0.642];
bolck_viaductDown_BDS = 0.768;

mean_viaductUp_GPS = [-3.24, -2.35, -0.79];
mean_viaductUp_BDS = -2.17;
bolck_viaductUp_GPS = [0.089, 0.035, 0.025];
bolck_viaductUp_BDS = 0.040;



x_GPS = [15, 45, 75];
x_BDS = 45;

figure()
hold on;
plot(x_GPS, mean_urban_GPS);
hold on;
plot(x_GPS, mean_suburb_GPS);
hold on;
plot(x_GPS, mean_viaductDown_GPS);
hold on;
plot(x_GPS, mean_viaductUp_GPS);
hold on;
plot(x_BDS, mean_urban_BDS, 'o');
hold on;
plot(x_BDS, mean_suburb_BDS, 'o');
hold on;
plot(x_BDS, mean_viaductDown_BDS, 'o');
hold on;
plot(x_BDS, mean_viaductUp_BDS, 'o');

figure()
hold on;
plot(x_GPS, bolck_urban_GPS);
hold on;
plot(x_GPS, bolck_suburb_GPS);
hold on;
plot(x_GPS, bolck_viaductDown_GPS);
hold on;
plot(x_GPS, bolck_viaductUp_GPS);
hold on;
plot(x_BDS, bolck_urban_BDS, 'o');
hold on;
plot(x_BDS, bolck_suburb_BDS, 'o');
hold on;
plot(x_BDS, bolck_viaductDown_BDS, 'o');
hold on;
plot(x_BDS, bolck_viaductUp_BDS, 'o');

