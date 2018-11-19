function loadrinexn(filename)
%LOADRINEXN 	Satellite ephemeris (Navigation message) data
%               in RINEX2 format. Load the data from a user-specified
%               ASCII text file in RINEX2 format.  The data are
%               maintained as global variables.
%
%	loadrinexn(filename)
%
%   INPUTS
%  filename = Name of the ASCII text file containing the
%             RINEX2-formatted Navigation message data 
%             (NOTE: make sure to put the name in single 
%             quotation marks (e.g.,  loadrinexn('stkr2581.02n')

%
%   Copyright (c) 2002-2003    Michael S. Braasch / GPSoft LLC
%
global ALPHA BETA UTC_A0 UTC_A1 UTC_TOT UTC_WN LEAP_SEC
global SV_ID_VEC TOC_YEAR TOC_MONTH TOC_DAY TOC_HOUR
global TOC_MINUTE TOC_SEC AF0 AF1 AF2
global IODE CRS DELTAN MZERO CUC ECCEN CUS SQRTSMA
global TOE CIC OMEGAZERO CIS IZERO CRC ARGPERI OMEGADOT
global IDOT CODES_ON_L2 TOE_WN L2_P_FLAG
global URA SV_HEALTH TGD IODC TRANS_TIME_OF_MESSAGE
global FIT_INTERVAL SPARE1 SPARE2
%
fid = fopen(filename);
if fid==-1
   error('RINEX Navigation message data file not found or permission denied');
end
%
%  Pre-load iono model and UTC parameters in case files omit them
ALPHA(1:4) = NaN;  BETA(1:4) = NaN;
UTC_A0 = NaN; UTC_A1 = NaN; UTC_TOT = NaN; UTC_WN = NaN;
LEAP_SEC = NaN; TOE(1:32) = -9e99;
%
disp('Loading RINEX2 Navigation Data File - Please Be Patient')
%  Parse header
while 1   % this is the numeral '1'
    line = fgetl(fid);
    if line(61:73) == 'END OF HEADER',
        break
    end
    if line(61:69) == 'ION ALPHA',
        ALPHA(1) = str2num(line(3:14));
        ALPHA(2) = str2num(line(15:26));
        ALPHA(3) = str2num(line(27:38));
        ALPHA(4) = str2num(line(39:50));
    end
    if line(61:68) == 'ION BETA',
        BETA(1) = str2num(line(3:14));
        BETA(2) = str2num(line(15:26));
        BETA(3) = str2num(line(27:38));
        BETA(4) = str2num(line(39:50));
    end
    if line(61:69) == 'DELTA-UTC',
        UTC_A0 = str2num(line(4:23));
        UTC_A1 = str2num(line(24:42));
        UTC_TOT = str2num(line(43:51));
        UTC_WN = str2num(line(52:60));
    end
    if line(61:72) == 'LEAP SECONDS',
        LEAP_SEC = str2num(line(1:6));
    end
end
%
%  Initialize vector of Satellite ID's
SV_ID_VEC(1:32) = 0;
%  Loop through the file
while 1     % this is the numeral '1'
   %
   line = fgetl(fid);
   if ~ischar(line), break, end
   %
   svnum = str2num(line(1:2));
   SV_ID_VEC(svnum) = 1;
   TOC_YEAR(svnum) = str2num(line(4:5));
   TOC_MONTH(svnum) = str2num(line(7:8));
   TOC_DAY(svnum) = str2num(line(10:11));
   TOC_HOUR(svnum) = str2num(line(13:14));
   TOC_MINUTE(svnum) = str2num(line(16:17));
   TOC_SEC(svnum) = str2num(line(18:22));
   AF0(svnum) = str2num(line(23:41));
   AF1(svnum) = str2num(line(42:60));
   AF2(svnum) = str2num(line(61:79));
   
   line = fgetl(fid);
   IODE(svnum) = str2num(line(4:22));
   CRS(svnum) = str2num(line(23:41));
   DELTAN(svnum) = str2num(line(42:60));
   MZERO(svnum) = str2num(line(61:79));
   
   line = fgetl(fid);
   CUC(svnum) = str2num(line(4:22));
   ECCEN(svnum) = str2num(line(23:41));
   CUS(svnum) = str2num(line(42:60));
   SQRTSMA(svnum) = str2num(line(61:79));
   
   line = fgetl(fid);
   TOE(svnum) = str2num(line(4:22));
   CIC(svnum) = str2num(line(23:41));
   OMEGAZERO(svnum) = str2num(line(42:60));
   CIS(svnum) = str2num(line(61:79));
   
   line = fgetl(fid);
   IZERO(svnum) = str2num(line(4:22));
   CRC(svnum) = str2num(line(23:41));
   ARGPERI(svnum) = str2num(line(42:60));
   OMEGADOT(svnum) = str2num(line(61:79));
   
   line = fgetl(fid);
   IDOT(svnum) = str2num(line(4:22));
   CODES_ON_L2(svnum) = str2num(line(23:41));
   TOE_WN(svnum) = str2num(line(42:60));
   L2_P_FLAG(svnum) = str2num(line(61:79));
   
   line = fgetl(fid);
   URA(svnum) = str2num(line(4:22));
   SV_HEALTH(svnum) = str2num(line(23:41));
   TGD(svnum) = str2num(line(42:60));
   IODC(svnum) = str2num(line(61:79));
   
   line = fgetl(fid);
   TRANS_TIME_OF_MESSAGE(svnum) = str2num(line(4:22));
   FIT_INTERVAL(svnum) = str2num(line(23:41));
   SPARE1(svnum) = str2num(line(42:60));
   SPARE2(svnum) = str2num(line(61:79));   
end
%
