%% Calculate doppler frequency
function f = calcfrerange(syst, satPositions, pos, prnList)
% satposition : 6 * satnum  (x,y,z,vx,vy,vz)' CGS2000坐标系
% pos: position of reciever CGS2000坐标系 1*3
% f: doppler frequency, 每1km的位置误差可以导致卫星多普勒最大1Hz的误差
% prnList: [trackResults(activeChnList).sv]

global GSAR_CONSTANTS;

switch syst
    case 'BDS_B1I'
        carrierFreq = GSAR_CONSTANTS.STR_B1I.B0;
    case 'GPS_L1CA'
        carrierFreq = GSAR_CONSTANTS.STR_L1CA.L0;
end

numOfSatellites = size(prnList, 2);
for satNr = 1 : numOfSatellites
    %prn = prnList(satNr);
    e(:,satNr) = (pos - satPositions(1:3,satNr)) / norm(pos - satPositions(1:3,satNr));
    v(satNr) = dot(e(:, satNr), satPositions(4:6, satNr)');
    f(satNr) = carrierFreq*v(satNr)/GSAR_CONSTANTS.C;
    % d = f*v/c;
end

end
