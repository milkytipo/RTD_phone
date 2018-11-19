function [fitresult, gof] = lineFit(x_mean, y_mean)
%CREATEFIT(X_MEAN,Y_MEAN)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : x_mean
%      Y Output: y_mean
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  另请参阅 FIT, CFIT, SFIT.

%  由 MATLAB 于 30-Aug-2017 21:41:38 自动生成


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( x_mean, y_mean );

% Set up fittype and options.
ft = fittype( 'poly1' );

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft );

% % Plot fit with data.
% figure( 'Name', 'untitled fit 1' );
% h = plot( fitresult, xData, yData );
% legend( h, 'y_mean vs. x_mean', 'untitled fit 1', 'Location', 'NorthEast' );
% % Label axes
% xlabel x_mean
% ylabel y_mean
% grid on


