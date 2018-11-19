
[XYZ, TOWSEC] = readGPFPD('D:\Work\mp_research\sv_cadll\logfile_data\threeTower_logfile_kalmanpvt_jointGpsBds_CadON_1\The_Three_Towers_GPFPD.txt');
N = length(TOWSEC);
threeTower_Refpos = [-2852104.75; 4654050.36; 3288351.12];
ttd_enu_gpfpd_mt = zeros(3,N);
for i=1:N
    ttd_enu_gpfpd_mt(:,i) = xyz2enu(XYZ(i,:)', threeTower_Refpos);
end

range2D = max(max(ttd_enu_gpfpd_mt(1:2,1:N)));
range3D = max(max(max(ttd_enu_gpfpd_mt)));

[CEP2D,CEP3D]=calcRelativeCEP(ttd_enu_gpfpd_mt,0.95,20,20);