function STR_FILE_CTRL = recorderFileIni(STR_FILE_CTRL, receiver, prn, sv, record)

filePath_1 = receiver.config.logConfig.debugFilePath;
debugLevel = receiver.config.logConfig.debugLevel;
isCorrShapeStore = receiver.config.logConfig.isCorrShapeStore;

filePath = [filePath_1,record,'_',receiver.channels(sv).SYST];
STR_FILE_CTRL(sv).DEBUG_LEVEL         = debugLevel;
STR_FILE_CTRL(sv).PRN_ID              = prn;
STR_FILE_CTRL(sv).info                = [filePath,'_PRN',num2str(prn),'_info.txt'];
STR_FILE_CTRL(sv).isCorrShapeStore    = isCorrShapeStore;
% debugLevel==1
STR_FILE_CTRL(sv).trk_L1L2_package    = [filePath,'_PRN',num2str(prn),'_trk_L1L2_package.bin'];
STR_FILE_CTRL(sv).trk_carphs          = [filePath,'_PRN',num2str(prn),'_trk_carphs.bin'];
STR_FILE_CTRL(sv).trk_carfreq         = [filePath,'_PRN',num2str(prn),'_trk_carfreq.bin'];
STR_FILE_CTRL(sv).trk_timeaxis        = [filePath,'_PRN',num2str(prn),'_trk_timeaxis.bin'];
% debugLevel==2
STR_FILE_CTRL(sv).trk_cad_codphs_diff = [filePath,'_PRN',num2str(prn),'_trk_cad_codphs_diff.bin'];
STR_FILE_CTRL(sv).trk_cad_codphs_diff_2 = [filePath,'_PRN',num2str(prn),'_trk_cad_codphs_diff_2.bin'];
STR_FILE_CTRL(sv).trk_cad_ai          = [filePath,'_PRN',num2str(prn),'_trk_cad_ai.bin'];
STR_FILE_CTRL(sv).trk_cad_aq          = [filePath,'_PRN',num2str(prn),'_trk_cad_aq.bin'];
STR_FILE_CTRL(sv).unit_active_mt      = [filePath,'_PRN',num2str(prn),'_unit_active_mt.bin'];
STR_FILE_CTRL(sv).unit_active_mt_2    = [filePath,'_PRN',num2str(prn),'_unit_active_mt_2.bin'];
STR_FILE_CTRL(sv).CNR_AmpMoni_time    = [filePath,'_PRN',num2str(prn),'_CNR_AmpMoni_time'];
STR_FILE_CTRL(sv).cad_trch_ai         = [filePath,'_PRN',num2str(prn),'_cad_trch_ai.bin'];
STR_FILE_CTRL(sv).cad_trch_aq         = [filePath,'_PRN',num2str(prn),'_cad_trch_aq.bin'];
STR_FILE_CTRL(sv).cad_trch_a_avg      = [filePath,'_PRN',num2str(prn),'_cad_trch_a_avg.bin'];
STR_FILE_CTRL(sv).cad_trch_snr        = [filePath,'_PRN',num2str(prn),'_cad_trch_snr.bin'];
STR_FILE_CTRL(sv).cad_trch_active     = [filePath,'_PRN',num2str(prn),'_cad_trch_active.bin'];
STR_FILE_CTRL(sv).cad_trch_cnr        = [filePath,'_PRN',num2str(prn),'_cad_trch_cnr.bin'];
STR_FILE_CTRL(sv).cad_trch_corrM_IQ   = [filePath,'_PRN',num2str(prn),'_cad_trch_corrM_IQ.bin'];
STR_FILE_CTRL(sv).corrM_IQ            = [filePath,'_PRN',num2str(prn),'_corrM_IQ.bin'];
STR_FILE_CTRL(sv).uncancelled_corrM_IQ= [filePath,'_PRN',num2str(prn),'_uncancelled_corrM_IQ.bin'];
% debugLevel==3
STR_FILE_CTRL(sv).trk_codphs          = [filePath,'_PRN',num2str(prn),'_trk_codphs.bin'];
STR_FILE_CTRL(sv).trk_codfreq         = [filePath,'_PRN',num2str(prn),'_trk_codfreq.bin'];
STR_FILE_CTRL(sv).Dch_T_IQ            = [filePath,'_PRN',num2str(prn),'_Dch_T_IQ.bin'];
STR_FILE_CTRL(sv).cad_trch_codphs     = [filePath,'_PRN',num2str(prn),'_cad_trch_codphs.bin'];
STR_FILE_CTRL(sv).cad_trch_codfreq    = [filePath,'_PRN',num2str(prn),'_cad_trch_codfreq.bin'];
STR_FILE_CTRL(sv).cad_trch_codphs_diff= [filePath,'_PRN',num2str(prn),'_cad_trch_codphs_diff.bin'];
STR_FILE_CTRL(sv).cad_trch_a_std      = [filePath,'_PRN',num2str(prn),'_cad_trch_a_std.bin'];
STR_FILE_CTRL(sv).cad_trch_DchT_IQ    = [filePath,'_PRN',num2str(prn),'_cad_trch_DchT_IQ.bin'];
STR_FILE_CTRL(sv).kalman_filter_results=[filePath,'_PRN',num2str(prn),'_kalman_filter_results.bin'];
...    STR_FILE_CTRL(sv).cad_trch_PchT_IQ    = [filePath,'_PRN',num2str(prn),'_cad_trch_PchT_IQ.bin'];
% debugLevel==4
STR_FILE_CTRL(sv).Dch_Tslot_IQ        = [filePath,'_PRN',num2str(prn),'_Dch_Tslot_IQ.bin'];
...    STR_FILE_CTRL(sv).Pch_Tslot_IQ        = [filePath,'_PRN',num2str(prn),'_Pch_Tslot_IQ.bin'];
% debugLevel==5
STR_FILE_CTRL(sv).BBSig_I             = [filePath,'_PRN',num2str(prn),'_BBSig_I.bin'];
STR_FILE_CTRL(sv).BBSig_Q             = [filePath,'_PRN',num2str(prn),'_BBSig_Q.bin'];
STR_FILE_CTRL(sv).LO_Dch_Codes        = [filePath,'_PRN',num2str(prn),'_LO_Dch_Codes.bin'];
STR_FILE_CTRL(sv).LO_Pch_Codes        = [filePath,'_PRN',num2str(prn),'_LO_Pch_Codes.bin'];

%% Construct debug_level 1 files
if( debugLevel>0 )

    fid = fopen(STR_FILE_CTRL(sv).trk_L1L2_package,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);
    
    fid = fopen(STR_FILE_CTRL(sv).trk_carphs,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

    fid = fopen(STR_FILE_CTRL(sv).trk_carfreq,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

    fid = fopen(STR_FILE_CTRL(sv).trk_timeaxis,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

end

%% Construct debug_level 2 files
if( debugLevel>1 )

    fid = fopen(STR_FILE_CTRL(sv).trk_cad_codphs_diff,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

    if receiver.config.logConfig.isCorrShapeStore >0
        fid = fopen(STR_FILE_CTRL(sv).trk_cad_codphs_diff_2,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);
    end

    fid = fopen(STR_FILE_CTRL(sv).trk_cad_ai,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

    fid = fopen(STR_FILE_CTRL(sv).trk_cad_aq,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

    fid = fopen(STR_FILE_CTRL(sv).unit_active_mt,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

    fid = fopen(STR_FILE_CTRL(sv).unit_active_mt_2,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

%     fid = fopen(STR_FILE_CTRL(sv).Pch_T_IQ,'w+');
%     if(fid<0)
%         error('file initializing failed!');
%     end
%     fclose(fid); 

    fid = fopen(STR_FILE_CTRL(sv).CNR_AmpMoni_time,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

    fid = fopen(STR_FILE_CTRL(sv).cad_trch_ai,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

    fid = fopen(STR_FILE_CTRL(sv).cad_trch_aq,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

    fid = fopen(STR_FILE_CTRL(sv).cad_trch_a_avg,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

    fid = fopen(STR_FILE_CTRL(sv).cad_trch_snr,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

    fid = fopen(STR_FILE_CTRL(sv).cad_trch_active,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

    fid = fopen(STR_FILE_CTRL(sv).cad_trch_cnr, 'w+');
    if(fid<0)
        error('cad_trch_cnr file initializing failed!');
    end
    fclose(fid);

    fid = fopen(STR_FILE_CTRL(sv).cad_trch_corrM_IQ, 'w+');
    if(fid<0)
        error('cad_trch_corrM_IQ file initializing failed!');
    end
    fclose(fid);

    if receiver.config.logConfig.isCorrShapeStore >0
        fid = fopen(STR_FILE_CTRL(sv).corrM_IQ, 'w+');
        if(fid<0)
            error('file corrM_IQ initializing failed!');
        end
        fclose(fid);

        fid = fopen(STR_FILE_CTRL(sv).uncancelled_corrM_IQ, 'w+');
        if(fid<0)
            error('file uncancelled_corrM_IQ initializing failed!');
        end
        fclose(fid);
    end

end

%% Construct debugLevel 3 files
if (debugLevel > 2)

    fid = fopen(STR_FILE_CTRL(sv).trk_codphs,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

    fid = fopen(STR_FILE_CTRL(sv).trk_codfreq,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

    fid = fopen(STR_FILE_CTRL(sv).Dch_T_IQ,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

    fid = fopen(STR_FILE_CTRL(sv).cad_trch_codphs,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

    fid = fopen(STR_FILE_CTRL(sv).cad_trch_codfreq,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

    fid = fopen(STR_FILE_CTRL(sv).cad_trch_codphs_diff,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

    fid = fopen(STR_FILE_CTRL(sv).cad_trch_a_std,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

    fid = fopen(STR_FILE_CTRL(sv).cad_trch_DchT_IQ,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

    fid = fopen(STR_FILE_CTRL(sv).kalman_filter_results,'w+');
    if(fid<0)
        error('file(kalman_filter_results) initializing failed!');
    end
    fclose(fid);

%     fid = fopen(STR_FILE_CTRL(sv).cad_trch_PchT_IQ,'w+');
%     if(fid<0)
%         error('file initializing failed!');
%     end
%     fclose(fid);

end

%% Construct debugLevel 4 files
if( debugLevel>3 )

    fid = fopen(STR_FILE_CTRL(sv).Dch_Tslot_IQ,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

%     fid = fopen(STR_FILE_CTRL(sv).Pch_Tslot_IQ,'w+');
%     if(fid<0)
%         error('file initializing failed!');
%     end
%     fclose(fid);

end
%% Construct debugLevel 5 files
if( debugLevel>4 )

    fid = fopen(STR_FILE_CTRL(sv).BBSig_I,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);


    fid = fopen(STR_FILE_CTRL(sv).BBSig_Q,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

    fid = fopen(STR_FILE_CTRL(sv).LO_Dch_Codes,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);

    fid = fopen(STR_FILE_CTRL(sv).LO_Pch_Codes,'w+');
    if(fid<0)
        error('file initializing failed!');
    end
    fclose(fid);  
end

%% Construct info files
if( debugLevel>0 )

    fid = fopen(STR_FILE_CTRL(sv).info,'w+');
    if(fid<0)
        error('file initializing failed!');
    end

    fprintf( fid, 'DEBUG_LEVEL = %d\n', debugLevel );
    fprintf( fid, 'CADUNIT_MAXMAX = %d\n', 10 );
    fprintf( fid, 'CadUnitMax = %d\n', receiver.channels(sv).STR_CAD.CadUnitMax );
    fprintf( fid, 'bpSampling_OddFold = %d\n', receiver.channels(sv).bpSampling_OddFold );
    fprintf( fid, 'AThreLow1 = %f\n', receiver.channels(sv).STR_CAD.AThreLow1 );
    fprintf( fid, 'ADevThre = %f\n', receiver.channels(sv).STR_CAD.ADevThre );
    fprintf( fid, 'TrCN0Thre = %f\n', receiver.channels(sv).STR_CAD.TrCN0Thre );

    fprintf( fid, 'trk_est_N = %d\n', 0 );

    fprintf( fid, 'corrM_N = %d\n', 0 );
    fprintf(fid, 'corrM_N_valid = %d\n', 0); % Records latest valid number of correlation times, normally reset when a MP appears/disappears 

    fprintf( fid, 'last_trk_record_time = %.4f\n', 0);
    fprintf( fid, 'cnr_moniamp_time_N = %d\n', 0);
    fprintf( fid, 'cad_trch_cnr_N = %d\n', 0 );

    switch receiver.channels(sv).SYST
        case 'BD_B1I'
            fprintf( fid, 'corrM_Num = %d\n', receiver.channels(sv).CH_B1I.CorrM_Bank.corrM_Num );
            fprintf( fid, 'corrM_Spacing = %d\n', receiver.channels(sv).CH_B1I.CorrM_Bank.corrM_Spacing );
    end

    if( debugLevel>1 )
        fprintf( fid, 'trk_accTslot_IQ_N = %d\n', 0 );
        fprintf( fid, 'trk_accT_IQ_N = %d\n', 0 );
        fprintf( fid, 'kalman_filter_results_N = %d\n', 0);
    end

     if( debugLevel>4 )

        fprintf( fid, 'BBSig_I_N = %d\n', 0 );
        fprintf( fid, 'BBSig_Q_N = %d\n', 0 );
        fprintf( fid, 'LO_Dch_Codes_N = %d\n', 0 );
        fprintf( fid, 'LO_Pch_Codes_N = %d\n', 0 );
     end 

    fclose(fid); 
end