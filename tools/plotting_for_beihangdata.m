%% Beihang Data processed results: GEO PRN5
filename = 'beihang_data_PRN5_sampled.xlsx';

p1_time = xlsread(filename,1,'A4:A11962');
p1_mp1delay = xlsread(filename,1,'B4:B11962');
p1_mp1phase = xlsread(filename,1,'D4:D11962');
p1_dlosphase = xlsread(filename,1,'C4:C11962');

p1_snrtime = xlsread(filename,1,'E4:E1196');
p1_dlossnr = xlsread(filename,1,'F4:F1196');
p1_mp1snr = xlsread(filename,1,'G4:G1196');


p2_time = xlsread(filename,1,'H4:H6149') + 1170;
p2_mp1delay = xlsread(filename,1,'I4:I6149');
p2_mp1phase = xlsread(filename,1,'K4:K6149');
p2_dlosphase = xlsread(filename,1,'J4:J6149');

p2_snrtime = xlsread(filename,1,'L4:L643') + 1170;
p2_dlossnr = xlsread(filename,1,'M4:M643');
p2_mp1snr = xlsread(filename,1,'N4:N643');

p3_time = xlsread(filename,2,'A4:A6399') + 1850;
p3_mp1delay = xlsread(filename,2,'B4:B6399');
p3_mp1phase = xlsread(filename,2,'D4:D6399');
p3_dlosphase = xlsread(filename,2,'C4:C6399');

p3_snrtime = xlsread(filename,2,'E4:E643') + 1850;
p3_dlossnr = xlsread(filename,2,'F4:F643');
p3_mp1snr = xlsread(filename,2,'G4:G643');

p4_time = xlsread(filename,2,'H4:H14208') + 2450;
p4_mp1delay = xlsread(filename,2,'I4:I14208');
p4_mp1phase = xlsread(filename,2,'K4:K14208');
p4_dlosphase = xlsread(filename,2,'J4:J14208');

p4_snrtime = xlsread(filename,2,'L4:L1463') + 2450;
p4_dlossnr = xlsread(filename,2,'M4:M1463');
p4_mp1snr = xlsread(filename,2,'N4:N1463');

p5_time = xlsread(filename,3,'A4:A962') + 4500;
p5_mp1delay = xlsread(filename,3,'B4:B962');
p5_mp1phase = xlsread(filename,3,'D4:D962');
p5_dlosphase = xlsread(filename,3,'C4:C962');

p5_snrtime = xlsread(filename,3,'E4:E98') + 4500;
p5_dlossnr = xlsread(filename,3,'F4:F98');
p5_mp1snr = xlsread(filename,3,'G4:G98');


prn5_time = [p1_time; p2_time; p3_time; p4_time; p5_time];
prn5_mp1delay = [p1_mp1delay; p2_mp1delay; p3_mp1delay; p4_mp1delay; p5_mp1delay];
prn5_mp1phase = [p1_mp1phase; p2_mp1phase; p3_mp1phase; p4_mp1phase; p5_mp1phase];
prn5_dlosphase = [p1_dlosphase; p2_dlosphase; p3_dlosphase; p4_dlosphase; p5_dlosphase];

prn5_snr_time = [p1_snrtime; p2_snrtime; p3_snrtime; p4_snrtime; p5_snrtime];
prn5_mp1snr = [p1_mp1snr; p2_mp1snr; p3_mp1snr; p4_mp1snr; p5_mp1snr];
prn5_dlossnr = [p1_dlossnr; p2_dlossnr; p3_dlossnr; p4_dlossnr; p5_dlossnr];


prn5_dlosphase_mean = mean(prn5_dlosphase);
prn5_mp1phase = prn5_mp1phase - prn5_dlosphase_mean;

% Plot the accumulated dopplar of multipath with respect to DLOS
Fs = 10;
Bp = 0.01;
Bs = 0.025;

d1 = fdesign.lowpass('Fp,Fst,Ap,Ast', Bp, Bs, 0.1, 30, Fs);
hd1 = design(d1,'butter','MatchExactly','passband');
hd1.persistentmemory = true;
hd1.states = -10;
prn5_mp1phase_filted = filter(hd1,prn5_mp1phase);

figure, 
subplot(3,1,1)
plot(prn5_time(1:18105), prn5_mp1phase(1:18105));
hold on;
plot(prn5_time(18106:38706), prn5_mp1phase(18106:38706));
plot(prn5_time(38707:end), prn5_mp1phase(38707:end));

plot(prn5_time(1:18105), prn5_mp1phase_filted(1:18105),'k');
plot(prn5_time(18106:38706), prn5_mp1phase_filted(18106:38706),'k');
plot(prn5_time(38707:end), prn5_mp1phase_filted(38707:end),'k');

% Plot the multipath delay with respect to DLOS
Fs = 10;
Bp = 0.002;
Bs = 0.01;

d2 = fdesign.lowpass('Fp,Fst,Ap,Ast', Bp, Bs, 0.1, 30, Fs);
hd2 = design(d2,'butter','MatchExactly','passband');
hd2.persistentmemory = true;
hd2.states = 70;

prn5_mp1delay_filted = filter(hd2,prn5_mp1delay);

prn5_mp1delay = prn5_mp1delay*0.3;
prn5_mp1delay_filted = prn5_mp1delay_filted*0.3;

subplot(3,1,2);
plot(prn5_time(1:18105), prn5_mp1delay(1:18105));
hold on;
plot(prn5_time(18106:38706), prn5_mp1delay(18106:38706));
plot(prn5_time(38707:end), prn5_mp1delay(38707:end));

plot(prn5_time(1:18105), prn5_mp1delay_filted(1:18105),'k');
plot(prn5_time(18106:38706), prn5_mp1delay_filted(18106:38706),'k');
plot(prn5_time(38707:end), prn5_mp1delay_filted(38707:end),'k');

% plot the snr
mp1_att = prn5_dlossnr - prn5_mp1snr;

Fs = 1;
Bp = 0.001;
Bs = 0.003;

d3 = fdesign.lowpass('Fp,Fst,Ap,Ast', Bp, Bs, 0.1, 15, Fs);
hd3 = design(d3,'butter');
hd3.persistentmemory = true;
hd3.states = 3;

mp1_att_filted = filter(hd3, mp1_att);

subplot(3,1,3)
plot(prn5_snr_time(1:3933), mp1_att(1:3933));
hold on;
plot(prn5_snr_time(3934:end), mp1_att(3934:end));

plot(prn5_snr_time(1:3933), mp1_att_filted(1:3933), 'k')
plot(prn5_snr_time(3934:end), mp1_att_filted(3934:end), 'k')











