% cx_pos_accuracy_test
%% Roof_5min_Data
% fname_gpfpd = 'D:\Work\softrecv_research\sv_cadll\trunk\m\logfile\ProfChen_roof_16M_-6_GPFPD.txt';
% [roof16M_xyz, roof16M_TOWSEC] = readGPFPD(fname_gpfpd);
% roof16M_N = length(roof16M_TOWSEC);
% % Lab Roof reference antenna: 
% % LLh: 31°1分30.126秒   121度26分22.008秒，36.31米
% % LLH: 31.025035°       121.439447°       36.31米
% % XYZ: -2853445.36   4667464.90   3268291.09
% roof_ref_xyz = [-2853445.36   4667464.90   3268291.09];
% roof16M_enu = zeros(3, roof16M_N);
% for n=1:roof16M_N
%     roof16M_enu(:,n) = xyz2enu(roof16M_xyz(n,1:3), roof_ref_xyz);
% end
% 
% % plot(roof16M_TOWSEC, roof16M_enu(1,:), 'r', roof16M_TOWSEC, roof16M_enu(2,:), 'b', roof16M_TOWSEC, roof16M_enu(3,:), 'k')
% figure(1), plot(roof16M_enu(1,:), roof16M_enu(2,:),'+');
% ylim([-10,10]), xlim([-10,10]), grid on;
% figure(2), plot(roof16M_TOWSEC, roof16M_enu(3,:), 'k');

%% Three Tower Data
fname_ttd_gpfpd = 'D:\Work\softrecv_research\sv_cadll\trunk\m\logfile\The_Three_Towers_GPFPD.txt';
[ttd_xyz, ttd_TOWSEC] = readGPFPD(fname_ttd_gpfpd);
ttd_N = length(ttd_TOWSEC);
% Three Towers Data reference: 
% XYZ: -2852104.75   4654050.36   3288351.12
ttd_ref_xyz = [-2852104.75   4654050.36   3288351.12];
ttd_enu = zeros(3, ttd_N);
for n=1:ttd_N
    ttd_enu(:,n) = xyz2enu(ttd_xyz(n,1:3), ttd_ref_xyz);
end
start_N = 20;
figure(1), plot(ttd_enu(1, start_N:ttd_N), ttd_enu(2, start_N:ttd_N),'+'); grid on;
% ylim([-10,10]), xlim([-10,10]);
figure(2), plot(ttd_TOWSEC(start_N:ttd_N), ttd_enu(3, start_N:ttd_N), 'k');




