clear;
fileName = 'D:\胎猟才祉烏\胎猟可創\IAG\LuJiazui_Data_Analysis_original.xlsx';
sheetName = 'lujiazui_1_2016-7-4_20-19-48';
[parameter,~,~] = xlsread(fileName, sheetName);
multiNum = size(parameter, 1);
bdsNum = 174;
sys = 'BDS';  %  BDS / GPS / ALL
switch sys
    case 'BDS'
        line = 1 : bdsNum;
    case 'GPS'
        line = (bdsNum+1) : multiNum;
    case 'ALL'
        line = 1 : multiNum;
end
codeDelay = [parameter(line,3);parameter(line,9);parameter(line,15)];
attenuation = [parameter(line,4);parameter(line,10);parameter(line,16)]*-1;
lifeTime = [parameter(line,5);parameter(line,11);parameter(line,17)];
codeDelay(isnan(codeDelay)) = [];
attenuation(isnan(attenuation)) = [];
lifeTime(isnan(lifeTime)) = [];
remove = [lifeTime<=0];
codeDelay(remove) = [];
attenuation(remove) = [];
lifeTime(remove) = [];

MpNum = length(codeDelay);

%% multipath delay distribution model
% ！！！！！！！！！！ 岷圭夕 ！！！！！！！！！！%
delay_hist_step = 10;
delay_xvalues = 0:delay_hist_step:1100;
[delaynelements, delaycenters] = hist(codeDelay,delay_xvalues);
figure();
bar(delaycenters, delaynelements/MpNum);%+delay_hist_step/2

%！！！！！！！！！！ 痕方亭栽 ！！！！！！！！！！！！%
% delay_pd = fitdist(delaycenters','Gamma','Frequency',delaynelements');
% x = (1:5:1000);
% a1 = delay_pd.a-0.1;
% b1 = delay_pd.b;
% c1 = 20.5;
% f1 = c1/(b1^a1 * gamma(a1)) * x.^(a1-1).*exp(-x/b1);
% hold on
% % plot(x*delay_hist_step,f1,'r')
% plot(x,f1,'r')
% delay_pd_ex = fitdist(delaycenters','Exponential','Frequency',delaynelements');
% lamda = 0.003;%delay_pd_ex.mu;
% f2 = 28*lamda*exp(-lamda*x);
% hold on
% plot(x,f2,'m')
% real_data = delaynelements(2:end)/MpNum;
% model_data_Ga = c1/(b1^a1 * gamma(a1)) * delay_xvalues(2:end).^(a1-1).*exp(-delay_xvalues(2:end)/b1);
% model_data_Ex = 28*lamda*exp(-lamda * delay_xvalues(2:end));
% MSE_Ga = sum((model_data_Ga - real_data).^2);
% MSE_Ex = sum((model_data_Ex - real_data).^2);
%% multipath power-delay profile model
% figure;
power_values = NaN(length(delay_xvalues)-1,1);
for i=1:length(delay_xvalues)-1
    L1 = codeDelay >=delay_xvalues(i);
    L2 = codeDelay < delay_xvalues(i+1);
    L3 = L1&L2;
    att = attenuation(L3);
    if ~isempty(att)
        L = isnan(att);
        power_values(i) = mean(10.^(att(~L)/20));
    end
end
% powerdelay_profile_pd = fitdist(power_values,'Exponential');
powerdelay_profile = 20*log10(power_values);
delayx = delay_xvalues(2:end)-delay_hist_step/2;
figure() 
plot(delay_xvalues(2:end)-delay_hist_step/2, powerdelay_profile,'o');
%！！！！！！ 痕方亭栽 ！！！！！！！！%
% S0db = -11.7;
% d = -0.0085;
% x = 10:5:1000;
% avg_mp_power = S0db + d*x;





%% multipath life-time model
%----- scatter multipath ----=
x_liftime_scatter = 1:1:100;
figure();
[mpltnelements, mpltcenters] = hist(lifeTime,x_liftime_scatter);
bar(mpltcenters, mpltnelements/length(lifeTime))

%！！！！！！ 痕方亭栽 ！！！！！！！！%
% mplt_pd_gamma = fitdist(mpltcenters','Gamma','Frequency',mpltnelements');
% mplt_a_gamma = mplt_pd_gamma.a;
% mplt_b_gamma= mplt_pd_gamma.b;
% mplt_c =1;
% mplt_f_gamma = mplt_c/(mplt_b_gamma^mplt_a_gamma * gamma(mplt_a_gamma)) * x_liftime_scatter.^(mplt_a_gamma-1).*exp(-x_liftime_scatter/mplt_b_gamma);
% hold on
% plot(x_liftime_scatter,mplt_f_gamma,'m')
% 
% % calculate MSE
% real_data = mpltnelements/length(mp_lifetime_list_Scatters);
% rmse_gamma = sum((mplt_f_gamma - real_data).^2);
% 
% 
% mplt_pd_rayleigh = fitdist(mpltcenters','Rayleigh','Frequency',mpltnelements');
% mplt_b_rayleigh = mplt_pd_rayleigh.b;
% mplt_f_rayleigh = (x_liftime_scatter/mplt_b_rayleigh^2).*exp(-x_liftime_scatter.^2/2/mplt_b_rayleigh^2);
% plot(x_liftime_scatter,mplt_f_rayleigh,'g')
% 
% % calculate MSE
% rmse_rayleigh = sum((mplt_f_rayleigh - real_data).^2);
% 
% 
% mplt_pd_normal = fitdist(mpltcenters','Normal','Frequency',mpltnelements');
% mplt_mu_normal = 6; %mplt_pd_normal.mu;  6
% mplt_sigma_normal = 5.8; %mplt_pd_normal.sigma;  5.8
% mplt_f_normal = exp(-(x_liftime_scatter-mplt_mu_normal).^2/2/mplt_sigma_normal^2)/mplt_sigma_normal/sqrt(2*pi);
% plot(x_liftime_scatter,mplt_f_normal,'r')
% 
% % calculate MSE
% rmse_normal = sum((mplt_f_normal - real_data).^2);
% % chi square test
% sumUse = sum(mpltnelements(1:29));
% chi_normal = sum(((mplt_f_normal(1:29)*sumUse - mpltnelements(1:29)).^2)./mpltnelements(1:29));



% %----- IgsoMeoSpecular multipath lift time -----
% x_liftime_IgsoMeoSpecular = 10:20:1000;
% figure;
% [mpltnelements, mpltcenters] = hist(mp_lifetime_list_IgsoMeoSpecular,x_liftime_IgsoMeoSpecular);
% bar(mpltcenters, mpltnelements/length(mp_lifetime_list_IgsoMeoSpecular))
% % bar(mpltcenters, mpltnelements/1000*length(mp_lifetime_list_IgsoMeoSpecular))
% 
% x = 0:1:1000;
% mplt_mu_normal = 90; %mplt_pd_normal.mu;
% mplt_sigma_normal = 55; %mplt_pd_normal.sigma;
% mplt_f_normal = 20*exp(-(x-mplt_mu_normal).^2/2/mplt_sigma_normal^2)/mplt_sigma_normal/sqrt(2*pi);
% hold on;
% plot(x,mplt_f_normal,'r')