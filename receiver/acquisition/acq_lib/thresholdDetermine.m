function threshold = thresholdDetermine(tcoh, nncoh)
% threhold is determined by experience

threshold = (10 + (tcoh * 1e3)/10) - nncoh * 1e-3 *0.2;
if threshold <= 10
    threshold = 10;
end