%% Read almanac YUMA file to get almanac parameters.
function almanac = ReadYUMA(filePath, SYST)

    almanac = AlmanacInitializing(SYST);

    fid = fopen(filePath);
    if fid == -1
        error('Almanac file isn''t existed!');
    end
    
    % A simple check
    almHead = '******** Week'; % Head of almanac data in YUMA format
    line = fgetl(fid);
    if ~strcmp(almHead, line(1:13))
        error('Almanac data is wrong!');
    end
    
    switch SYST
        case 'GPS_L1CA'
            lineNo = 465;
        case 'BD_B1I'
            lineNo = 450; % Not sure
    end
    
    for lineCnt = 2:lineNo
        
        line = fgetl(fid);
        
        if rem(lineCnt, 15) == 2
            switch strcmp(line(1:2), 'ID')
                case 1
                    prnID = str2double(line(29:end));
                case 0
                    error('Almanac file''s format is wrong!');
            end
        end
        
        if rem(lineCnt, 15) == 3
            switch strcmp(line(1:6), 'Health')
                case 1
                    almanac.hea(prnID) = str2double(line(29:end));
                    almanac.dect(prnID) = 1;
                case 0
                    error('Almanac file''s format is wrong!');
            end
        end
        
        % No check, read parameters of struct alm        
        switch rem(lineCnt, 15)
            case 4
                almanac.alm(prnID).e = str2double(line(28:end));
            case 5
                almanac.alm(prnID).toa = str2double(line(28:end));
            case 6
                almanac.alm(prnID).deltai = str2double(line(28:end));
            case 7
                almanac.alm(prnID).omegaDot = str2double(line(28:end));
            case 8
                almanac.alm(prnID).sqrtA = str2double(line(28:end));
            case 9
                almanac.alm(prnID).omega0 = str2double(line(28:end));
            case 10
                almanac.alm(prnID).w = str2double(line(28:end));
            case 11
                almanac.alm(prnID).M0 = str2double(line(28:end));
            case 12
                almanac.alm(prnID).a0 = str2double(line(28:end));
            case 13
                almanac.alm(prnID).a1 = str2double(line(28:end));
        end
        
        if rem(lineCnt, 15) == 14
            switch strcmp(line(1:4), 'week')
                case 1
                    almanac.WNa = str2double(line(28:end));
                case 0
                    error('Almanac file''s format is wrong!');
            end
        end
        
    end
    
    almanac.almReady = 1; % All almanac data have been received
    
    fclose(fid);
    
end