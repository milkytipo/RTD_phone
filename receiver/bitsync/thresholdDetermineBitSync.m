function threshold = thresholdDetermineBitSync(tcoh, nncoh, syst)
% threhold is determined by experience
switch syst
    case 'GPS'
        threshold = 1.1;
    case 'BDS'
        threshold = 1.2;
end
