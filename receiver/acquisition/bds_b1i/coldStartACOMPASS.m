function acqResults = coldStartACOMPASS(recv_cfg, acq_cfg)

% simple scheme: first GEO then Non-GEO
GEOVisible = acq_cfg.svVisible (acq_cfg.svVisible <= 5);
NGEOVisible = acq_cfg.svVisible (acq_cfg.svVisible > 5);
% find caldop of each satellite
GEOVisible_pos = find(acq_cfg.svVisible  <= 5);
NGEOVisible_pos = find(acq_cfg.svVisible > 5);
% acq_cfg_GEO.caldop = acq_cfg.caldop(GEOVisible_pos);
% acq_cfg_NGEO.caldop = acq_cfg.caldop(NGEOVisible_pos);
%
if isempty(GEOVisible)
    if isempty(NGEOVisible)
        fprintf('no visible satellitie ');
        acqResults =  defineAcqResult();
        return
    else
        acqResultsGEO = defineAcqResult();
        % acquire none GEO satellites
        acq_cfg_NGEO = acq_cfg.NGEO;
        recv_cfg.bitFreq           = recv_cfg.bitFreqD2;
        acq_cfg_NGEO.svVisible     = NGEOVisible;
%         acq_cfg_NGEO.caldop = acq_cfg.caldop(2);
        acq_cfg_NGEO.caldop = acq_cfg.caldop(NGEOVisible_pos);
        acqResultsNGEO = acquireACompass(recv_cfg, acq_cfg_NGEO);
        acqResults = [acqResultsNGEO];
        % ----------------FOR TEST :XQJ--------------------%
%         acqResultsNGEO = acquireACompass_dop(recv_cfg, acq_cfg_NGEO);
        %  acqResultsNGEO = acquireGPSSat_test(recv_cfg, acq_cfg_NGEO);
        %--------------------------------------------------%
    end
else
     % acquire GEO satellites
        acq_cfg_GEO = acq_cfg.GEO;
        recv_cfg.bitFreq           = recv_cfg.bitFreqD2;
        acq_cfg_GEO.svVisible      = GEOVisible;
        acq_cfg_GEO.caldop = acq_cfg.caldop(GEOVisible_pos);
        % acqResultsGEO = acquireCompassSat(recv_cfg, acq_cfg_GEO, 1);
        acqResultsGEO = acquireACompass(recv_cfg, acq_cfg_GEO);
        % ----------------FOR TEST :XQJ--------------------%
%         acqResultsGEO = acquireACompass_dop(recv_cfg, acq_cfg_GEO);
%         acqResultsGEO = acquireGPSSat(recv_cfg, acq_cfg_GEO);
        %--------------------------------------------------%
    if isempty(NGEOVisible)
%         acqResultsNGEO = defineAcqResult(); 
         acqResults = [acqResultsGEO];
    else
        % acquire none GEO satellites
        acq_cfg_NGEO = acq_cfg.NGEO;
        recv_cfg.bitFreq           = recv_cfg.bitFreqD2;
        acq_cfg_NGEO.svVisible     = NGEOVisible;
        acq_cfg_NGEO.caldop = acq_cfg.caldop(NGEOVisible_pos);
        % acqResultsNGEO = acquireCompassSat(recv_cfg, acq_cfg_NGEO, 0);
        acqResultsNGEO = acquireACompass(recv_cfg, acq_cfg_NGEO);
         acqResults = [acqResultsGEO acqResultsNGEO];
        % ----------------FOR TEST :XQJ--------------------%
%         acqResultsNGEO = acquireACompass_dop(recv_cfg, acq_cfg_NGEO);
        %  acqResultsNGEO = acquireGPSSat_test(recv_cfg, acq_cfg_NGEO);
        %--------------------------------------------------%
    end
end
% RESULTS
% acqResults = [acqResultsGEO acqResultsNGEO];
end

