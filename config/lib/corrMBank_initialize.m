function [CorrM_Bank] = corrMBank_initialize(SYST, CorrM_Bank, GSAR_CONSTANTS)

switch SYST
    case 'BDS_B1I'
        CorrM_Bank.corrM_Spacing  = 4;
        CorrM_Bank.corrM_Num      = 5 + 2*round( 2 * GSAR_CONSTANTS.STR_RECV.fs / GSAR_CONSTANTS.STR_B1I.Fcode0 / CorrM_Bank.corrM_Spacing );
        
    case 'GPS_L1CA'
        CorrM_Bank.corrM_Spacing  = 8;
        CorrM_Bank.corrM_Num      = 5 + 2 * round(2 * GSAR_CONSTANTS.STR_RECV.fs / GSAR_CONSTANTS.STR_L1CA.Fcode0 / CorrM_Bank.corrM_Spacing);
end


CorrM_Bank.corrM_I_vt     = zeros(CorrM_Bank.corrM_Num, 1);
CorrM_Bank.corrM_Q_vt     = zeros(CorrM_Bank.corrM_Num, 1);
CorrM_Bank.corrM_Loop_I_vt     = zeros(210, 15); % %此处维度必须与C中保持一致
CorrM_Bank.corrM_Loop_Q_vt     = zeros(210, 15);
CorrM_Bank.uncancelled_corrM_I_vt = zeros(CorrM_Bank.corrM_Num, 1);
CorrM_Bank.uncancelled_corrM_Q_vt = zeros(CorrM_Bank.corrM_Num, 1);
CorrM_Bank.normRx_I_vt    = zeros(CorrM_Bank.corrM_Num, 1);
CorrM_Bank.normRx_Q_vt    = zeros(CorrM_Bank.corrM_Num, 1);
CorrM_Bank.normRx_vt      = zeros(CorrM_Bank.corrM_Num, 1);
CorrM_Bank.corrM_I_vt_Save= zeros(CorrM_Bank.corrM_Num, 1);
CorrM_Bank.corrM_Q_vt_Save= zeros(CorrM_Bank.corrM_Num, 1);
CorrM_Bank.uncancelled_corrM_I_vt_Save = zeros(CorrM_Bank.corrM_Num, 1);
CorrM_Bank.uncancelled_corrM_Q_vt_Save = zeros(CorrM_Bank.corrM_Num, 1);