function [calibration] = readCalib(calibration, fileCalib, YYMMDD, fileType)

switch fileType
    case 1
        [XYZ, LLH, TOWSEC, HHMMSS]=readCarliFile(fileCalib);
        calibration.pos_xyz = XYZ';
        calibration.pos_llh = LLH';
        calibration.SOW(1,:) = TOWSEC;
        calibration.SOW(2:4,:) = HHMMSS;
        
    case 2
        [XYZ, LLH, TOWSEC, HHMMSS] = readIE(fileCalib, YYMMDD);
        calibration.pos_xyz = XYZ';
        calibration.pos_llh = LLH';
        calibration.SOW(1,:) = TOWSEC;
        calibration.SOW(2:4,:) = HHMMSS;
    case 3
        calibration.pos_xyz = [-2853440.935, 4667457.025, 3268287.402]';
        calibration.pos_llh = xyz2llh(calibration.pos_xyz)';
        calibration.SOW(1,:) = 0;
        calibration.SOW(2:4,:) = 0;
end