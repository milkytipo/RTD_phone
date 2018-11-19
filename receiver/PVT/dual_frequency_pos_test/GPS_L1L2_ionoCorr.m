function diff = GPS_L1L2_ionoCorr( channel_spc, ISC )

%求解电离层延时和卫星设备延时，单位：米
% 设L1伪距为rho1,则校正公式为（GPS-200H,p172):
... rho = rho1 + (rho2-rho1)/(1-gamma) + c*(ISC_L2C-gamma*ISC_L1CA)/(1-gamma) - c*T_GD;
... 而从跟踪环路可以计算： rho2-rho1 = （L1_codPhs - L2_codPhs）* c / 1.023MHz

%diff: 延时校正量 rho = rho1 + diff;
%channel_spc: 通过L1和L2的码相位可以获取频间总延时
%ISC: 星历播发的卫星设备延时信息

c = 299792458;
gamma = (77/60)^2; % (f1/f2)^2

p1 = channel_spc.LO_codPhs;   %local code phase of CA code
p2 = channel_spc.LO_codPhs_L2;

delta_phs = mod(p1-p2, 1023);
if (delta_phs>511.5)
    delta_phs = delta_phs - 1023;
end
delta_phs = (delta_phs * c/1.023e6)/(1-gamma); %换算成以米为单位

if (ISC.ISC_ready)
    ISC_corr =  c*(ISC.ISC_L2C - gamma * ISC.ISC_L1CA)/(1-gamma) - c*ISC.T_GD;
else
    ISC_corr = 0;
end

diff = delta_phs + ISC_corr;