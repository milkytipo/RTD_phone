function [multiPara] = mp_xls_read(parameter_GPS, parameter_BDS_GEO, parameter_BDS_IGSO, parameter_BDS_MEO, del_flag)

paraLog = zeros(1, 4); % 登僅貧峰膨倖延楚頁倦畠何験峙
isNew = 0;
%！！！！！！！！歌方兜兵晒！！！！！！！！！！%
multiPara = struct(...
    'sateType',     '',...
    'codeDelay',    [],...
    'attenuation',  [],...
    'power',  [],...
    'doppBias',     [],...
    'lifeTime',     [],...
    'elelvation',   [],...
    'flag',         [],...
    'lifeTimeflag',         [],...
    'Occur_proba',  []...
    );
multiPara(1:8) = multiPara;
multiPara(1).sateType = 'BDS_GEO';
multiPara(2).sateType = 'BDS_IGSO';
multiPara(3).sateType = 'BDS_MEO';
multiPara(4).sateType = 'GPS';
multiPara(5).sateType = 'BDS_IGSO+BDS_MEO';
multiPara(6).sateType = 'GPS+BDS_MEO';
multiPara(7).sateType = 'GPS+BDS_IGSO+BDS_MEO';
multiPara(8).sateType = 'GPS+BDS_IGSO+BDS_MEO+BDS_GEO';
%%
%！！！！！！！！！！！！！！ 歌方験峙 ！！！！！！！！！！！！！！%
% ！！！！！！！！BDS_GEO！！！！！！！！！%
if ~isempty(parameter_BDS_GEO)
    multiNum = size(parameter_BDS_GEO, 1);
    path_N = size(parameter_BDS_GEO, 2);
    if path_N <= 11
        multipath = 1;
    elseif path_N <= 23
        multipath = 2;
    else
        multipath = 3;
    end
    line = 1 : multiNum;
    column_N = 3;
    for i = 1 : multipath
        multiPara(1).codeDelay = [multiPara(1).codeDelay; parameter_BDS_GEO(line, column_N)];
        multiPara(1).attenuation = [multiPara(1).attenuation; parameter_BDS_GEO(line, column_N+1)];
        multiPara(1).doppBias = [multiPara(1).doppBias; parameter_BDS_GEO(line, column_N+2)];
        multiPara(1).lifeTime = [multiPara(1).lifeTime; parameter_BDS_GEO(line, column_N+3)];
        multiPara(1).elelvation = [multiPara(1).elelvation; parameter_BDS_GEO(line, column_N+4)];
        multiPara(1).flag = [multiPara(1).flag; parameter_BDS_GEO(line, column_N+5)];
        if isNew
            multiPara(1).lifeTimeflag = [multiPara(1).lifeTimeflag; parameter_BDS_GEO(line, column_N+6)];
            multiPara(1).power = [multiPara(1).power; parameter_BDS_GEO(line, column_N+7)];
        end
        column_N = column_N + 12;
    end
    multiPara(1).codeDelay(isnan(multiPara(1).codeDelay)) = [];
    multiPara(1).attenuation(isnan(multiPara(1).attenuation)) = [];
    multiPara(1).doppBias(isnan(multiPara(1).doppBias)) = [];
    multiPara(1).lifeTime(isnan(multiPara(1).lifeTime)) = [];
    multiPara(1).elelvation(isnan(multiPara(1).elelvation)) = [];
    multiPara(1).flag(isnan(multiPara(1).flag)) = [];
    multiPara(1).lifeTimeflag(isnan(multiPara(1).lifeTimeflag)) = [];
    multiPara(1).power(isnan(multiPara(1).power)) = [];   
%     multiPara(1).Occur_proba = Occur_BDS(Occur_BDS(:,1)<=5&Occur_BDS(:,1)>0,:);
    paraLog(1) = 1;
end
% ！！！！！！！！BDS_IGSO！！！！！！！！！%
if ~isempty(parameter_BDS_IGSO)
    multiNum = size(parameter_BDS_IGSO, 1);
    path_N = size(parameter_BDS_IGSO, 2);
    if path_N <= 11
        multipath = 1;
    elseif path_N <= 23
        multipath = 2;
    else
        multipath = 3;
    end
    line = 1 : multiNum;
    column_N = 3;
    for i = 1 : multipath
        multiPara(2).codeDelay = [multiPara(2).codeDelay; parameter_BDS_IGSO(line, column_N)];
        multiPara(2).attenuation = [multiPara(2).attenuation; parameter_BDS_IGSO(line, column_N+1)];
        multiPara(2).doppBias = [multiPara(2).doppBias; parameter_BDS_IGSO(line, column_N+2)];
        multiPara(2).lifeTime = [multiPara(2).lifeTime; parameter_BDS_IGSO(line, column_N+3)];
        multiPara(2).elelvation = [multiPara(2).elelvation; parameter_BDS_IGSO(line, column_N+4)];
        multiPara(2).flag = [multiPara(2).flag; parameter_BDS_IGSO(line, column_N+5)];
        if isNew
            multiPara(2).lifeTimeflag = [multiPara(2).lifeTimeflag; parameter_BDS_IGSO(line, column_N+6)];
            multiPara(2).power = [multiPara(2).power; parameter_BDS_IGSO(line, column_N+7)];
        end
        column_N = column_N + 12;
    end
%     multiPara(2).Occur_proba = Occur_BDS(Occur_BDS(:,1)<=10&Occur_BDS(:,1)>5,:);
    paraLog(2) = 1;
    multiPara(2).codeDelay(isnan(multiPara(2).codeDelay)) = [];
    multiPara(2).attenuation(isnan(multiPara(2).attenuation)) = [];
    multiPara(2).doppBias(isnan(multiPara(2).doppBias)) = [];
    multiPara(2).lifeTime(isnan(multiPara(2).lifeTime)) = [];
    multiPara(2).elelvation(isnan(multiPara(2).elelvation)) = [];
    multiPara(2).flag(isnan(multiPara(2).flag)) = [];
    multiPara(2).lifeTimeflag(isnan(multiPara(2).lifeTimeflag)) = [];
    multiPara(2).power(isnan(multiPara(2).power)) = [];   
end
% ！！！！！！！！BDS_MEO！！！！！！！！！%
if ~isempty(parameter_BDS_MEO)
    multiNum = size(parameter_BDS_MEO, 1);
    path_N = size(parameter_BDS_MEO, 2);
    if path_N <= 11
        multipath = 1;
    elseif path_N <= 23
        multipath = 2;
    else
        multipath = 3;
    end
    line = 1 : multiNum;
    column_N = 3;
    for i = 1 : multipath
        multiPara(3).codeDelay = [multiPara(3).codeDelay; parameter_BDS_MEO(line, column_N)];
        multiPara(3).attenuation = [multiPara(3).attenuation; parameter_BDS_MEO(line, column_N+1)];
        multiPara(3).doppBias = [multiPara(3).doppBias; parameter_BDS_MEO(line, column_N+2)];
        multiPara(3).lifeTime = [multiPara(3).lifeTime; parameter_BDS_MEO(line, column_N+3)];
        multiPara(3).elelvation = [multiPara(3).elelvation; parameter_BDS_MEO(line, column_N+4)];
        multiPara(3).flag = [multiPara(3).flag; parameter_BDS_MEO(line, column_N+5)];
        if isNew
            multiPara(3).lifeTimeflag = [multiPara(3).lifeTimeflag; parameter_BDS_MEO(line, column_N+6)];
            multiPara(3).power = [multiPara(3).power; parameter_BDS_MEO(line, column_N+7)];
        end
        column_N = column_N + 12;
    end
    multiPara(3).codeDelay(isnan(multiPara(3).codeDelay)) = [];
    multiPara(3).attenuation(isnan(multiPara(3).attenuation)) = [];
    multiPara(3).doppBias(isnan(multiPara(3).doppBias)) = [];
    multiPara(3).lifeTime(isnan(multiPara(3).lifeTime)) = [];
    multiPara(3).elelvation(isnan(multiPara(3).elelvation)) = [];
    multiPara(3).flag(isnan(multiPara(3).flag)) = [];
    multiPara(3).lifeTimeflag(isnan(multiPara(3).lifeTimeflag)) = [];
    multiPara(3).power(isnan(multiPara(3).power)) = [];   
%     multiPara(3).Occur_proba = Occur_BDS(Occur_BDS(:,1)>10,:);
    paraLog(3) = 1;
end
% ！！！！！！！！GPS！！！！！！！！！%
if ~isempty(parameter_GPS)
    multiNum = size(parameter_GPS, 1);
    path_N = size(parameter_GPS, 2);
    if path_N <= 11
        multipath = 1;
    elseif path_N <= 23
        multipath = 2;
    else
        multipath = 3;
    end
    line = 1 : multiNum;
    column_N = 3;
    for i = 1 : multipath
        multiPara(4).codeDelay = [multiPara(4).codeDelay; parameter_GPS(line, column_N)];
        multiPara(4).attenuation = [multiPara(4).attenuation; parameter_GPS(line, column_N+1)];
        multiPara(4).doppBias = [multiPara(4).doppBias; parameter_GPS(line, column_N+2)];
        multiPara(4).lifeTime = [multiPara(4).lifeTime; parameter_GPS(line, column_N+3)];
        multiPara(4).elelvation = [multiPara(4).elelvation; parameter_GPS(line, column_N+4)];
        multiPara(4).flag = [multiPara(4).flag; parameter_GPS(line, column_N+5)];
        if isNew
            multiPara(4).lifeTimeflag = [multiPara(4).lifeTimeflag; parameter_GPS(line, column_N+6)];
            multiPara(4).power = [multiPara(4).power; parameter_GPS(line, column_N+7)];
        end
        column_N = column_N + 12;
    end
    multiPara(4).codeDelay(isnan(multiPara(4).codeDelay)) = [];
    multiPara(4).attenuation(isnan(multiPara(4).attenuation)) = [];
    multiPara(4).doppBias(isnan(multiPara(4).doppBias)) = [];
    multiPara(4).lifeTime(isnan(multiPara(4).lifeTime)) = [];
    multiPara(4).elelvation(isnan(multiPara(4).elelvation)) = [];
    multiPara(4).flag(isnan(multiPara(4).flag)) = [];
    multiPara(4).lifeTimeflag(isnan(multiPara(4).lifeTimeflag)) = [];
    multiPara(4).power(isnan(multiPara(4).power)) = [];   
%     multiPara(4).Occur_proba = Occur_GPS;
    paraLog(4) = 1;
end

%%
%！！！！！！！！！！！！！！ 方象序匯化侃尖 ！！！！！！！！！！！！！！！！%
for i = 1 : 4
    if paraLog(i)
        for j = 1 : length(del_flag) 
            removeLine = multiPara(i).flag==del_flag(j);  % 僉夲肇茅議方象
            multiPara(i).codeDelay(removeLine) = [];
            multiPara(i).attenuation(removeLine) = [];
            multiPara(i).doppBias(removeLine) = [];
            multiPara(i).lifeTime(removeLine) = [];
            multiPara(i).elelvation(removeLine) = [];
            multiPara(i).flag(removeLine) = [];
            if isNew
                multiPara(i).lifeTimeflag(removeLine) = [];
                multiPara(i).power(removeLine) = [];
            end
        end
    end
end



%！！！！！！！！！！ BDS_IGSO + BDS_MEO ！！！！！！！！！！！！%
multiPara(5).codeDelay = [multiPara(2).codeDelay; multiPara(3).codeDelay];
multiPara(5).attenuation = [multiPara(2).attenuation; multiPara(3).attenuation];
multiPara(5).doppBias = [multiPara(2).doppBias; multiPara(3).doppBias];
multiPara(5).lifeTime = [multiPara(2).lifeTime; multiPara(3).lifeTime];
multiPara(5).elelvation = [multiPara(2).elelvation; multiPara(3).elelvation];
multiPara(5).flag = [multiPara(2).flag; multiPara(3).flag];
multiPara(5).lifeTimeflag = [multiPara(2).lifeTimeflag; multiPara(3).lifeTimeflag];
multiPara(5).power = [multiPara(2).power; multiPara(3).power];
multiPara(5).Occur_proba = [multiPara(2).Occur_proba; multiPara(3).Occur_proba];

%！！！！！！！！！！ GPS + BDS_MEO ！！！！！！！！！！！！%
multiPara(6).codeDelay = [multiPara(3).codeDelay; multiPara(4).codeDelay];
multiPara(6).attenuation = [multiPara(3).attenuation; multiPara(4).attenuation];
multiPara(6).doppBias = [multiPara(3).doppBias; multiPara(4).doppBias];
multiPara(6).lifeTime = [multiPara(3).lifeTime; multiPara(4).lifeTime];
multiPara(6).elelvation = [multiPara(3).elelvation; multiPara(4).elelvation];
multiPara(6).flag = [multiPara(3).flag; multiPara(4).flag];
multiPara(6).lifeTimeflag = [multiPara(3).lifeTimeflag; multiPara(4).lifeTimeflag];
multiPara(6).power = [multiPara(3).power; multiPara(4).power];
multiPara(6).Occur_proba = [multiPara(3).Occur_proba; multiPara(4).Occur_proba];

%！！！！！！！！！！ GPS + BDS_IGSO + BDS_MEO ！！！！！！！！！！！！%
multiPara(7).codeDelay = [multiPara(2).codeDelay; multiPara(3).codeDelay; multiPara(4).codeDelay];
multiPara(7).attenuation = [multiPara(2).attenuation; multiPara(3).attenuation; multiPara(4).attenuation];
multiPara(7).doppBias = [multiPara(2).doppBias; multiPara(3).doppBias; multiPara(4).doppBias];
multiPara(7).lifeTime = [multiPara(2).lifeTime; multiPara(3).lifeTime; multiPara(4).lifeTime];
multiPara(7).elelvation = [multiPara(2).elelvation; multiPara(3).elelvation; multiPara(4).elelvation];
multiPara(7).flag = [multiPara(2).flag; multiPara(3).flag; multiPara(4).flag];
multiPara(7).lifeTimeflag = [multiPara(2).lifeTimeflag; multiPara(3).lifeTimeflag; multiPara(4).lifeTimeflag];
multiPara(7).power = [multiPara(2).power; multiPara(3).power; multiPara(4).power];
multiPara(7).Occur_proba = [multiPara(2).Occur_proba; multiPara(3).Occur_proba; multiPara(4).Occur_proba];

%！！！！！！！！！！ GPS + BDS_IGSO + BDS_MEO + GEO ！！！！！！！！！！！！%
multiPara(8).codeDelay = [multiPara(1).codeDelay; multiPara(2).codeDelay; multiPara(3).codeDelay; multiPara(4).codeDelay];
multiPara(8).attenuation = [multiPara(1).attenuation; multiPara(2).attenuation; multiPara(3).attenuation; multiPara(4).attenuation];
multiPara(8).doppBias = [multiPara(1).doppBias; multiPara(2).doppBias; multiPara(3).doppBias; multiPara(4).doppBias];
multiPara(8).lifeTime = [multiPara(1).lifeTime; multiPara(2).lifeTime; multiPara(3).lifeTime; multiPara(4).lifeTime];
multiPara(8).elelvation = [multiPara(1).elelvation; multiPara(2).elelvation; multiPara(3).elelvation; multiPara(4).elelvation];
multiPara(8).flag = [multiPara(1).flag; multiPara(2).flag; multiPara(3).flag; multiPara(4).flag];
multiPara(8).lifeTimeflag = [multiPara(1).lifeTimeflag; multiPara(2).lifeTimeflag; multiPara(3).lifeTimeflag; multiPara(4).lifeTimeflag];
multiPara(8).power = [multiPara(1).power; multiPara(2).power; multiPara(3).power; multiPara(4).power];
multiPara(8).Occur_proba = [multiPara(1).Occur_proba; multiPara(2).Occur_proba; multiPara(3).Occur_proba; multiPara(4).Occur_proba];