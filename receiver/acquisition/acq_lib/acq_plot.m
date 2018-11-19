% function acq_plot(array,acqResults)
function acq_plot(Status,SYST,array,acqResults)
%this program is to plot acqusition results
%    [A,B] = size(array);
sv = acqResults.sv;

if strcmp(SYST,'BDS_B1I')
   if strcmp(Status,'BIT_SYNC')||strcmp(Status,'COLD_ACQ')
      title=['BDS PRN = ',num2str(sv),' in COLD_ACQ mode'];
   else
        if strcmp(Status,'HOT_BIT_SYNC')||strcmp(Status,'HOT_ACQ')
            title=['BDS PRN = ',num2str(sv),' in HOT_ACQ mode'];
        end
   end
end

if strcmp(SYST,'GPS_L1CA')
   if strcmp(Status,'BIT_SYNC')||strcmp(Status,'COLD_ACQ')
      title=['GPS PRN = ',num2str(sv),' in COLD_ACQ mode'];
   else
        if strcmp(Status,'HOT_BIT_SYNC')||strcmp(Status,'HOT_ACQ')
            title=['GPS PRN = ',num2str(sv),' in HOT_ACQ mode'];
        end 
   end
end


%    freqmin = -sv_acq_cfg.freqRange/2;
%    freqmax = sv_acq_cfg.freqRange/2;
%    step = sv_acq_cfg.freqBin;
%   plot code phase
     
%         subplot(2,1,1); plot(acqResults.samps*acqResults.RcFsratio, array(acqResults.freqIdx,:));
%         xlabel('码相位/samples');ylabel('相关值');
%         title(['PRN = ' int2str(sv)],'fontsize',14);
%         set(gca,'FontSize',14); % 设置文字大小，同时影响坐标轴标注、图例、标题等。
%         set(get(gca,'XLabel'),'FontSize',14);%图上文字为8 point或小5号
%         set(get(gca,'YLabel'),'FontSize',14);
% % plot freq
%         subplot(2,1,2);mesh(acqResults.samps, acqResults.freqOrder, array);
%         title(['PRN = ' int2str(sv)]); 
%         xlabel('码相位/samples');ylabel('频率槽/个');zlabel('相关值')
% %         set(gca,'ytick',[freqmax:-step:0 step:step:freqmax]);
%         set(gca,'FontSize',14); % 设置文字大小，同时影响坐标轴标注、图例、标题等。
%         set(get(gca,'XLabel'),'FontSize',14);%图上文字为8 point或小5号
%         set(get(gca,'YLabel'),'FontSize',14);
%         set(get(gca,'ZLabel'),'FontSize',14);

                figure('Name',title,'NumberTitle','off');subplot(2,1,1);
                plot(acqResults.samps*acqResults.RcFsratio, array(acqResults.freqIdx,:));
                xlabel('码片/samples');ylabel('相关值');
                %title(['PRN = ' int2str(sv)],'fontsize',14);
                set(gca,'FontSize',14); % 设置文字大小，同时影响坐标轴标注、图例、标题等。
                set(get(gca,'XLabel'),'FontSize',14);%图上文字为8 point或小5号
                set(get(gca,'YLabel'),'FontSize',14);

                subplot(2,1,2);
                mesh(acqResults.samps, acqResults.freqOrder, array);
        %        plot(acqResults.samps,array(acqResults.freqIdx,:))
        %        title(['BDS: PRN = ' int2str(sv)]); 
                xlabel('码相位/samples');ylabel('频率槽/个');zlabel('相关值')
        %        xlabel('码相位/samples');ylabel('相关值')
        %         set(gca,'ytick',[freqmax:-step:0 step:step:freqmax]);
                set(gca,'FontSize',14); % 设置文字大小，同时影响坐标轴标注、图例、标题等。
                set(get(gca,'XLabel'),'FontSize',14);%图上文字为8 point或小5号
                set(get(gca,'YLabel'),'FontSize',14);
                set(get(gca,'ZLabel'),'FontSize',14);
       
%                 subplot(2,1,2);
%                 plot(acqResults.freqOrder,array(:,acqResults.codeIdx))
%         %        title(['BDS: PRN = ' int2str(sv)]); 
%                 xlabel('多普勒频移 [Hz]');ylabel('相关值')
%         %         set(gca,'ytick',[freqmax:-step:0 step:step:freqmax]);
%                 set(gca,'FontSize',14); % 设置文字大小，同时影响坐标轴标注、图例、标题等。
%                 set(get(gca,'XLabel'),'FontSize',14);%图上文字为8 point或小5号
%                 set(get(gca,'YLabel'),'FontSize',14);

end
%  axis([0 10000 -4 4])
