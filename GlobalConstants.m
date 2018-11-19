%% Constants Definition
function [GSAR_CONSTANTS] = GlobalConstants()

STR_L1CA = struct(...
    'L0',                     1575.42e6,    ...the nominal L transmitting frequency [Hz]
    'Fcode0',                 1.023e6,      ...the nominal code chipping rate in the transmitting station,[Hz]
    'L0Fc0_R',                1540,         ...L0/Fcode0
    'ChipNum',                1023,         ...
    'TBIT',                   0.02,         ...
    'NT1ms_in_bit',           20,           ...
    'CAlength',               0.001,        ...
    'NBIT_in_SEC',            50,           ...
    'NBIT_in_WORD',           30,           ...
    'NWORD_in_SF',            10,           ...
    'NSF_in_FRAME',           5             ...
);

STR_L2C = struct(...
    'L0',                     1227.6e6,     ...the nominal L transmitting frequency [Hz]
    'Fcode0',                 511.5e3,      ...the nominal code chipping rate in the transmitting station,[Hz]
    'Fcode0_Multiplex',       1.023e6,      ...the Multiplex code chipping rate in the transmitting station,[Hz]
    'L0Fc0_R',                1200,         ...L0/Fcode0
    'ChipNum_CM',             10230,        ...the length of CM code chips
    'ChipNum_CL',             767250,       ...the length of CL code chips
    'TCM',                    0.02,         ...the time length of CM code,[s]
    'TCL',                    1.5,          ...the time length of CL code,[s]
    'CLCM_R',                 75,           ...CL/CM
    'TBIT',                   0.02,         ...navigate bits,[s]
    'NBIT_in_SEC',            50,           ...navigate bits,[bps]
    'NBIT_in_Message',        600,          ...the naviate message length after FEC
    'L2L1_FreqRatio',         60/77         ...carrier frequency ratio of L1 and L2
);

STR_B1I = struct(...
    'B0',                     1561.098e6,   ...
    'Fcode0',                 2.046e6,      ...
    'L0Fc0_R',                763,          ...
    'ChipNum',                2046,         ...
    ...Define D1 timing parameters
    'T_NH',                   0.001,        ...time length of 1 bit of Neumann-Hoffman code on D1
    'NT1ms_in_D1',            20,           ...PRN period number in a D1 bit
    'T_D1',                   0.02,         ...time length of D1 navigation bit
    'ND1_in_D1WORD',          30,           ...D1 bit number in a word
    'T_D1WORD',               0.6,          ...D1 word time length,[s]
    'ND1WORD_in_D1SUBFRAME',  10,           ...D1 word number in a subframe
    'T_D1SUBFRAME',           6,            ...D1 subframe length,[s]
    'ND1SUB_in_D1FRAME',      5,            ...D1 subframe number in a frame
    'T_D1FRAME',              30,           ...D1 frame time length,[s]
    'ND1FRAME_in_D1SUPER',    24,           ...D1 frame number in a superframe
    'T_D1SUPER',              12*60,        ...D1 superframe time length,[s]
    'NHCode',                 bin2dec('01110010101100100000'),...Neumann-Hoffman code, first bit saved 
    ...Define D2 timing parameters
    'NT1ms_in_D2',            2,            ...PRN period number in a D2 bit
    'T_D2',                   0.002,        ...time length of D2 navigation bit
    'ND2_in_D2WORD',          30,           ...D2 bit number in a word
    'T_D2WORD',               0.06,         ...D2 word time length,[s]
    'ND2WORD_in_D2SUBFRAME',  10,           ...D2 word number in a subframe
    'T_D2SUBFRAME',           0.6,          ...D2 subframe length,[s]
    'ND2SUB_in_D2FRAME',      5,            ...D2 subframe number in a frame
    'T_D2FRAME',              3,            ...D2 frame time length,[s]
    'ND2FRAME_in_D2SUPER',    120,          ...D2 frame number in a superframe
    'T_D2SUPER',              6*60          ...D2 superframe time length,[s]
);

STR_B2I = struct(...
    'B0',                     1207.140e6,   ...
    'Fcode0',                 2.046e6,      ...
    'L0Fc0_R',                590,          ...
    'ChipNum',                2046,         ...
    ...Define D1 timing parameters
    'T_NH',                   0.001,        ...time length of 1 bit of Neumann-Hoffman code on D1
    'NT1ms_in_D1',            20,           ...PRN period number in a D1 bit
    'T_D1',                   0.02,         ...time length of D1 navigation bit
    'ND1_in_D1WORD',          30,           ...D1 bit number in a word
    'T_D1WORD',               0.6,          ...D1 word time length,[s]
    'ND1WORD_in_D1SUBFRAME',  10,           ...D1 word number in a subframe
    'T_D1SUBFRAME',           6,            ...D1 subframe length,[s]
    'ND1SUB_in_D1FRAME',      5,            ...D1 subframe number in a frame
    'T_D1FRAME',              30,           ...D1 frame time length,[s]
    'ND1FRAME_in_D1SUPER',    24,           ...D1 frame number in a superframe
    'T_D1SUPER',              12*60,        ...D1 superframe time length,[s]
    'NHCode',                 bin2dec('01110010101100100000'),...Neumann-Hoffman code, first bit saved 
    ...Define D2 timing parameters
    'NT1ms_in_D2',            2,            ...PRN period number in a D2 bit
    'T_D2',                   0.002,        ...time length of D2 navigation bit
    'ND2_in_D2WORD',          30,           ...D2 bit number in a word
    'T_D2WORD',               0.06,         ...D2 word time length,[s]
    'ND2WORD_in_D2SUBFRAME',  10,           ...D2 word number in a subframe
    'T_D2SUBFRAME',           0.6,          ...D2 subframe length,[s]
    'ND2SUB_in_D2FRAME',      5,            ...D2 subframe number in a frame
    'T_D2FRAME',              3,            ...D2 frame time length,[s]
    'ND2FRAME_in_D2SUPER',    120,          ...D2 frame number in a superframe
    'T_D2SUPER',              6*60          ...D2 superframe time length,[s]
);

STR_RECV = struct(...
    'RECV_OSCREF0',           10.23e6,      ... receiver's nominal onboard oscillator frequency,[Hz]
    'RECV_OSCREF_offset',     0,            ... the frequency offset of the reference frequency of the 
    'IF_B1I',                 0,        ... nominal BDS IF frequency in the RF circuits,[Hz] YuZhiDvc:-6.902e6/ KeDaDvc: 23.098e6
    'IF_B2I',                 0,        ...
    'IF_B3I',                 0,        ...
    'IF_L1CA',                0,        ... nominal GPS IF frequency in the RF circuits,[Hz] YuZhiDvc:7.42e6/ KeDaDvc: 37.42e6
    'IF_L2C',                 0,        ... 
    'IF_L5',                 0,        ...
    'IF_G1',                  0,        ...
    'IF_G2',                  0,        ...
    'IF_E1',                  0,        ...
    'IF_E5a',                 0,        ...
    'IF_E5b',                 0,        ...
    'RECV_fs0',               0,         ... receiver's nominal sampling frequency,[Hz] 62e6/100e6
    'RECV_fs_offset',         0,            ... receiver's sampling frequency offset,[Hz]
    'fs',                     0,           ... effective sampling frequency
    'N0',                     -204.0,       ... noise power density,[dB]
    'BW',                     16,           ... front-end bandpass bandwidth, MHz
    'RFGAIN',                 100,          ... the RF gain,[dB]    
    'Xm',                     0.4,          ... equivalent to -100db signal,0.334568463738615
    'B',                      7,            ... equivalent to 8 bit ADC
    'DELTA',                  [],           ... quatization step
    ...IF file config
    'IQForm',                ' ',       ... Complex/Real output
    'DataSource',            1,            ... 0: internal signal genrator; 1: external digitized data
    'dataType',              ' ',       ... data type for external data; bit4/int8/int16/int32   
    'fileNum',               0,        ... number of data files
    'datafilename',          ' ',      ... list of external data file name
    'dataNum',               0,        ... number of IF data read
    'dataSource_B1',         0,        ... data cell number of B1I signal
    'dataSource_B2',         0,        ... data cell number of B2I signal
    'dataSource_B3',         0,        ... data cell number of B3I signal
    'dataSource_L1',         0,        ... data cell number of L1CA signal
    'dataSource_L2',         0,        ... data cell number of L2C signal
    'dataSource_L5',         0,        ... data cell number of L5 signal
    'dataSource_G1',         0,        ... data cell number of GLONASS L1 signal
    'dataSource_G2',         0,        ... data cell number of GLONASS L2 signal
    'dataSource_E1',         0,        ... data cell number of E1 signal
    'dataSource_E5a',        0,        ... data cell number of E5a signal
    'dataSource_E5b',        0,        ... data cell number of E5b signal
    ...
    ... When using bandpass direct sampling technique, if the alignsed RF frequency lies in the upper
    ... half sampling band (ps: fix(Rf/(Fs/2)) is odd ), the intermidiate frequency will be flipped
    ... into the lower half sampling band, (ps: IF = Fs - rem(Rf,Rs) ), then the doppler frequency is
    ... also flipped in signa, and so we need a variable for accounting this effect.
    ...
    'bpSampling_OddFold',     +1,           ... +1 for internal signal; -1 for Beihang signal
    'Pre_filtering',         'Off'          ... On/Off
    ...
);
STR_RECV.fs = STR_RECV.RECV_fs0 + STR_RECV.RECV_fs_offset;
STR_RECV.DELTA = STR_RECV.Xm/2^(STR_RECV.B);

load PRN_code.mat;
STR_PRN_CODE = struct( ...  ±£´æÀ©ÆµÂë
    'CA_code',           CA_code,   ... 33*1023     PRN:1~33
    'RZCM_code',         RZCM_code, ... 32*20460    PRN:1~32
    'RZCL_code',         RZCL_code, ... 32*1534500  PRN:1~32
    'BDS_code',          BDS_code   ... 33*2046     PRN:1~33
);

GSAR_CONSTANTS = struct(...
    ...Define the Satellite signals' parameters
    'STR_L1CA',               STR_L1CA,     ...L1CA's parameters' structure
    'STR_L2C',                STR_L2C,      ...L2C's parameters' structure
    'STR_B1I',                STR_B1I,      ...BDS B1I parameters' structure
    'STR_B2I',                STR_B2I,      ...BDS B1I parameters' structure
    ...Define the receiver's parameters
    'STR_RECV',               STR_RECV,     ...Receiver's parameters' structure 
    ...Some constants
    'WEEKLONGSEC',            604800,       ...the time length in one week,[s]
    'DAYLONGSEC',             86400,        ...the time length in one day,[s]
    'C',                      2.99792458e8, ...light speed,[m/s]
    'PRN_CODE',               STR_PRN_CODE  ...À©ÆµÂë
);

end
