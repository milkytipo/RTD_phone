function loadyuma(filename)
%LOADYUMA	Satellite almanac data in Yuma format.
%		Load the almanac parameters from a user-specified
%     ASCII text file in Yuma format.  The data are
%     maintained as global variables.
%
%	loadyuma(filename)
%
%   INPUTS
%  filename = Name of the ASCII text file containing the
%             YUMA-formatted almanac data (NOTE: make sure
%             to put the name in single quotation marks
%             (e.g.,  loadyuma('yuma1.txt')
%
%   GLOBAL VARIABLES
%	SVIDV =	vector of satellite identification numbers
%	MV = 	vector of Mean anomalies for the satellites in SVID
%		(at reference time) in degrees
%	RV =	vector orbit radii for the satellites in SVID 
%		(semi-major axis) in meters
%	TOEV =	vector of reference times for the Kepler parameters 
%		for the satellites in SVID (time of applicability) in seconds
%	OMGV = 	vector of longitudes of the ascending nodes for the 
%		satellites in SVID (at weekly epoch) in degrees
%	INCLV = vector of inclination angles of orbital planes of
%		the satellites in SVID (in degrees)
%  HEALTHV = vector of health words for the satellites
%            in SVID (000 = satellite is good)
%  ECCENV = vector of eccentricities for the satellites
%           in SVID (dimensionless)
%  OMGDOTV = vector of Rates of Right Ascension for the
%            satellites in SVID (radians/sec)
%  ARGPERIV = vector of Arguments of Perigee for the
%             satellites in SVID (radians)
%  AF0V = vector of satellite clock offsets for the
%         satellites in SVID (seconds)
%  AF1V = vector of satellite clock drift coefficients
%         for the satellites in SVID (sec/sec)
%  WEEKV = vector of week numbers for the almanac data
%          for the satellites in SVID

%	Copyright (c) 1999 by GPSoft LLC
%

global SVIDV MV OMGV RV INCLV TOEV HEALTHV ECCENV
global OMGDOTV ARGPERIV AF0V AF1V WEEKV

fid = fopen(filename,'rt');
     if fid==-1
       error('Yuma almanac file not found or permission denied');
    end
%
% Loop through the file
k = 0;
while 1
   %
   line = fgetl(fid);
   if ~ischar(line), break, end
   % Search for valid Yuma header and skip over blank lines
   if ( length(line) > 12 ) & (mean( line(1:13) == '******** Week') | ...
         mean(line(1:9) == '**** Week' )),
      %
      id = fgetl(fid);
      id = sscanf(id,'%s',inf);
      idN = max(size(id));
      idM = 1;
      while id(idM) ~= ':',
         idM = idM + 1;
      end
      idM = idM + 1;
      
      health = fgetl(fid);
      health = sscanf(health,'%s',inf);
      healthN = max(size(health));
      healthM = 1;
      while health(healthM) ~= ':',
         healthM = healthM + 1;
      end
      healthM = healthM + 1;
      
      eccen = fgetl(fid); 
      eccen = sscanf(eccen,'%s',inf);
      eccenN = max(size(eccen));
      eccenM = 1;
      while eccen(eccenM) ~= ':',
         eccenM = eccenM + 1;
      end
      eccenM = eccenM + 1;
      
      toa = fgetl(fid); 
      toa = sscanf(toa,'%s',inf);
      toaN = max(size(toa));
      toaM = 1;
      while toa(toaM) ~= ':',
         toaM = toaM + 1;
      end
      toaM = toaM + 1;
      
      incl = fgetl(fid); 
      incl = sscanf(incl,'%s',inf);
      inclN = max(size(incl));
      inclM = 1;
      while incl(inclM) ~= ':',
         inclM = inclM + 1;
      end
      inclM = inclM + 1;
      
      omegadot = fgetl(fid); 
      omegadot = sscanf(omegadot,'%s',inf);
      omegadN = max(size(omegadot)); 
      omegadM = 1;
      while omegadot(omegadM) ~= ':',
         omegadM = omegadM + 1;
      end
      omegadM = omegadM + 1;
      
      sqrsma = fgetl(fid); 
      sqrsma = sscanf(sqrsma,'%s',inf);
      sqrsmaN = max(size(sqrsma));
      sqrsmaM = 1;
      while sqrsma(sqrsmaM) ~= ':',
         sqrsmaM = sqrsmaM + 1;
      end
      sqrsmaM = sqrsmaM + 1;
      
      omega0 = fgetl(fid); 
      omega0 = sscanf(omega0,'%s',inf);
      omega0N = max(size(omega0));
      omega0M = 1;
      while omega0(omega0M) ~= ':',
         omega0M = omega0M + 1;
      end
      omega0M = omega0M + 1;
      
      argperig = fgetl(fid); 
      argperig = sscanf(argperig,'%s',inf);
      argperiN = max(size(argperig));
      argperiM = 1;
      while argperig(argperiM) ~= ':',
         argperiM = argperiM + 1;
      end
      argperiM = argperiM + 1;
      
      M0 = fgetl(fid); 
      M0 = sscanf(M0,'%s',inf);
      M0N = max(size(M0));
      M0M = 1;
      while M0(M0M) ~= ':',
         M0M = M0M + 1;
      end
      M0M = M0M + 1;
      
      af0 = fgetl(fid); 
      af0 = sscanf(af0,'%s',inf);
      af0N = max(size(af0));
      af0M = 1;
      while af0(af0M) ~= ':',
         af0M = af0M + 1;
      end
      af0M = af0M + 1;
      
      af1 = fgetl(fid); 
      af1 = sscanf(af1,'%s',inf);
      af1N = max(size(af1));
      af1M = 1;
      while af1(af1M) ~= ':',
         af1M = af1M + 1;
      end
      af1M = af1M + 1;
      
      week = fgetl(fid); 
      week = sscanf(week,'%s',inf);
      weekN = max(size(week));
      weekM = 1;
      while week(weekM) ~= ':',
         weekM = weekM + 1;
      end
      weekM = weekM + 1;
      
      k = k + 1;
      
      SVIDV(k) = str2double(id(idM:idN));
      HEALTHV(k) = str2double(health(healthM:healthN));
      ECCENV(k) = str2double(eccen(eccenM:eccenN));
      TOEV(k) = str2double(toa(toaM:toaN));
      INCLV(k) = (180/pi)*str2double(incl(inclM:inclN));
      OMGDOTV(k) = str2double(omegadot(omegadM:omegadN));
      sqrsma = str2double(sqrsma(sqrsmaM:sqrsmaN));
      RV(k) = sqrsma*sqrsma;
      OMGV(k) = (180/pi)*str2double(omega0(omega0M:omega0N));
      ARGPERIV(k) = str2double(argperig(argperiM:argperiN));
      MV(k) = (180/pi)*str2double(M0(M0M:M0N));
      AF0V(k) = str2double(af0(af0M:af0N));
      AF1V(k) = str2double(af1(af1M:af1N));
      WEEKV(k) = str2double(week(weekM:weekN));
   end %End of IF loop for valid header
%
end %End WHILE loop for checking end-of-file  
st = fclose(fid);
