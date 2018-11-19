function [fitresult, gof] = createFitPoly4(x_t, y_t)
%CREATEFIT(X_T,PRERR_TEMP)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : x_t
%      Y Output: prErr_temp
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  另请参阅 FIT, CFIT, SFIT.

%  由 MATLAB 于 07-Jun-2018 14:07:42 自动生成


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( x_t, y_t );

% Set up fittype and options.
ft = fittype( 'poly4' );

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft );

% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
h = plot( fitresult, xData, yData );
legend( h, 'prErr_temp vs. x_t', 'untitled fit 1', 'Location', 'NorthEast' );
% Label axes
xlabel x_t
ylabel prErr_temp
grid on


