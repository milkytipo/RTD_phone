% Design a LMS anti-jamming adaptive filer for the receiver
% Created by xin.chen@sjtu.edu.cn, May 8 2015

function preFilt = ConfigurePreFilter

global GSAR_CONSTANTS;

% Config the pre-filter object. The define paramters of the filter is
% defined in the function 'prefilter_design'
% preFilt.Hd = prefilter_design;

% Design the LMS filter
preFilt.Rnk = 64;
preFilt.mu  = 0.00001;
preFilt.w   = zeros(preFilt.Rnk,1);
preFilt.u   = zeros(preFilt.Rnk,1);
preFilt.Hd = dsp.LMSFilter('Length',preFilt.Rnk, 'Method','Normalized LMS', 'StepSize',preFilt.mu);

% preFilt.zi = zeros(length(preFilt.Hd) -1, 1);

preFilt.fs = GSAR_CONSTANTS.STR_RECV.fs;

% preFilt.IF1 = GSAR_CONSTANTS.STR_RECV.IF;

% preFilt.phase = 0;





end