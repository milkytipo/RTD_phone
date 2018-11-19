function chn = chn_loopintegrator_initialize(chn)

chn.Tslot_I    = zeros(3,1);
chn.Tslot_Q    = zeros(3,1);
chn.T_I        = zeros(3,1);
chn.T_Q        = zeros(3,1);
chn.Tcoh_I     = zeros(3,1);
chn.Tcoh_Q     = zeros(3,1);
chn.Tcoh_I_prev= zeros(3,1);
chn.Tcoh_Q_prev= zeros(3,1);
chn.T_pll_I    = zeros(3,1);
chn.T_pll_Q    = zeros(3,1);
chn.PromptIQ_D = zeros(2,1);
% Note: the first set of elements of Loop_I need to be assigned some
% positive values
chn.Loop_I  = [100*ones(3,1), zeros(3,14)];
chn.Loop_Q  = [100*ones(3,1), zeros(3,14)];
chn.Loop_N  = 0;
