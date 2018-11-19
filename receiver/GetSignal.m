% Getting the signal-in-space data
function [signal, siscount, config] = GetSignal(signal, config, N)

global GSAR_CONSTANTS;
fileNum = GSAR_CONSTANTS.STR_RECV.fileNum; %总共所需读取的文件数量
dataNum = GSAR_CONSTANTS.STR_RECV.dataNum; %总共存储的中频信号cell数量
signal.sis = cell(1,dataNum); %初始化避免赋值出错

%% 宇志设备，支持L1和B1频点的复采样，共用中频数据文件
if signal.equipType == 1
    if GSAR_CONSTANTS.STR_RECV.DataSource > 0  % external data source
        
        if 0 == signal.fid(1)
            signal.fid(1) = fopen( GSAR_CONSTANTS.STR_RECV.datafilename{1} , 'rb');
            if (fseek(signal.fid(1), round(config.sisConfig.skipNumberOfBytes), 'bof') ~= 0)
                error('fseek operation at the beginning of GetSignal failed!');
            end
        end
        % Complex          
        [sis_temp, siscount] = fread(signal.fid(1), 2*N, GSAR_CONSTANTS.STR_RECV.dataType);
        signal.sis{1}(1,:) = sis_temp(1:2:end) + 1i*sis_temp(2:2:end);
        siscount = floor(siscount/2);
        
        config.sisConfig.skipNumberOfBytes = config.sisConfig.skipNumberOfBytes + 2*N; %2*bit8

    else % internal signal genenrator
        error('Internal signal generator is not defined in this version!');
    end
end

%% Keda Device File Reading
% 数据格式说明：
% 采样率：100MHz    量化位数：4bit   L1: 37.42MHz     B1: 23.098MHz
% 每4092个字节后，即8184个采样点，会有4个字节的校验和
if signal.equipType == 2
    if GSAR_CONSTANTS.STR_RECV.DataSource > 0  % external data source
        
        checkNum = ceil((N-signal.headData)/8184) * 8; % 校验位的总数量,且保证终止点非校验位
        numAll = checkNum + N; %加上校验位的采样点数目
        for fN = 1:fileNum
            if 0 == signal.fid(fN)
                signal.fid(fN) = fopen( GSAR_CONSTANTS.STR_RECV.datafilename{fN} , 'rb');
                if (fseek(signal.fid(fN), floor(config.sisConfig.skipNumberOfBytes+0.1), 'bof') ~= 0)
                    error('fseek operation at the beginning of GetSignal failed!');
                end
                %断点续传时需要处理半字节数据
                if (rem(config.sisConfig.skipNumberOfBytes,1)>0.1)
                    fread(signal.fid(fN), 1, GSAR_CONSTANTS.STR_RECV.dataType);
                end        
            end
            [sis_temp(:,1), siscount] = fread(signal.fid(fN), numAll, GSAR_CONSTANTS.STR_RECV.dataType);
            
            tail_N = mod(siscount-signal.headData-8, 8192);
            sis_head = sis_temp(1:signal.headData);
            sis_tail = sis_temp(siscount-tail_N+1:end);
            sis_body = reshape( sis_temp(signal.headData+9:siscount-tail_N), 8192, [] );
            sis_body(8185:8192,:) = []; %去校验位
            signal.sis{fN}(1,:) = [ sis_head; reshape(sis_body,[],1); sis_tail ];
        end
        
        siscount = size(signal.sis,1);
        signal.headData = 8184 - tail_N;
        config.sisConfig.skipNumberOfBytes = config.sisConfig.skipNumberOfBytes + N/2; %bit4
        
    else % internal signal genenrator
        error('Internal signal generator is not defined in this version!');
    end
    
end

%% 总站去校验位数据
% 数据格式说明：
% 采样率：100MHz    量化位数：4bit  real
if signal.equipType == 21
    
    if GSAR_CONSTANTS.STR_RECV.DataSource > 0  % external data source       
        for fN = 1:fileNum
            if 0 == signal.fid(fN)
                signal.fid(fN) = fopen( GSAR_CONSTANTS.STR_RECV.datafilename{fN} , 'rb');
                if (fseek(signal.fid(fN), floor(config.sisConfig.skipNumberOfBytes+0.1), 'bof') ~= 0)
                    error('fseek operation at the beginning of GetSignal failed!');
                end
                %断点续传时需要处理半字节数据
                if (rem(config.sisConfig.skipNumberOfBytes,1)>0.1)
                    fread(signal.fid(fN), 1, GSAR_CONSTANTS.STR_RECV.dataType);
                end
            end
            [signal.sis{fN}(1,:), siscount] = fread(signal.fid(fN), N, GSAR_CONSTANTS.STR_RECV.dataType);             
        end           
    else % internal signal genenrator
        error('Internal signal generator is not defined in this version!');
    end 
    
    config.sisConfig.skipNumberOfBytes = config.sisConfig.skipNumberOfBytes + N/2; %bit4
end

%% Sample Device File Reading
if signal.equipType == 3
    if GSAR_CONSTANTS.STR_RECV.DataSource > 0  % external data source
        
        for fN = 1:fileNum
            if 0 == signal.fid(fN)
                signal.fid(fN) = fopen( GSAR_CONSTANTS.STR_RECV.datafilename{fN} , 'rb');
                % File header 128byte
                if (fseek(signal.fid(fN), config.sisConfig.skipNumberOfBytes + 128, 'bof') ~= 0)
                    error('fseek operation at the beginning of GetSignal failed!');
                end    
            end

            if strcmp('Real', GSAR_CONSTANTS.STR_RECV.IQForm)
                [signal.sis{fN}(1,:), siscount] = fread(signal.fid(fN), N, GSAR_CONSTANTS.STR_RECV.dataType);
            else % Complex
                [sis_temp, siscount] = fread(signal.fid(fN), 2*N, GSAR_CONSTANTS.STR_RECV.dataType);
                signal.sis{fN}(1,:) = sis_temp(1:2:end) + 1i*sis_temp(2:2:end);
                siscount = floor(siscount/2);
            end
        end
    else % internal signal genenrator
        error('Internal signal generator is not defined in this version!');
    end
end %EOF "if signal.equipType == 3"

%% 宇志全频点采样设备，数据文件仅一个，各频点数据按一定顺序排列
if signal.equipType == 4
    switch mod(signal.devSubtype, 10)
        case 0 %9频点模式，待更新
            
        case {1,2,3,4,5} %4频点模式
            if 0 == signal.fid(1)
                signal.fid(1) = fopen( GSAR_CONSTANTS.STR_RECV.datafilename{1} , 'rb');
                if (fseek(signal.fid(1), round(4*config.sisConfig.skipNumberOfBytes), 'bof') ~= 0)
                    error('fseek operation at the beginning of GetSignal failed!');
                end
            end
            [sis_temp, siscount] = fread(signal.fid(1), 4*N, GSAR_CONSTANTS.STR_RECV.dataType);
            signal.sis{1}(1,:) = sis_temp(1:4:end);
            signal.sis{2}(1,:) = sis_temp(2:4:end);
            signal.sis{3}(1,:) = sis_temp(3:4:end);
            signal.sis{4}(1,:) = sis_temp(4:4:end);
            siscount = floor(siscount/4);
            
            switch floor(signal.devSubtype/100)
                case 0 %4bits
                    config.sisConfig.skipNumberOfBytes = config.sisConfig.skipNumberOfBytes + 0.5*N;
                case 1 %8bits
                    config.sisConfig.skipNumberOfBytes = config.sisConfig.skipNumberOfBytes + N;
                case 2 %12bits
                    config.sisConfig.skipNumberOfBytes = config.sisConfig.skipNumberOfBytes + 1.5*N;
            end
            
    end
    
end %EOF "if signal.equipType == 3"

%% 仿真数据  20M, 4bit, real
if signal.equipType == 100
    
    for fN = 1:fileNum
        if 0 == signal.fid(fN)
            signal.fid(fN) = fopen( cell2mat(GSAR_CONSTANTS.STR_RECV.datafilename(fN)) , 'rb');
                if (fseek(signal.fid(fN), floor(config.sisConfig.skipNumberOfBytes+0.1), 'bof') ~= 0)
                    error('fseek operation at the beginning of GetSignal failed!');
                end
                %断点续传时需要处理半字节数据
                if (rem(config.sisConfig.skipNumberOfBytes,1)>0.1)
                    fread(signal.fid(fN), 1, GSAR_CONSTANTS.STR_RECV.dataType);
                end   
        end
        [signal.sis{fN}(1,:), siscount] = fread(signal.fid(fN), N, GSAR_CONSTANTS.STR_RECV.dataType);         
    end
    
    config.sisConfig.skipNumberOfBytes = config.sisConfig.skipNumberOfBytes + N/2; %bit4
end

%% 仿真数据2  16.384M, 8bit, real
if signal.equipType == 101
    
    for fN = 1:fileNum
        if 0 == signal.fid(fN)
            signal.fid(fN) = fopen( cell2mat(GSAR_CONSTANTS.STR_RECV.datafilename(fN)) , 'rb');
                if (fseek(signal.fid(fN), config.sisConfig.skipNumberOfBytes, 'bof') ~= 0)
                    error('fseek operation at the beginning of GetSignal failed!');
                end
 
        end
        [signal.sis{fN}(1,:), siscount] = fread(signal.fid(fN), N, GSAR_CONSTANTS.STR_RECV.dataType);         
    end
    
    config.sisConfig.skipNumberOfBytes = config.sisConfig.skipNumberOfBytes + N; %bit8
end
