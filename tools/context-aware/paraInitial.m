function [parameter, calibration] = paraInitial(fileNum)
% 初始化parameter结构体
%———————————— 参数初始化 ————————————%
parameter = struct(...
    'SYST',              '',...         % 系统
    'TYPE',              '',...          % 场景类型
    'SOW',               [],...          % 记录时刻的SOW值、时、分、秒 [4 × 记录时刻]
    'pos_llh',           [],...          % 记录经纬高信息 [3 × 记录时刻]
    'pos_xyz',           [],...          % 记录经纬高信息 [3 × 记录时刻]
    'pos_enu',           [],...          % 记录想对于第一个点的ENU信息 [3 × 记录时刻]
    'ENU_error',         [],...          % ENU_ERROR [6 × 记录时刻] [E, N ,U, 总， 平行， 正交]
    'posValid',          [],...          % 判断输出定位是否有效
    'vel',               [],...          % 记录速度信息 （m / s）
    'vel_angle',         [],...          % 速度的方向角 /°
    'satNum',            [],...          % 此段数据所有可见卫星数
    'blockNum',          [],...          % 此段数据被遮挡的卫星数
    'prnNo',             [],...          % 当前时刻可见卫星的PRN号
    'prnNo_useless',     [],...          % 不进行计算的卫星号
    'GDOP',              [],...          % GDOP值 [1 × 记录时刻]
    'GDOP_ratio',        [],...          % GDOP值 [1 × 记录时刻]
    'Elevation',         [],...          % 仰角 [卫星PRN号 × 记录时刻]
    'Azimuth',           [],...          % 方位角 [卫星PRN号 × 记录时刻]
    'CNR',               [],...           % 载噪比 [卫星PRN号 × 记录时刻]
    'CNR_Var',           [],...          % 载噪比的方差值 [卫星PRN号 × 记录时刻]
    'movLength',         [],...          % 行驶的里程数 /m [1 × 记录时刻]
    'length',            0 ...           % 时间长度
    );
parameter(1:fileNum) = parameter;

calibration = struct(...
    'SYST',               '',...                         % 系统
    'SOW',               [],...          % 记录时刻的SOW值、时、分、秒 [4 × 记录时刻]
    'pos_llh',           [],...          % 记录经纬高信息 [3 × 记录时刻]
    'pos_xyz',           [],...          % 记录经纬高信息 [3 × 记录时刻]
    'vel',               [],...          % 记录速度信息 m / s
    'length',            0 ...           % 时间长度
    );
calibration(1:fileNum) = calibration;



end % function