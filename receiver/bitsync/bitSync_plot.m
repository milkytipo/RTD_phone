function  bitSync_plot( array ,bitSyncResults,sv_acq_cfg)
%this program is to plot bitsync results
sv = bitSyncResults.sv;
figure(20+sv);mesh(array);
ylabel('频率槽数/个','fontsize',16);
xlabel('比特位置/ms','fontsize',16);
zlabel('相关值','fontsize',16)
end

