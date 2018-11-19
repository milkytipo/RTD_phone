%% This file is to plot.
function PlotTrackResults(recorder, syst, channel, time)

close all;

switch syst
    case 'BDS_B1I'
        codFreqBasis = 2.046;   %MHz
        PRNID = channel.CH_B1I.PRNID;
        if PRNID > 5
            accum_times = 50;
        else
            accum_times = 500;
        end
    case 'GPS_L1CA'
        codFreqBasis = 1.023;   %MHz
        PRNID = channel.CH_L1CA.PRNID;
        accum_times = 50;
    case 'GPS_L1CA_L2C'
        PRNID = channel.CH_L1CA_L2C.PRNID;
        trackPlot_L1L2(recorder,PRNID); %GPS双频绘图时使用
        return;
end

% CADUNIT_MAXMAX = 10;
global GSAR_CONSTANTS;
% Set a array of colors
colors = [
    [0.00, 0.00, 0.00]; ... black for compound signal
    [0.00, 0.45, 0.74]; ... light blue for default and LOS
    [0.64, 0.08, 0.18]; ... dark red for MP1
    [0.47, 0.67, 0.19]; ... light green for MP2
    [0.93, 0.69, 0.13]; ... dark yellow for MP3
    [0.49, 0.18, 0.56]; ... purple for MP4
    [0.08, 0.17, 0.55]; ... dark blue for MP5
    [1.00, 0.60, 0.78]; ... light red for MP6
    [0.00, 0.50, 0.00]; ... dark green for MP7
    [0.85, 0.70, 1.00]  ... light purple for MP8 
    ];

STATUS = channel.STATUS;
PLL_LOOPTYPE = channel.PLL.LoopType;
corr_accu_times = 1000;

% Read the the content of 'txt' file,including
% DEBUG_LEVEL,trk_est_N,trk_accTslot_IQ_N and trk_accT_IQ_N maybe.
if recorder.DEBUG_LEVEL>0

    [ data1, ~, data3 ] = textread( recorder.info, '%s %s %f' );

    if recorder.DEBUG_LEVEL~=data3(1)

        error('Error, check the programe please!');    
    end

    for i= 2:length(data3)
        
        if strcmp(data1(i),'CADUNIT_MAXMAX')
            CADUNIT_MAXMAX = round(data3(i));
            
        elseif strcmp(data1(i),'CadUnitMax')
            CadUnitMax = round(data3(i));
            
        elseif strcmp(data1(i),'bpSampling_OddFold')
            bpSampling_OddFold = data3(i);
            
        elseif strcmp(data1(i),'AThreLow1')
            AThreLow = data3(i);
            
        elseif strcmp(data1(i),'ADevThre')
            ADevThre = data3(i);
            
        elseif strcmp(data1(i),'CN0Thre')
            CN0Thre = data3(i);
            
        elseif strcmp(data1(i),'SNRThre1')
            SNRThre = data3(i);
            
        elseif strcmp(data1(i),'TrCN0Thre')
            TrCN0Thre = data3(i);
            
        elseif strcmp(data1(i),'TrSNRThre')
            TrSNRThre = data3(i);
            
        elseif strcmp(data1(i),'TrAmpThre')
            TrAmpThre = data3(i);
            
        elseif strcmp(data1(i),'trk_est_N')
            trk_est_N = round(data3(i));
            
        elseif strcmp(data1(i),'corrM_N')
            corrM_N = round(data3(i));
            
        elseif strcmp(data1(i), 'corrM_N_valid')
            corrM_N_valid = round(data3(i));
            
        elseif strcmp(data1(i), 'cnr_moniamp_time_N')
            cnr_moniamp_time_N = round(data3(i));
        
        elseif strcmp(data1(i),'cad_trch_cnr_N')
            cad_trch_cnr_N = round(data3(i));
            
        elseif strcmp(data1(i),'kalman_filter_results_N')
            kalman_filter_results_N = round(data3(i));

        elseif  strcmp(data1(i),'BBSig_I_N')
            BBSig_I_N = round(data3(i));

        elseif  strcmp(data1(i),'BBSig_Q_N')
            BBSig_Q_N = round(data3(i));   

        elseif  strcmp(data1(i),'LO_Dch_Codes_N')
            LO_Dch_Codes_N = round(data3(i));

        elseif  strcmp(data1(i),'LO_Pch_Codes_N')
            LO_Pch_Codes_N = round(data3(i));
            
        elseif strcmp(data1(i), 'corrM_Num')
            corrM_Num = round(data3(i));
            
        elseif strcmp(data1(i), 'corrM_Spacing')
            corrM_Spacing = round(data3(i));
        end
    end
end

%% DEBUG_LEVEL 1 Plotting
if (recorder.DEBUG_LEVEL > 0)
    if strcmp(STATUS,'TRACK')||strcmp(STATUS,'PULLIN')||strcmp(STATUS,'SUBFRAME_SYNCED')||strcmp(STATUS,'HOT_PULLIN')
        %-----time axis------%
        fd = fopen(recorder.trk_timeaxis,'r');
        [trk_timeaxis,cntout] = fread(fd, trk_est_N, 'double');
        fclose(fd);
        
        %-----carrier phase----%
        fd = fopen(recorder.trk_carphs,'r');
        [trk_carphs,cntout] = fread(fd, trk_est_N, 'double');
        fclose(fd);
        figure('Name',['PRN_', num2str(PRNID),' CarrPhs']), plot(trk_timeaxis, trk_carphs*360, 'color', colors(2, :)), xlabel('time [s]'), ylabel('degree');
        title('PLL Discriminator Output');
        
        %-----carrier freq-----%
        fd = fopen(recorder.trk_carfreq,'r');
        [trk_carfreq,cntout] = fread(fd, trk_est_N, 'double');
        fclose(fd);
        figure('Name','CarrDoppler'), plot(trk_timeaxis, bpSampling_OddFold*trk_carfreq, 'color', colors(2, :)), xlabel('time [s]'), ylabel('Hz');
        title('Carr Doppler Freq');
    end
end

%% DEBUG_LEVEL 2 Plotting
if (recorder.DEBUG_LEVEL > 1 && trk_est_N > 0)   
    if strcmp(STATUS,'TRACK')||strcmp(STATUS,'PULLIN')||strcmp(STATUS,'SUBFRAME_SYNCED')||strcmp(STATUS,'HOT_PULLIN')
        %------- Unit Active Flag Matrix -------%
        fd = fopen(recorder.unit_active_mt,'r');
        [unit_active_mt,cntout] = fread(fd, [CADUNIT_MAXMAX, trk_est_N], 'uchar');
        fclose(fd);
        
        figure_num = valid_figure_num_counting_plotprepare(unit_active_mt, CadUnitMax);
        
%         %-----code phase diff_cad-----%
%         fd = fopen(recorder.trk_cad_codphs_diff,'r');
%         cad_codphs_diff_units = zeros(CadUnitMax-1, trk_est_N);
%         for i = 1:(CadUnitMax-1)
%             fseek(fd, 8*(i-1), -1);
%             [cad_codphs_diff_units(i,:),cntout] = fread(fd, trk_est_N, '1*double', (CADUNIT_MAXMAX-2)*8);
%         end
%         fclose(fd);
%         trk_results_plot(trk_timeaxis, -cad_codphs_diff_units*1e3/codFreqBasis, unit_active_mt(2:CadUnitMax,:), ...
%             CadUnitMax-1, 0, 'time [s]', 'ns', 'Code Phase Delay of MP Unit');
        
        %-----Unit amplitude of CADLL-----%
        %IA
        fd = fopen(recorder.trk_cad_ai,'r');
        cad_ai_units = zeros(CadUnitMax, trk_est_N);
        for i = 1:CadUnitMax
            fseek(fd, 8*(i-1), -1);
            [cad_ai_units(i,:),cntout] = fread(fd, trk_est_N, '1*double', (CADUNIT_MAXMAX-1)*8);
        end
        fclose(fd);
        
        %QA
        fd = fopen(recorder.trk_cad_aq,'r');
        cad_aq_units = zeros(CadUnitMax, trk_est_N);
        for i = 1:CadUnitMax
            fseek(fd, 8*(i-1), -1);
            [cad_aq_units(i,:),cntout] = fread(fd, trk_est_N, '1*double', (CADUNIT_MAXMAX-1)*8);
        end
        fclose(fd);
        
        h=figure('Name', 'Amplitude');
        %Plot norm of A
        hx = subplot(4,1,1);
        trk_results_plot_1(hx, figure_num, trk_timeaxis, abs(cad_ai_units(1:CadUnitMax, :)+1i*cad_aq_units(1:CadUnitMax, :)),...
                           unit_active_mt(1:CadUnitMax,:), CadUnitMax, 0, [], [], 'Norm Amplitude', [], colors);
        
        %Plot i component of A
        hx = subplot(4,1,2);
        trk_results_plot_1(hx, figure_num, trk_timeaxis, cad_ai_units(1:CadUnitMax, :),...
                           unit_active_mt(1:CadUnitMax,:), CadUnitMax, 0, [], [], 'I Channel Amplitude', [], colors);
        
        %Plot q component of A
        hx = subplot(4,1,3);
        trk_results_plot_1(hx, figure_num, trk_timeaxis, cad_aq_units(1:CadUnitMax, :),...
                           unit_active_mt(1:CadUnitMax,:), CadUnitMax, 0, 'time,[s]', [], 'Q Channel Amplitude',[], colors);
        
%        cad_aphase_units = cad_aq_units ./ cad_ai_units;
        cad_aphase_units = atan2(cad_aq_units, cad_ai_units);
        cad_aphase_units = cad_aphase_units ./pi * 180;
        hx = subplot(4,1,4);
        trk_results_plot_1(hx, figure_num, trk_timeaxis, cad_aphase_units(1:CadUnitMax, :),...
                           unit_active_mt(1:CadUnitMax,:), CadUnitMax, 0, 'time,[s]', [], 'Phase', [], colors);
        
        %----- Units CN0, aratio, astd SNR Plotting -------
        if cnr_moniamp_time_N>0
            fd = fopen(recorder.CNR_AmpMoni_time, 'r');
            [cad_cnr_ampmoni_time, cntout] = fread(fd, [2+CADUNIT_MAXMAX*4, cnr_moniamp_time_N], 'double');
            cad_cnr_ampmoni_time = cad_cnr_ampmoni_time(1:2+CadUnitMax*4, :);
            fclose(fd);
            
            cad_cnr_ampmoni_time = cad_cnr_ampmoni_time';  %Transpose the matrix
            ever_active_units_num = figure_num; %the number of units ever active, which means the number of curves to be plotted
            
            time1 = cad_cnr_ampmoni_time(:,1);
            std_ns1 = cad_cnr_ampmoni_time(:,2);
            cnr1 = cad_cnr_ampmoni_time(:,3);
            aratio1 = cad_cnr_ampmoni_time(:,4);
            SNR1 = cad_cnr_ampmoni_time(:,5);
            astd1 = cad_cnr_ampmoni_time(:,6);
            
            for i=2:CadUnitMax % Unit1 ~ Unit_(CadUnitMax-1); Unit0 is defauled active
                if sum(unit_active_mt(i,:)) % which means current unit was ever actived
                    tmp = cad_cnr_ampmoni_time(:, 2+(i-1)*4+1); % unit1's cnr
                    L = tmp == -1;
                    tmp(L) = 0;
                    cnr1 = [cnr1, tmp];
                    
                    tmp = cad_cnr_ampmoni_time(:, 2+(i-1)*4+2); % unit1's aratio
                    L = tmp == -1;
                    tmp(L) = 0;
                    aratio1 = [aratio1, tmp];
                    
                    tmp = cad_cnr_ampmoni_time(:, 2+(i-1)*4+3); % unit1's SNR
                    L = tmp == -1;
                    tmp(L) = 0;
                    SNR1 = [SNR1, tmp];
                    
                    tmp = cad_cnr_ampmoni_time(:, 2+(i-1)*4+4); % unit1's std ratio to noise's std
                    L = tmp == -1;
                    tmp(L) = 0;
                    astd1 = [astd1, tmp];
                end
            end
            
            scrsz = get(0,'ScreenSize');
            h = figure('Name','CN0_aratio_astd_SNR', 'Position', [scrsz(3)/8 scrsz(4)/8 scrsz(3)*6/8 scrsz(4)*6/8]);
            
            hx = subplot(2,6,[1 3]);  %For CN0
            b = bar(hx, time1, cnr1, 'grouped'); % colormap(colors(2:end, :));
            for i = 1 : length(b)
                set(b(i), 'FaceColor', colors(i + 1, :));
            end
            title('Normal Units'' CN0'); xlabel('time,[s]'), ylabel('dB-Hz');
            hold on; plot(hx, time1, repmat(CN0Thre, cnr_moniamp_time_N, 1));
            AddTags(ever_active_units_num,0);
            
            hx = subplot(2,6,[4 6]);  %For SNR
            b = bar(hx, time1, SNR1, 'grouped'); % colormap(colors(2:end, :));
            for i = 1 : length(b)
                set(b(i), 'FaceColor', colors(i + 1, :));
            end
            title('Normal Units'' SNR'); xlabel('time,[s]'), ylabel('[db]');
            hold on; plot(hx, time1, repmat(SNRThre, cnr_moniamp_time_N,1));
            
            if ever_active_units_num>1
                hx=subplot(2,6,[7 8]);  %For aratio
                b = bar(hx, time1, aratio1(:, 2:end), 'grouped'); % colormap(colors(2:end, :));
                for i = 1 : length(b)
                    set(b(i), 'FaceColor', colors(i + 2, :));
                end
                title('Amplitude ratio to LOS'); xlabel('time,[s]');
                hold on; plot(hx, time1, repmat(AThreLow, cnr_moniamp_time_N, 1));
            end
            
            hx = subplot(2,6,[9 10]);  % For std ratio
            b = bar(hx, time1, astd1, 'grouped'); % colormap(colors(2:end, :));\
            for i = 1 : length(b)
                set(b(i), 'FaceColor', colors(i + 1, :));
            end
            title('Standard deviation ratio to noise'); xlabel('time,[s]');
            hold on; plot(hx, time1, repmat(ADevThre, cnr_moniamp_time_N,1));
            
            hx = subplot(2,6,[11 12]);  % For noise std
            b = bar(hx, time1, std_ns1, 'grouped'); % colormap(colors(2:end, :));
            for i = 1 : length(b)
                set(b(i), 'FaceColor', colors(i, :));
            end
            title('Noise''s standard deviation'); xlabel('time,[s]');
        end
        
        % read the trial_unit_active file
        fd = fopen(recorder.cad_trch_active,'r');
        [cad_trch_active,cntout] = fread(fd, trk_est_N, 'uchar');
        fclose(fd);
        
        % Plot trial unit's codephase error, codphs_diff, amplitude, accumulates, estimated CN0
        if sum(cad_trch_active)
        %-   Read and plot trial unit's code phase discriminator output
    
            scrsz = get(0,'ScreenSize');
            h = figure('Name','Trail\_CH', 'Position', [scrsz(3)/8 scrsz(4)/8 scrsz(3)*6/8 scrsz(4)*6/8]);
    
            %-- Read and plot trial unit's i and q channels amplitude
%             fd = fopen(recorder.cad_trch_ai,'r');
%             [cad_trch_ai, cntout] = fread(fd, trk_est_N, 'double');
%             fclose(fd);
    
%             fd = fopen(recorder.cad_trch_aq,'r');
%             [cad_trch_aq, cntout] = fread(fd, trk_est_N, 'double');
%             fclose(fd);
%             cad_trch_a = [abs((cad_trch_ai+1i*cad_trch_aq)'); cad_trch_ai'; cad_trch_aq'];
    
%             hx=subplot(2,2,1);
%             legend_str = {'|a|','ai','aq'};
%             trk_results_plot_1(hx, 1, trk_timeaxis, cad_trch_a, repmat(cad_trch_active',3,1), 3, 0, ...
%                 'time, [s]', [], 'Tr\_CH Amplitude', legend_str, colors);
    
%             cad_trch_aphase = atan2(cad_trch_aq, cad_trch_ai);
%             cad_trch_aphase = cad_trch_aphase' ./pi * 180;
% 
%             hx = subplot(2,2,2);
%             trk_results_plot_1(hx, 1, trk_timeaxis, cad_trch_aphase, cad_trch_active', 1, 0, ...
%                 'time, [s]', [], 'Tr\_CH Phase', [], colors);

            if cad_trch_cnr_N > 0
                %-- Read and plot trial unit's CN0 --%
                fd = fopen(recorder.cad_trch_cnr,'r');
                [cad_trch_time_CN0, cntout] = fread(fd, [2, cad_trch_cnr_N], 'double');
                fclose(fd);
    
                %-- Read and plot trail unit's amplitude average --%
                fd = fopen(recorder.cad_trch_a_avg, 'r');
                [cad_trch_a_avg, cntout] = fread(fd, cad_trch_cnr_N, 'double');
                fclose(fd);
    
                hx = subplot(2,2,1);
                b = bar(hx, cad_trch_time_CN0(1,:), cad_trch_a_avg); % colormap(colors(2:end, :));
                for i = 1 : length(b)
                    set(b(i), 'FaceColor', colors(i + 1, :));
                end
                hold on; plot(hx, cad_trch_time_CN0(1,:), repmat(TrAmpThre,1,cad_trch_cnr_N));
                title('Tr\_CH Amplitude to LOS Amplitude ratio'); xlabel('time,[s]'), ylabel('amp');
        
                %-- Read and plot trial unit's SNR --%
                fd = fopen(recorder.cad_trch_snr, 'r');
                [cad_trch_snr, cntout] = fread(fd, cad_trch_cnr_N, 'double');
                fclose(fd);
        
                hx = subplot(2,2,2);
                b = bar(hx, cad_trch_time_CN0(1,:), cad_trch_snr); % colormap(colors(2:end, :));
                for i = 1 : length(b)
                    set(b(i), 'FaceColor', colors(i + 1, :));
                end
                hold on; plot(hx, cad_trch_time_CN0(1,:), repmat(TrSNRThre,1,cad_trch_cnr_N));
                title('Tr_CH SNR'); xlabel('time,[s]'), ylabel('SNR,[db]');
        
            end
    
            %--- Read and plot trial unit's correlation function ---%
            fd = fopen(recorder.cad_trch_corrM_IQ, 'r');
    
            corrM_spacing = (-(corrM_Num-1)/2 :1: (corrM_Num-1)/2)*corrM_Spacing * codFreqBasis * 1e6 / GSAR_CONSTANTS.STR_RECV.fs;%x axis
        
            h3 = subplot(2,2,3);hold on; grid on; % figure('Name','Trail CorrShapes'); 
    
            corrM_all = fread(fd, [2*corrM_Num, trk_est_N], 'double'); % read all data
            rec_valid = find(sum(abs(corrM_all), 1)~=0); % get position of non-zero column
            len_valid = length(rec_valid); % number of non-zero column, valid column
            Avg_Num2 = min(len_valid, accum_times);
            corrM_Tr = zeros(2*corrM_Num, Avg_Num2);
    
            if len_valid > Avg_Num2
                for t = 1:Avg_Num2
                    corrM_Tr(:,t) = corrM_all(:,rec_valid(len_valid-Avg_Num2+t));
                end
            else
                for t = 1:Avg_Num2
                    corrM_Tr(:,t) = corrM_all(:,rec_valid(t));
                end
            end
            
            corrM_Tr = abs(corrM_Tr(1:corrM_Num,:) + 1i*corrM_Tr(corrM_Num+1:2*corrM_Num,:));
    
            corrM_Tr1 = mean(corrM_Tr, 2); % get mean value of each row
            corrM_Tr2 = corrM_Tr1(2:2:corrM_Num-1);
            corrM_Tr3 = corrM_Tr1(3:2:corrM_Num);
            corrM_Tr1 = [flipud(corrM_Tr2); corrM_Tr1(1); corrM_Tr3];
            
            plot(corrM_spacing, corrM_Tr1, 'color', colors(2, :));
            xlabel('Tc'); title('Trail Channel'' Correlation Functions'); 
            
            fclose(fd);
    
        end % EOF "if sum(cad_trch_active)"
        
                %%
        % save Correlation Functions' log file
%         if figure_num>1
%            rinexCorrFun_header(PRNID,time,figure_num);
%         end

        %%
        % --- Draw correlation function's waveform --- %
        if recorder.isCorrShapeStore
        % Read code phase diff first
        fd = fopen(recorder.trk_cad_codphs_diff_2, 'r');
        cad_codphs_diff_units_2 = zeros(CadUnitMax-1, corrM_N);
        for i = 1:(CadUnitMax-1)
            fseek(fd, 8*(i-1), -1);
            [cad_codphs_diff_units_2(i,:), cntout] = fread(fd, corrM_N, '1*double', (CADUNIT_MAXMAX-2)*8);
        end
        fclose(fd);
        cad_codphs_diff_units_3 = cad_codphs_diff_units_2(:, (corrM_N - corrM_N_valid + 1) : corrM_N);
        
        fd = fopen(recorder.unit_active_mt_2,'r');
        [unit_active_mt_2,cntout] = fread(fd, [CADUNIT_MAXMAX, corrM_N], 'uchar');
        fclose(fd);
        unit_active_mt_3 = unit_active_mt_2(:, (corrM_N - corrM_N_valid + 1) : corrM_N);
        
        fd = fopen(recorder.corrM_IQ, 'r');
        fd1 = fopen(recorder.uncancelled_corrM_IQ, 'r');
    
        cad_codphs_diff_units_3 = [zeros(1, corrM_N_valid); cad_codphs_diff_units_3];%(CADUNIT_MAXMAX, trk_est_N)
        corrM_spacing = (-(corrM_Num-1)/2 :1: (corrM_Num-1)/2)*corrM_Spacing * codFreqBasis * 1e6 / GSAR_CONSTANTS.STR_RECV.fs;% Set x axis
        
        h = figure('Name','CorrShapes'); hold on; grid on;
        Avg_Num = min(corrM_N_valid, corr_accu_times);
        legstr = 0;
        for i=1:figure_num
            if sum(unit_active_mt_3(i, (corrM_N_valid - Avg_Num + 1) : corrM_N_valid)) % the last Avg_Num points
            
                if corrM_N_valid > Avg_Num % corrM_N_valid > 50(or 500), and Avg_Num = 50(or 500)
                    corrM = zeros(2 * corrM_Num, Avg_Num);
                    fseek(fd, 2 * corrM_Num * (i - 1 + CADUNIT_MAXMAX * (corrM_N - Avg_Num)) * 8, 'bof'); % skip the data out of range
                    codphs1 = -mean(cad_codphs_diff_units_3(i, corrM_N_valid - Avg_Num + 1 : corrM_N_valid), 2); % mean of row
                    RT = Avg_Num;
                else
                    corrM = zeros(2 * corrM_Num, corrM_N_valid);
                    fseek(fd, 2 * corrM_Num * (i - 1 + CADUNIT_MAXMAX * (corrM_N - corrM_N_valid)) * 8, 'bof');
                    codphs1 = -mean(cad_codphs_diff_units_3(i, :), 2);
                    RT = corrM_N_valid;
                end
            
                for t=1:RT
                    corrM(:, t) = fread(fd, [2 * corrM_Num, 1], 'double');
                    fseek(fd, 2 * corrM_Num * (CADUNIT_MAXMAX - 1) * 8, 'cof');
                end
            
                corrM = abs(corrM(1:corrM_Num,:) + 1i*corrM(corrM_Num+1:2*corrM_Num,:));
            
                corrM1 = mean(corrM, 2);
                corrM2 = corrM1(2:2:corrM_Num-1);
                corrM3 = corrM1(3:2:corrM_Num);
                corrM1 = [flipud(corrM2); corrM1(1); corrM3];
                
                plot(corrM_spacing + codphs1, corrM1, 'color', colors(i + 1, :));
%                 if figure_num>1
%                     rinexCorrFun_data(corrM_spacing + codphs1, corrM1);  %%%记录log文件
%                 end
                legstr = legstr+1;
            end
        end
    
        % Draw the original uncancelled signal's corr func
        if corrM_N_valid > Avg_Num
            corrM = zeros(2*corrM_Num, Avg_Num);
            fseek(fd1, 2*corrM_Num*(corrM_N - Avg_Num)*8, 'bof');
            RT = Avg_Num;
        else
            corrM = zeros(2*corrM_Num, corrM_N_valid); % From the beginning of the file
            fseek(fd1, 2 * corrM_Num * (corrM_N - corrM_N_valid) * 8, 'bof');
%         fseek(fd1,2*corrM_Num*(j-1)*accum_times*8, 'bof');
            RT = corrM_N_valid;
        end
            
        for t=1:RT
            corrM(:,t) = fread(fd1, [2*corrM_Num, 1], 'double');
        end
            
        corrM = abs(corrM(1:corrM_Num,:) + 1i*corrM(corrM_Num+1:2*corrM_Num,:));
            
        corrM1 = mean(corrM, 2);
        corrM2 = corrM1(2:2:corrM_Num-1);
        corrM3 = corrM1(3:2:corrM_Num);
        corrM1 = [flipud(corrM2); corrM1(1); corrM3];
                
        plot(corrM_spacing, corrM1, 'color', colors(1, :));
%         if figure_num>1
%             rinexCorrFun_data(corrM_spacing, corrM1);  %%%记录log文件
%         end
        xlabel('Tc'); title('Correlation Functions');
        AddTags(legstr, 0);
        fclose(fd);
        fclose(fd1);
 %      rinexCorrFun_data(recv_time,rawP,inte_dopp,dopplerfre,CNR,xyzdt(4),queue);
        end%EOF "if recorder.isCorrShapeStore"
        
        %-----code phase diff_cad-----%
        fd = fopen(recorder.trk_cad_codphs_diff,'r');
        cad_codphs_diff_units = zeros(CadUnitMax-1, trk_est_N);
        for i = 1:(CadUnitMax-1)
            fseek(fd, 8*(i-1), -1);
            [cad_codphs_diff_units(i,:),cntout] = fread(fd, trk_est_N, '1*double', (CADUNIT_MAXMAX-2)*8);
        end
        fclose(fd);
        trk_results_plot(trk_timeaxis, -cad_codphs_diff_units*1e3/codFreqBasis, unit_active_mt(2:CadUnitMax,:), ...
            CadUnitMax-1, 0, 'time [s]', 'ns', 'Code Phase Delay of MP Unit', colors(2:end, :));

    
        
    end
end
%% DEBUG_LEVEL 3 Plotting
if (recorder.DEBUG_LEVEL > 2 && trk_est_N > 0)
    
    if strcmp(STATUS,'TRACK')||strcmp(STATUS,'PULLIN')||strcmp(STATUS,'SUBFRAME_SYNCED')||strcmp(STATUS,'HOT_PULLIN')
%     CHtr_Max = 1;        
        %-----code phase-----%
        fd = fopen(recorder.trk_codphs,'r');
        codphs_units = zeros(CadUnitMax, trk_est_N);
        for i = 1:CadUnitMax
            fseek(fd, 8*(i-1), -1);
%             [temp,cntout] = fread(fd, trk_est_N, '1*double', (CADUNIT_MAXMAX-1)*8);
            [codphs_units(i,:),cntout] = fread(fd, trk_est_N, '1*double', (CADUNIT_MAXMAX-1)*8);
%             eval(['trk_codphs_unit_',num2str(i-1),'=temp;']);
        end
        fclose(fd);
        trk_results_plot(trk_timeaxis, codphs_units, unit_active_mt(1:CadUnitMax,:), CadUnitMax, 1, ...
            'time [s]', 'Tc', 'DLL Discriminator Output of Unit', colors);
        
        %-----code freq-----%
        fd = fopen(recorder.trk_codfreq,'r');
        codfreq_units = zeros(CadUnitMax, trk_est_N);
        for i = 1:CadUnitMax
            fseek(fd, 8*(i-1), -1);
%             [temp,cntout] = fread(fd, trk_est_N, '1*double', 72);
            [codfreq_units(i,:), cntout] = fread(fd, trk_est_N, '1*double', (CADUNIT_MAXMAX-1)*8);
%             eval(['trk_codfreq_unit_',num2str(i-1),'=temp;']);
        end
        fclose(fd);
        trk_results_plot(trk_timeaxis, codfreq_units, unit_active_mt(1:CadUnitMax,:), CadUnitMax, 1, 'time [s]', 'Hz', 'Code Doppler Freq of Unit', colors);
        
        %--------- Kalman tracking loop results -------------%
      if strcmp(PLL_LOOPTYPE,'KALMAN')
        fd = fopen(recorder.kalman_filter_results, 'r');
        kalfilt_results = fread(fd, [12,trk_est_N], 'double');
        fclose(fd);
        figure;
        subplot(3,4,1); % plotting estimated dtau 
        plot(trk_timeaxis, kalfilt_results(1,:)), ylabel('dtau [chips]'), title('Code-phs error, state(1)');
        subplot(3,4,2); % plotting estimated dcarrphs 
        plot(trk_timeaxis, kalfilt_results(2,:)*360), ylabel('dcarrphs [degree]'), title('Carr-phs error, state(2)');
        subplot(3,4,3); % plotting estimated dDopplar 
        plot(trk_timeaxis, kalfilt_results(3,:)), ylabel('dDopplar [Hz]'), title('Dopplar error, state(3)');
        subplot(3,4,4); % plotting estimated dAcceleration 
        plot(trk_timeaxis, kalfilt_results(4,:)), ylabel('dAcceleration [Hz/s]'), title('Acceleration error, state(4)');
        
        subplot(3,4,5); % plotting Kalman gain 1, gain for tau 
        plot(trk_timeaxis, kalfilt_results(5,:)), title('tau Kalman gain, K(1)');
        subplot(3,4,6); % plotting Kalman gain 2, gain for carrier phase 
        plot(trk_timeaxis, kalfilt_results(6,:)), title('Carr-phs Kalman gain, K(2)');
        subplot(3,4,7); % plotting Kalman gain 3, gain for Doppler frequency 
        plot(trk_timeaxis, kalfilt_results(7,:)), title('Doppler Kalman gain, K(3)');
        subplot(3,4,8); % plotting Kalman gain 4, gain for acceleration 
        plot(trk_timeaxis, kalfilt_results(8,:)), title('Acceleration gain, K(4)');
        
        subplot(3,4,9); % plotting Kalman P1, variance for dtau 
        plot(trk_timeaxis, kalfilt_results(9,:)), xlabel('time [s]'), title('P\_tau, P(1)');
        subplot(3,4,10); % plotting Kalman P2, variance for dcarrphs 
        plot(trk_timeaxis, kalfilt_results(10,:)), xlabel('time [s]'), title('P\_carrphs, P(2)');
        subplot(3,4,11); % plotting Kalman P3, variance for dDoppler 
        plot(trk_timeaxis, kalfilt_results(11,:)), xlabel('time [s]'), title('P\_Doppler, P(3)');
        subplot(3,4,12); % plotting Kalman P4, variance for dAcceleration 
        plot(trk_timeaxis, kalfilt_results(12,:)), xlabel('time [s]'), title('P\_acceleration, P(4)');
      end
    
        %-----Unit Accumulation values-----%
        fd = fopen(recorder.Dch_T_IQ,'r');
        Dch_TIQ_units = zeros(CadUnitMax, 2*trk_est_N);
        for i = 1:CadUnitMax
            fseek(fd, 2*8*(i-1), 'bof');
            [Dch_TIQ_units(i,:),cntout] = fread(fd, 2*trk_est_N, '2*double', 2*(CADUNIT_MAXMAX-1)*8);
        end
        fclose(fd);
        
        figure,
        for i = 1:CadUnitMax
            if sum( unit_active_mt(i,:) )
                subplot(figure_num,1,i);
                tiq_unit = reshape(Dch_TIQ_units(i,:), 2, trk_est_N);
                plot(trk_timeaxis(unit_active_mt(i,:)==1), tiq_unit(1,unit_active_mt(i,:)==1), 'color', colors(i + 1, :));
                hold on;
                plot(trk_timeaxis(unit_active_mt(i,:)==1), tiq_unit(2,unit_active_mt(i,:)==1), 'color', colors(i + 2, :));
            end
        end
        
    end
end
%% DEBUG_LEVEL 3 Plotting
if( recorder.DEBUG_LEVEL>2 )
  
    if strcmp(STATUS,'TRACK')||strcmp(STATUS,'PULLIN')||strcmp(STATUS,'SUBFRAME_SYNCED')||strcmp(STATUS,'HOT_PULLIN')
    
    
    
    
%     fd = fopen(STR_FILE_CTRL.Dch_Tslot_IQ,'r');
%     [Dch_Tslot_IQ,cntout] = fread(fd, trk_accTslot_IQ_N, 'double');
%     fclose(fd);
%     figure,subplot(2,1,1);
%     plot( Dch_Tslot_IQ(1:2:trk_accTslot_IQ_N) ), title('Data Tslot_I Correlator');
%     subplot(2,1,2);
%     plot( Dch_Tslot_IQ(2:2:trk_accTslot_IQ_N) ), title('Data Tslot_Q Correlator');
% 
%     if strcmp(SYST , 'GPS_L2C')
%         fd = fopen(STR_FILE_CTRL.Pch_Tslot_IQ,'r');
%         [Pch_Tslot_IQ,cntout] = fread(fd, trk_accTslot_IQ_N, 'double');
%         fclose(fd);
%         figure,subplot(2,1,1);
%         plot( Pch_Tslot_IQ(1:2:trk_accTslot_IQ_N) ), title('Pilot Tslot_I Correlator');
%         subplot(2,1,2);
%         plot( Pch_Tslot_IQ(2:2:trk_accTslot_IQ_N) ), title('Pilot Tslot_Q Correlator');
%     end
    end
end
%% DEBUG_LEVEL 5 Plotting
if( recorder.DEBUG_LEVEL>4 )   
    if strcmp(STATUS,'TRACK')||strcmp(STATUS,'PULLIN')||strcmp(STATUS,'SUBFRAME_SYNCED')||strcmp(STATUS,'HOT_PULLIN')
        fd = fopen(recorder.BBSig_I,'r');
        [BBSig_I,cntout] = fread(fd, BBSig_I_N, 'double');
        fclose(fd);
        figure,subplot(2,1,1);
        plot( BBSig_I(1:cntout) ), title('BBSig_I data');
        fd = fopen(recorder.BBSig_I,'r');
        [BBSig_Q,cntout] = fread(fd, BBSig_Q_N, 'double');
        fclose(fd);    
        subplot(2,1,2);
        plot( BBSig_Q(1:cntout) ), title('BBSig_Q data');

        fd = fopen(recorder.LO_Dch_Codes,'r');
        [LO_Dch_Codes,cntout] = fread(fd, LO_Dch_Codes_N, 'schar');
        fclose(fd);
        figure, plot(LO_Dch_Codes), title('local Data channel code');

        if strcmp(syst , 'GPS_L2C')
            fd = fopen(recorder.LO_Pch_Codes,'r');
            [LO_Pch_Codes,cntout] = fread(fd, LO_Pch_Codes_N, 'schar');
            fclose(fd);
            figure, plot(LO_Pch_Codes), title('local Pilot channel code');
        end    
    end
end

