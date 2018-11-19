% This function will initialize the stations of SV.

function [STR_SV] = SV_Initializing(SYST, CallingFlat)

global STR_Constants;

UTC = struct(...
    'WN',              673,           ...    % counting since 1999.xx.xx
    'TOW',             STR_Constants.DAYLONGSEC+(11*60+51)*60+13, ...       % Monday, 11:51:13 AM
    'BITN',            31,            ...    % navigation bits in a second, 50bps
    'Codphs',          0.05       ...here the code phase is measured according to the multiplexed codes.
);


%---------------------------------------------------------
% Initializing L2C SV
STR_L2C_SV = struct(...
    'PRNID',           1,                 ...
...    'L2CM_Code',       [],                 ...
...    'L2CL_Code',       [],                 ...
...    'L2C_Multiplex',   [],                 ...
    'WN',              UTC.WN,             ...   
    'TOW',             UTC.TOW,            ... counting seconds
    'BITN',            UTC.BITN,           ... counting the navigation bits in a second
    'Codphs',          UTC.Codphs,         ...
    'Carphs',          0,                  ... rand,               ...
    'CL_Segment_indx', [],                 ...
    'SFNav',           [],                 ...
    'SFNav_Posi',      [],                 ...
    'typeID',          10,                 ...
    'Register_FEC',    [],                 ...the initial state of convolutional encoder,[0 0 0 0 0 0]'
    'fd',              1000,...5800,              ...Doppler frequency,[Hz]
    'framp',           0,                 ...accelation of fd,[Hz/s]
    'fjerk',           0,               ...accelation of framp,[Hz/s^2]
    'CN0',             50,                 ...dB
    'ampc',            0                   ...the signal amplitude computed according to input parameters
);%16 components
temp1 = round(UTC.TOW/STR_Constants.STR_L2C.TBIT) + UTC.BITN;
STR_L2C_SV.CL_Segment_indx = mod(temp1, STR_Constants.STR_L2C.CLCM_R);

STR_L2C_SV.SFNav_Posi = mod(temp1, STR_Constants.STR_L2C.NBIT_in_Message);

%---------------------------------------------------------
% Initializing BDS B1I SV
STR_B1I_SV = struct(...
    'PRNID',           6,                  ...
    'WN',              UTC.WN,             ...Week number counter
    'SOW',             [],                 ...Second number counter of current subframe beginning in a week,
    'navType',         'B1I_D1',           ...B1I_D1 / B1I_D2
    ...Define information frame format
    'Frame_N',         [],                 ...Frame counter, 0~23 for D1, 0~119 for D2
    'SubFrame_N',      [],                 ...Frame counter, 0~4
    'Word_N',          [],                 ...word counter,0~9
    'Bit_N',           [],                 ...navigation bit counter in a word,0~29       
    'T1ms_N',          [],                 ...PRN period counter in a bit, 0~19 for D1, 0~1 for D2
    ...BD code and carrier phase 
    'Codphs',          mod(UTC.Codphs, STR_Constants.STR_B1I.ChipNum),         ...
    'Carphs',          0,                  ...
    'SFNav',           [],                 ...pointer to a subframe's navigation bits
    'fd',              1185,              ...Doppler frequency,[Hz]
    'framp',           30,                 ...accelation of fd,[Hz/s]
    'fjerk',           1.33,               ...accelation of framp,[Hz/s^2]
    'CN0',             40,                 ...dB
    'ampc',            0                   ...the signal amplitude computed according to input parameters
);

if STR_B1I_SV.PRNID > 5
    STR_B1I_SV.navType = 'B1I_D1';
    %D1 time parameters initializing
    STR_B1I_SV.SOW = UTC.TOW - mod(UTC.TOW, STR_Constants.STR_B1I.T_D1SUBFRAME);%本子帧同步头第1上升沿的时刻
    STR_B1I_SV.Frame_N = floor(mod(UTC.TOW, STR_Constants.STR_B1I.T_D1SUPER)/STR_Constants.STR_B1I.T_D1FRAME);
    STR_B1I_SV.SubFrame_N = floor(mod(UTC.TOW, STR_Constants.STR_B1I.T_D1FRAME)/STR_Constants.STR_B1I.T_D1SUBFRAME);
    STR_B1I_SV.Word_N = floor(mod(UTC.TOW, STR_Constants.STR_B1I.T_D1SUBFRAME)/STR_Constants.STR_B1I.T_D1WORD);
    STR_B1I_SV.Bit_N = floor(mod(UTC.TOW, STR_Constants.STR_B1I.T_D1WORD)/STR_Constants.STR_B1I.T_D1);
    STR_B1I_SV.T1ms_N = 17;
else
    STR_B1I_SV.navType = 'B1I_D2';
    %D2 time parameters initializing
    STR_B1I_SV.SOW = UTC.TOW - mod(UTC.TOW, STR_Constants.STR_B1I.T_D2FRAME);%当前主帧的子帧1同步头第1上升沿的时刻
    STR_B1I_SV.Frame_N = floor(mod(UTC.TOW, STR_Constants.STR_B1I.T_D2SUPER)/STR_Constants.STR_B1I.T_D2FRAME);
    STR_B1I_SV.SubFrame_N = floor(mod(UTC.TOW, STR_Constants.STR_B1I.T_D2FRAME)/STR_Constants.STR_B1I.T_D2SUBFRAME);
    STR_B1I_SV.Word_N = floor(mod(UTC.TOW, STR_Constants.STR_B1I.T_D2SUBFRAME)/STR_Constants.STR_B1I.T_D2WORD);
    STR_B1I_SV.Bit_N = floor(mod(UTC.TOW, STR_Constants.STR_B1I.T_D2WORD)/STR_Constants.STR_B1I.T_D2);
    ...STR_B1I_SV.T1ms_N = mod(STR_B1I_SV.T1ms_N_inD1, STR_Constants.STR_B1I.NT1ms_in_D2); ...??
    STR_B1I_SV.T1ms_N = 1;
end

% C_MEX
if strcmp(CallingFlat, 'CallinMex') && strcmp(SYST, 'GPS_L2C')
    STR_L2C_SV.Register_FEC = uint32(25);  
    
    STR_syst_arg = struct(...
        'SYST',           SYST,                   ...GPS_CA/GPS_L2C
        'PRNID',          STR_L2C_SV.PRNID,       ...
        'WN',             STR_L2C_SV.WN,          ...
        'TOW',            STR_L2C_SV.TOW,         ...
        'typeID',         STR_L2C_SV.typeID,      ...
        'Register_FEC',   STR_L2C_SV.Register_FEC ...
    );

    STR_Nav = struct(...
        'SFNav',          [],                     ...
        'Register_FEC',   []                      ...
    );

    [STR_Nav] = mx_Navigation_Bits_Gen(STR_syst_arg);
    
    STR_L2C_SV.SFNav = STR_Nav.SFNav;
    STR_L2C_SV.Register_FEC = STR_Nav.Register_FEC;
end

if strcmp(CallingFlat, 'CallinMex') && strcmp(SYST, 'BD_B1I')
    STR_syst_arg = struct(...
        'SYST',           SYST,                   ...BD_B1I
        'navType',        STR_B1I_SV.navType,     ...
        'SubFrame_N',     STR_B1I_SV.SubFrame_N,     ...
        'SOW',            STR_B1I_SV.SOW,         ...
        'WN',             STR_B1I_SV.WN           ...
    );
    
    STR_B1I_SV.SFNav = mx_Navigation_Bits_Gen(STR_syst_arg);

end

% Define the multipath structure
STR_MP = struct(...
    'P',                  1,              ... number of multipath signals
    'dtau',               [240,200],... delays of multipath in ns (should be less than 1000)
    'a_mp',               [0.5,0.5],... relative amplitude to LOS
    'phs_mp',             [0,-110]/180 ...relative phase bias to LOS(in rad)
);


STR_SV = struct(...
    'L2C_SV',             STR_L2C_SV,     ...
    'B1I_SV',             STR_B1I_SV,     ...
    'STR_MP',             STR_MP,         ... 
    'navbit_ctrl',        1,              ... a controller controlling the navigation bit modulation, 1->on, 0->off
    'noise_ctrl',         1,              ... a controller controlling the noise generation, 1->on, 0->off
    'multipath_ctrl',     1,              ... a controller controlling the multipath generation, 1->on, 0->off
    'accel_ctrl',         0,              ... a controller controlling the acceleration phenomenon, 1->on, 0->off
    'ADC_ctrl',           0              ... a controller controlling the ADC,  1->on, 0->off
);








