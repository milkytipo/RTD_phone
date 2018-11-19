function [ ephemeris, prn_list, updateTimes, isNorm, toe_matrix] = loadEphFromRINEX_C( ifile, sys  )
% 从RINEX导航电文文件中提取GPS卫星星历;也包括SV_ACCURACY等参数
% ifile = 'D:\Work\softrecv_research\sv_cadll\trunk\m\logfile\The_Three_Towers.15R';
ephemeris = [];
ephemeris_temp = [];
toe_matrix = [];
fid = fopen(ifile, 'rt');
if fid==-1
    error('BDS RINEX Nav Msg file open failure!\n');
end

%% 文件头
while true
    tline=fgets(fid);           
    if strfind(tline, 'END OF HEADER')>0       
        break;
    end
end
prn_old = -1;
toe_old = -1;

prn_list = [];
toe_list = [];

dat_b = [ 5, 24, 43, 62];
dat_e = [23, 42, 61, 80];
line_num = 1;
while ~feof(fid)
    tline = fgets(fid);
    if length(tline)<80
        % 正文部分每行含有80个字符
        continue;
    end
    tline(tline=='D') = 'E';
    if strcmp(tline(1), 'C') || strcmp(tline(1), 'G')
        line_num = 1; 
    end
    switch line_num
        case 1
            eph.prn      = sscanf( tline(2:3), '%d');
            year         = sscanf( tline(5:8), '%d');
            month        = sscanf( tline(10:11), '%d');
            day          = sscanf( tline(13:14), '%d');
            hour         = sscanf( tline(16:17), '%d');
            min          = sscanf( tline(19:20), '%d');
            sec          = sscanf( tline(22:23), '%d');
            todsec       = 3600 * hour + 60 * min + sec;  % time of day in seconds       
            daynum       = dayofweek(year,month,day);
            eph.toc      = todsec + 86400*daynum;   % 当前条数的周内秒
            eph.af0      = sscanf( tline(dat_b(2):dat_e(2)), '%f');
            eph.af1      = sscanf( tline(dat_b(3):dat_e(3)), '%f');
            eph.af2      = sscanf( tline(dat_b(4):dat_e(4)), '%f');
        case 2
            eph.iode     = sscanf( tline(dat_b(1):dat_e(1)), '%f');
            eph.Crs      = sscanf( tline(dat_b(2):dat_e(2)), '%f');
            eph.deltan   = sscanf( tline(dat_b(3):dat_e(3)), '%f');
            eph.M0       = sscanf( tline(dat_b(4):dat_e(4)), '%f');    
        case 3
            eph.Cuc      = sscanf( tline(dat_b(1):dat_e(1)), '%f');
            eph.e        = sscanf( tline(dat_b(2):dat_e(2)), '%f');
            eph.Cus      = sscanf( tline(dat_b(3):dat_e(3)), '%f');
            eph.sqrtA    = sscanf( tline(dat_b(4):dat_e(4)), '%f');
        case 4
            eph.toe      = sscanf( tline(dat_b(1):dat_e(1)), '%f');
            eph.Cic      = sscanf( tline(dat_b(2):dat_e(2)), '%f');
            eph.omega0   = sscanf( tline(dat_b(3):dat_e(3)), '%f');
            eph.Cis      = sscanf( tline(dat_b(4):dat_e(4)), '%f');
        case 5
            eph.i0       = sscanf( tline(dat_b(1):dat_e(1)), '%f');
            eph.Crc      = sscanf( tline(dat_b(2):dat_e(2)), '%f');
            eph.omega        = sscanf( tline(dat_b(3):dat_e(3)), '%f');
            eph.omegaDot = sscanf( tline(dat_b(4):dat_e(4)), '%f');
        case 6
            eph.iDot     = sscanf( tline(dat_b(1):dat_e(1)), '%f');
            %eph.codes_on_L2      = sscanf( tline(dat_b(2):dat_e(2)), '%f');
            eph.week     = sscanf( tline(dat_b(3):dat_e(3)), '%f');
            %eph.L2_P_flag= sscanf( tline(dat_b(4):dat_e(4)), '%f');
        case 7
            eph.svAccuracy      = sscanf( tline(dat_b(1):dat_e(1)), '%f');
            eph.health   = sscanf( tline(dat_b(2):dat_e(2)), '%f');
            if strcmp(sys, 'GPS')
                eph.TGD      = sscanf( tline(dat_b(3):dat_e(3)), '%f');
            elseif strcmp(sys, 'BDS')
                eph.TGD1      = sscanf( tline(dat_b(3):dat_e(3)), '%f');
            end
            eph.iodc     = sscanf( tline(dat_b(4):dat_e(4)), '%f');
%         case 8
%             dump         = sscanf( tline(dat_b(1):dat_e(1)), '%f');
            %eph.fit_interval = sscanf( tline(dat_b(2):dat_e(2)), '%f');
            if sum(eph.prn==prn_list)==0
                prn_list(end+1) = eph.prn;
            end
            toe = eph.toe+eph.week*604800;
            if sum(toe==toe_list)==0
                toe_list(end+1) = toe;
            end
            ephemeris_temp = [ ephemeris_temp, eph ];
    end
    line_num = line_num + 1;    % 此处假设每颗卫星的星历数据共有六行
end
satNum = length(prn_list);
updateTimes = length(toe_list);

% 初始化ephemeris结构
ephemeris = ephemeris_temp(1);


for i = 1:length(prn_list)
    prn = prn_list(i);
    updateCnt = 1;
    for j = 1:length(ephemeris_temp)
        if ephemeris_temp(j).prn == prn
           %% 将ephemeris 按照toe时间进行排序:插入排序法
            toe_to_insert = ephemeris_temp(j).toe + ephemeris_temp(j).week*604800;
            for k = 1:updateCnt-1
                toe_k = ephemeris(i, k).toe+ ephemeris(i,k).week*604800;
                if toe_to_insert<toe_k
                    break;
                end                
            end
          
            if updateCnt==1 || k == updateCnt-1
                % 直接插入到第updateCnt个位置
                ephemeris(i, updateCnt) = ephemeris_temp(j);
                toe_matrix(i,updateCnt) = ephemeris(i, updateCnt).toe;
            else
                % 需要将第k个到第updateCnt-1的星历向后移一格
                for mv_idx = updateCnt:-1:k+1
                    ephemeris(i, mv_idx) = ephemeris(i, mv_idx-1);
                    toe_matrix(i, mv_idx) = ephemeris(i, mv_idx).toe;
                end
                ephemeris(i,k) = ephemeris_temp(j);
                toe_matrix(i,k) = ephemeris(i,k).toe;
            end
            updateCnt = updateCnt + 1;
        end
    end
end

%% 检查星历数据是否是正则的， 即：所有卫星星历更新次数相同,每次更新的参考时间相同
isNorm = false;
[row, col] = size(ephemeris);
if col == updateTimes % 每颗卫星的最大星历更新次数相等
    isNorm = true;
    for i = 1:satNum % 检查同一卫星的星历参考时间有没有重复
        toe_old = ephemeris(i, 1).toe + ephemeris(i, 1).week*604800; 
        for j = 2:updateTimes
            toe = ephemeris(i, j).toe + ephemeris(i, j).week*604800; 
            if toe~=toe_old
                toe_old = toe;
            else
                isNorm = false;
                break;
            end
        end
        if ~isNorm
            break;
        end
    end
end

fclose(fid);




