function [recorder] = UpdateRecorder(sateList, channelList, recorder, receiver)

% Input: sateList is new satellite's PRN ID, channelList is serial number of channels be replaced,
% These two ones' length should be equal, has already checked not empty

if (length(channelList) ~= length(sateList))
   error('Error! The lengths are not equal!') 
end

% Recorder initialization, use a valid channel (the 1st channel must be valid), in case of the channel num larger than initial satellite num
marker = strfind(recorder(channelList(1)).info, '_PRN');
filepath = recorder(channelList(1)).info(1:(marker-1));
DEBUG_LEVEL = recorder(channelList(1)).DEBUG_LEVEL;

for i = 1:length(channelList)
    prn = sateList(i);
    recorder(channelList(i)).DEBUG_LEVEL         = DEBUG_LEVEL;
    recorder(channelList(i)).PRN_ID              = prn;
    recorder(channelList(i)).info                = [filepath,'_PRN',num2str(prn),'_info.txt'];
    % DEBUG_LEVEL==1
    recorder(channelList(i)).trk_carphs          = [filepath,'_PRN',num2str(prn),'_trk_carphs.bin'];
    recorder(channelList(i)).trk_carfreq         = [filepath,'_PRN',num2str(prn),'_trk_carfreq.bin'];
    recorder(channelList(i)).trk_timeaxis        = [filepath,'_PRN',num2str(prn),'_trk_timeaxis.bin'];
    % DEBUG_LEVEL==2
    recorder(channelList(i)).trk_cad_codphs_diff = [filepath,'_PRN',num2str(prn),'_trk_cad_codphs_diff.bin'];
    recorder(channelList(i)).trk_cad_codphs_diff_2 = [filepath,'_PRN',num2str(prn),'_trk_cad_codphs_diff_2.bin'];
    recorder(channelList(i)).trk_cad_ai          = [filepath,'_PRN',num2str(prn),'_trk_cad_ai.bin'];
    recorder(channelList(i)).trk_cad_aq          = [filepath,'_PRN',num2str(prn),'_trk_cad_aq.bin'];
    recorder(channelList(i)).unit_active_mt      = [filepath,'_PRN',num2str(prn),'_unit_active_mt.bin'];
    recorder(channelList(i)).unit_active_mt_2    = [filepath,'_PRN',num2str(prn),'_unit_active_mt_2.bin'];
    recorder(channelList(i)).CNR_AmpMoni_time    = [filepath,'_PRN',num2str(prn),'_CNR_AmpMoni_time'];
    recorder(channelList(i)).cad_trch_ai         = [filepath,'_PRN',num2str(prn),'_cad_trch_ai.bin'];
    recorder(channelList(i)).cad_trch_aq         = [filepath,'_PRN',num2str(prn),'_cad_trch_aq.bin'];
    recorder(channelList(i)).cad_trch_a_avg      = [filepath,'_PRN',num2str(prn),'_cad_trch_a_avg.bin'];
    recorder(channelList(i)).cad_trch_snr        = [filepath,'_PRN',num2str(prn),'_cad_trch_snr.bin'];
    recorder(channelList(i)).cad_trch_active     = [filepath,'_PRN',num2str(prn),'_cad_trch_active.bin'];
    recorder(channelList(i)).cad_trch_cnr        = [filepath,'_PRN',num2str(prn),'_cad_trch_cnr.bin'];
    recorder(channelList(i)).cad_trch_corrM_IQ   = [filepath,'_PRN',num2str(prn),'_cad_trch_corrM_IQ.bin'];
    recorder(channelList(i)).corrM_IQ            = [filepath,'_PRN',num2str(prn),'_corrM_IQ.bin'];
    recorder(channelList(i)).uncancelled_corrM_IQ= [filepath,'_PRN',num2str(prn),'_uncancelled_corrM_IQ.bin'];
    % DEBUG_LEVEL==3
    recorder(channelList(i)).trk_codphs          = [filepath,'_PRN',num2str(prn),'_trk_codphs.bin'];
    recorder(channelList(i)).trk_codfreq         = [filepath,'_PRN',num2str(prn),'_trk_codfreq.bin'];
    recorder(channelList(i)).Dch_T_IQ            = [filepath,'_PRN',num2str(prn),'_Dch_T_IQ.bin'];
    recorder(channelList(i)).cad_trch_codphs     = [filepath,'_PRN',num2str(prn),'_cad_trch_codphs.bin'];
    recorder(channelList(i)).cad_trch_codfreq    = [filepath,'_PRN',num2str(prn),'_cad_trch_codfreq.bin'];
    recorder(channelList(i)).cad_trch_codphs_diff= [filepath,'_PRN',num2str(prn),'_cad_trch_codphs_diff.bin'];
    recorder(channelList(i)).cad_trch_a_std      = [filepath,'_PRN',num2str(prn),'_cad_trch_a_std.bin'];
    recorder(channelList(i)).cad_trch_DchT_IQ    = [filepath,'_PRN',num2str(prn),'_cad_trch_DchT_IQ.bin'];
    ...    strfile_ctrl(idleList(i)).cad_trch_PchT_IQ    = [filepath,'_PRN',num2str(prn),'_cad_trch_PchT_IQ.bin'];
    % DEBUG_LEVEL==4
    recorder(channelList(i)).Dch_Tslot_IQ        = [filepath,'_PRN',num2str(prn),'_Dch_Tslot_IQ.bin'];
    ...    strfile_ctrl(idleList(i)).Pch_Tslot_IQ        = [filepath,'_PRN',num2str(prn),'_Pch_Tslot_IQ.bin'];
    % DEBUG_LEVEL==5
    recorder(channelList(i)).BBSig_I             = [filepath,'_PRN',num2str(prn),'_BBSig_I.bin'];
    recorder(channelList(i)).BBSig_Q             = [filepath,'_PRN',num2str(prn),'_BBSig_Q.bin'];
    recorder(channelList(i)).LO_Dch_Codes        = [filepath,'_PRN',num2str(prn),'_LO_Dch_Codes.bin'];
    recorder(channelList(i)).LO_Pch_Codes        = [filepath,'_PRN',num2str(prn),'_LO_Pch_Codes.bin'];

%% Construct debug_level 1 files
    if( DEBUG_LEVEL>0 )

        fid = fopen(recorder(channelList(i)).trk_carphs,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).trk_carfreq,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).trk_timeaxis,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

    end

%% Construct debug_level 2 files
    if( DEBUG_LEVEL>1 )

        fid = fopen(recorder(channelList(i)).trk_cad_codphs_diff,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).trk_cad_codphs_diff_2,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).trk_cad_ai,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).trk_cad_aq,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).unit_active_mt,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).unit_active_mt_2,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

    %     fid = fopen(strfile_ctrl(idleList(i)).Pch_T_IQ,'w+');
    %     if(fid<0)
    %         error('file initializing failed!');
    %     end
    %     fclose(fid); 

        fid = fopen(recorder(channelList(i)).CNR_AmpMoni_time,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).cad_trch_ai,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).cad_trch_aq,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).cad_trch_a_avg,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).cad_trch_snr,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).cad_trch_active,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).cad_trch_cnr, 'w+');
        if(fid<0)
            error('cad_trch_cnr file initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).cad_trch_corrM_IQ, 'w+');
        if(fid<0)
            error('cad_trch_corrM_IQ file initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).corrM_IQ, 'w+');
        if(fid<0)
            error('file corrM_IQ initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).uncancelled_corrM_IQ, 'w+');
        if(fid<0)
            error('file uncancelled_corrM_IQ initializing failed!');
        end
        fclose(fid);

    end

    %% Construct debug_level 3 files
    if( DEBUG_LEVEL>2 )

        fid = fopen(recorder(channelList(i)).trk_codphs,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).trk_codfreq,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).Dch_T_IQ,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).cad_trch_codphs,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).cad_trch_codfreq,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).cad_trch_codphs_diff,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).cad_trch_a_std,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).cad_trch_DchT_IQ,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

    %     fid = fopen(strfile_ctrl(idleList(i)).cad_trch_PchT_IQ,'w+');
    %     if(fid<0)
    %         error('file initializing failed!');
    %     end
    %     fclose(fid);

    end

    %% Construct debug_level 4 files
    if( DEBUG_LEVEL>3 )

        fid = fopen(recorder(channelList(i)).Dch_Tslot_IQ,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

    %     fid = fopen(strfile_ctrl(idleList(i)).Pch_Tslot_IQ,'w+');
    %     if(fid<0)
    %         error('file initializing failed!');
    %     end
    %     fclose(fid);

    end
    %% Construct debug_level 5 files
    if( DEBUG_LEVEL>4 )

        fid = fopen(recorder(channelList(i)).BBSig_I,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);


        fid = fopen(recorder(channelList(i)).BBSig_Q,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).LO_Dch_Codes,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);

        fid = fopen(recorder(channelList(i)).LO_Pch_Codes,'w+');
        if(fid<0)
            error('file initializing failed!');
        end
        fclose(fid);  
    end

    %% Construct info files
    if( DEBUG_LEVEL>0 )

        fid = fopen(recorder(channelList(i)).info,'w+');
        if(fid<0)
            error('file initializing failed!');
        end

        fprintf( fid, 'DEBUG_LEVEL = %d\n', recorder(channelList(i)).DEBUG_LEVEL );
        fprintf( fid, 'CADUNIT_MAXMAX = %d\n', 10 );
        fprintf( fid, 'CadUnitMax = %d\n', receiver.channels(channelList(i)).STR_CAD.CadUnitMax );
        fprintf( fid, 'bpSampling_OddFold = %d\n', receiver.channels(channelList(i)).bpSampling_OddFold );
        fprintf( fid, 'AThreLow1 = %f\n', receiver.channels(channelList(i)).STR_CAD.AThreLow1 );
        fprintf( fid, 'ADevThre = %f\n', receiver.channels(channelList(i)).STR_CAD.ADevThre );
        fprintf( fid, 'TrCN0Thre = %f\n', receiver.channels(channelList(i)).STR_CAD.TrCN0Thre );

        fprintf( fid, 'trk_est_N = %d\n', 0 );

        fprintf( fid, 'corrM_N = %d\n', 0 );

        fprintf( fid, 'last_trk_record_time = %.4f\n', 0);
        fprintf( fid, 'cnr_moniamp_time_N = %d\n', 0);
        fprintf( fid, 'cad_trch_cnr_N = %d\n', 0 );

        switch receiver.syst
            case 'BD_B1I'
                fprintf( fid, 'corrM_Num = %d\n', receiver.channels(channelList(i)).CH_B1I.CorrM_Bank.corrM_Num );
                fprintf( fid, 'corrM_Spacing = %d\n', receiver.channels(channelList(i)).CH_B1I.CorrM_Bank.corrM_Spacing );
        end

        if( DEBUG_LEVEL>1 )
            fprintf( fid, 'trk_accTslot_IQ_N = %d\n', 0 );
            fprintf( fid, 'trk_accT_IQ_N = %d\n', 0 );
        end

         if( DEBUG_LEVEL>4 )

            fprintf( fid, 'BBSig_I_N = %d\n', 0 );
            fprintf( fid, 'BBSig_Q_N = %d\n', 0 );
            fprintf( fid, 'LO_Dch_Codes_N = %d\n', 0 );
            fprintf( fid, 'LO_Pch_Codes_N = %d\n', 0 );
         end 

        fclose(fid); 
    end
end

end