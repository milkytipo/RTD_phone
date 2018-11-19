function [out] = rsv_Sreg(y,X,nsamp,W)

% global ROBUST_EST
%% Beginning of code
    %============ for test ------------
% % %     len = size(X,2) - 3;
% % %     if len>1
% % %     for l=1:len
% % %         xx = X\y;
% % %         ind1 = find(X(:,3+l)==1);
% % %         y(ind1) = y(ind1) - repmat(xx(3+l),1,length(ind1))';
% % %     end
% % %     end
    
% %     ind1 = find(X(:,5)==1);
% %     y(ind1) = y(ind1) - repmat(xx(5),1,length(ind1))';
    
% turn off warning
war = warning('query','MATLAB:rankDeficientMatrix');
id  = war.identifier;
 warning('off',id)
 war = warning('query','MATLAB:singularMatrix');
id  = war.identifier;
 warning('off',id)
if nargin < 4  && nargin >= 3
   n = length(y);
   W = ones(n,1);
elseif nargin < 3
    nsamp = 5;
elseif nargin < 2
    warning('Input arguments are not enough to compute initial value');
    return;
end    
% default value of break down point
bdpdef=0.5;


% p is the number of parameters to be estimated
% nnargin = nargin;
% vvarargin = varargin;
p=size(X,2);
n = size(X,1);
% % % [y,X,n,p] = rsv_chkinputR(y,X);
% [y,X,n,p] =  chkinputR(y,X,nnargin,'');
% default values of subsamples to extract
ncomb=bc(n,nsamp);
% % ncomb=bc(n,p);
nsampdef=min(10000,ncomb);

% default value of number of refining iterations (C steps) for each extracted subset
refstepsdef=3;

% default value of tolerance for the refining steps convergence for  each extracted subset
reftoldef=1e-6;

% default value of number of best betas to remember
bestrdef=5;

% default value of number of refining iterations (C steps) for best subsets
% refstepsbestrdef=50;
refstepsbestrdef=20;

% default value of tolerance for the refining steps convergence for best subsets
reftolbestrdef=1e-8;

% default value of tolerance for finding the minimum value of the scale
% both for each extracted subset and each of the best subsets
minsctoldef=1e-7;

msg = 1;

% rho (psi) function which has to be used to weight the residuals
% % rhofuncdef=ROBUST_EST.rho; %'bisquare';
rhofuncdef = 'bisquare';

% Tukey's biweight is strictly increasing on [0 c] and constant (equal to c^2/6) on [c \infty)
% Compute tuning constant associated to the requested breakdown
% point
% For bdp =0.5 and Tukey biweight rho function c1=0.4046
bdp = 0.5;
c=TBbdp(bdp,1);
% c = 1.547644980928226;
u = c;
w = (abs(u)<=c);
% kc = ((u.^2/(2).*(1-(u.^2/(c^2))+(u.^4/(3*c^4)))).*w +(1-w)*(c^2/6))*bdp;
kc=TBrho(c,c)*bdp;

psifunc.c1=c;
psifunc.kc1=kc;
psifunc.class='TB';


bestbetas  = zeros(bestrdef,p); 
bestsubset = zeros(bestrdef,nsamp);
bestscales = Inf * ones(bestrdef,1);
sworst     = Inf;

% singsub = scalar which will contain the number of singular subsets which
% are extracted (that is the subsets of size p which are not full rank)
singsub=0;

% ij is a scalar used to ensure that the best first bestr non singular
% subsets are stored
ij=1;

%% Extract in the rows of matrix C the indexes of all required subsets
[C,nselected] = subsets(nsampdef,n,nsamp,ncomb,msg);
% initialise and start timer.
tsampling = ceil(min(nselected/100 , 1000));
time=zeros(tsampling,1);
XXrho=strcat(psifunc.class,'rho');
hrho=str2func(XXrho);
for i = 1:nselected
    
    if i <= tsampling, tic; end
    
    % extract a subset of size p
    index = C(i,:);
%     index = [194 103 88 11]; % for debugging only
    Xb = X(index,:); 
    yb = y(index);
    
    % beta estimate
%     w = diag(W(index));
%     beta = inv(Xb'*w*Xb)*Xb'*w*yb;
    beta = Xb\yb;


    if ~isnan(beta(1)) && ~isinf(beta(1))
        
        if refstepsdef > 0
            
            % do the refsteps refining steps
            % kc determines the breakdown point
            % c is linked to the biweight function
            tmp = rcv_IRWLSregS(y,X,beta,psifunc,refstepsdef,reftoldef,W);
%             tmp = IRWLSregS(y,X,beta,psifunc,refstepsdef,reftoldef,W);
            betarw = tmp.betarw;
            scalerw = tmp.scalerw;
            resrw = y - X * betarw;
            
        else
            
            % no refining steps
            betarw = beta;
            resrw = y - X * betarw;
            scalerw = median(abs(resrw))/.6745;
        end
        
        % to find s, save first the best bestr scales (deriving from non
        % singular subsets) and, from iteration bestr+1 (associated to
        % another non singular subset), replace the worst scale
        % with a better one as follows
        
        if ij > bestrdef
            
            % compute the objective function using current residuals and
            % the worst estimate of the scale among the bests previously
            % stored
            % scaletest = (1/n) \sum_i=1^n (u_i/(sworst*c))
            
            % Use function handle hrho. For example if
            % for optimal psi hrho=OPTrho
            %scaletest = mean(TBrho(resrw/sworst,c));
            scaletest=mean(feval(hrho,resrw/sworst,psifunc.c1));
% %             scaletest=mean(TBrho(resrw/sworst,psifunc.c1));
            
            if scaletest < kc
                
                % Find position of the maximum value of previously stored
                % best scales
                [~,ind] = max(bestscales);
                
                sbest = Mscale(resrw,psifunc,scalerw,minsctoldef);
                
                % Store sbest, betarw and indexes of the units forming the
                % best subset associated with minimum value
                % of the scale
                bestscales(ind) = sbest;
                bestbetas(ind,:) = betarw';
                % best subset
                bestsubset(ind,:)=index;
                % sworst = the best scale among the bestr found up to now
                sworst = max(bestscales);
                
            end
            
        else
            
            bestscales(ij) = Mscale(resrw,psifunc,scalerw,minsctoldef);
            
            bestbetas(ij,:) = betarw';
            
            bestsubset(ij,:) = index;
            
            ij=ij+1;
            
        end
        
    else
        
        singsub=singsub+1;
        
    end
    
%     % Write total estimate time to compute final estimate
%     if i <= tsampling
%         % sampling time until step tsampling
%         time(i)=toc;
%     elseif i==tsampling+1
%         % stop sampling and print the estimated time
% %         if msg==1
% %             fprintf('Total estimated time to complete S estimate: %5.2f seconds \n', nselected*median(time));
% %         end
%     end
    
end

% perform C-steps on best 'bestr' solutions, till convergence or for a
% maximum of refstepsbestr steps using a convergence tolerance as specified
% by scalar reftolbestr

superbestscale = Inf;

for i=1:bestrdef
%     tmp = IRWLSregS(y,X,bestbetas(i,:)',psifunc,refstepsbestrdef,reftolbestrdef,bestscales(i));
    tmp = rcv_IRWLSregS(y,X,bestbetas(i,:)',psifunc,refstepsbestrdef,reftolbestrdef,bestscales(i));
    if tmp.scalerw < superbestscale
        superbestscale = tmp.scalerw;
        superbestbeta = tmp.betarw;
        superbestsubset = bestsubset(i,:);
        weights = tmp.weights;
    end
end

% Store in output structure \beta, s, best subset and vector of S-weights
%% fro debugging=========================================================
if isinf(superbestscale)
    superbestbeta = beta;
    superbestsubset = [1:length(y)];
    out.scale = superbestscale;
    out.weights = ones(length(y),1);
    out.beta = superbestbeta;
    out.bs = superbestsubset;
else
    out.beta = superbestbeta;
    out.scale = superbestscale;
    out.bs = superbestsubset;
    out.weights = weights;
end
%%========================================================================
% % out.beta = superbestbeta;
% % out.scale = superbestscale;
% % out.bs = superbestsubset;
% % out.weights = weights;


% compute and store in output structure the S robust scaled residuals
out.residuals=(y-X*out.beta)/out.scale;

% Store in output structure the number of singular subsets
out.singsub=singsub;

conflev = 0.999;

out.conflev = conflev;

conflev = (conflev+1)/2;
seq = 1:n;
out.outliers = seq( abs(out.residuals)>norminv(conflev) );
% warning('on',id)

