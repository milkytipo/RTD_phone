function [kalman] = pvtEKF_prediction(SYST, kalman,parameter, Loop)

Ac = kalman.Ac;
Qp = kalman.Qp;
Qb = kalman.Qb;

% predict the x/y/z positions
% kalman.stt_x(2) =  parameter(2).IMU_vx(Loop);         
% kalman.stt_y(2) =  parameter(2).IMU_vy(Loop);
% kalman.stt_z(2) =  parameter(2).IMU_vz(Loop);
kalman.stt_x = Ac * kalman.stt_x;
kalman.stt_y = Ac * kalman.stt_y;
kalman.stt_z = Ac * kalman.stt_z;
% kalman.stt_x(2) =  parameter(2).IMU_vx(Loop);         %œ»‘§≤‚∫Û”√IMUv
% kalman.stt_y(2) =  parameter(2).IMU_vy(Loop);
% kalman.stt_z(2) =  parameter(2).IMU_vz(Loop);


% predict the x/y/z estimation covariance matrix
% kalman.Pxyz(1).Psub = Ac * kalman.Pxyz(1).Psub * Ac' + Qp;
% kalman.Pxyz(2).Psub = Ac * kalman.Pxyz(2).Psub * Ac' + Qp;
% kalman.Pxyz(3).Psub = Ac * kalman.Pxyz(3).Psub * Ac' + Qp;
% predict the clk errors
switch SYST
    case {'BDS_B1I'}
        kalman.stt_dtf(1:3, 1) = Ac * kalman.stt_dtf(1:3, 1);
        A = [Ac, zeros(3,3), zeros(3,3), zeros(3,3);
            zeros(3,3), Ac, zeros(3,3), zeros(3,3);
            zeros(3,3), zeros(3,3), Ac, zeros(3,3);
            zeros(3,3), zeros(3,3), zeros(3,3), Ac];  % 12x12 matrix
        Qw = [Qp, zeros(3,3), zeros(3,3), zeros(3,3);
            zeros(3,3), Qp, zeros(3,3), zeros(3,3);
            zeros(3,3), zeros(3,3), Qp, zeros(3,3);
            zeros(3,3), zeros(3,3), zeros(3,3), Qb];  % 12x12 matrix
        kalman.P = A * kalman.P * A' + Qw;

    case 'GPS_L1CA'
        kalman.stt_dtf(3, 2) =  kalman.stt_dtf(3, 2);
        A = [ blkdiag(Ac,eye(1)), zeros(4,4), zeros(4,4);
            zeros(4,4),  blkdiag(Ac,eye(1)), zeros(4,4);
            zeros(4,4), zeros(4,4),  blkdiag(Ac,eye(1))];
%             zeros(4,4), zeros(4,4), zeros(4,4), Ac];  % 12x12 matrix
        Qw = [Qp, zeros(4,4), zeros(4,4);
            zeros(4,4), Qp, zeros(4,4);
            zeros(4,4), zeros(4,4), Qp];  % 12x12 matrix
        kalman.P = A * kalman.P * A' + Qw;  % 12x12 matrix

    case 'B1I_L1CA'
        kalman.stt_dtf = Ac * kalman.stt_dtf;
        A = [Ac, zeros(3,3), zeros(3,3), zeros(3,3), zeros(3,3);
            zeros(3,3), Ac, zeros(3,3), zeros(3,3), zeros(3,3);
            zeros(3,3), zeros(3,3), Ac, zeros(3,3), zeros(3,3);
            zeros(3,3), zeros(3,3), zeros(3,3), Ac, zeros(3,3);
            zeros(3,3), zeros(3,3), zeros(3,3), zeros(3,3), Ac]; % 10x10 matrix
        Qw = [Qp, zeros(3,3), zeros(3,3), zeros(3,3), zeros(3,3);
            zeros(3,3), Qp, zeros(3,3), zeros(3,3), zeros(3,3);
            zeros(3,3), zeros(3,3), Qp, zeros(3,3), zeros(3,3);
            zeros(3,3), zeros(3,3), zeros(3,3), Qb, zeros(3,3);
            zeros(3,3), zeros(3,3), zeros(3,3), zeros(3,3), Qb];  % 10x10 matrix
        kalman.P = A * kalman.P * A' + Qw;
end
