function outIRWLS = rcv_IRWLSregS(y,X,ini_beta,psifunc,refsteps,reftol,init_weight,initialscale)
%IRWLSregS (iterative reweighted least squares) does refsteps refining steps from initialbeta for S estimator
%
%  Required input arguments:
%
%    y:         A vector with n elements that contains the response variable.
%               It can be both a row or column vector.
%    X :        Data matrix of explanatory variables (also called 'regressors')
%               of dimension (n x p). Rows of X represent observations, and
%               columns represent variables.
% initialbeta : p x 1 vector containing initial estimate of beta
%     psifunc : a structure specifying the class of rho function to use, the
%               consistency factor, and the value associated with the
%               Expectation of rho in correspondence of the consistency
%               factor
%               psifunc must contain the following fields
%               c1 = consistency factor associated to required
%                    breakdown point
%               kc1= Expectation for rho associated with c1
%               class = string identyfing the rho (psi) function to use.
%                    Admissible values for class are 'bisquare', 'optimal'
%                    'hyperbolic' and 'hampel'
%               Remark: if class is 'hyperbolic' it is also necessary to
%                   specify parameters k (sup CVC), A, B and d
%               Remark: if class is 'hampel' it is also necessary to
%                   specify parameters a, b and c
%   refsteps  : scalar, number of refining (IRLS) steps
%   reftol    : relative convergence tolerance
%               Default value is 1e-7
%
%  Optional input arguments:
%
% initialscale: scalar, initial estimate of the scale. If not defined,
%               scaled MAD of residuals is used.
%
%  Output:
%
%  The output consists of a structure 'outIRWLS' containing the following fields:
%      betarw  : p x 1 vector. Estimate of beta after refsteps refining steps
%     scalerw  : scalar. Estimate of scale after refsteps refining step
%     weights  : n x 1 vector. Weights assigned to each observation
%
% In the IRWLS procedure the value of beta and the value of the scale are
% updated in each step

%% Beginning of code
c=psifunc.c1;
kc=psifunc.kc1;

% Residuals for the initialbeta
res = y - X * ini_beta;

% The scaled MAD of residuals is the initial scale estimate default value
if (nargin < 8)
    initialscale = median(abs(res))/.6745;
end

beta = ini_beta;
scale = initialscale;

XXrho=strcat(psifunc.class,'rho');
hrho=str2func(XXrho);


XXwei=strcat(psifunc.class,'wei');
hwei=str2func(XXwei);


iter = 0;
betadiff = 9999;

while ( (betadiff > reftol) && (iter < refsteps) )
    iter = iter + 1;
    
    % Solve for the scale
    meanrho=mean(feval(hrho,res/scale,c));
    
    scale = scale * sqrt(meanrho / kc );
    
    % Compute n x 1 vector of weights (using TB)
    
    weights = feval(hwei,res/scale,c);
    % weight estimation methods:
    % TB = Tucky's biweight function. It is hard rejection finction
    %      w = (1 - (u/c).^2).^2;   % c = consistency factor
    %      w( abs(u/c) > 1 )= 0;    % u = res/scale;
    % DM = Dansih Method of weight estimation. 
    %      w = exp(-u^2/c^2)
    %      w(( abs(u/c) > 1 )= 1;
    %      however danish method can be further improved for our
    %      requirement in a way that replace 1 with initial CN0 based
    %      weight function by multiplying initialweights with w vector.
    %      This can be doned by adding additional paprameter of
    %      init_weightin fuction call
    %      weights = weight_compute(res,scale,c,'TB',init_weight);
% %     weights = weight_compute(res,scale,c,'TB',init_weight);
    
    sqweights = weights.^(1/2);
    
    % Xw = [X(:,1) .* sqweights X(:,2) .* sqweights ... X(:,end) .* sqweights]
    Xw = bsxfun(@times, X, sqweights);
    % for test only 
    % do clock corrections
    if size(X,2)<5
        clk1 = find(X(:,4) == 1);
        clk11 = find(X(:,1) == 1);
    end
    if size(X,2)>=5
        clk12 = find(X(:,4) == 1);
        clk22 = find(X(:,5)==1);
    end
    if size(X,2)<5
        if ~isempty(clk1)
            y = y - beta(4);
        elseif ~isempty(clk11)
            y = y - beta(1);
        end
    end
    if size(X,2)>=5
        if ~isempty(clk12) && isempty(clk22)
            y(clk12) = y(clk12) - beta(4);
        elseif ~isempty(clk22) && isempty(clk12)
            y(clk22) = y(clk22)-beta(5);
        elseif ~isempty(clk12) && ~isempty(clk22)
            y(clk12) = y(clk12) - beta(4);
            y(clk22) = y(clk22)-beta(5);
        end
    end
        
    yw = y .* sqweights;
    
    % estimate of beta from (re)weighted regression (RWLS)
    newbeta = Xw\yw;
%     newbeta = X\y;
    % exit from the loop if the new beta has singular values. In such a
    % case, any intermediate estimate is not reliable and we can just
    % keep the initialbeta and initial scale.
    if (any(isnan(newbeta)))
        newbeta = ini_beta;
        scale = initialscale;
        weights = NaN;
        break
    end
    
    % betadiff is linked to the tolerance (specified in scalar reftol)
    betadiff = norm(beta - newbeta,1) / norm(beta,1);
    
    % update residuals and beta
    res = y - X * newbeta;
    beta = newbeta;
    
end

% store final estimate of beta
outIRWLS.betarw = newbeta;
% store final estimate of scale
outIRWLS.scalerw = scale;
% store final estimate of the weights for each observation
outIRWLS.weights=weights;
end