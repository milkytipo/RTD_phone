% This function realizes one channel's cold acquisition initialization.
function acqParameters = CH_Cold_AcqParameters_Init(SYST, navType, chFreqCenter, configPage)

switch SYST
    case 'BDS_B1I'
        switch navType
            case 'B1I_D1'
                acqParameters.tcoh       = configPage.acqConfig.BDS_B1I.NGEO.tcoh;
                acqParameters.noncoh     = configPage.acqConfig.BDS_B1I.NGEO.nnchList;
                acqParameters.freqCenter = chFreqCenter;
                acqParameters.freqBin    = configPage.acqConfig.BDS_B1I.NGEO.freqBin;
                acqParameters.freqRange  = configPage.acqConfig.BDS_B1I.NGEO.coldFreqRange;
                acqParameters.thre_stronmode = configPage.acqConfig.BDS_B1I.NGEO.thre_stronmode;
                acqParameters.thre_weakmode  = configPage.acqConfig.BDS_B1I.NGEO.thre_weakmode;
                
            case 'B1I_D2'
                acqParameters.tcoh       = configPage.acqConfig.BDS_B1I.GEO.tcoh;
                acqParameters.noncoh     = configPage.acqConfig.BDS_B1I.GEO.nnchList;
                acqParameters.freqCenter = chFreqCenter;
                acqParameters.freqBin    = configPage.acqConfig.BDS_B1I.GEO.freqBin;
                acqParameters.freqRange  = configPage.acqConfig.BDS_B1I.GEO.coldFreqRange;
                acqParameters.thre_stronmode = configPage.acqConfig.BDS_B1I.GEO.thre_stronmode;
                acqParameters.thre_weakmode  = configPage.acqConfig.BDS_B1I.GEO.thre_weakmode;
        end
    case 'GPS_L1CA'
        acqParameters.tcoh       = configPage.acqConfig.GPS_L1CA.tcoh;
        acqParameters.noncoh     = configPage.acqConfig.GPS_L1CA.nnchList;
        acqParameters.freqCenter = chFreqCenter;
        acqParameters.freqBin    = configPage.acqConfig.GPS_L1CA.freqBin;
        acqParameters.freqRange  = configPage.acqConfig.GPS_L1CA.coldFreqRange;
        acqParameters.thre_stronmode= configPage.acqConfig.GPS_L1CA.thre_stronmode;
        acqParameters.thre_weakmode = configPage.acqConfig.GPS_L1CA.thre_weakmode;
end