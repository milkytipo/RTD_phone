% 
clear;
filename_test = 'E:\陆家嘴代码_v2.0\resource\BDS\B1I_PRN10_CORR.bin';
fid_test = fopen(filename_test, 'rb');
[corr_test,testnum_test] = fread(fid_test,1000,'float64');
fclose(fid_test);
%  E:\多径研究项目\sv_cadll\trunk\resource\GPS
%  E:\陆家嘴代码_v2.0\resource\GPS
filename_test2 = 'E:\软件接收机代码_SVN\trunk\wangyz_trunk\resource\BDS\B1I_PRN10_CORR.bin';
fid_test2 = fopen(filename_test2, 'rb');
[corr_test2,testnum_test2] = fread(fid_test2,1000,'float64');
fclose(fid_test2);



close all;clc;clear
shape_gen = 1;
shape_test = 0;
%——————————相关波形生成————————————%
if shape_gen == 1
%     clear;
    noise = 0;
    for i = 9 : 9
        prn = num2str(i);
        figName = strcat('F:\临时\标准相关波形v2.0\GPS', '\GPS_PRN', prn, '.fig');
        uiopen(figName, 1);
        obj = get(gca,'children');
        abcd = 1;
        x_orig = get(obj(abcd), 'xdata')';  % 
        y_orig = get(obj(abcd), 'ydata')';
        y_norm = y_orig / max(y_orig);
        x_norm = x_orig;
        x_use = x_norm(5:485);   % GPS:  5:485     % BDS:  5:245   % number = 481
        y_use = y_norm(5:485);
        x_fit = x_use(1) : 0.01 : x_use(end);
        y_fit = interp1(x_use, y_use, x_fit, 'pchip');
        figure();
        plot(x_fit*100, y_fit, ':.');
        title('y _ fit');
        grid on
        grid minor
        
%         noise = min(y_fit);
%         y_fit_pure = (y_fit-noise);
%         y_fit_pure = y_fit_pure/max(y_fit_pure);

    %     k2 = (1 - y4(297))/100;
    %     b2 = 1;
    %     k1 = (1 - y4(297)+noise)/100;
    %     b1 = 1;
    %     k22 = (y4(497)-1)/100;
    %     b22 = 1;
    %     k11 = (y4(497)-noise-1)/100;
    %     b11 = 1;
    %     y5_1 = y4(1:296) - noise;
    %     y5_2 = k1/k2*y4(297:397) + b1 - k1/k2*b2;
    %     y5_3 = k11/k22*y4(398:497) + b11 - k11/k22*b22;
    %     y5_4 = y4(498:793) - noise;
    %     y5 = [y5_1 ,y5_2 ,y5_3 ,y5_4];
    
%         figure();
%         plot(x_fit*100, y_fit_pure, ':.');
%         title('y _ fit _ pure');
%         grid on
%         grid minor
%         pure_err = y_fit_pure - y_fit;
%         figure();
%         plot(pure_err, ':.');
%         title('pure _ err');
%         grid on
%         grid minor
%         y_mix = [y_fit_pure(1:320), y_fit(321:473), y_fit_pure(474:793)];
%         figure();
%         plot(x_fit*100, y_mix, ':.');
%         title('y _ mix');
%         grid on
%         grid minor
        binName = strcat('F:\临时\标准相关波形v2.0\GPS', '\L1CA_PRN',prn,'_CORR.bin');
        fid = fopen(binName, 'w+');
        fwrite(fid, y_fit, 'double');
        fclose(fid);
    end
end


















%——————————波形准确度测试————————————%
if shape_test == 1
    figName_test = 'F:\临时\GPS_PRN5_fortest.fig';
    uiopen(figName_test, 1);
    obj = get(gca,'children');
    abcd = 1;
    x_test_orig = get(obj(abcd), 'xdata')';  % 
    y_test_orig = get(obj(abcd), 'ydata')';
    x_test_use = x_test_orig(5:485);
    y_test_use = y_test_orig(5:485);
    x_test_fit = x_test_use(1) : 0.01 : x_test_use(end);
    y_test_fit = interp1(x_test_use, y_test_use, x_test_fit, 'pchip'); 
    factor = 1;%(max(y_test_fit)-6300)/max(y_test_fit);
    shape_cancel = y_test_fit - y_fit_pure * factor * max(y_test_fit);
    figure()
    plot(x_fit, shape_cancel, ':.');
end





% clear;close all;
% % filename = 'I:\lujiazui\ie\lujiazui.txt';
% filename1 = 'G:\新建文件夹\BMAW14510070R_1.16O';
% % [Vel, TOWSEC] = readFile(filename);
% [C1, L1,S1,D1,ch,TOWSEC1]=read_rinex(filename1,1);
% absVel = sqrt(Vel(:,1).^2 + Vel(:,2).^2 + Vel(:,3).^2); 
% figure()
% plot(TOWSEC, absVel);
% a1 = find(TOWSEC1==45613);
% a2 = find(TOWSEC1==47280);
% prnBDS = intersect(ch.BDS(a1:a2,:), ch.BDS(a1:a2,:));
% prnGPS = intersect(ch.GPS(a1:a2,:), ch.GPS(a1:a2,:));