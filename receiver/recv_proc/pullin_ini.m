function [recv_channel]=pullin_ini(recv_channel)


recv_channel.DLL.SPACING = 0.5; %Note: The spacing is set 1 in pullin status

switch recv_channel.SYST
    case 'GPS_L1CA'
        recv_channel.CH_L1CA.WN         = 0;
        recv_channel.CH_L1CA.TOW_6SEC   = 0;
        recv_channel.CH_L1CA.SubFrame_N = 0;
        recv_channel.CH_L1CA.Word_N     = 0;
        recv_channel.CH_L1CA.Bit_N      = 0;
        recv_channel.CH_L1CA.T1ms_N     = 0;
        recv_channel.CH_L1CA.LO_CodPhs  = 0;
        recv_channel.CH_L1CA.Tcohn_cnt  = 0;
        recv_channel.CH_L1CA.Trk_Count  = 0;
        recv_channel.CH_L1CA.fdPre = recv_channel.CH_L1CA.LO2_fd;
        recv_channel.CH_L1CA.Fcode_fdPre = recv_channel.CH_L1CA.LO_Fcode_fd;
        
        recv_channel.CH_L1CA = chn_loopintegrator_initialize(recv_channel.CH_L1CA);
%         recv_channel.CH_L1CA.Tslot_I    = zeros(3,1);
%         recv_channel.CH_L1CA.Tslot_Q    = zeros(3,1);
%         recv_channel.CH_L1CA.T_I        = zeros(3,1);
%         recv_channel.CH_L1CA.T_Q        = zeros(3,1);
%         recv_channel.CH_L1CA.Tcoh_I     = zeros(3,1);
%         recv_channel.CH_L1CA.Tcoh_Q     = zeros(3,1);
%         recv_channel.CH_L1CA.Tcoh_I_prev= zeros(3,1);
%         recv_channel.CH_L1CA.Tcoh_Q_prev= zeros(3,1);
%         recv_channel.CH_L1CA.T_pll_I    = zeros(3,1);
%         recv_channel.CH_L1CA.T_pll_Q    = zeros(3,1);
%         recv_channel.CH_L1CA.PromptIQ_D = zeros(2,1);
%         
%         recv_channel.CH_L1CA.Loop_I  = zeros(3,15);
%         recv_channel.CH_L1CA.Loop_Q  = zeros(3,15);
%         recv_channel.CH_L1CA.Loop_N  = 0;
        
        recv_channel.CH_L1CA.CN0_Estimator.CN0EstActive = 1;
        recv_channel.CH_L1CA.muk_cnt = 0;
        recv_channel.CH_L1CA.mu_avg  = 0;
        recv_channel.CH_L1CA.CN0     = 0;
        recv_channel.CH_L1CA.WideB_Pw_IQ   = zeros(2,1);
        recv_channel.CH_L1CA.NarrowB_Pw_IQ = zeros(2,1);
        
        recv_channel.CH_L1CA.CorrM_Bank.corrM_I_vt = zeros(recv_channel.CH_L1CA.CorrM_Bank.corrM_Num, 1);
        recv_channel.CH_L1CA.CorrM_Bank.corrM_Q_vt = zeros(recv_channel.CH_L1CA.CorrM_Bank.corrM_Num, 1);
        recv_channel.CH_L1CA.CorrM_Bank.normRx_I_vt = zeros(recv_channel.CH_L1CA.CorrM_Bank.corrM_Num, 1);
        recv_channel.CH_L1CA.CorrM_Bank.normRx_Q_vt = zeros(recv_channel.CH_L1CA.CorrM_Bank.corrM_Num, 1);
        
        recv_channel.PLL.REG(1) = recv_channel.CH_L1CA.LO2_fd;
        recv_channel.DLL.REG(1) = recv_channel.CH_L1CA.LO_Fcode_fd;
%         recv_channel.DLL.REG(1) = 0; % When using loopfilter_2nd_variant1 for DLL, the initial value of REG(1) is 0.
        

        recv_channel.KalPreFilt.loopErrState = [0, 0, 0, 0]';
        recv_channel.KalPreFilt.P(1,1)=recv_channel.KalPreFilt.P0(1);
        recv_channel.KalPreFilt.P(2,2)=recv_channel.KalPreFilt.P0(2);
        recv_channel.KalPreFilt.P(3,3)=recv_channel.KalPreFilt.P0(3);
        recv_channel.KalPreFilt.P(4,4)=recv_channel.KalPreFilt.P0(4);

        recv_channel.ALL.NormSampN      = 0;
        recv_channel.ALL.TslotNormSampN = 0;
        recv_channel.ALL.acnt           = 0;
        recv_channel.ALL.SNR            = 0;
        recv_channel.ALL.ai_kalfilt_state = [0, 0]';
        recv_channel.ALL.ai_kalfilt_P(1,1)=recv_channel.ALL.a_kalfilt_P0(1);
        recv_channel.ALL.ai_kalfilt_P(2,2)=recv_channel.ALL.a_kalfilt_P0(2);
        recv_channel.ALL.aq_kalfilt_state = [0, 0]';
        recv_channel.ALL.aq_kalfilt_P(1,1)=recv_channel.ALL.a_kalfilt_P0(1);
        recv_channel.ALL.aq_kalfilt_P(2,2)=recv_channel.ALL.a_kalfilt_P0(2);
        
        recv_channel.STR_CAD.CADLL_MODE = 'CADLL';
        recv_channel.STR_CAD.CAD_STATUS = 'CAD_TRACK';
        % Setting CadCnt to a very large value so as to let the routine not start the new multipath
        % component detecting operations in the pullin status
        recv_channel.STR_CAD.CadCnt     = 1e9; %recv_channel.STR_CAD.CadLoop_NMAX;
        
        recv_channel.STATUS = 'PULLIN';
        recv_channel.CH_L1CA.CH_STATUS = recv_channel.STATUS;
        
    case 'GPS_L1CA_L2C'
        recv_channel.CH_L1CA_L2C.WN         = 0;
        recv_channel.CH_L1CA_L2C.TOW_6SEC   = 0;
        recv_channel.CH_L1CA_L2C.SubFrame_N = 0;
        recv_channel.CH_L1CA_L2C.Word_N     = 0;
        recv_channel.CH_L1CA_L2C.Bit_N      = 0;
        recv_channel.CH_L1CA_L2C.bitInMessage = 0;
        recv_channel.CH_L1CA_L2C.T1ms_N     = 0;
        recv_channel.CH_L1CA_L2C.LO_CodPhs  = 0;
        recv_channel.CH_L1CA_L2C.Tcohn_cnt  = 0;
        recv_channel.CH_L1CA_L2C.Trk_Count  = 0;
        %             recv_channel.CH_L1CA_L2C.fdPre = recv_channel.CH_L1CA_L2C.LO2_fd;
        %             recv_channel.CH_L1CA_L2C.Fcode_fdPre = recv_channel.CH_L1CA_L2C.LO_Fcode_fd;
        recv_channel.CH_L1CA_L2C.LO2_CarPhs  = 0;
        recv_channel.CH_L1CA_L2C.LO2_CarPhs_L2  = 0;

        recv_channel.CH_L1CA_L2C.CN0_Estimator.CN0EstActive = 1;
        recv_channel.CH_L1CA_L2C.CN0_Estimator.muk_cnt = 0;
        recv_channel.CH_L1CA_L2C.CN0_Estimator.mu_avg  = zeros(7,1);
        recv_channel.CH_L1CA_L2C.CN0_Estimator.CN0     = zeros(7,1);

%         recv_channel.CH_L1CA_L2C.CorrM_Bank.corrM_I_vt = zeros(recv_channel.CH_L1CA.CorrM_Bank.corrM_Num, 1);
%         recv_channel.CH_L1CA_L2C.CorrM_Bank.corrM_Q_vt = zeros(recv_channel.CH_L1CA.CorrM_Bank.corrM_Num, 1);
%         recv_channel.CH_L1CA_L2C.CorrM_Bank.normRx_I_vt = zeros(recv_channel.CH_L1CA.CorrM_Bank.corrM_Num, 1);
%         recv_channel.CH_L1CA_L2C.CorrM_Bank.normRx_Q_vt = zeros(recv_channel.CH_L1CA.CorrM_Bank.corrM_Num, 1);
%         
%         recv_channel.PLL.REG(1) = recv_channel.CH_L1CA_L2C.LO2_fd;
%         recv_channel.DLL.REG(1) = recv_channel.CH_L1CA_L2C.LO_Fcode_fd;

        recv_channel.CH_L1CA_L2C.KalPreFilt_L1L2.loopErrState = zeros(6,1);
        recv_channel.CH_L1CA_L2C.KalPreFilt_L1L2.P = diag(recv_channel.CH_L1CA_L2C.KalPreFilt_L1L2.P0);

%         recv_channel.ALL.NormSampN      = 0;
%         recv_channel.ALL.TslotNormSampN = 0;
%         recv_channel.ALL.acnt           = 0;
%         recv_channel.ALL.SNR            = 0;
%         recv_channel.ALL.ai_kalfilt_state = [0, 0]';
%         recv_channel.ALL.ai_kalfilt_P(1,1)=recv_channel.ALL.a_kalfilt_P0(1);
%         recv_channel.ALL.ai_kalfilt_P(2,2)=recv_channel.ALL.a_kalfilt_P0(2);
%         recv_channel.ALL.aq_kalfilt_state = [0, 0]';
%         recv_channel.ALL.aq_kalfilt_P(1,1)=recv_channel.ALL.a_kalfilt_P0(1);
%         recv_channel.ALL.aq_kalfilt_P(2,2)=recv_channel.ALL.a_kalfilt_P0(2);
%         
%         recv_channel.STR_CAD.CADLL_MODE = 'CADLL';
%         recv_channel.STR_CAD.CAD_STATUS = 'CAD_TRACK';
%         recv_channel.STR_CAD.CadCnt     = 1e9; %recv_channel.STR_CAD.CadLoop_NMAX;
        recv_channel.STATUS = 'PULLIN';
        recv_channel.CH_L1CA_L2C.CH_STATUS = recv_channel.STATUS;
    
    case 'BDS_B1I'
        recv_channel.CH_B1I.WN         = 0;
        recv_channel.CH_B1I.SOW        = 0;
        recv_channel.CH_B1I.Frame_N    = 0;
        recv_channel.CH_B1I.SubFrame_N = 0;
        recv_channel.CH_B1I.Word_N     = 0;
        recv_channel.CH_B1I.Bit_N      = 0;
        recv_channel.CH_B1I.T1ms_N     = 0;
        recv_channel.CH_B1I.LO_CodPhs  = 0;
        recv_channel.CH_B1I.Tcohn_cnt  = 0;
        recv_channel.CH_B1I.Trk_Count  = 0;
        recv_channel.CH_B1I.fdPre = recv_channel.CH_B1I.LO2_fd;
        recv_channel.CH_B1I.Fcode_fdPre = recv_channel.CH_B1I.LO_Fcode_fd;
        
        recv_channel.CH_B1I = chn_loopintegrator_initialize(recv_channel.CH_B1I);
%         recv_channel.CH_B1I.Tslot_I    = zeros(3,1);
%         recv_channel.CH_B1I.Tslot_Q    = zeros(3,1);
%         recv_channel.CH_B1I.T_I        = zeros(3,1);
%         recv_channel.CH_B1I.T_Q        = zeros(3,1);
%         recv_channel.CH_B1I.Tcoh_I     = zeros(3,1);
%         recv_channel.CH_B1I.Tcoh_Q     = zeros(3,1);
%         recv_channel.CH_B1I.Tcoh_I_prev= zeros(3,1);
%         recv_channel.CH_B1I.Tcoh_Q_prev= zeros(3,1);
%         recv_channel.CH_B1I.T_pll_I    = zeros(3,1);
%         recv_channel.CH_B1I.T_pll_Q    = zeros(3,1);
%         recv_channel.CH_B1I.PromptIQ_D = zeros(2,1);
        
        recv_channel.CH_B1I.CN0_Estimator.CN0EstActive = 1;
        recv_channel.CH_B1I.muk_cnt = 0;
        recv_channel.CH_B1I.mu_avg  = 0;
        recv_channel.CH_B1I.CN0     = 0;
        recv_channel.CH_B1I.WideB_Pw_IQ   = zeros(2,1);
        recv_channel.CH_B1I.NarrowB_Pw_IQ = zeros(2,1);
        
        recv_channel.CH_B1I.CorrM_Bank.corrM_I_vt = zeros(recv_channel.CH_B1I.CorrM_Bank.corrM_Num, 1);
        recv_channel.CH_B1I.CorrM_Bank.corrM_Q_vt = zeros(recv_channel.CH_B1I.CorrM_Bank.corrM_Num, 1);
        recv_channel.CH_B1I.CorrM_Bank.normRx_I_vt = zeros(recv_channel.CH_B1I.CorrM_Bank.corrM_Num, 1);
        recv_channel.CH_B1I.CorrM_Bank.normRx_Q_vt = zeros(recv_channel.CH_B1I.CorrM_Bank.corrM_Num, 1);
        
        recv_channel.PLL.REG(1) = recv_channel.CH_B1I.LO2_fd;
        recv_channel.DLL.REG(1) = recv_channel.CH_B1I.LO_Fcode_fd;
%         recv_channel.DLL.REG(1) = 0; % When using loopfilter_2nd_variant1 for DLL, the initial value of REG(1) is 0.
        recv_channel.KalPreFilt.loopErrState = [0, 0, 0, 0]';
        recv_channel.KalPreFilt.P(1,1)=recv_channel.KalPreFilt.P0(1);
        recv_channel.KalPreFilt.P(2,2)=recv_channel.KalPreFilt.P0(2);
        recv_channel.KalPreFilt.P(3,3)=recv_channel.KalPreFilt.P0(3);
        recv_channel.KalPreFilt.P(4,4)=recv_channel.KalPreFilt.P0(4);

        recv_channel.ALL.NormSampN      = 0;
        recv_channel.ALL.TslotNormSampN = 0;
        recv_channel.ALL.acnt           = 0;
        recv_channel.ALL.SNR            = 0;
        recv_channel.ALL.ai_kalfilt_state = [0, 0]';
        recv_channel.ALL.ai_kalfilt_P(1,1)=recv_channel.ALL.a_kalfilt_P0(1);
        recv_channel.ALL.ai_kalfilt_P(2,2)=recv_channel.ALL.a_kalfilt_P0(2);
        recv_channel.ALL.aq_kalfilt_state = [0, 0]';
        recv_channel.ALL.aq_kalfilt_P(1,1)=recv_channel.ALL.a_kalfilt_P0(1);
        recv_channel.ALL.aq_kalfilt_P(2,2)=recv_channel.ALL.a_kalfilt_P0(2);
        
        recv_channel.STR_CAD.CADLL_MODE = 'CADLL';
        recv_channel.STR_CAD.CAD_STATUS = 'CAD_TRACK';
        % Setting CadCnt to a very large value so as to let the routine not start the new multipath
        % component detecting operations in the pullin status
        recv_channel.STR_CAD.CadCnt     = 1e9; %recv_channel.STR_CAD.CadLoop_NMAX;
        
        recv_channel.STATUS = 'PULLIN';
        recv_channel.CH_B1I.CH_STATUS = recv_channel.STATUS;
end
