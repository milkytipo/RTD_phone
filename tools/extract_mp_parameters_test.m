% extract parameters
close all;
clear all;
filename = 'D:\Work\work_personal_svn\mypaper\Journal\Multipath_Model\Lujiazui_three_towers_data\The_Three_Towers.15GMP';
[parameter,prnNum,TOWSEC] = readMP(filename);
% filename_satobs='D:\Work\work_personal_svn\mypaper\Journal\Multipath_Model\Lujiazui_three_towers_data\The_Three_Towers_SateObs_BDS.txt';
% [el,az,SNR,CNR,carriVar,satPos_x,satPos_y,satPos_z,satVel_x,satVel_y,satVel_z,satClcErr,satClcErrDot,TOWSEC_satobs] = readSatobs(filename_satobs);

TOWSEC=TOWSEC';
N = length(TOWSEC);
%% PRN 2 MP parameters
%Primitive codeDelay
prn4_codedelay_primitive1 = parameter(4).codeDelay(:,2);
prn4_codedelay_primitive2 = parameter(4).codeDelay(:,3);
%Primitive carriDelay
prn4_carriDelay_mp1_primitive = parameter(4).carriDelay(:,2)';
prn4_carriDelay_mp2_primitive = parameter(4).carriDelay(:,3)';
%Primitive SNR
prn4_SNR_los_primitive = parameter(4).SNR(:,1);
prn4_SNR_mp1_primitive = parameter(4).SNR(:,2);
prn4_SNR_mp2_primitive = parameter(4).SNR(:,3);

prn4_codedelay_mp1 = NaN(N,1,'double');
prn4_codedelay_mp1_indx1 = [(14:219)];
prn4_codedelay_mp1_indx2 = [(220:349),(373:492),(496:N)];
prn4_codedelay_mp1(prn8_codedelay_mp1_indx1) = prn2_codedelay_primitive1(prn8_codedelay_mp1_indx1);
prn4_codedelay_mp1(prn8_codedelay_mp1_indx2) = prn2_codedelay_primitive2(prn8_codedelay_mp1_indx2);
prn4_codedelay_mpothers = NaN(N,1,'double');
prn4_codedelay_mpothers_indx2 = [(203:208),(358:363),(366:370)];
prn4_codedelay_mpothers(prn8_codedelay_mpothers_indx2) = prn2_codedelay_primitive2(prn8_codedelay_mpothers_indx2);


prn2_carrphase_mp1 = NaN(N,1,'double');
prn2_carrphase_mp1(prn8_codedelay_mp1_indx1) = prn2_carrphase_primitive1(prn8_codedelay_mp1_indx1);
prn2_carrphase_mp1(prn8_codedelay_mp1_indx2) = prn2_carrphase_primitive2(prn8_codedelay_mp1_indx2);
prn2_carrphase_mpothers = NaN(N,1,'double');
prn2_carrphase_mpothers(prn8_codedelay_mpothers_indx2) = prn2_carrphase_primitive2(prn8_codedelay_mpothers_indx2);

prn2_snr_primitivelos = parameter(2).SNR(:,1);
prn2_snr_los = NaN(N,1,'double');
prn2_snr_los_indx = (14:N);
prn2_snr_los(prn2_snr_los_indx) = prn2_snr_primitivelos(prn2_snr_los_indx);
prn2_snr_primitive1 = parameter(2).SNR(:,2);
prn2_snr_primitive2 = parameter(2).SNR(:,3);
prn2_snr_mp1 = NaN(N,1,'double');
prn2_snr_mp1(prn8_codedelay_mp1_indx1) = prn2_snr_primitive1(prn8_codedelay_mp1_indx1);
prn2_snr_mp1(prn8_codedelay_mp1_indx2) = prn2_snr_primitive2(prn8_codedelay_mp1_indx2);
prn2_snr_mpothers = NaN(N,1,'double');
prn2_snr_mpothers(prn8_codedelay_mpothers_indx2) = prn2_snr_primitive2(prn8_codedelay_mpothers_indx2);


%% PRN8 MP parameters
% %Primitive codeDelay
% prn8_codeDelay_mp1_primitive = parameter(8).codeDelay(:,2)';
% prn8_codeDelay_mp2_primitive = parameter(8).codeDelay(:,3)';
% % figure,plot(prn8_codeDelay_mp1_primitive);
% % figure,plot(prn8_codeDelay_mp2_primitive);
% %Primitive carriDelay
% prn8_carriDelay_mp1_primitive = parameter(8).carriDelay(:,2)';
% prn8_carriDelay_mp2_primitive = parameter(8).carriDelay(:,3)';
% % figure,plot(prn8_carriDelay_mp1_primitive);
% % figure,plot(prn8_carriDelay_mp2_primitive);
% %Primitive SNR
% prn8_SNR_los_primitive = parameter(8).SNR(:,1);
% prn8_SNR_mp1_primitive = parameter(8).SNR(:,2);
% prn8_SNR_mp2_primitive = parameter(8).SNR(:,3);
% %prn8 prime_mp1
% L = prn8_codeDelay_mp1_primitive~=0;
% prn8_codeDelay_mp1_prime = NaN(N,1,'double');
% prn8_codeDelay_mp1_prime(L) = prn8_codeDelay_mp1_primitive(L);
% prn8_carriDelay_mp1_prime = NaN(N,1,'double');
% prn8_carriDelay_mp1_prime(L) = prn8_carriDelay_mp1_primitive(L);
% prn8_SNR_mp1_prime = NaN(N,1,'double');
% prn8_SNR_mp1_prime(L) = prn8_SNR_mp1_primitive(L);
% %prn8 prime_mp2
% L = prn8_codeDelay_mp2_primitive~=0;
% prn8_codeDelay_mp2_prime=NaN(N,1,'double');
% prn8_codeDelay_mp2_prime(L)=prn8_codeDelay_mp2_primitive(L);
% prn8_carriDelay_mp2_prime=NaN(N,1,'double');
% prn8_carriDelay_mp2_prime(L)=prn8_carriDelay_mp1_primitive(L);
% prn8_SNR_mp2_prime = NaN(N,1,'double');
% prn8_SNR_mp2_prime(L) = prn8_SNR_mp2_primitive(L);
% %prn8 prime los snr
% L = prn8_SNR_los_primitive~=0;
% prn8_SNR_los_prime = NaN(N,1,'double');
% prn8_SNR_los_prime(L)=prn8_SNR_los_primitive(L);
% %prn8 mp1
% prn8_codeDelay_mp1 = NaN(N,1,'double');
% prn8_carriDelay_mp1= NaN(N,1,'double');
% prn8_SNR_mp1 = NaN(N,1,'double');
% prn8_codeDelay_mp1_indx1=[(1:100),(148:158)];
% % prn8_codeDelay_mp1_indx2=[(217:223)];
% prn8_codeDelay_mp1(prn8_codeDelay_mp1_indx1)=prn8_codeDelay_mp1_prime(prn8_codeDelay_mp1_indx1);
% % prn8_codeDelay_mp1(prn8_codeDelay_mp1_indx2)=prn8_codeDelay_mp2_prime(prn8_codeDelay_mp1_indx2);
% prn8_carriDelay_mp1(prn8_codeDelay_mp1_indx1)=prn8_carriDelay_mp1_prime(prn8_codeDelay_mp1_indx1);
% prn8_carriDelay_mp1(22:end)=prn8_carriDelay_mp1(22:end)-2*pi;
% prn8_carriDelay_mp1(59:end)=prn8_carriDelay_mp1(59:end)-2*pi;
% prn8_carriDelay_mp1(82:end)=prn8_carriDelay_mp1(82:end)-2*pi;
% prn8_carriDelay_mp1(148:end)=prn8_carriDelay_mp1(148:end)-4*pi;
% % prn8_carriDelay_mp1(prn8_codeDelay_mp1_indx2)=prn8_carriDelay_mp2_prime(prn8_codeDelay_mp1_indx2);
% prn8_SNR_mp1(prn8_codeDelay_mp1_indx1)=prn8_SNR_mp1_prime(prn8_codeDelay_mp1_indx1);
% 
% % figure,subplot(3,1,1),plot(prn8_codeDelay_mp1);
% % subplot(3,1,2),plot(prn8_carriDelay_mp1);
% % subplot(3,1,3),plot(prn8_SNR_mp1);
% 
% %prn8 mp2
% prn8_codeDelay_mp2 = NaN(N,1,'double');
% prn8_carriDelay_mp2= NaN(N,1,'double');
% prn8_SNR_mp2 = NaN(N,1,'double');
% prn8_codeDelay_mp2_indx1=[(247:254),(307:316),(375:388)];
% prn8_codeDelay_mp2(prn8_codeDelay_mp2_indx1)=prn8_codeDelay_mp1_prime(prn8_codeDelay_mp2_indx1);
% prn8_carriDelay_mp2(prn8_codeDelay_mp2_indx1)=prn8_carriDelay_mp1_prime(prn8_codeDelay_mp2_indx1);
% prn8_carriDelay_mp2(311:end)=prn8_carriDelay_mp2(311:end)-2*pi;
% prn8_carriDelay_mp2(383:end)=prn8_carriDelay_mp2(383:end)-2*pi;
% prn8_SNR_mp2(prn8_codeDelay_mp2_indx1) = prn8_SNR_mp1_prime(prn8_codeDelay_mp2_indx1);
% %prn8 mp3
% prn8_codeDelay_mp3 = NaN(N,1,'double');
% prn8_carriDelay_mp3= NaN(N,1,'double');
% prn8_SNR_mp3 = NaN(N,1,'double');
% prn8_codeDelay_mp3_indx1=[(572:615),(658:685),(721:756)];
% prn8_codeDelay_mp3(prn8_codeDelay_mp3_indx1)=prn8_codeDelay_mp1_prime(prn8_codeDelay_mp3_indx1);
% prn8_carriDelay_mp3(prn8_codeDelay_mp3_indx1)=prn8_carriDelay_mp1_prime(prn8_codeDelay_mp3_indx1);
% prn8_carriDelay_mp3(586:end)=prn8_carriDelay_mp3(586:end)-2*pi;
% prn8_carriDelay_mp3(658:end)=prn8_carriDelay_mp3(658:end)-4*pi;
% prn8_carriDelay_mp3(721:end)=prn8_carriDelay_mp3(721:end)-2*pi;
% prn8_carriDelay_mp3(729:end)=prn8_carriDelay_mp3(729:end)-2*pi;
% prn8_SNR_mp3(prn8_codeDelay_mp3_indx1) = prn8_SNR_mp1_prime(prn8_codeDelay_mp3_indx1);
% %prn8 mp4
% prn8_codeDelay_mp4 = NaN(N,1,'double');
% prn8_carriDelay_mp4= NaN(N,1,'double');
% prn8_SNR_mp4 = NaN(N,1,'double');
% prn8_codeDelay_mp4_indx1=[(693:707),(758:774)];
% prn8_codeDelay_mp4(prn8_codeDelay_mp4_indx1) = prn8_codeDelay_mp1_prime(prn8_codeDelay_mp4_indx1);
% prn8_carriDelay_mp4(prn8_codeDelay_mp4_indx1) = prn8_carriDelay_mp1_prime(prn8_codeDelay_mp4_indx1);
% prn8_carriDelay_mp4(762:end) = prn8_carriDelay_mp4(762:end) - 2*pi;
% prn8_SNR_mp4(prn8_codeDelay_mp4_indx1) = prn8_SNR_mp1_prime(prn8_codeDelay_mp4_indx1);
% %prn8 mp5
% prn8_codeDelay_mp5 = NaN(N,1,'double');
% prn8_carriDelay_mp5= NaN(N,1,'double');
% prn8_SNR_mp5 = NaN(N,1,'double');
% prn8_codeDelay_mp5_indx1=[(968:1011),(1041:1047),(1088:1098),(1034:1044),(1187:1270),(1291:1309),(1364:1394),(1565:1598),(1750:1814)];
% prn8_codeDelay_mp5(prn8_codeDelay_mp5_indx1)=prn8_codeDelay_mp1_prime(prn8_codeDelay_mp5_indx1);
% prn8_carriDelay_mp5(prn8_codeDelay_mp5_indx1)=prn8_carriDelay_mp1_prime(prn8_codeDelay_mp5_indx1);
% prn8_carriDelay_mp5(995:end) = prn8_carriDelay_mp5(995:end)-2*pi;
% prn8_carriDelay_mp5(1039:end) = prn8_carriDelay_mp5(1039:end)-2*pi;
% prn8_carriDelay_mp5(1088:end) = prn8_carriDelay_mp5(1088:end)-4*pi;
% prn8_carriDelay_mp5(1187:end) = prn8_carriDelay_mp5(1187:end)-4*pi;
% prn8_carriDelay_mp5(1200:end) = prn8_carriDelay_mp5(1200:end)-2*pi;
% prn8_carriDelay_mp5(1241:end) = prn8_carriDelay_mp5(1241:end)-2*pi;
% prn8_carriDelay_mp5(1268:end) = prn8_carriDelay_mp5(1268:end)-2*pi;
% prn8_carriDelay_mp5(1291:end) = prn8_carriDelay_mp5(1291:end)-2*pi;
% prn8_carriDelay_mp5(1364:end) = prn8_carriDelay_mp5(1364:end)-2*pi;
% prn8_carriDelay_mp5(1376:end) = prn8_carriDelay_mp5(1376:end)-2*pi;
% prn8_carriDelay_mp5(1565:end) = prn8_carriDelay_mp5(1565:end)-10*pi;
% prn8_carriDelay_mp5(1581:end) = prn8_carriDelay_mp5(1581:end)-2*pi;
% prn8_carriDelay_mp5(1750:end) = prn8_carriDelay_mp5(1750:end)-10*pi;
% prn8_carriDelay_mp5(1759:end) = prn8_carriDelay_mp5(1759:end)-2*pi;
% prn8_carriDelay_mp5(1804:end) = prn8_carriDelay_mp5(1804:end)-2*pi;
% prn8_SNR_mp5(prn8_codeDelay_mp5_indx1) = prn8_SNR_mp1_prime(prn8_codeDelay_mp5_indx1);
% %prn8 mpothers
% prn8_codeDelay_mpothers = NaN(N,1,'double');
% prn8_carriDelay_mpothers= NaN(N,1,'double');
% prn8_SNR_mpothers = NaN(N,1,'double');
% prn8_codeDelay_mpothers_indx1=[(489:493),(1169:1173),(1335:1344),(1621:1632),(1724:1730)];
% prn8_codeDelay_mpothers(prn8_codeDelay_mpothers_indx1)=prn8_codeDelay_mp1_prime(prn8_codeDelay_mpothers_indx1);
% prn8_carriDelay_mpothers(prn8_codeDelay_mpothers_indx1)=prn8_carriDelay_mp1_prime(prn8_codeDelay_mpothers_indx1);
% prn8_SNR_mpothers(prn8_codeDelay_mpothers_indx1)=prn8_SNR_mp1_prime(prn8_codeDelay_mpothers_indx1);
% 
% prn8_codeDelay_mpothers_indx2 = ~isnan(prn8_codeDelay_mp2_prime);
% prn8_codeDelay_mpothers(prn8_codeDelay_mpothers_indx2) = prn8_codeDelay_mp2_prime(prn8_codeDelay_mpothers_indx2);
% prn8_carriDelay_mpothers(prn8_codeDelay_mpothers_indx2) = prn8_carriDelay_mp2_prime(prn8_codeDelay_mpothers_indx2);
% prn8_SNR_mpothers(prn8_codeDelay_mpothers_indx2) = prn8_SNR_mp2_prime(prn8_codeDelay_mpothers_indx2);



%% PRN10 MP parameters
% %Primitive codeDelay
% prn10_codeDelay_mp1_primitive = parameter(10).codeDelay(:,2)';
% prn10_codeDelay_mp2_primitive = parameter(10).codeDelay(:,3)';
% %Primitive carriDelay
% prn10_carriDelay_mp1_primitive = parameter(10).carriDelay(:,2)';
% prn10_carriDelay_mp2_primitive = parameter(10).carriDelay(:,3)';
% %Primitive SNR
% prn10_SNR_los_primitive = parameter(10).SNR(:,1);
% prn10_SNR_mp1_primitive = parameter(10).SNR(:,2);
% prn10_SNR_mp2_primitive = parameter(10).SNR(:,3);
% %prn10 prime_mp1
% L = prn10_codeDelay_mp1_primitive~=0;
% prn10_codeDelay_mp1_prime = NaN(N,1,'double');
% prn10_codeDelay_mp1_prime(L) = prn10_codeDelay_mp1_primitive(L);
% prn10_carriDelay_mp1_prime = NaN(N,1,'double');
% prn10_carriDelay_mp1_prime(L) = prn10_carriDelay_mp1_primitive(L);
% prn10_SNR_mp1_prime = NaN(N,1,'double');
% prn10_SNR_mp1_prime(L) = prn10_SNR_mp1_primitive(L);
% %prn10 prime_mp2
% L = prn10_codeDelay_mp2_primitive~=0;
% prn10_codeDelay_mp2_prime=NaN(N,1,'double');
% prn10_codeDelay_mp2_prime(L)=prn10_codeDelay_mp2_primitive(L);
% prn10_carriDelay_mp2_prime=NaN(N,1,'double');
% prn10_carriDelay_mp2_prime(L)=prn10_carriDelay_mp1_primitive(L);
% prn10_SNR_mp2_prime = NaN(N,1,'double');
% prn10_SNR_mp2_prime(L) = prn10_SNR_mp2_primitive(L);
% %prn10 prime los snr
% L = prn10_SNR_los_primitive~=0;
% prn10_SNR_los_prime = NaN(N,1,'double');
% prn10_SNR_los_prime(L)=prn10_SNR_los_primitive(L);
% %prn10 mp1
% prn10_codeDelay_mp1 = NaN(N,1,'double');
% prn10_carriDelay_mp1= NaN(N,1,'double');
% prn10_SNR_mp1=NaN(N,1,'double');
% prn10_codeDelay_mp1_indx1=[(543:588),(624:647)];
% prn10_codeDelay_mp1(prn10_codeDelay_mp1_indx1)=prn10_codeDelay_mp1_prime(prn10_codeDelay_mp1_indx1);
% prn10_carriDelay_mp1(prn10_codeDelay_mp1_indx1)=prn10_carriDelay_mp1_prime(prn10_codeDelay_mp1_indx1);
% prn10_carriDelay_mp1(563:end)=prn10_carriDelay_mp1(563:end)-2*pi;
% prn10_carriDelay_mp1(587:end)=prn10_carriDelay_mp1(587:end)-2*pi;
% prn10_carriDelay_mp1(630:end)=prn10_carriDelay_mp1(630:end)-2*pi;
% prn10_SNR_mp1(prn10_codeDelay_mp1_indx1)=prn10_SNR_mp1_prime(prn10_codeDelay_mp1_indx1);
% %prn10 mp2
% prn10_codeDelay_mp2 = NaN(N,1,'double');
% prn10_carriDelay_mp2= NaN(N,1,'double');
% prn10_SNR_mp2=NaN(N,1,'double');
% prn10_codeDelay_mp2_indx1=[(876:928),(1016:1028),(1428:1466),(1843:1885)];
% prn10_codeDelay_mp2(prn10_codeDelay_mp2_indx1)=prn10_codeDelay_mp1_prime(prn10_codeDelay_mp2_indx1);
% prn10_carriDelay_mp2(prn10_codeDelay_mp2_indx1)=prn10_carriDelay_mp1_prime(prn10_codeDelay_mp2_indx1);
% prn10_carriDelay_mp2(906:end)=prn10_carriDelay_mp2(906:end)-2*pi;
% prn10_carriDelay_mp2(1016:end)=prn10_carriDelay_mp2(1016:end)-6*pi;
% prn10_carriDelay_mp2(1024:end)=prn10_carriDelay_mp2(1024:end)-2*pi;
% prn10_carriDelay_mp2(1428:end)=prn10_carriDelay_mp2(1428:end)-28*pi;
% prn10_carriDelay_mp2(1435:end)=prn10_carriDelay_mp2(1435:end)-2*pi;
% prn10_carriDelay_mp2(1457:end)=prn10_carriDelay_mp2(1457:end)-2*pi;
% prn10_carriDelay_mp2(1843:end)=prn10_carriDelay_mp2(1843:end)-28*pi;
% prn10_carriDelay_mp2(1858:end)=prn10_carriDelay_mp2(1858:end)-2*pi;
% prn10_carriDelay_mp2(1882:end)=prn10_carriDelay_mp2(1882:end)-2*pi;
% prn10_SNR_mp2(prn10_codeDelay_mp2_indx1)=prn10_SNR_mp1_prime(prn10_codeDelay_mp2_indx1);
% %prn10 mp3
% prn10_codeDelay_mp3 = NaN(N,1,'double');
% prn10_carriDelay_mp3= NaN(N,1,'double');
% prn10_SNR_mp3=NaN(N,1,'double');
% prn10_codeDelay_mp3_indx1=[(935:984),(1064:1080),(1101:1123)];
% prn10_codeDelay_mp3(prn10_codeDelay_mp3_indx1)=prn10_codeDelay_mp1_prime(prn10_codeDelay_mp3_indx1);
% prn10_carriDelay_mp3(prn10_codeDelay_mp3_indx1)=prn10_carriDelay_mp1_prime(prn10_codeDelay_mp3_indx1);
% prn10_carriDelay_mp3(956:end)=prn10_carriDelay_mp3(956:end)-2*pi;
% prn10_carriDelay_mp3(978:end)=prn10_carriDelay_mp3(978:end)-2*pi;
% prn10_carriDelay_mp3(1064:end)=prn10_carriDelay_mp3(1064:end)-6*pi;
% prn10_carriDelay_mp3(1101:end)=prn10_carriDelay_mp3(1101:end)-2*pi;
% prn10_carriDelay_mp3(1123:end)=prn10_carriDelay_mp3(1123:end)-2*pi;
% prn10_SNR_mp3(prn10_codeDelay_mp3_indx1)=prn10_SNR_mp1_prime(prn10_codeDelay_mp3_indx1);
% %prn10 mpothers
% prn10_codeDelay_mpothers = prn10_codeDelay_mp1_prime;
% prn10_carriDelay_mpothers= prn10_carriDelay_mp1_prime;
% prn10_SNR_mpothers = prn10_SNR_mp1_prime;
% 
% prn10_codeDelay_mpothers(prn10_codeDelay_mp1_indx1)=NaN;
% prn10_carriDelay_mpothers(prn10_codeDelay_mp1_indx1)=NaN;
% prn10_SNR_mpothers(prn10_codeDelay_mp1_indx1)=NaN;
% 
% prn10_codeDelay_mpothers(prn10_codeDelay_mp2_indx1)=NaN;
% prn10_carriDelay_mpothers(prn10_codeDelay_mp2_indx1)=NaN;
% prn10_SNR_mpothers(prn10_codeDelay_mp2_indx1)=NaN;
% 
% prn10_codeDelay_mpothers(prn10_codeDelay_mp3_indx1)=NaN;
% prn10_carriDelay_mpothers(prn10_codeDelay_mp3_indx1)=NaN;
% prn10_SNR_mpothers(prn10_codeDelay_mp3_indx1)=NaN;
% 
% L = ~isnan(prn10_codeDelay_mp2_prime);
% prn10_codeDelay_mpothers(L) = prn10_codeDelay_mp2_prime(L);
% prn10_carriDelay_mpothers(L)= prn10_carriDelay_mp2_prime(L);
% prn10_SNR_mpothers(L)= prn10_SNR_mp2_prime(L);
% 
% prn10_codeDelay_mpothers_nanindx=[(1:93),(173:182),(215:223),(235:237),(258:283),(326:341),(394:398),(458:468),(530:538),(589:618),664,(668:675),(689:703),...
%     (727:728),744,766,(808),(812:819),832,(873:875),(922:934),(1003:1007),1029,1049,(1056:1058),1081,1086,(1127:1129),1145,(1153:1154),(1260:1274),(1297),...
%     (1397:1401),(1410:1413),(1421:1422),1467,(1480:1481),(1489:1492),1504,(1528:1531),(1542:1545),(1555:1557),1646,1653,1732,(1746:1757)];%,(1594:1716),(1722:1818)];
% prn10_codeDelay_mpothers(prn10_codeDelay_mpothers_nanindx)=NaN;
% prn10_carriDelay_mpothers(prn10_codeDelay_mpothers_nanindx)=NaN;
% prn10_SNR_mpothers(prn10_codeDelay_mpothers_nanindx)=NaN;
% 
% prn10_carriDelay_mpothers(107:110)=prn10_carriDelay_mpothers(107:110)+2*pi;
% prn10_carriDelay_mpothers(138:147)=prn10_carriDelay_mpothers(138:147)+2*pi;
% prn10_carriDelay_mpothers(200:208)=prn10_carriDelay_mpothers(200:208)+2*pi;
% prn10_carriDelay_mpothers(284:289)=prn10_carriDelay_mpothers(284:289)+2*pi;
% prn10_carriDelay_mpothers(349:352)=prn10_carriDelay_mpothers(349:352)-2*pi;
% prn10_carriDelay_mpothers(729:731)=prn10_carriDelay_mpothers(729:731)+2*pi;
% prn10_carriDelay_mpothers(764:765)=prn10_carriDelay_mpothers(764:765)-2*pi;
% prn10_carriDelay_mpothers(783:794)=prn10_carriDelay_mpothers(783:794)-2*pi;
% prn10_carriDelay_mpothers(807)=prn10_carriDelay_mpothers(807)-2*pi;
% prn10_carriDelay_mpothers(906:907)=prn10_carriDelay_mpothers(906:907)-2*pi;
% prn10_carriDelay_mpothers(1000:1002)=prn10_carriDelay_mpothers(1000:1002)-2*pi;
% prn10_carriDelay_mpothers(1023)=prn10_carriDelay_mpothers(1023)+2*pi;
% prn10_carriDelay_mpothers(1030:1033)=prn10_carriDelay_mpothers(1030:1033)-2*pi;
% prn10_carriDelay_mpothers(1041:1051)=prn10_carriDelay_mpothers(1041:1051)+2*pi;
% prn10_carriDelay_mpothers(1169:1186)=prn10_carriDelay_mpothers(1169:1186)-2*pi;
% prn10_carriDelay_mpothers(1227:1259)=prn10_carriDelay_mpothers(1227:1259)-2*pi;
% prn10_carriDelay_mpothers(1249:1259)=prn10_carriDelay_mpothers(1249:1259)-2*pi;
% prn10_carriDelay_mpothers(1298:1309)=prn10_carriDelay_mpothers(1298:1309)+2*pi;
% prn10_carriDelay_mpothers(1333:1342)=prn10_carriDelay_mpothers(1333:1342)-2*pi;
% prn10_carriDelay_mpothers(1359:1361)=prn10_carriDelay_mpothers(1359:1361)-2*pi;
% prn10_carriDelay_mpothers(1392:1396)=prn10_carriDelay_mpothers(1392:1396)-2*pi;
% prn10_carriDelay_mpothers(1359:1361)=prn10_carriDelay_mpothers(1359:1361)-2*pi;
% prn10_carriDelay_mpothers(1457:1459)=prn10_carriDelay_mpothers(1457:1459)-2*pi;
% prn10_carriDelay_mpothers(1474:1488)=prn10_carriDelay_mpothers(1474:1488)-2*pi;
% prn10_carriDelay_mpothers(1499:1514)=prn10_carriDelay_mpothers(1499:1514)-2*pi;
% prn10_carriDelay_mpothers(1535:1541)=prn10_carriDelay_mpothers(1535:1541)-2*pi;
% prn10_carriDelay_mpothers(1588)=prn10_carriDelay_mpothers(1588)+2*pi;
% prn10_carriDelay_mpothers(1578:1584)=prn10_carriDelay_mpothers(1578:1584)-2*pi;
% prn10_carriDelay_mpothers(1594:1596)=prn10_carriDelay_mpothers(1594:1596)+2*pi;
% prn10_carriDelay_mpothers(1625:1636)=prn10_carriDelay_mpothers(1625:1636)-2*pi;
% prn10_carriDelay_mpothers(1625:1636)=prn10_carriDelay_mpothers(1625:1636)-2*pi;
% prn10_carriDelay_mpothers(1672:1674)=prn10_carriDelay_mpothers(1672:1674)+2*pi;
% prn10_carriDelay_mpothers(1725:1739)=prn10_carriDelay_mpothers(1725:1739)-2*pi;
% prn10_carriDelay_mpothers(1774:1788)=prn10_carriDelay_mpothers(1774:1788)-2*pi;
% prn10_carriDelay_mpothers(1794)=prn10_carriDelay_mpothers(1794)+2*pi;
% prn10_carriDelay_mpothers(1824:1825)=prn10_carriDelay_mpothers(1824:1825)+2*pi;
% prn10_carriDelay_mpothers(1855:1857)=prn10_carriDelay_mpothers(1855:1857)+2*pi;







