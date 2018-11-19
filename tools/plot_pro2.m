% This file is to plot.
function [corr_movie, corr_movie_tr] = plot_pro2(STR_FILE_CTRL, SYST, STATUS, corr_movie, corr_movie_tr, PRNID, corr_accu_times, plotCorrMovie)

global STR_Constants;
STR_Constants = GlobalConstants();

%set a array of colors
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


switch SYST
    case 'BD_B1I'
        CodFreqBasis = 2.046;   %MHz
    case 'GPS_CA'
        CodFreqBasis = 1.023;   %MHz
    case 'GPS_L2C'
        CodFreqBasis = 1.023;   %MHz
end

if PRNID > 5
    accum_times = 50;
else
    accum_times = 500;
end

% Read the the content of 'txt' file,including
% DEBUG_LEVEL,trk_est_N,trk_accTslot_IQ_N and trk_accT_IQ_N maybe.
if STR_FILE_CTRL.DEBUG_LEVEL>0
    
    fd = fopen(STR_FILE_CTRL.info, 'r');
    data = textscan(fd, '%s %s %f');
    fclose(fd);
    
    data1 = data{1,1};
    data3 = data{1,3};

    if STR_FILE_CTRL.DEBUG_LEVEL~=data3(1)

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
            
        elseif strcmp(data1(i), 'cnr_moniamp_time_N')
            cnr_moniamp_time_N = round(data3(i));
        
        elseif strcmp(data1(i),'cad_trch_cnr_N')
            cad_trch_cnr_N = round(data3(i));

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
if( STR_FILE_CTRL.DEBUG_LEVEL>0 )   
    
    if strcmp(STATUS,'track')||strcmp(STATUS,'pullin')||strcmp(STATUS,'track_ini')||strcmp(STATUS,'towsynced')
        %-----time axis------%
        fd = fopen(STR_FILE_CTRL.trk_timeaxis,'r');
        [trk_timeaxis,cntout] = fread(fd, trk_est_N, 'double');
        fclose(fd);
        
        %-----carrier phase----%
        fd = fopen(STR_FILE_CTRL.trk_carphs,'r');
        [trk_carphs,cntout] = fread(fd, trk_est_N, 'double');
        fclose(fd);
        figure('Name', ['PRN_', num2str(PRNID), ' CarrPhs']), plot(trk_timeaxis, trk_carphs*360), xlabel('time [s]'), ylabel('degree');
        title('PLL Discriminator Output');
        
        %-----carrier freq-----%
        fd = fopen(STR_FILE_CTRL.trk_carfreq,'r');
        [trk_carfreq,cntout] = fread(fd, trk_est_N, 'double');
        fclose(fd);
        figure('Name', ['PRN_', num2str(PRNID), 'CarrDoppler']), plot(trk_timeaxis, bpSampling_OddFold*trk_carfreq), xlabel('time [s]'), ylabel('Hz');
        title('Carr Doppler Freq');
        
    end
end
%% DEBUG_LEVEL 2 Plotting
if( STR_FILE_CTRL.DEBUG_LEVEL>1 )
    
    if strcmp(STATUS,'track')||strcmp(STATUS,'pullin')||strcmp(STATUS,'track_ini')||strcmp(STATUS,'towsynced')
%     CHtr_Max = 1;
    
    %******************** Multiple Units Plotting *******************
        %------- Unit Active Flag Matrix -------
        fd = fopen(STR_FILE_CTRL.unit_active_mt,'r');
        [unit_active_mt,cntout] = fread(fd, [CADUNIT_MAXMAX, trk_est_N], 'uchar');
        fclose(fd);
        
        figure_num = valid_figure_num_counting_plotprepare(unit_active_mt, CadUnitMax);
        
        %-----code phase diff_cad-----%
        fd = fopen(STR_FILE_CTRL.trk_cad_codphs_diff,'r');
        cad_codphs_diff_units = zeros(CadUnitMax-1, trk_est_N);
        for i = 1:(CadUnitMax-1)
            fseek(fd, 8*(i-1), -1);
%             [temp,cntout] = fread(fd, trk_est_N, '1*double', 64);
            [cad_codphs_diff_units(i,:),cntout] = fread(fd, trk_est_N, '1*double', (CADUNIT_MAXMAX-2)*8);
%             eval(['trk_cad_codphs_diff_unit_',num2str(i),'= (-temp)*1e3/2.046;']);
        end
        fclose(fd);
        trk_results_plot(trk_timeaxis, -cad_codphs_diff_units*1e3/2.046, unit_active_mt(2:CadUnitMax,:), CadUnitMax-1, 0, ...
            'time [s]', 'ns', ['PRN\_', num2str(PRNID), ' Code Phase Delay of MP Unit'], colors(2:end, :));
        
        
        %-----Unit amplitude of CADLL-----%
        %IA
        fd = fopen(STR_FILE_CTRL.trk_cad_ai,'r');
        cad_ai_units = zeros(CadUnitMax, trk_est_N);
        for i = 1:CadUnitMax
            fseek(fd, 8*(i-1), -1);
%             [temp,cntout] = fread(fd, trk_est_N, '1*double', 72);
            [cad_ai_units(i,:),cntout] = fread(fd, trk_est_N, '1*double', (CADUNIT_MAXMAX-1)*8);
%             eval(['trk_cad_ai_unit_',num2str(i-1),'=temp;']);
        end
        fclose(fd);
        
        %QA
        fd = fopen(STR_FILE_CTRL.trk_cad_aq,'r');
        cad_aq_units = zeros(CadUnitMax, trk_est_N);
        for i = 1:CadUnitMax
            fseek(fd, 8*(i-1), -1);
%             [temp,cntout] = fread(fd, trk_est_N, '1*double', 72);
            [cad_aq_units(i,:),cntout] = fread(fd, trk_est_N, '1*double', (CADUNIT_MAXMAX-1)*8);
%             eval(['trk_cad_aq_unit_',num2str(i-1),'=temp;']);
        end
        fclose(fd);
        
        h=figure('Name', ['PRN_', num2str(PRNID), ' Amplitude']);
        %Plot norm of A
        hx = subplot(4,1,1);
        trk_results_plot_1(hx, figure_num, trk_timeaxis, abs(cad_ai_units(1:CadUnitMax, :)+1i*cad_aq_units(1:CadUnitMax, :)),...
                           unit_active_mt(1:CadUnitMax,:), CadUnitMax, 0, [], [], 'Norm Amplitude',[], colors);
        
        %Plot i component of A
        hx = subplot(4,1,2);
        trk_results_plot_1(hx, figure_num, trk_timeaxis, cad_ai_units(1:CadUnitMax, :),...
                           unit_active_mt(1:CadUnitMax,:), CadUnitMax, 0, [], [], 'I Channel Amplitude',[], colors);
        
        %Plot q component of A
        hx = subplot(4,1,3);
        trk_results_plot_1(hx, figure_num, trk_timeaxis, cad_aq_units(1:CadUnitMax, :),...
                           unit_active_mt(1:CadUnitMax,:), CadUnitMax, 0, 'time,[s]', [], 'Q Channel Amplitude',[], colors);
        
%        cad_aphase_units = cad_aq_units ./ cad_ai_units;
        cad_aphase_units = atan2(cad_aq_units, cad_ai_units);
        cad_aphase_units = cad_aphase_units ./pi * 180;
        hx = subplot(4,1,4);
        trk_results_plot_1(hx, figure_num, trk_timeaxis, cad_aphase_units(1:CadUnitMax, :),...
                           unit_active_mt(1:CadUnitMax,:), CadUnitMax, 0, 'time,[s]', [], 'Phase',[], colors);
        
        %----- Units CN0, aratio, astd SNR Plotting -------
        if cnr_moniamp_time_N>0
            fd = fopen(STR_FILE_CTRL.CNR_AmpMoni_time, 'r');
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
            h = figure('Name', ['PRN_', num2str(PRNID), ' CN0_aratio_astd_SNR'], 'Position', [scrsz(3)/8 scrsz(4)/8 scrsz(3)*6/8 scrsz(4)*6/8]);
            
            hx = subplot(2,6,[1 3]);  %For CN0
            bar(hx, time1, cnr1, 'grouped'); colormap hot;
            title('Normal Units'' CN0'); xlabel('time,[s]'), ylabel('dB-Hz');
            hold on; plot(hx, time1, repmat(CN0Thre, cnr_moniamp_time_N, 1));
            ADD_Tag(ever_active_units_num,0);
            
            hx = subplot(2,6,[4 6]);  %For SNR
            bar(hx, time1, SNR1, 'grouped'); colormap hot;
            title('Normal Units'' SNR'); xlabel('time,[s]'), ylabel('[db]');
            hold on; plot(hx, time1, repmat(SNRThre, cnr_moniamp_time_N,1));
            
            if ever_active_units_num>1
                hx=subplot(2,6,[7 8]);  %For aratio
                bar(hx, time1, aratio1(:,2:end), 'grouped'); colormap summer;
                title('Amplitude ratio to LOS'); xlabel('time,[s]');
                hold on; plot(hx, time1, repmat(AThreLow, cnr_moniamp_time_N, 1));
            end
            
            hx = subplot(2,6,[9 10]);  % For std ratio
            bar(hx, time1, astd1, 'grouped'); colormap hot;
            title('Standard deviation ratio to noise'); xlabel('time,[s]');
            hold on; plot(hx, time1, repmat(ADevThre, cnr_moniamp_time_N,1));
            
            hx = subplot(2,6,[11 12]);  % For noise std
            bar(hx, time1, std_ns1, 'grouped'); colormap hot;
            title('Noise''s standard deviation'); xlabel('time,[s]');
        end
        
        
        % read the trial_unit_active file
%         fd = fopen(STR_FILE_CTRL.cad_trch_active,'r');
%         [cad_trch_active,cntout] = fread(fd, trk_est_N, 'uchar');
%         fclose(fd);
%     
%         %*** Plot trial unit's codephase error, codphs_diff, amplitude, accumulates, estimated CN0 ...
%         %***
%         if sum(cad_trch_active)
%     %-   Read and plot trial unit's code phase discriminator output
% %     fd = fopen(STR_FILE_CTRL.cad_trch_codphs,'r');
% %     [cad_trch_codphs,cntout] = fread(fd, trk_est_N, 'double');
% %     fclose(fd);
%     
%             scrsz = get(0,'ScreenSize');
%             h = figure('Name',['PRN_', num2str(PRNID), ' Trail_CH'], 'Position', [scrsz(3)/8 scrsz(4)/8 scrsz(3)*6/8 scrsz(4)*6/8]);
% 
%     
%     
%     %--  Read and plot trial unit's code phase difference from the Unit0
%     
%             %-- Read and plot trial unit's i and q channels amplitude
%             fd = fopen(STR_FILE_CTRL.cad_trch_ai,'r');
%             [cad_trch_ai, cntout] = fread(fd, trk_est_N, 'double');
%             fclose(fd);
%             fd = fopen(STR_FILE_CTRL.cad_trch_aq,'r');
%             [cad_trch_aq, cntout] = fread(fd, trk_est_N, 'double');
%             fclose(fd);
%             cad_trch_a = [abs((cad_trch_ai+1i*cad_trch_aq)'); cad_trch_ai'; cad_trch_aq'];
%     
%             hx=subplot(2,2,1);
%             legend_str = {'|a|','ai','aq'};
%             trk_results_plot_1(hx, 1, trk_timeaxis, cad_trch_a, repmat(cad_trch_active',3,1), 3, 0, ...
%                 'time, [s]', [], 'Tr\_CH Amplitude',legend_str, colors);
%     
%             cad_trch_aphase = atan2(cad_trch_aq, cad_trch_ai);
%             cad_trch_aphase = cad_trch_aphase' ./pi * 180;
% 
%             hx = subplot(2,2,2);
%             trk_results_plot_1(hx, 1, trk_timeaxis, cad_trch_aphase, cad_trch_active', 1, 0, ...
%                 'time, [s]', [], 'Tr\_CH Phase',[], colors);
% 
%             if cad_trch_cnr_N>0
%                 %-- Read and plot trial unit's CN0 --%
%                 fd = fopen(STR_FILE_CTRL.cad_trch_cnr,'r');
%                 [cad_trch_time_CN0, cntout] = fread(fd, [2, cad_trch_cnr_N], 'double');
%                 fclose(fd);
%     
%                 %-- Read and plot trail unit's amplitude average --%
%                 fd = fopen(STR_FILE_CTRL.cad_trch_a_avg, 'r');
%                 [cad_trch_a_avg, cntout] = fread(fd, cad_trch_cnr_N, 'double');
%                 fclose(fd);
%     
%                 hx = subplot(2,2,3);
%                 bar(hx, cad_trch_time_CN0(1,:), cad_trch_a_avg); colormap summer;
%                 hold on; plot(hx, cad_trch_time_CN0(1,:), repmat(TrAmpThre,1,cad_trch_cnr_N));
%                 title('Tr\_CH Amplitude to LOS Amplitude ratio'); xlabel('time,[s]'), ylabel('amp');
%         
%                 %-- Read and plot trial unit's SNR --%
%                 fd = fopen(STR_FILE_CTRL.cad_trch_snr, 'r');
%                 [cad_trch_snr, cntout] = fread(fd, cad_trch_cnr_N, 'double');
%                 fclose(fd);
%         
%                 hx = subplot(2,2,4);
%                 bar(hx, cad_trch_time_CN0(1,:), cad_trch_snr); colormap summer;
%                 hold on; plot(hx, cad_trch_time_CN0(1,:), repmat(TrSNRThre,1,cad_trch_cnr_N));
%                 title('Tr_CH SNR'); xlabel('time,[s]'), ylabel('SNR,[db]');
%             end
%     
%             %--- Read and plot trial unit's correlation function ---%
%             fd = fopen(STR_FILE_CTRL.cad_trch_corrM_IQ, 'r');
% %     fseek(fd, 2*corrM_Num*(cad_trch_cnr_N-1)*8, 'bof');
%     
%             corrM_spacing = (-(corrM_Num-1)/2 :1: (corrM_Num-1)/2)*corrM_Spacing * STR_Constants.STR_B1I.Fcode0 / STR_Constants.STR_RECV.fs;%x axis
%         
%             corrM_all = fread(fd, [2*corrM_Num, trk_est_N], 'double'); % read all data
%             rec_valid = find(sum(abs(corrM_all), 1)~=0); % get position of non-zero column
%             len_valid = length(rec_valid); % number of non-zero column, valid column
%     
%             corrM_valid = zeros(2*corrM_Num, len_valid);
%             plot_times = floor(len_valid / accum_times);
%             last = mod(len_valid, accum_times); % The last values
% 
%             % Put all valid values into matrix corrM_valid
%             for t = 1:len_valid
%                 corrM_valid(:,t) = corrM_all(:,rec_valid(t));
%             end
%     
%             for i = 1:plot_times
%                 h2 = figure('Name', ['PRN_', num2str(PRNID), ' Trail CorrShapes']); hold on; grid on;
% %         axis([-3 3 1e4 1.5e4]);
%         
%                 corrM_Tr = corrM_valid(:,(i-1)*accum_times+1:i*accum_times); % Every accum_times points
% 
%                 corrM_Tr = abs(corrM_Tr(1:corrM_Num,:) + 1i*corrM_Tr(corrM_Num+1:2*corrM_Num,:));
%                 corrM_Tr1 = mean(corrM_Tr, 2); % get mean value of each row
%                 corrM_Tr2 = corrM_Tr1(2:2:corrM_Num-1);
%                 corrM_Tr3 = corrM_Tr1(3:2:corrM_Num);
%                 corrM_Tr1 = [flipud(corrM_Tr2); corrM_Tr1(1); corrM_Tr3];
%                 
%                 plot(corrM_spacing, corrM_Tr1);
%                 M = getframe(h2);
%                 corr_movie_tr(i).cdata = M.cdata;
%                 corr_movie_tr(i).colormap = M.colormap;
% 
%                 xlabel('Tc'); title('Trail Channel'' Correlation Functions');
%                 close(h2);
%             end
%     
%             % Draw the last accum_times points
%             if last ~= 0
%                 last = accum_times;
% 
%                 h3 = figure('Name', ['PRN_', num2str(PRNID), ' Trail CorrShapes']); hold on; grid on;
%         %         axis([-3 3 1e4 1.5e4]);
% 
%                 corrM_Tr = corrM_valid(:,len_valid-last+1:len_valid);
%                 corrM_Tr = abs(corrM_Tr(1:corrM_Num,:) + 1i*corrM_Tr(corrM_Num+1:2*corrM_Num,:));
%                 corrM_Tr1 = mean(corrM_Tr, 2); % get mean value of each row
%                 corrM_Tr2 = corrM_Tr1(2:2:corrM_Num-1);
%                 corrM_Tr3 = corrM_Tr1(3:2:corrM_Num);
%                 corrM_Tr1 = [flipud(corrM_Tr2); corrM_Tr1(1); corrM_Tr3];
% 
%                 plot(corrM_spacing, corrM_Tr1);
%                 xlabel('Tc'); title('Trail Channel'' Correlation Functions'); 
% 
%                 M = getframe(h3);
%                 corr_movie_tr(plot_times+1).cdata = M.cdata;
%                 corr_movie_tr(plot_times+1).colormap = M.colormap;
%             end
% 
%             fclose(fd);
%         end%EOF "if sum(cad_trch_active)"
%        

        if plotCorrMovie
            % corr func waveform
            fd = fopen(STR_FILE_CTRL.trk_cad_codphs_diff_2,'r');
            cad_codphs_diff_units_2 = zeros(CadUnitMax-1, corrM_N);
            for i = 1:(CadUnitMax-1)
                fseek(fd, 8*(i-1), -1);
    %             [temp,cntout] = fread(fd, trk_est_N, '1*double', 64);
                [cad_codphs_diff_units_2(i,:),cntout] = fread(fd, corrM_N, '1*double', (CADUNIT_MAXMAX-2)*8);
    %             eval(['trk_cad_codphs_diff_unit_',num2str(i),'= (-temp)*1e3/2.046;']);
            end
            fclose(fd);

            fd = fopen(STR_FILE_CTRL.unit_active_mt_2,'r');
            [unit_active_mt_2,cntout] = fread(fd, [CADUNIT_MAXMAX, corrM_N], 'uchar');
            fclose(fd);

            fd = fopen(STR_FILE_CTRL.corrM_IQ, 'r');
            fd1 = fopen(STR_FILE_CTRL.uncancelled_corrM_IQ, 'r');

            cad_codphs_diff_units_2 = [zeros(1,corrM_N);cad_codphs_diff_units_2]; % (CADUNIT_MAXMAX, trk_est_N)
            corrM_spacing = (-(corrM_Num-1)/2 :1: (corrM_Num-1)/2)*corrM_Spacing * STR_Constants.STR_B1I.Fcode0 / STR_Constants.STR_RECV.fs; % Set x axis

        %     h = figure('Name','CorrShapes'); hold on; grid on;
        %     Avg_Num = min(trk_est_N, accum_times);

            temp = accum_times;
            accum_times = corr_accu_times; % 1s / 10ms

            plot_times = floor(corrM_N / accum_times); % Set the corr func plotting times
            last = mod(corrM_N, accum_times);

            legstr = 0;
            for j = 1:plot_times
        %         fseek(fd, 2*corrM_Num*(j-1)*accum_times*CADUNIT_MAXMAX*8, 'bof');
                h = figure('Name', ['PRN_', num2str(PRNID), ' CorrShapes']); hold on; grid on;
        %         axis([-3 3 0 18e4]);
                for i = 1:figure_num
                    fseek(fd, 2*corrM_Num*(j-1)*accum_times*CADUNIT_MAXMAX*8+2*corrM_Num*(i-1)*8, 'bof');
                    if sum(unit_active_mt_2(i, (j-1)*accum_times+1:j*accum_times)) % These accum_times points is valid 
                        corrM = zeros(2*corrM_Num, accum_times);
                        codphs1 = -mean( cad_codphs_diff_units_2(i, (j-1)*accum_times+1:j*accum_times), 2); % mean of row

                        for t=1:accum_times
                            corrM(:,t) = fread(fd, [2*corrM_Num, 1], 'double');
                            fseek(fd, 2*corrM_Num*(CADUNIT_MAXMAX-1)*8, 'cof');
                        end

                        corrM = abs(corrM(1:corrM_Num,:) + 1i*corrM(corrM_Num+1:2*corrM_Num,:));

                        corrM1 = mean(corrM, 2);
                        corrM2 = corrM1(2:2:corrM_Num-1);
                        corrM3 = corrM1(3:2:corrM_Num);
                        corrM1 = [flipud(corrM2); corrM1(1); corrM3];

                        plot(corrM_spacing+codphs1, corrM1, 'color', colors(i+1,:));
        %                 drawnow;
                        legstr = legstr+1;
                    end
                end

                % Draw the original uncancelled signal's corr func
                fseek(fd1,2*corrM_Num*(j-1)*accum_times*8, 'bof');
                corrM = zeros(2*corrM_Num, accum_times);

                for t=1:accum_times
                    corrM(:,t) = fread(fd1, [2*corrM_Num, 1], 'double');
                end

                corrM = abs(corrM(1:corrM_Num,:) + 1i*corrM(corrM_Num+1:2*corrM_Num,:));

                corrM1 = mean(corrM, 2);
                corrM2 = corrM1(2:2:corrM_Num-1);
                corrM3 = corrM1(3:2:corrM_Num);
                corrM1 = [flipud(corrM2); corrM1(1); corrM3];

                plot(corrM_spacing, corrM1, 'k-');

                xlabel('Tc'); title('Correlation Functions');
        %         ADD_Tag(legstr, 0); 

    %             M = getframe(h);
    %             corr_movie(j).cdata = M.cdata;
    %             corr_movie(j).colormap = M.colormap;

                close(h);
            end

            % Draw last accum_times points
            if last ~= 0
                last = accum_times;
                h4 = figure('Name', ['PRN_', num2str(PRNID), ' CorrShapes']); hold on; grid on;
        %         axis([-3 3 0 18e4]);
                corrM_last = zeros(2*corrM_Num, last);
                for i = 1:figure_num
                    fseek(fd, 2*corrM_Num*(corrM_N-last)*CADUNIT_MAXMAX*8+2*corrM_Num*(i-1)*8, 'bof');
                    if sum(unit_active_mt_2(i, corrM_N-last+1:corrM_N))
                        codphs1 = -mean( cad_codphs_diff_units_2(i, corrM_N-last+1:corrM_N), 2);
                        for t=1:last
                            corrM_last(:,t) = fread(fd, [2*corrM_Num, 1], 'double');
                            fseek(fd, 2*corrM_Num*(CADUNIT_MAXMAX-1)*8, 'cof');
                        end

                        corrM = abs(corrM_last(1:corrM_Num,:) + 1i*corrM_last(corrM_Num+1:2*corrM_Num,:));

                        corrM1 = mean(corrM, 2);
                        corrM2 = corrM1(2:2:corrM_Num-1);
                        corrM3 = corrM1(3:2:corrM_Num);
                        corrM1 = [flipud(corrM2); corrM1(1); corrM3];

                        plot(corrM_spacing+codphs1, corrM1, 'color', colors(i+1,:));
                    end
                end

                fseek(fd1,2*corrM_Num*(corrM_N-last)*8, 'bof');
                corrM = zeros(2*corrM_Num, accum_times);

                for t=1:accum_times
                    corrM(:,t) = fread(fd1, [2*corrM_Num, 1], 'double');
                end

                corrM = abs(corrM(1:corrM_Num,:) + 1i*corrM(corrM_Num+1:2*corrM_Num,:));

                corrM1 = mean(corrM, 2);
                corrM2 = corrM1(2:2:corrM_Num-1);
                corrM3 = corrM1(3:2:corrM_Num);
                corrM1 = [flipud(corrM2); corrM1(1); corrM3];

                plot(corrM_spacing, corrM1, 'k-');

                xlabel('Tc'); title('Correlation Functions');

    %             M = getframe(h4);
    %             corr_movie(plot_times+1).cdata = M.cdata;
    %             corr_movie(plot_times+1).colormap = M.colormap;

            end

            fclose(fd);
            fclose(fd1);

            accum_times = temp;
        end
    end
end
%% DEBUG_LEVEL 3 Plotting
if( STR_FILE_CTRL.DEBUG_LEVEL>2 )
  
    if strcmp(STATUS,'track')||strcmp(STATUS,'pullin')||strcmp(STATUS,'track_ini')||strcmp(STATUS,'towsynced')
        
        %-----code phase-----%
        fd = fopen(STR_FILE_CTRL.trk_codphs,'r');
        codphs_units = zeros(CadUnitMax, trk_est_N);
        for i = 1:CadUnitMax
            fseek(fd, 8*(i-1), -1);
%             [temp,cntout] = fread(fd, trk_est_N, '1*double', (CADUNIT_MAXMAX-1)*8);
            [codphs_units(i,:),cntout] = fread(fd, trk_est_N, '1*double', (CADUNIT_MAXMAX-1)*8);
%             eval(['trk_codphs_unit_',num2str(i-1),'=temp;']);
        end
        fclose(fd);
        trk_results_plot(trk_timeaxis, codphs_units, unit_active_mt(1:CadUnitMax,:), CadUnitMax, 1, ...
            'time [s]', 'Tc', ['PRN\_', num2str(PRNID), ' DLL Discriminator Output of Unit']);
        
        %-----code freq-----%
        fd = fopen(STR_FILE_CTRL.trk_codfreq,'r');
        codfreq_units = zeros(CadUnitMax, trk_est_N);
        for i = 1:CadUnitMax
            fseek(fd, 8*(i-1), -1);
%             [temp,cntout] = fread(fd, trk_est_N, '1*double', 72);
            [codfreq_units(i,:), cntout] = fread(fd, trk_est_N, '1*double', (CADUNIT_MAXMAX-1)*8);
%             eval(['trk_codfreq_unit_',num2str(i-1),'=temp;']);
        end
        fclose(fd);
        trk_results_plot(trk_timeaxis, codfreq_units, unit_active_mt(1:CadUnitMax,:), CadUnitMax, 1, 'time [s]', ...
            'Hz', ['PRN\_', num2str(PRNID), ' Code Doppler Freq of Unit']);
       
        %-----Unit Accumulation values-----%
        fd = fopen(STR_FILE_CTRL.Dch_T_IQ,'r');
        Dch_TIQ_units = zeros(CadUnitMax, 2*trk_est_N);
        for i = 1:CadUnitMax
            fseek(fd, 2*8*(i-1), 'bof');
            [Dch_TIQ_units(i,:),cntout] = fread(fd, 2*trk_est_N, '2*double', 2*(CADUNIT_MAXMAX-1)*8);
        end
        fclose(fd);
        
        figure('Name', ['PRN_', num2str(PRNID), ' Accumulation']);
        for i = 1:CadUnitMax
            if sum( unit_active_mt(i,:) )
                subplot(figure_num,1,i);
                tiq_unit = reshape(Dch_TIQ_units(i,:), 2, trk_est_N);
                plot(trk_timeaxis(unit_active_mt(i,:)==1), tiq_unit(1,unit_active_mt(i,:)==1), colors(i));
                hold on;
                plot(trk_timeaxis(unit_active_mt(i,:)==1), tiq_unit(2,unit_active_mt(i,:)==1), colors(i+1));
            end
        end
    end
end
%% DEBUG_LEVEL 5 Plotting
if( STR_FILE_CTRL.DEBUG_LEVEL>4 )
    
    if strcmp(STATUS,'track')||strcmp(STATUS,'pullin')||strcmp(STATUS,'track_ini')||strcmp(STATUS,'towsynced')
    
        fd = fopen(STR_FILE_CTRL.BBSig_I,'r');
        [BBSig_I,cntout] = fread(fd, BBSig_I_N, 'double');
        fclose(fd);
        figure,subplot(2,1,1);
        plot( BBSig_I(1:cntout) ), title('BBSig_I data');
        fd = fopen(STR_FILE_CTRL.BBSig_I,'r');
        [BBSig_Q,cntout] = fread(fd, BBSig_Q_N, 'double');
        fclose(fd);    
        subplot(2,1,2);
        plot( BBSig_Q(1:cntout) ), title('BBSig_Q data');

        fd = fopen(STR_FILE_CTRL.LO_Dch_Codes,'r');
        [LO_Dch_Codes,cntout] = fread(fd, LO_Dch_Codes_N, 'schar');
        fclose(fd);
        figure, plot(LO_Dch_Codes), title('local Data channel code');

        if strcmp(SYST , 'GPS_L2C')
            fd = fopen(STR_FILE_CTRL.LO_Pch_Codes,'r');
            [LO_Pch_Codes,cntout] = fread(fd, LO_Pch_Codes_N, 'schar');
            fclose(fd);
            figure, plot(LO_Pch_Codes), title('local Pilot channel code');
        end    
    end
end
