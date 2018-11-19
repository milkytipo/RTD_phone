function out = rsv_MMreg(y,X,nsamp,W,hOpt)

% default values for the initial S estimate:

if nargin < 4
    W = ones(length(y),1);
elseif nargin <3
    nsamp = 5;
elseif nargin < 2
    warning('Warning: Inputs are not enough for estimation');
    return;
end

% default value of break down point
Sbdpdef=0.5;
% default values of subsamples to extract
Snsampdef=20;
% default value of number of refining iterations (C steps) for each extracted subset
Srefstepsdef=3;
% default value of tolerance for the refining steps convergence for  each extracted subset
Sreftoldef=1e-6;
% default value of number of best locs to remember
Sbestrdef=5;
% default value of number of refining iterations (C steps) for best subsets
Srefstepsbestrdef=50;
% default value of tolerance for the refining steps convergence for best subsets
Sreftolbestrdef=1e-8;
% default value of tolerance for finding the minimum value of the scale 
% both for each extracted subset and each of the best subsets
Sminsctoldef=1e-7;

% rho (psi) function which has to be used to weight the residuals
Srhofuncdef='bisquare';
% Srhofuncdef='optimal';
% Asymptotic nominal efficiency (for location or shape)
eff  = 0.999;
% refsteps = maximum number of iteration in the MM step
refsteps = 300;
% tol = tolerance to declare convergence in the MM step
tol = 1e-7; 
% confidence level
conflev = 0.975;

% MMregcore = function which does IRWLS steps from initialbeta (bs) and sigma (ss)
% Notice that the estimate of sigma (scale) remains fixed

% InitialEst = structure which contains initial estimate of beta and sigma
% If InitialEst is empty then initial estimates of beta and sigma come from
% S-estimation
InitialEst='';
% % [y,X,~,~] = rsv_chkinputR(y,X);

if isempty(InitialEst)

% %     bdp = options.Sbdp;              % break down point
% %     refsteps = options.Srefsteps;    % refining steps
% %     bestr = options.Sbestr;          % best locs for refining steps till convergence
% %     nsamp = options.Snsamp;          % subsamples to extract
% %     reftol = options.Sreftol;        % tolerance for refining steps
% %     minsctol = options.Sminsctol;    % tolerance for finding minimum value of the scale for each subset
% %     refstepsbestr=options.Srefstepsbestr;  % refining steps for the best subsets 
% %     reftolbestr=options.Sreftolbestr;      % tolerance for refining steps for the best subsets
% %     
% %     rhofunc=options.Srhofunc;           % rho function which must be used
% %     rhofuncparam=options.Srhofuncparam;    % eventual additional parameters associated to the rho function
    
    
    % first compute S-estimator with a fixed breakdown point
    
    % SR is the routine which computes S estimates of beta and sigma in regression
    % Note that intercept is taken care of by chkinputR call.
    if hOpt == 3
        X = X(:,1:3);
        [y,X,~,~] = rsv_chkinputR(y,X);
        if nargout==2
            [Sresult , C] = rsv_Sreg_03(y,X,nsamp,W);
            varargout = {C};
        else
            Sresult = rsv_Sreg_03(y,X,nsamp,W);
        end
    elseif hOpt == 4
        if nargout==2
            [Sresult , C] = rsv_Sreg(y,X,nsamp,W);
            varargout = {C};
        else
            Sresult = rsv_Sreg(y,X,nsamp,W);
        end
    end
    
    bs = Sresult.beta;
    ss = Sresult.scale;
    singsub=Sresult.singsub;
else
    bs = InitialEst.beta;
    ss = InitialEst.scale;
    singsub=0;
end

% Asymptotic nominal efficiency (for location or shape)


outIRW = rsv_MMregcore(y,X,bs,ss);  % original



out = struct;
out.beta = outIRW.beta;
out.auxscale = ss;
out.residuals = (y-X*outIRW.beta)/ss; % MM scaled residuals

out.Sbeta = bs;
out.Ssingsub=singsub;
out.weights=outIRW.weights;
out.outliers=outIRW.outliers;
out.conflev=conflev;
out.class='MM';


end