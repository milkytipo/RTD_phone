function [posvel,el,az,dop] = KalmanFilter_pos(satpos, obs, Beijing_Time, ...
                             ephemeris, activeChannel, elevationMask, syst,channels,satClkCorr)
                             
global GSAR_CONSTANTS;

%% this code is designed for single GNSS system. For multi-GNSS H and kalman filter parameters 
% will be modifed by adding additional clock paramters i.e. P, Q and posvel
% this code iterative and estimates position individually at each epoch
% If kalman is used as estimation filter based on previous position;
% posvel will not be zero and will be updated as follows
% posvel = F*old_posvel
% Fsingle = [1 0 0 T 0 0 0 0;
%            0 1 0 0 T 0 0 0;
%            0 0 1 0 0 T 0 0;
%            0 0 0 1 0 0 0 0;
%            0 0 0 0 1 0 0 0;
%            0 0 0 0 0 1 0 0;
%            0 0 0 0 0 0 1 T;
%            0 0 0 0 0 0 0 1];
% Fmulti = [1 0 0 T 0 0 0 0 0 0;
%           0 1 0 0 T 0 0 0 0 0;
%           0 0 1 0 0 T 0 0 0 0;
%           0 0 0 1 0 0 0 0 0 0;
%           0 0 0 0 1 0 0 0 0 0;
%           0 0 0 0 0 1 0 0 0 0;
%           0 0 0 0 0 0 1 T 0 0;
%           0 0 0 0 0 0 0 1 0 0
%           0 0 0 0 0 0 0 0 1 T
%           0 0 0 0 0 0 0 0 0 1];
% T = integration time  = round(Tunit/Tcoh_N)*Tcoh_N*1e-3;


nmbOfIterations = 9;
dop     = zeros(1, 5);
dtr     = pi/180;
sat_xyz = satpos(1:3,:);
vX = satpos(4:6,:);
nmbOfSatellites = size(activeChannel, 2);
Rot_X   = zeros(3,35);%%经过地球自转修正后的卫星位置
H       = zeros(nmbOfSatellites, 8);
delRho     = zeros(1,nmbOfSatellites);
Rhodot     = zeros(1,nmbOfSatellites);
az      = zeros(3, nmbOfSatellites);
el      = az;
az(2,:)=activeChannel(2,:);    %令计算后的数值与卫星的prn号相对应
el(2,:)=activeChannel(2,:);
az(3,:)=activeChannel(1,:);    
el(3,:)=activeChannel(1,:);
%---
T_amb = 20;%20
P_amb = 101.325; %KPa
P_vap = .849179;%.86; 0.61078*(H/100)*exp(T/(T+238.3)*17.2694) KPa
posvel = zeros(8, 1);
delRho_dot = zeros(1,nmbOfSatellites);
c = 299792458;
% position variance == can be decided by hit and trial
Q = diag([10 10 10 0.25 0.25 0.25,1e-7,1e-5]);
% process covariance matrix
P0 = diag([1 1 1 1 1 1 1 1]);
for i=1:nmbOfSatellites
    switch syst
        case 'GPS_L1CA'
            channel   = channels(activeChannel(1,i),1).CH_L1CA(1,1);
             T =  channel.Tcohn_N*1e-3*25;
             carrFreq  = GSAR_CONSTANTS.STR_L1CA.L0;
             temp = channel.CN0_Estimator.CN0/10;
             alpha = (c/(pi*carrFreq)*(T*1e-3))^2;
             R(i,i)       =  ((beta^2)/(2*(T*exp(temp)))^2) + ((beta^2)/(4*T*exp(temp)));
             R(i+numberOfSats,i+numberOfSats) = (2/(T*exp(temp))^2) + (2/(T*exp(temp)));
             Rhodot(i) = (-c/carrFreq)*channel.LO2_fd;
        case 'BD_B1I'
            channel   = channels(activeChannel(1,i),1).CH_B1I(1,1);
             T =  channel.Tcohn_N*1e-3*25;
             carrFreq  = GSAR_CONSTANTS.STR_B1I.L0;
             temp = channel.CN0_Estimator.CN0/10;
             alpha = (c/(pi*carrFreq)*(T*1e-3))^2;
             R(i,i)       =  ((beta^2)/(2*(T*exp(temp)))^2) + ((beta^2)/(4*T*exp(temp)));
             R(i+numberOfSats,i+numberOfSats) = (2/(T*exp(temp))^2) + (2/(T*exp(temp)));
             Rhodot(i) = (-c/carrFreq)*channel.LO2_fd;
    end
end

for iter = 1:nmbOfIterations
    W = R;
    for i = 1:nmbOfSatellites
        if ephemeris(activeChannel(2,i)).eph.Alpha0 == 'N'
            Alpha_i = [2.186179e-008,-9.73869e-008,7.03774e-008,3.031505e-008];
            Beta_i = [ 129643.8, -64245.75, -866336.2,1612913];
        else
            Alpha_i =[ephemeris(activeChannel(2,i)).eph.Alpha0,ephemeris(activeChannel(2,i)).eph.Alpha1, ...
                   ephemeris(activeChannel(2,i)).eph.Alpha2,ephemeris(activeChannel(2,i)).eph.Alpha3];
            Beta_i =[ephemeris(activeChannel(2,i)).eph.Beta0,ephemeris(activeChannel(2,i)).eph.Beta1, ...
                    ephemeris(activeChannel(2,i)).eph.Beta2,ephemeris(activeChannel(2,i)).eph.Beta3];
                
        end
        
        if iter == 1
            Rot_X(:, activeChannel(2,i)) = sat_xyz(:, activeChannel(2,i));
            trop(1,i) = 2;
            
        else
            rho2 = (Rot_X(1, activeChannel(2,i)) - posvel(1))^2 + (Rot_X(2, activeChannel(2,i)) - posvel(2))^2 + ...
                    (Rot_X(3, activeChannel(2,i)) - posvel(3))^2;
            traveltime = sqrt(rho2) / 299792458;
            %--- Correct satellite position (do to earth rotation) --------
            Rot_X(:, activeChannel(2,i)) = e_r_corr(traveltime, sat_xyz(:, activeChannel(2,i)));
            %--- Find the elevation angle of the satellite ----------------
            [az(1,i), el(1,i), dist] = topocent(posvel(1:3, 1), Rot_X(:, activeChannel(2,i)) - posvel(1:3, 1));
            el(2,i) = activeChannel(2,i);
            az(2,i) = activeChannel(2,i);
            az(3,i) = activeChannel(1,i);  
            el(3,i) = activeChannel(1,i);
            
            %            ---find the longtitude and latitude of position CGCS2000---
            [ Lat, Lon, Hight ] = cart2geo( posvel(1), posvel(2), posvel(3), 5 );
            
            if iter>=4
                %--- Calculate tropospheric correction --------------------
                            trop1 = Tropospheric(T_amb,P_amb,P_vap,el(1,i));
                             trop2 =Ionospheric_GPS(Lat,Lon,el(1,i),az(1,i),Alpha_i,Beta_i,Beijing_Time(activeChannel(2,i)));

                             trop(1,i) = trop1 + trop2;
                             wucha(i,1)=trop1;
                             wucha(i,2)=trop2;

             end % if iter >=6 , ... ... correct atmesphere
        end
        
        %--- Apply the corrections ----------------------------------------
        delRho(i) = (obs(activeChannel(2,i)) - norm(Rot_X(:, activeChannel(2,i)) - posvel(1:3,1), 'fro') - pos(4) - trop(1,i));
        %--- Construct the A matrix ---------------------------------------
        
        
        lx = Rot_X(1,activeChannel(2,i)) - posvel(1,1);
        ly = Rot_X(2,activeChannel(2,i)) - posvel(2,1);
        lz = Rot_X(2,activeChannel(2,i)) -posvel(3,1);
        normH = (lx^2 + ly^2 + lz^2);
        H(i,:)              = [-lx/normH -ly/normH -lz/normH 0 0 0 1 0];
        H(i+nmbOfSatellites,:) = [0 0 0 -lx/normH -ly/normH -lz/normH 0 1];
        
        delRho_dot(i) = Rhodot(i) - H(i, 1:3)*(vX(:,activeChannel(2,i)) - posvel(4:6,1)) - 299792458*satClkCorr(2,activeChannel(2,i));
    end
    
    if iter >=4
        for j= nmbOfSatellites:-1:1
            if el(1,j) < elevationMask
                delRho(j)=[];
                H(j,:)=[];
                delRho_dot(j) = [];
                W(j,:) = [];
                W(:,j) = [];
            end
        end
    end
    if rank(H) ~= 4  
        posvel = zeros(1, 8);
        return
    end
    
    % kalman filter model
    Z = [delRho delRho_dot]';
    P = F*P0*F' + Q;
    K = P*H'*inv(H*P*H' + W);
    P0 = (eye(8,8) - K*H)*P;
    delX =  K*Z;
    posvel = posvel + delX;
end
Hd = [H(1:nmbOfSatellites,1:3) -1*ones(nmbOfSatellites,1)];
Q = inv(Hd'*Hd);

 dop(1)  = sqrt(trace(Q));                       % GDOP
 dop(2)  = sqrt(Q(1,1) + Q(2,2) + Q(3,3));       % PDOP
 dop(3)  = sqrt(Q(1,1) + Q(2,2));                % HDOP
 dop(4)  = sqrt(Q(3,3));                         % VDOP
 dop(5)  = sqrt(Q(4,4));                         % TDOP
 %     fprintf('dop -- %.6f \n',dop);

