function plot_MP_figure(multiPara, prn, multipathNum, sys)
    %！！！！！！！！！！！！！！！！！！ 鮫夕 ！！！！！！！！！！！！！！！！！！！！！！！！
    timeInterval = 0.1; % second
    x_time = timeInterval : timeInterval : length(multiPara(1).codeDelay)*timeInterval;
 
    RGB = [0.2,0.6,1; 1,0.4,0; 0.47,0.67,0.19];
    figureName = strcat(sys,' PRN  ',num2str(prn),'     CodeDelay');
    figure();
    subplot(2,2,1);
    for i = 1:multipathNum
        hold on;
        line1 = plot(x_time, multiPara(i).codeDelay,'-','LineWidth',2,'Color',RGB(i,:));
    end
    title(figureName);
    grid on
    grid minor
    set(gca, 'GridLineStyle', '-.');
    % set(gca, 'GridAlpha', 0.4);
    % set(gca, 'MinorGridAlpha', 0.6);
    hold off;

    figureName = strcat(sys,' PRN  ',num2str(prn),'     PowerAttenu');
    subplot(2,2,2);
    for i = 1:multipathNum
        hold on;
        plot(x_time, multiPara(i).attenu,'-*','LineWidth',2,'MarkerSize',4,'Color',RGB(i,:));
    end
    title(figureName);
    grid on
    grid minor
    set(gca, 'GridLineStyle', '-.');
    % set(gca, 'GridAlpha', 0.4);
    % set(gca, 'MinorGridAlpha', 0.6);
    hold off;

    figureName = strcat(sys,' PRN  ',num2str(prn),'     CarriDelay');
    subplot(2,2,3);
    for i = 1:multipathNum
        hold on;
        plot(x_time, multiPara(i).carriPhase,'-','LineWidth',2,'Color',RGB(i,:));
    end
    title(figureName);
    grid on
    grid minor
    set(gca, 'GridLineStyle', '-.');
    % set(gca, 'GridAlpha', 0.4);
    % set(gca, 'MinorGridAlpha', 0.6);
    hold off;

    figureName = strcat(sys,' PRN  ',num2str(prn),'     CarriConti');
    % figure();
    subplot(2,2,4);
    for i = 1:multipathNum
        hold on;
        plot(x_time, multiPara(i).contiPhase,'-','LineWidth',2,'Color',RGB(i,:));
    end
    title(figureName);
    grid on
    grid minor
    set(gca, 'GridLineStyle', '-.');
    % set(gca, 'GridAlpha', 0.4);
    % set(gca, 'MinorGridAlpha', 0.6);
    hold off;

    figureName = strcat(sys,' PRN  ',num2str(prn),'     doppRate');
    figure();
    subplot(2,2,1);
    for i = 1:multipathNum
        hold on;
        plot(x_time, multiPara(i).doppRate,'-*','LineWidth',2,'MarkerSize',4,'Color',RGB(i,:));
    end
    title(figureName);
    grid on
    grid minor
    set(gca, 'GridLineStyle', '-.');
    % set(gca, 'GridAlpha', 0.4);
    % set(gca, 'MinorGridAlpha', 0.6);
    hold off;

    figureName = strcat(sys,' PRN  ',num2str(prn),'     elevation');
    subplot(2,2,2);
    for i = 1:1
        hold on;
        plot(x_time, multiPara(i).elevation,'-','LineWidth',2,'Color',RGB(i,:));
    end
    title(figureName);
    grid on
    grid minor
    set(gca, 'GridLineStyle', '-.');
    % set(gca, 'GridAlpha', 0.4);
    % set(gca, 'MinorGridAlpha', 0.6);
    hold off;

    figureName = strcat(sys,' PRN  ',num2str(prn),'     CNR');
    subplot(2,2,3);
    for i = 1:1
        hold on;
        plot(x_time, multiPara(i).CNR,'-','LineWidth',1,'Color',RGB(i,:));
    end
    title(figureName);
    grid on
    grid minor
    set(gca, 'GridLineStyle', '-.');
    % set(gca, 'GridAlpha', 0.4);
    % set(gca, 'MinorGridAlpha', 0.6);
    hold off; 
    
    figureName = strcat(sys,' PRN  ',num2str(prn),'     elevation_fit');
    subplot(2,2,4);
    for i = 1:1
        hold on;
        plot(x_time, multiPara(i).elevation_fit,'-','LineWidth',2,'Color',RGB(i,:));
    end
    title(figureName);
    grid on
    grid minor
    set(gca, 'GridLineStyle', '-.');
    % set(gca, 'GridAlpha', 0.4);
    % set(gca, 'MinorGridAlpha', 0.6);
    hold off;
    
    
    
 
    %%%%%%%%%%%%%%%%%%%%  厚仟朔議方象泣鮫夕  %%%%%%%%%%%%%%%%%%%%% 
    
     RGB = [0.2,0.6,1; 1,0.4,0; 0.47,0.67,0.19];
    figureName = strcat(sys,' PRN  ',num2str(prn),'     CodeDelay ！！ Update');
    figure();
    subplot(2,2,1);
    for i = 1:multipathNum
        hold on;
        line1 = plot(x_time, multiPara(i).codeDelay_Auto,'-','LineWidth',3,'Color',RGB(i,:));
    end
    title(figureName);
    grid on
    grid minor
    set(gca, 'GridLineStyle', '-.');
    % set(gca, 'GridAlpha', 0.4);
    % set(gca, 'MinorGridAlpha', 0.6);
    hold off;

    
    figureName = strcat(sys,' PRN  ',num2str(prn),'     PowerAttenu ！！ Update');
    subplot(2,2,2);
    for i = 1:multipathNum
        hold on;
        x_value = isnan(multiPara(i).codeDelay_Auto);
        atteun_update = multiPara(i).attenu;
        atteun_update(x_value) = NaN;
        plot(x_time, atteun_update,'-*','LineWidth',2,'MarkerSize',4,'Color',RGB(i,:));
    end
    title(figureName);
    grid on
    grid minor
    set(gca, 'GridLineStyle', '-.');
    % set(gca, 'GridAlpha', 0.4);
    % set(gca, 'MinorGridAlpha', 0.6);
    hold off;

    figureName = strcat(sys,' PRN  ',num2str(prn),'     CarriDelay ！！ Update');
    subplot(2,2,3);
    for i = 1:multipathNum
        hold on;
        x_value = isnan(multiPara(i).codeDelay_Auto);
        carri_update = multiPara(i).carriPhase;
        carri_update(x_value) = NaN;
        plot(x_time, carri_update,'-','LineWidth',2,'Color',RGB(i,:));
    end
    title(figureName);
    grid on
    grid minor
    set(gca, 'GridLineStyle', '-.');
    % set(gca, 'GridAlpha', 0.4);
    % set(gca, 'MinorGridAlpha', 0.6);
    hold off;

    figureName = strcat(sys,' PRN  ',num2str(prn),'     CarriConti ！！ Update');
    % figure();
    subplot(2,2,4);
    for i = 1:multipathNum
        hold on;
        x_value = isnan(multiPara(i).codeDelay_Auto);
        conti_update = multiPara(i).contiPhase;
        conti_update(x_value) = NaN;
        plot(x_time, conti_update,'-','LineWidth',2,'Color',RGB(i,:));
    end
    title(figureName);
    grid on
    grid minor
    set(gca, 'GridLineStyle', '-.');
    % set(gca, 'GridAlpha', 0.4);
    % set(gca, 'MinorGridAlpha', 0.6);
    hold off;