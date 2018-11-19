function pvtKalman = pvtEKF_Reset(pvtKalman, sysNum, pvtT)

pvtKalman.preTag = 0;% Kalman filter initialization flag: 1 - initialized
% Receiver x,vx,y,vy,z,vz state sub-vectors
pvtKalman.stt_x  = zeros(2,1); %[x,vx], x-component position-velocity state vector
pvtKalman.stt_y  = zeros(2,1); %[y,vy], y-component position-velocity state vector
pvtKalman.stt_z  = zeros(2,1); %[z,vz], z-component position-velocity state vector
% receiver clk error state sub-vectors for different systems
% col1 [dt;dtf] for BDS, col2 [dt;dtf] for GPS
pvtKalman.stt_dtf = zeros(2,sysNum);
% Kalman updating interval
pvtKalman.T = pvtT;
% state component sub-vector transition matrix for both position states and
% clk error states
pvtKalman.Ac = [1, pvtT; 0, 1];
% position state component sub-vector error covirance matrix
Sv = 10; % velocity variance, m^2
pvtKalman.Qp = Sv*[pvtT^3/3, pvtT^2/2; pvtT^2/2, pvtT];
% clk error sub-vector covirance matrix
Sf = 0.01; % clk drift covirance m/s
St = 20; % clk error covirance m^2
pvtKalman.Qb = St*[pvtT, 0; 0, 0] + Sf*[pvtT^3/3, pvtT^2/2; pvtT^2/2, pvtT];
% Rv, measurement floor variance, e1 for pseudorange, e2 for velocity
pvtKalman.Rv = [0.5; 0.1];
% Pxyz0: initial state covirance matrix diagnal values for each sub-state-vector
pvtKalman.Pxyz0 = [30; 3];
% Pb0: initial state covirance matrix diagnal values for clk error
% sub-state vector
pvtKalman.Pb0 = [10; 2];
% Pxyz: real-time state covariance matrix for each sub state vectors
pvtKalman.P = [];
% pvtKalman.Pxyz.Psub = zeros(2,2);
% pvtKalman.Pxyz(1:3) = pvtKalman.Pxyz;
% % Pb: real-time state covariance matrix for clk error sub state vectors
% pvtKalman.Pb.Ptdf = zeros(2,2);
% pvtKalman.Pb.Ptdf(1:sysNum) = pvtKalman.Pb.Ptdf;



