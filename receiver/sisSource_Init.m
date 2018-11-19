function [] = sisSource_Init(signal)

global GSAR_CONSTANTS;
%------ Re-setup the signal bands info according to device type -------
switch signal.equipType
    case 1 % Yuzhi Device
        GSAR_CONSTANTS.STR_RECV.RECV_fs0      = 62e6;
        GSAR_CONSTANTS.STR_RECV.fs            = 62e6;
        GSAR_CONSTANTS.STR_RECV.IF_B1I        = -6.902e6;
        GSAR_CONSTANTS.STR_RECV.IF_L1CA       = 7.42e6;
        GSAR_CONSTANTS.STR_RECV.dataNum       = 1;
        GSAR_CONSTANTS.STR_RECV.dataSource_B1 = 1;
        GSAR_CONSTANTS.STR_RECV.dataSource_L1 = 1;
        GSAR_CONSTANTS.STR_RECV.IQForm        = 'Complex';
        GSAR_CONSTANTS.STR_RECV.DataSource    = 1;
        GSAR_CONSTANTS.STR_RECV.dataType      = 'int8';
        GSAR_CONSTANTS.STR_RECV.bpSampling_OddFold = 1;
        
    case {2,21}
        GSAR_CONSTANTS.STR_RECV.RECV_fs0     = 100e6;
        GSAR_CONSTANTS.STR_RECV.fs           = 100e6;
        GSAR_CONSTANTS.STR_RECV.IF_B1I       = 23.098e6;
        GSAR_CONSTANTS.STR_RECV.IF_B2I       = 21.14e6;
        GSAR_CONSTANTS.STR_RECV.IF_L1CA      = 37.42e6;
        GSAR_CONSTANTS.STR_RECV.IF_L2C       = 41.60e6;
        GSAR_CONSTANTS.STR_RECV.dataNum      = 2;
        GSAR_CONSTANTS.STR_RECV.dataSource_B1  = 1;
        GSAR_CONSTANTS.STR_RECV.dataSource_B2  = 2;
        GSAR_CONSTANTS.STR_RECV.dataSource_L1  = 1;
        GSAR_CONSTANTS.STR_RECV.dataSource_L2  = 2;
        GSAR_CONSTANTS.STR_RECV.IQForm          = 'Real';
        GSAR_CONSTANTS.STR_RECV.DataSource      = 1;
        GSAR_CONSTANTS.STR_RECV.dataType        = 'bit4';
        GSAR_CONSTANTS.STR_RECV.bpSampling_OddFold = 1;
        
    case 3
        % SamplingFreq: 25MHz; RFBw = 5MHz; GPS L1 only
        GSAR_CONSTANTS.STR_RECV.RECV_fs0     = 25e6;
        GSAR_CONSTANTS.STR_RECV.fs           = 25e6;
        GSAR_CONSTANTS.STR_RECV.IF_B1I       = 0 ;
        GSAR_CONSTANTS.STR_RECV.IF_L1CA      = 5e6;
        GSAR_CONSTANTS.STR_RECV.dataNum = 1;
        GSAR_CONSTANTS.STR_RECV.dataSource_B1 = 0;
        GSAR_CONSTANTS.STR_RECV.dataSource_L1 = 1;
        GSAR_CONSTANTS.STR_RECV.IQForm       = 'Real';
        GSAR_CONSTANTS.STR_RECV.DataSource   = 1;
        GSAR_CONSTANTS.STR_RECV.dataType     = 'int16';
        GSAR_CONSTANTS.STR_RECV.bpSampling_OddFold = 1;
    
        
    case 4 %宇志全频点 目前无论宽带窄带采样模式，各个频点采样率都按50M处理，中频按12.5M处理。后续可改进
        GSAR_CONSTANTS.STR_RECV.RECV_fs0      = 50e6;
        GSAR_CONSTANTS.STR_RECV.fs            = 50e6;
        GSAR_CONSTANTS.STR_RECV.IQForm        = 'Real';
        GSAR_CONSTANTS.STR_RECV.DataSource    = 1;
        GSAR_CONSTANTS.STR_RECV.bpSampling_OddFold = 1;
        
        switch floor(signal.devSubtype/100)
            case 0
                GSAR_CONSTANTS.STR_RECV.dataType     = 'bit4';
            case 1
                GSAR_CONSTANTS.STR_RECV.dataType     = 'bit8';
            case 2
                GSAR_CONSTANTS.STR_RECV.dataType     = 'bit12';
        end
        
        switch mod(signal.devSubtype, 100)
            case {00,10} %全频点9路信号采样，无宽带窄带的区别，4比特采样
                %格式： B1+B2+B3+L1(E1)+L2+L5(E5a)+G1+G2+E5b
                
            case {01,11} %L1+L2+L5+B1
                GSAR_CONSTANTS.STR_RECV.dataNum = 4;
                GSAR_CONSTANTS.STR_RECV.dataSource_L1 = 1;
                GSAR_CONSTANTS.STR_RECV.dataSource_L2 = 2;
                GSAR_CONSTANTS.STR_RECV.dataSource_L5 = 3;
                GSAR_CONSTANTS.STR_RECV.dataSource_B1 = 4;
                GSAR_CONSTANTS.STR_RECV.IF_L1CA       = 12.5e6;
                GSAR_CONSTANTS.STR_RECV.IF_L2C        = 12.5e6;
                GSAR_CONSTANTS.STR_RECV.IF_L5         = 12.5e6;
                GSAR_CONSTANTS.STR_RECV.IF_B2I        = 12.5e6;
                
            case {02,12} %B1+B2+B3+L1
                GSAR_CONSTANTS.STR_RECV.dataNum = 4;
                GSAR_CONSTANTS.STR_RECV.dataSource_B1 = 1;
                GSAR_CONSTANTS.STR_RECV.dataSource_B2 = 2;
                GSAR_CONSTANTS.STR_RECV.dataSource_B3 = 3;
                GSAR_CONSTANTS.STR_RECV.dataSource_L1 = 4;
                GSAR_CONSTANTS.STR_RECV.IF_B1I        = 12.5e6;
                GSAR_CONSTANTS.STR_RECV.IF_B2I        = 12.5e6;
                GSAR_CONSTANTS.STR_RECV.IF_B3I        = 12.5e6;
                GSAR_CONSTANTS.STR_RECV.IF_L1CA       = 12.5e6;
            case {03,13} %L1+B1+G1+E1
                GSAR_CONSTANTS.STR_RECV.dataNum = 4;
                GSAR_CONSTANTS.STR_RECV.dataSource_L1 = 1;
                GSAR_CONSTANTS.STR_RECV.dataSource_B1 = 2;
                GSAR_CONSTANTS.STR_RECV.dataSource_G1 = 3;
                GSAR_CONSTANTS.STR_RECV.dataSource_E1 = 4;
                GSAR_CONSTANTS.STR_RECV.IF_L1CA       = 12.5e6;
                GSAR_CONSTANTS.STR_RECV.IF_B1I        = 12.5e6;
                GSAR_CONSTANTS.STR_RECV.IF_G1         = 12.5e6;
                GSAR_CONSTANTS.STR_RECV.IF_E1         = 12.5e6;
                
            case {04,14} %L1+L2+B1+B2
                GSAR_CONSTANTS.STR_RECV.dataNum = 4;
                GSAR_CONSTANTS.STR_RECV.dataSource_L1 = 1;
                GSAR_CONSTANTS.STR_RECV.dataSource_L2 = 2;
                GSAR_CONSTANTS.STR_RECV.dataSource_B1 = 3;
                GSAR_CONSTANTS.STR_RECV.dataSource_B2 = 4;
                GSAR_CONSTANTS.STR_RECV.IF_L1CA      = 12.5e6;
                GSAR_CONSTANTS.STR_RECV.IF_L2C       = 12.5e6;
                GSAR_CONSTANTS.STR_RECV.IF_B1I       = 12.5e6;
                GSAR_CONSTANTS.STR_RECV.IF_B2I       = 12.5e6;

            case {05,15} %L1+B1+G1+B3
                GSAR_CONSTANTS.STR_RECV.dataNum = 4;
                GSAR_CONSTANTS.STR_RECV.dataSource_L1 = 1;
                GSAR_CONSTANTS.STR_RECV.dataSource_B1 = 2;
                GSAR_CONSTANTS.STR_RECV.dataSource_G1 = 3;
                GSAR_CONSTANTS.STR_RECV.dataSource_B1 = 4;
                GSAR_CONSTANTS.STR_RECV.IF_L1CA       = 12.5e6;
                GSAR_CONSTANTS.STR_RECV.IF_B1I        = 12.5e6;
                GSAR_CONSTANTS.STR_RECV.IF_G1         = 12.5e6;
                GSAR_CONSTANTS.STR_RECV.IF_B3I        = 12.5e6;
        end
        
    case 100 %仿真类型1
        GSAR_CONSTANTS.STR_RECV.RECV_fs0     = 20e6;
        GSAR_CONSTANTS.STR_RECV.fs           = 20e6;
        GSAR_CONSTANTS.STR_RECV.IF_L1CA      = 3.42e6;
        GSAR_CONSTANTS.STR_RECV.IF_L2C       = 7.60e6;
        GSAR_CONSTANTS.STR_RECV.dataNum   = 2;
        GSAR_CONSTANTS.STR_RECV.dataSource_L1 = 1;
        GSAR_CONSTANTS.STR_RECV.dataSource_L2  = 2;
        GSAR_CONSTANTS.STR_RECV.IQForm       = 'Real';
        GSAR_CONSTANTS.STR_RECV.dataType     = 'bit4';
        GSAR_CONSTANTS.STR_RECV.DataSource   = 1;
        GSAR_CONSTANTS.STR_RECV.bpSampling_OddFold = 1;
        
    case 101 %仿真类型2
        GSAR_CONSTANTS.STR_RECV.RECV_fs0     = 16.384e6;
        GSAR_CONSTANTS.STR_RECV.fs           = 16.384e6;
        GSAR_CONSTANTS.STR_RECV.IF_L1CA      = 4e6;
        GSAR_CONSTANTS.STR_RECV.IF_L2C       = 4e6;
        GSAR_CONSTANTS.STR_RECV.dataNum   = 2;
        GSAR_CONSTANTS.STR_RECV.dataSource_L1 = 1;
        GSAR_CONSTANTS.STR_RECV.dataSource_L2  = 2;
        GSAR_CONSTANTS.STR_RECV.IQForm       = 'Real';
        GSAR_CONSTANTS.STR_RECV.dataType     = 'bit8';
        GSAR_CONSTANTS.STR_RECV.DataSource   = 1;
        GSAR_CONSTANTS.STR_RECV.bpSampling_OddFold = 1;
        
    otherwise
        error('Illegal Device Type Code!')
end