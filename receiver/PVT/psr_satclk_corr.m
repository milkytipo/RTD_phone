function [psr_obs_corr] = psr_satclk_corr(psr_obs, satClkCorr_dts)
% Pseudorange satellite clock error correction

c = 299792458;    % The speed of light, [m/s]
psr_obs_corr = psr_obs + c*satClkCorr_dts;