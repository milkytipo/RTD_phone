function [posvel, el, az, dop] = leastSq_rangeDiff(satpos, pr_diff, activeChannel, elevationMask, checkNGEO)%freqforcal, settings)

%   Inputs:
%       satpos      - Satellites positions (in ECEF system: [X; Y; Z;] -
%                   one column per satellite)
%       obs         - Observations - the pseudorange measurements to each
%                   satellite:
%                   (e.g. [20000000 21000000 .... .... .... .... ....])
%       settings    - receiver settings
%        time        -transmit time
%       channelList   -activechannel
%   Outputs:
%       pos         - receiver position and receiver clock error
%                   (in ECEF system: [X, Y, Z, dt])
%       el          - Satellites elevation angles (degrees)
%       az          - Satellites azimuth angles (degrees)
%       dop         - Dilutions Of Precision ([GDOP PDOP HDOP VDOP TDOP])

%--------------------------------------------------------------------------
%                           SoftGNSS v3.0
%--------------------------------------------------------------------------
%Based on Kai Borre
%Copyright (c) by Kai Borre
%Updated by Darius Plausinaitis, Peter Rinder and Nicolaj Bertelsen
%
% CVS record:
% $Id: leastSquarePos.m,v 1.1.2.12 2006/08/22 13:45:59 dpl Exp $
%==========================================================================

%=== Initialization =======================================================
% nmbOfIterations = 9;
refxyz = [-2853445.340;4667464.957;3268291.032];%参考系坐标
% dtr     = pi/180;
pos     = zeros(4, 1);
% pos = [-2605249.211205  4743124.060174  3364584.183359 -2.098158367372609e+06]'; %for test
vel = zeros(4,1); %calculate velocity and ddt
sat_xyz = satpos(1:3,:);
vX = satpos(4:6,:);
nmbOfSatellites = size(activeChannel, 2);
Rot_X   = zeros(3,32);%%经过地球自转修正后的卫星位置
A       = zeros(nmbOfSatellites, 4);
omc     = zeros(nmbOfSatellites, 1);
az      = zeros(2, nmbOfSatellites);
el      = az;
dop     = zeros(1, 5);
az(2,:)=activeChannel(2,:);    %令计算后的数值与卫星的prn号相对应
el(2,:)=activeChannel(2,:);
posvel = zeros(1, 8);

if length(activeChannel(1,:))>=4 && checkNGEO==1
%=== Iteratively find receiver position ===================================
% for iter = 1:nmbOfIterations

    for i = 1:nmbOfSatellites          
            %--- Update equations -----------------------------------------
            rho2 = (sat_xyz(1, activeChannel(2,i)) - refxyz(1))^2 + (sat_xyz(2, activeChannel(2,i)) - refxyz(2))^2 + ...
                (sat_xyz(3, activeChannel(2,i)) - refxyz(3))^2;%卫星i的伪距平方
            traveltime = sqrt(rho2) / 299792458 ;
            %--- Correct satellite position (do to earth rotation) --------
            Rot_X(:, activeChannel(2,i)) = e_r_corr(traveltime, sat_xyz(:, activeChannel(2,i)));%卫星i经过地球自转修正后的位置

            %--- Find the elevation angle of the satellite ----------------
            [az(1,i), el(1,i), dist] = topocent(refxyz, Rot_X(:, activeChannel(2,i)) - refxyz);   
            el(2,i) = activeChannel(2,i);
            az(2,i) = activeChannel(2,i);            
        %--- Apply the corrections ----------------------------------------
        omc(i) = pr_diff(activeChannel(2,i));                
        %--- Construct the A matrix ---------------------------------------
        A(i, :) =  [ (-(Rot_X(1, activeChannel(2,i)) - refxyz(1))) / norm(Rot_X(:, activeChannel(2,i)) - refxyz, 'fro') ...
            (-(Rot_X(2, activeChannel(2,i)) - refxyz(2))) / norm(Rot_X(:, activeChannel(2,i)) - refxyz, 'fro') ...
            (-(Rot_X(3, activeChannel(2,i)) - refxyz(3))) / norm(Rot_X(:, activeChannel(2,i)) - refxyz, 'fro') ...
            1 ];
     end % for i = 1:nmbOfSatellites
%     if iter >= 4
    for j = nmbOfSatellites:-1:1  %去除仰角低于elevationMask的卫星
         if el(1,j) < elevationMask            %
%              el(:,j)=[];
%              az(:,j)=[];
             omc(j)=[];
             A(j,:)=[];
         end
    end
%     end
    % These lines allow the code to exit gracefully in case of any errors
    if rank(A) ~= 4
        posvel = zeros(1, 8);
        return
    end

    %--- Find position update ---------------------------------------------
    x   = A \ omc;
   
    %--- Apply position update --------------------------------------------
    pos(1:3) = refxyz + x(1:3);
    
% end % for iter = 1:nmbOfIterations
% fprintf('Satellite pos(自转矫正) -- %.6f \n', Rot_X);
% fprintf('accP -- %.6f \n',accP);
% fprintf('wucha -- %.6f \n',wucha);
% fprintf('az -- %.6f \n',az);
% fprintf('el -- %.6f \n',el);

%calculate velocity from carrier frequency
% for i = 1:nmbOfSatellites
%     r=sqrt(sum((pos(1:3)-X(:,i)').^2));
%     satvol=vX(:,i)';
%     a(i,:)=(X(:,i)'-pos(1:3))/r;
%     %if Doppler is reversed
%     d(i,1)=settings.c*(-freqforcal(i)+settings.IF)/1575.42e6+sum(satvol.*a(i,:));
%     %if Doppler is normal
% %     d(i,1)=settings.c*(freqforcal(i)-settings.IF)/1575.42e6+sum(satvol.*a(i,:));
%     HH(i,:)=[a(i,:),1];
% end
% vel=HH\d;

pos(4) = x(4)/299792458;
posvel=[pos',vel'];
%=== Calculate Dilution Of Precision ======================================
% if nargout  == 4
    %--- Initialize output ------------------------------------------------
    

    %--- Calculate DOP ----------------------------------------------------
    Q       = inv(A'*A);

    dop(1)  = sqrt(trace(Q));                       % GDOP
    dop(2)  = sqrt(Q(1,1) + Q(2,2) + Q(3,3));       % PDOP
    dop(3)  = sqrt(Q(1,1) + Q(2,2));                % HDOP
    dop(4)  = sqrt(Q(3,3));                         % VDOP
    dop(5)  = sqrt(Q(4,4));                         % TDOP
%     fprintf('dop -- %.6f \n',dop);
end
end