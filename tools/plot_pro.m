clear; clc; close all;
addpath(genpath('.\sisgen\'));
addpath(genpath('.\receiver\'));
addpath(genpath('.\recorder\'));

%% Input Config Parameters 
sv_visible = [4];
filepath = 'E:\work_Private\wangyz\软件接收机_SVN\trunk\wangyz_trunk\data\The_Three_Towers_BDS_B1I'; ...'E:\mp_allday\processed\mpdata_2014-7-1_14-29-41\2014_7_14_17_53_20_BD_B1I'; % Set prefix
corr_accu_times = 1000; % 相关函数每10ms记录一次，每次为1ms的累积量，设为100表示数据均取自同一秒内
plotCorrMovie = 1;

%%
numberOfChannels = length(sv_visible);
STR_FILE_CTRL(numberOfChannels,1) = struct(...
    'DEBUG_LEVEL',            2, ...  
    'info',                   [], ...
    ... DEBUG_LEVEL==1
    'trk_carphs',             [], ...
    'trk_carfreq',            [], ...
    ... % record the time axis of each recording variable in order to accommodate different coherent tracking time
    'trk_timeaxis',           [], ... 
    ... DEBUG_LEVEL==2
    'trk_cad_codphs_diff',    [], ...
    'trk_cad_codphs_diff_2',  [], ...
    'trk_cad_ai',             [], ...
    'trk_cad_aq',             [], ...
    'unit_active_mt',         [], ...
    'unit_active_mt_2',       [], ...
    ... % recording each active unit's CNR, monitored normalized amplitudes and its corresponding time axis
    'CNR_AmpMoni_time',       [], ...
    'cad_trch_ai',            [], ...
    'cad_trch_aq',            [], ...
    'cad_trch_a_avg',         [], ...
    'cad_trch_snr',           [], ...
    'cad_trch_active',        [], ...
    'cad_trch_cnr',           [], ...
    'cad_trch_corrM_IQ',      [], ...
    'corrM_IQ',               [],...
    'uncancelled_corrM_IQ',   [],...
    ... DEBUG_LEVEL==3
    'trk_codphs',             [], ...
    'trk_codfreq',            [], ...
    'Dch_T_IQ',               [], ...
    'cad_trch_codphs',        [], ...
    'cad_trch_codfreq',       [], ...
    'cad_trch_codphs_diff',   [], ...
    'cad_trch_a_std',         [], ...
    'cad_trch_DchT_IQ',       [], ...
    ... DEBUG_LEVEL==4
    'Dch_Tslot_IQ',           [], ...
    ... DEBUG_LEVEL==5
    'BBSig_I',                [], ... %Downconverted baseband signal with code still in there
    'BBSig_Q',                [], ...  
    'LO_Dch_Codes',           [], ... %Locally generated data channel codes
    'LO_Pch_Codes',           [] ...  %Locally generated pilot channel codes
);

for sv = 1:numberOfChannels
    prn = sv_visible(sv);

    STR_FILE_CTRL(sv).DEBUG_LEVEL         = 2;
    STR_FILE_CTRL(sv).info                = [filepath,'_PRN',num2str(prn),'_info.txt'];
    % DEBUG_LEVEL==1
    STR_FILE_CTRL(sv).trk_carphs          = [filepath,'_PRN',num2str(prn),'_trk_carphs.bin'];
    STR_FILE_CTRL(sv).trk_carfreq         = [filepath,'_PRN',num2str(prn),'_trk_carfreq.bin'];
    STR_FILE_CTRL(sv).trk_timeaxis        = [filepath,'_PRN',num2str(prn),'_trk_timeaxis.bin'];
    % DEBUG_LEVEL==2
    STR_FILE_CTRL(sv).trk_cad_codphs_diff = [filepath,'_PRN',num2str(prn),'_trk_cad_codphs_diff.bin'];
    STR_FILE_CTRL(sv).trk_cad_codphs_diff_2 = [filepath,'_PRN',num2str(prn),'_trk_cad_codphs_diff_2.bin'];
    STR_FILE_CTRL(sv).trk_cad_ai          = [filepath,'_PRN',num2str(prn),'_trk_cad_ai.bin'];
    STR_FILE_CTRL(sv).trk_cad_aq          = [filepath,'_PRN',num2str(prn),'_trk_cad_aq.bin'];
    STR_FILE_CTRL(sv).unit_active_mt      = [filepath,'_PRN',num2str(prn),'_unit_active_mt.bin'];
    STR_FILE_CTRL(sv).unit_active_mt_2    = [filepath,'_PRN',num2str(prn),'_unit_active_mt_2.bin'];
    STR_FILE_CTRL(sv).CNR_AmpMoni_time    = [filepath,'_PRN',num2str(prn),'_CNR_AmpMoni_time'];
    STR_FILE_CTRL(sv).cad_trch_ai         = [filepath,'_PRN',num2str(prn),'_cad_trch_ai.bin'];
    STR_FILE_CTRL(sv).cad_trch_aq         = [filepath,'_PRN',num2str(prn),'_cad_trch_aq.bin'];
    STR_FILE_CTRL(sv).cad_trch_a_avg      = [filepath,'_PRN',num2str(prn),'_cad_trch_a_avg.bin'];
    STR_FILE_CTRL(sv).cad_trch_snr        = [filepath,'_PRN',num2str(prn),'_cad_trch_snr.bin'];
    STR_FILE_CTRL(sv).cad_trch_active     = [filepath,'_PRN',num2str(prn),'_cad_trch_active.bin'];
    STR_FILE_CTRL(sv).cad_trch_cnr        = [filepath,'_PRN',num2str(prn),'_cad_trch_cnr.bin'];
    STR_FILE_CTRL(sv).cad_trch_corrM_IQ   = [filepath,'_PRN',num2str(prn),'_cad_trch_corrM_IQ.bin'];
    STR_FILE_CTRL(sv).corrM_IQ            = [filepath,'_PRN',num2str(prn),'_corrM_IQ.bin'];
    STR_FILE_CTRL(sv).uncancelled_corrM_IQ= [filepath,'_PRN',num2str(prn),'_uncancelled_corrM_IQ.bin'];
    % DEBUG_LEVEL==3
    STR_FILE_CTRL(sv).trk_codphs          = [filepath,'_PRN',num2str(prn),'_trk_codphs.bin'];
    STR_FILE_CTRL(sv).trk_codfreq         = [filepath,'_PRN',num2str(prn),'_trk_codfreq.bin'];
    STR_FILE_CTRL(sv).Dch_T_IQ            = [filepath,'_PRN',num2str(prn),'_Dch_T_IQ.bin'];
    STR_FILE_CTRL(sv).cad_trch_codphs     = [filepath,'_PRN',num2str(prn),'_cad_trch_codphs.bin'];
    STR_FILE_CTRL(sv).cad_trch_codfreq    = [filepath,'_PRN',num2str(prn),'_cad_trch_codfreq.bin'];
    STR_FILE_CTRL(sv).cad_trch_codphs_diff= [filepath,'_PRN',num2str(prn),'_cad_trch_codphs_diff.bin'];
    STR_FILE_CTRL(sv).cad_trch_a_std      = [filepath,'_PRN',num2str(prn),'_cad_trch_a_std.bin'];
    STR_FILE_CTRL(sv).cad_trch_DchT_IQ    = [filepath,'_PRN',num2str(prn),'_cad_trch_DchT_IQ.bin'];
...    STR_FILE_CTRL(sv).cad_trch_PchT_IQ    = [filepath,'_PRN',num2str(prn),'_cad_trch_PchT_IQ.bin'];
    % DEBUG_LEVEL==4
    STR_FILE_CTRL(sv).Dch_Tslot_IQ        = [filepath,'_PRN',num2str(prn),'_Dch_Tslot_IQ.bin'];
...    STR_FILE_CTRL(sv).Pch_Tslot_IQ        = [filepath,'_PRN',num2str(prn),'_Pch_Tslot_IQ.bin'];
    % DEBUG_LEVEL==5
    STR_FILE_CTRL(sv).BBSig_I             = [filepath,'_PRN',num2str(prn),'_BBSig_I.bin'];
    STR_FILE_CTRL(sv).BBSig_Q             = [filepath,'_PRN',num2str(prn),'_BBSig_Q.bin'];
    STR_FILE_CTRL(sv).LO_Dch_Codes        = [filepath,'_PRN',num2str(prn),'_LO_Dch_Codes.bin'];
    STR_FILE_CTRL(sv).LO_Pch_Codes        = [filepath,'_PRN',num2str(prn),'_LO_Pch_Codes.bin'];
end

%% Normal units' corr func waveform and trail unit's
corr_movie = [];
corr_movie_tr = [];

%%
for n = 1:numberOfChannels
    [corr_movie, corr_movie_tr] = plot_pro2(STR_FILE_CTRL(n), 'BD_B1I', 'track', corr_movie, corr_movie_tr, sv_visible(n), corr_accu_times, plotCorrMovie);
    movie_path = ['.\corr_movie', '_PRN', num2str(sv_visible(n))];
    movie_path_tr = ['.\corr_movie_tr', '_PRN', num2str(sv_visible(n))];
  %  movie2avi(corr_movie, movie_path, 'FPS', 1, 'COMPRESSION', 'NONE');
  %  movie2avi(corr_movie_tr, movie_path_tr, 'FPS', 1, 'COMPRESSION', 'NONE');
end

