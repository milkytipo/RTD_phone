function [fitresult, gof] = createFitSin8(x_t, y_t)
%CREATEFIT(X_T,CLKERRRESI)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : x_t
%      Y Output: clkErrResi
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  另请参阅 FIT, CFIT, SFIT.

%  由 MATLAB 于 07-Jun-2018 10:42:00 自动生成


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( x_t, y_t );

% Set up fittype and options.
ft = fittype( 'sin8' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf];
opts.StartPoint = [13.4651292739256 0.00337352231257964 -1.00235248845954 6.85224005917819 0.00590366404701438 -1.16329950128424 6.13224358254161 0.00506028346886947 2.08711940198645 4.4028357876518 0.00253014173443473 -2.61004259855377 4.17976160057869 0.00421690289072455 1.32113822952497 4.04306145439102 0.00168676115628982 1.35327957830012 2.55961638818564 0.0075904252033042 -2.88732553743213 3.09667348258423 0.00843380578144911 1.57341831843077];
% opts.StartPoint = [93.2034525323653 0.00216661562316537 1.49881758020898 87.2190323972171 0.00144441041544358 -0.744063668872294 25.9664667929984 0.00361102603860896 2.37537184323084 21.3415536850106 0.00288882083088717 2.13211365340822 19.1127400628383 0.00505543645405254 -2.86605251771898 19.004467777308 0.00577764166177433 2.98498275395751 17.0880048006761 0.00433323124633075 2.55277848533876 14.7116362757882 0.00794425728493971 -3.04593747962838];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
h = plot( fitresult, xData, yData );
legend( h, 'clkErrResi vs. x_t', 'untitled fit 1', 'Location', 'NorthEast' );
% Label axes
xlabel x_t
ylabel clkErrResi
grid on


