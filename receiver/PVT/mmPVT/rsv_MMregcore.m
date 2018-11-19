function out=rsv_MMregcore(y,X,b0,auxscale)


eff     = 0.999;      % nominal efficiency
effshape= 0; % nominal efficiency refers to shape or location
refsteps= 300; % maximum refining iterations
reftol  = 1e-6;   % tolerance for refining iterations covergence
rhofunc = 'bisquare';    % String which specifies the function to use to weight the residuals
iter=0;crit=Inf;b1=b0;
epsf = eps;
c = TBeff(eff,1);
while (iter <= refsteps) && (crit > reftol)
    
    r1=(y-X*b1)/auxscale;
    tmp = find(abs(r1) <= epsf);
    n1 = size(tmp,1);
    if n1 ~= 0
        r1(tmp) = epsf;
    end
    res = (y-X*b1);
    w = weight_compute(res,auxscale,c,'TB');
    
    % Every column of matrix X and vector y is multiplied by the sqrt root of the n x 1
    % weight vector w, then weighted regression is performed
    w1=sqrt(w);
    Xw=bsxfun(@times,X,w1);
    Yw=y.*w1;
    % b2 = inv(X'W*X)*X'W*y where W=w*ones(1,k)
    b2=Xw\Yw;
    % disp([b2-b22])
    
    d=b2-b1;
    crit=max(abs(d));
    iter=iter+1;
    b1=b2;
    
end


out.class = 'MM';
out.beta = b2;
out.weights = w;
out.residuals = (y-X*out.beta)/auxscale;

% Store in output structure the outliers found with confidence level conflev
% which has been usedto declared the outliers
conflev = 0.999;
n = size(X,1);
seq = 1:n;
out.outliers = seq(abs(out.residuals) > sqrt(chi2inv(conflev,1)) );
out.conflev = conflev;