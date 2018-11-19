function [pvtCalculator] = pvtEKF_init(SYST, pvtCalculator)     
% Since calling this function means that the least-square position results
% are already obtained and checked by raim. It is trustable and the
% conditions flags are checked outside this function, so here we just use
% these results to initialize the Kalman filter.
kalman = pvtCalculator.kalman;

% C = 299792458;
% L1= 1575420000;
% wavelengthL1 = C/L1;
% B1= 1561.098e6;
% wavelengthB1 = C/B1;
% % ECEF XYZ Position Init
% kalman.state(1:3) = pvtCalculator.positionXYZ(1:3);
% % ECEF velocity init
% kalman.state(4:6) = pvtCalculator.positionVelocity(1:3);
% % Recv clk and clk_drift init
% kalman.state(7:8) = [0; 0]; %pvtCalculator.positionVelocity(4)];
% % State Estimation covariance init
% kalman.P      = diag(kalman.P0);
pos_ref_xyz= [ -2853445.926;4667466.476; 3268291.272];
bias_a=0;
% pos_ref_xyz= [ 0;0; 0];
kalman.stt_x(1:3) = [pvtCalculator.positionXYZ(1)-pos_ref_xyz(1), pvtCalculator.positionVelocity(1),pvtCalculator.positionAccelaration(1)]';
kalman.stt_y(1:3) = [pvtCalculator.positionXYZ(2)-pos_ref_xyz(2), pvtCalculator.positionVelocity(2),pvtCalculator.positionAccelaration(2)]';
kalman.stt_z(1:3) = [pvtCalculator.positionXYZ(3)-pos_ref_xyz(3), pvtCalculator.positionVelocity(3),pvtCalculator.positionAccelaration(3)]';
kalman.stt_dtf(1:3, 1) = [pvtCalculator.clkErr(1,1), pvtCalculator.clkErr(1,2),pvtCalculator.clkErr(1,3)]'; % initialize the clk states for BDS
kalman.stt_dtf(1:3, 2) = [bias_a,bias_a,bias_a]'; % initialize the acc bias for GPS

switch SYST
    case {'GPS_L1CA', 'BDS_B1I'}
        kalman.P = diag([kalman.Pxyz0; kalman.Pxyz0; kalman.Pxyz0]);
    case 'B1I_L1CA'
        kalman.P = diag([kalman.Pxyz0; kalman.Pxyz0; kalman.Pxyz0; kalman.Pb0; kalman.Pb0]);
end

% kalman.Pxyz(1).Psub = diag(pvtCalculator.kalman.Pxyz0); % initialize position x component estimation covariance matrix
% kalman.Pxyz(2).Psub = diag(pvtCalculator.kalman.Pxyz0); % initialize position y component estimation covariance matrix
% kalman.Pxyz(3).Psub = diag(pvtCalculator.kalman.Pxyz0); % initialize position z component estimation covariance matrix
% kalman.Pb(1).Ptdf = diag(kalman.Pb0); % initialize BDS clk estimation covariance matrix
% kalman.Pb(2).Ptdf = diag(kalman.Pb0); % initialize GPS clk estimation covariance matrix

kalman.preTag = 1;

pvtCalculator.kalman = kalman;
