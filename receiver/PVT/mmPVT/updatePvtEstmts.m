function [mmPvtEstmts] = updatePvtEstmts(mmPvtEstmts, pos_xyz, vel_xyz, DOP,cdtu, prError, activChn_raim_bds, activChn_raim_gps,SYST)

[ ~, ~, Hight ] = cart2geo( pos_xyz(1), pos_xyz(2), pos_xyz(3), 5 );

pvtEstmtsL1 = mmPvtEstmts.pvtEstmtsL1;
estCnt1     = pvtEstmtsL1.estCnt;
pvtEstmtsL2 = mmPvtEstmts.pvtEstmtsL2;
estCnt2     = pvtEstmtsL2.estCnt;
pvtEstmtsL3 = mmPvtEstmts.pvtEstmtsL3;
estCnt3     = pvtEstmtsL3.estCnt;
pvtEstmtsL4 = mmPvtEstmts.pvtEstmtsL4;
estCnt4     = pvtEstmtsL4.estCnt;


% Level 1 pvt estimation consists of all pvt estimations
% estCnt1 = estCnt1 + 1;
% pvtEstmtsL1.pos_xyz = [pvtEstmtsL1.pos_xyz pos_xyz];
% pvtEstmtsL1.vel_xyz = [pvtEstmtsL1.vel_xyz vel_xyz];
% pvtEstmtsL1.DOP     = [pvtEstmtsL1.DOP DOP];
% pvtEstmtsL1.clkCorr     = [pvtEstmtsL1.clkCorr cdtu];
% pvtEstmtsL1.prError     = [pvtEstmtsL1.prError sum(abs(prError))];
% if ~isempty(activChn_raim_bds)
%     pvtEstmtsL1.PRN.sat_actv(estCnt1).BDS = activChn_raim_bds(2,:);
% end
% if ~isempty(activChn_raim_gps)
%     pvtEstmtsL1.PRN.sat_actv(estCnt1).GPS = activChn_raim_gps(2,:);
% end
% pvtEstmtsL1.estCnt = estCnt1;
% mmPvtEstmts.pvtEstmtsL1 = pvtEstmtsL1;
% pvtEstmtsL1.pvtSats = [pvtEstmtsL1.pvtSats  [size(activChn_raim_bds,2);size(activChn_raim_gps,2)]];
% nmbOfSat_inraim_bds = pvtEstmtsL1.nmbOfSat_inraim_bds;
% nmbOfSat_inraim_bds(size(nmbOfSat_inraim_bds,1)+1,1:size(activChn_raim_bds,2)) = activChn_raim_bds(2,:);
% pvtEstmtsL1.nmbOfSat_inraim_bds = nmbOfSat_inraim_bds;
% nmbOfSat_inraim_gps = pvtEstmtsL1.nmbOfSat_inraim_gps;
% nmbOfSat_inraim_gps(size(nmbOfSat_inraim_gps,1)+1,1:size(activChn_raim_gps,2)) = activChn_raim_gps(2,:);
% pvtEstmtsL1.nmbOfSat_inraim_gps = nmbOfSat_inraim_gps;
% mmPvtEstmts.pvtEstmtsL1 =  pvtEstmtsL1;
switch SYST
    case 'BDS_B1I'
        % Level 1 pvt estimation consists of all pvt estimations
        estCnt1 = estCnt1 + 1;
        pvtEstmtsL1.pos_xyz = [pvtEstmtsL1.pos_xyz pos_xyz];
        pvtEstmtsL1.vel_xyz = [pvtEstmtsL1.vel_xyz vel_xyz];
        pvtEstmtsL1.DOP     = [pvtEstmtsL1.DOP DOP];
        pvtEstmtsL1.clkCorr     = [pvtEstmtsL1.clkCorr cdtu];
        pvtEstmtsL1.prError     = [pvtEstmtsL1.prError sum(abs(prError))];
        pvtEstmtsL1.PRN.sat_actv(estCnt1).BDS = activChn_raim_bds(2,:);
        pvtEstmtsL1.PRN.sat_actv(estCnt1).GPS = 0;
        pvtEstmtsL1.pvtSats = [pvtEstmtsL1.pvtSats  [size(activChn_raim_bds,2);0]];
        pvtEstmtsL1.estCnt = estCnt1;
        mmPvtEstmts.pvtEstmtsL1 = pvtEstmtsL1;
        
        % level 2 correction
        if Hight>-100 && Hight<500
            estCnt2 = estCnt2 + 1;
            pvtEstmtsL2.PRN.sat_actv(estCnt2).BDS = activChn_raim_bds(2,:);
            pvtEstmtsL2.PRN.sat_actv(estCnt2).GPS = 0;
            pvtEstmtsL2.pos_xyz = [pvtEstmtsL2.pos_xyz pos_xyz];
            pvtEstmtsL2.vel_xyz = [pvtEstmtsL2.vel_xyz vel_xyz];
            pvtEstmtsL2.DOP     = [pvtEstmtsL2.DOP DOP];
            pvtEstmtsL2.clkCorr     = [pvtEstmtsL2.clkCorr cdtu];
            pvtEstmtsL2.prError     = [pvtEstmtsL2.prError sum(abs(prError))];
            pvtEstmtsL2.pvtSats = [pvtEstmtsL2.pvtSats  [size(activChn_raim_bds,2);0]];
%             nmbOfSat_inraim_bds = pvtEstmtsL2.nmbOfSat_inraim_bds;
%             nmbOfSat_inraim_bds(size(nmbOfSat_inraim_bds,1)+1,1:size(activChn_raim_bds,2)) = activChn_raim_bds(2,:);
%             pvtEstmtsL2.nmbOfSat_inraim_bds = nmbOfSat_inraim_bds;
%             nmbOfSat_inraim_gps = [];
%             nmbOfSat_inraim_gps(size(nmbOfSat_inraim_gps,1)+1,1:size(activChn_raim_gps,2)) = [];
%             pvtEstmtsL2.nmbOfSat_inraim_gps = [];
            pvtEstmtsL2.estCnt = estCnt2;
            mmPvtEstmts.pvtEstmtsL2 =  pvtEstmtsL2;
            % level 3 correction
            if Hight>-30 && Hight<100
                estCnt3 = estCnt3 +1;
                pvtEstmtsL3.PRN.sat_actv(estCnt3).BDS = activChn_raim_bds(2,:);
                pvtEstmtsL3.PRN.sat_actv(estCnt3).GPS = 0;
                pvtEstmtsL3.pos_xyz = [pvtEstmtsL3.pos_xyz pos_xyz];
                pvtEstmtsL3.vel_xyz = [pvtEstmtsL3.vel_xyz vel_xyz];
                pvtEstmtsL3.DOP     = [pvtEstmtsL3.DOP DOP];
                pvtEstmtsL3.clkCorr     = [pvtEstmtsL3.clkCorr cdtu];
                pvtEstmtsL3.prError     = [pvtEstmtsL3.prError sum(abs(prError))];
                pvtEstmtsL3.pvtSats = [pvtEstmtsL3.pvtSats  [size(activChn_raim_bds,2);0]];
%                 nmbOfSat_inraim_bds = pvtEstmtsL3.nmbOfSat_inraim_bds;
%                 nmbOfSat_inraim_bds(size(nmbOfSat_inraim_bds,1)+1,1:size(activChn_raim_bds,2)) = activChn_raim_bds(2,:);
%                 pvtEstmtsL3.nmbOfSat_inraim_bds = nmbOfSat_inraim_bds;
%                 nmbOfSat_inraim_gps = pvtEstmtsL3.nmbOfSat_inraim_gps;
%                 nmbOfSat_inraim_gps(size(nmbOfSat_inraim_gps,1)+1,1:size(activChn_raim_gps,2)) = activChn_raim_gps(2,:);
%                 pvtEstmtsL3.nmbOfSat_inraim_gps = nmbOfSat_inraim_gps;
                pvtEstmtsL3.estCnt = estCnt3;
                mmPvtEstmts.pvtEstmtsL3 =  pvtEstmtsL3;
                % level 4 correction
                if (Hight>0) && (DOP(1)<20) && (Hight<50)
                    estCnt4= estCnt4 +1;
                    pvtEstmtsL4.PRN.sat_actv(estCnt4).BDS = activChn_raim_bds(2,:);
                    pvtEstmtsL4.PRN.sat_actv(estCnt4).GPS = 0;
                    pvtEstmtsL4.pos_xyz = [pvtEstmtsL4.pos_xyz pos_xyz];
                    pvtEstmtsL4.vel_xyz = [pvtEstmtsL4.vel_xyz vel_xyz];
                    pvtEstmtsL4.DOP     = [pvtEstmtsL4.DOP DOP];
                    pvtEstmtsL4.clkCorr     = [pvtEstmtsL4.clkCorr cdtu];
                    pvtEstmtsL4.prError     = [pvtEstmtsL4.prError sum(abs(prError))];
                    pvtEstmtsL4.pvtSats = [pvtEstmtsL4.pvtSats  [size(activChn_raim_bds,2);0]];
%                     nmbOfSat_inraim_bds = pvtEstmtsL4.nmbOfSat_inraim_bds;
%                     nmbOfSat_inraim_bds(size(nmbOfSat_inraim_bds,1)+1,1:size(activChn_raim_bds,2)) = activChn_raim_bds(2,:);
%                     pvtEstmtsL4.nmbOfSat_inraim_bds = nmbOfSat_inraim_bds;
%                     nmbOfSat_inraim_gps = pvtEstmtsL1.nmbOfSat_inraim_gps;
%                     nmbOfSat_inraim_gps(size(nmbOfSat_inraim_gps,1)+1,1:size(activChn_raim_gps,2)) = activChn_raim_gps(2,:);
%                     pvtEstmtsL4.nmbOfSat_inraim_gps = nmbOfSat_inraim_gps;
                    pvtEstmtsL4.estCnt = estCnt4;
                    mmPvtEstmts.pvtEstmtsL4 =  pvtEstmtsL4;
                 end % level4
            end %  level 3
        end % level 2      
            
        
    case 'GPS_L1CA'
        % Level 1 pvt estimation consists of all pvt estimations
        estCnt1 = estCnt1 + 1;
        pvtEstmtsL1.pos_xyz = [pvtEstmtsL1.pos_xyz pos_xyz];
        pvtEstmtsL1.vel_xyz = [pvtEstmtsL1.vel_xyz vel_xyz];
        pvtEstmtsL1.DOP     = [pvtEstmtsL1.DOP DOP];
        pvtEstmtsL1.clkCorr     = [pvtEstmtsL1.clkCorr cdtu];
        pvtEstmtsL1.prError     = [pvtEstmtsL1.prError sum(abs(prError))];
        pvtEstmtsL1.PRN.sat_actv(estCnt1).BDS = 0;
        pvtEstmtsL1.PRN.sat_actv(estCnt1).GPS = activChn_raim_gps(2,:);
        pvtEstmtsL1.pvtSats = [pvtEstmtsL1.pvtSats  [0;size(activChn_raim_gps,2)]];
        pvtEstmtsL1.estCnt = estCnt1;
        mmPvtEstmts.pvtEstmtsL1 = pvtEstmtsL1;
        
        % level 2 correction
        if Hight>-100 && Hight<500
            estCnt2 = estCnt2 + 1;
            pvtEstmtsL2.PRN.sat_actv(estCnt2).BDS = 0;
            pvtEstmtsL2.PRN.sat_actv(estCnt2).GPS = activChn_raim_gps(2,:);
            pvtEstmtsL2.pos_xyz = [pvtEstmtsL2.pos_xyz pos_xyz];
            pvtEstmtsL2.vel_xyz = [pvtEstmtsL2.vel_xyz vel_xyz];
            pvtEstmtsL2.DOP     = [pvtEstmtsL2.DOP DOP];
            pvtEstmtsL2.clkCorr     = [pvtEstmtsL2.clkCorr cdtu];
            pvtEstmtsL2.prError     = [pvtEstmtsL2.prError sum(abs(prError))];
            pvtEstmtsL2.pvtSats = [pvtEstmtsL2.pvtSats  [0;size(activChn_raim_gps,2)]];
%             nmbOfSat_inraim_bds = pvtEstmtsL2.nmbOfSat_inraim_bds;
%             nmbOfSat_inraim_bds(size(nmbOfSat_inraim_bds,1)+1,1:size(activChn_raim_bds,2)) = activChn_raim_bds(2,:);
%             pvtEstmtsL2.nmbOfSat_inraim_bds = nmbOfSat_inraim_bds;
%             nmbOfSat_inraim_gps = pvtEstmtsL2.nmbOfSat_inraim_gps;
%             nmbOfSat_inraim_gps(size(nmbOfSat_inraim_gps,1)+1,1:size(activChn_raim_gps,2)) = activChn_raim_gps(2,:);
%             pvtEstmtsL2.nmbOfSat_inraim_gps = nmbOfSat_inraim_gps;
            pvtEstmtsL2.estCnt = estCnt2;
            mmPvtEstmts.pvtEstmtsL2 =  pvtEstmtsL2;
            % level 3 correction
            if Hight>-50 && Hight<100
                estCnt3 = estCnt3 +1;
                pvtEstmtsL3.PRN.sat_actv(estCnt3).BDS = 0;
                pvtEstmtsL3.PRN.sat_actv(estCnt3).GPS = activChn_raim_gps(2,:);
                pvtEstmtsL3.pos_xyz = [pvtEstmtsL3.pos_xyz pos_xyz];
                pvtEstmtsL3.vel_xyz = [pvtEstmtsL3.vel_xyz vel_xyz];
                pvtEstmtsL3.DOP     = [pvtEstmtsL3.DOP DOP];
                pvtEstmtsL3.clkCorr     = [pvtEstmtsL3.clkCorr cdtu];
                pvtEstmtsL3.prError     = [pvtEstmtsL3.prError sum(abs(prError))];
                pvtEstmtsL3.pvtSats = [pvtEstmtsL3.pvtSats  [0;size(activChn_raim_gps,2)]];
%                 nmbOfSat_inraim_bds = pvtEstmtsL3.nmbOfSat_inraim_bds;
%                 nmbOfSat_inraim_bds(size(nmbOfSat_inraim_bds,1)+1,1:size(activChn_raim_bds,2)) = activChn_raim_bds(2,:);
%                 pvtEstmtsL3.nmbOfSat_inraim_bds = nmbOfSat_inraim_bds;
%                 nmbOfSat_inraim_gps = pvtEstmtsL3.nmbOfSat_inraim_gps;
%                 nmbOfSat_inraim_gps(size(nmbOfSat_inraim_gps,1)+1,1:size(activChn_raim_gps,2)) = activChn_raim_gps(2,:);
%                 pvtEstmtsL3.nmbOfSat_inraim_gps = nmbOfSat_inraim_gps;
                pvtEstmtsL3.estCnt = estCnt3;
                mmPvtEstmts.pvtEstmtsL3 =  pvtEstmtsL3;
                % level 4 correction
                if (Hight>0) && (DOP(1)<20) && (Hight<50)
                    estCnt4= estCnt4 +1;
                    pvtEstmtsL4.PRN.sat_actv(estCnt4).BDS = 0;
                    pvtEstmtsL4.PRN.sat_actv(estCnt4).GPS = activChn_raim_gps(2,:);
                    pvtEstmtsL4.pos_xyz = [pvtEstmtsL4.pos_xyz pos_xyz];
                    pvtEstmtsL4.vel_xyz = [pvtEstmtsL4.vel_xyz vel_xyz];
                    pvtEstmtsL4.DOP     = [pvtEstmtsL4.DOP DOP];
                    pvtEstmtsL4.clkCorr     = [pvtEstmtsL4.clkCorr cdtu];
                    pvtEstmtsL4.prError     = [pvtEstmtsL4.prError sum(abs(prError))];
                    pvtEstmtsL4.pvtSats = [pvtEstmtsL4.pvtSats  [0;size(activChn_raim_gps,2)]];
%                     nmbOfSat_inraim_bds = pvtEstmtsL4.nmbOfSat_inraim_bds;
%                     nmbOfSat_inraim_bds(size(nmbOfSat_inraim_bds,1)+1,1:size(activChn_raim_bds,2)) = activChn_raim_bds(2,:);
%                     pvtEstmtsL4.nmbOfSat_inraim_bds = nmbOfSat_inraim_bds;
%                     nmbOfSat_inraim_gps = pvtEstmtsL1.nmbOfSat_inraim_gps;
%                     nmbOfSat_inraim_gps(size(nmbOfSat_inraim_gps,1)+1,1:size(activChn_raim_gps,2)) = activChn_raim_gps(2,:);
%                     pvtEstmtsL4.nmbOfSat_inraim_gps = nmbOfSat_inraim_gps;
                    pvtEstmtsL4.estCnt = estCnt4;
                    mmPvtEstmts.pvtEstmtsL4 =  pvtEstmtsL4;
                 end % level4
            end %  level 3
        end % level 2      
        
    case 'B1I_L1CA'
        
        % Level 1 pvt estimation consists of all pvt estimations
        estCnt1 = estCnt1 + 1;
        pvtEstmtsL1.pos_xyz = [pvtEstmtsL1.pos_xyz pos_xyz];
        pvtEstmtsL1.vel_xyz = [pvtEstmtsL1.vel_xyz vel_xyz];
        pvtEstmtsL1.DOP     = [pvtEstmtsL1.DOP DOP];
        pvtEstmtsL1.clkCorr     = [pvtEstmtsL1.clkCorr cdtu];
        pvtEstmtsL1.prError     = [pvtEstmtsL1.prError sum(abs(prError))];
        pvtEstmtsL1.pvtSats = [pvtEstmtsL1.pvtSats  [size(activChn_raim_bds,2);size(activChn_raim_gps,2)]];
        pvtEstmtsL1.PRN.sat_actv(estCnt1).BDS = activChn_raim_bds(2,:);
        
        
        pvtEstmtsL1.PRN.sat_actv(estCnt1).GPS = activChn_raim_gps(2,:);

        pvtEstmtsL1.estCnt = estCnt1;
        mmPvtEstmts.pvtEstmtsL1 = pvtEstmtsL1;
        
        % level 2 correction
        if Hight>-100 && Hight<500
            estCnt2 = estCnt2 + 1;
            pvtEstmtsL2.PRN.sat_actv(estCnt2).BDS = activChn_raim_bds(2,:);
            pvtEstmtsL2.PRN.sat_actv(estCnt2).GPS = activChn_raim_gps(2,:);
            pvtEstmtsL2.pos_xyz = [pvtEstmtsL2.pos_xyz pos_xyz];
            pvtEstmtsL2.vel_xyz = [pvtEstmtsL2.vel_xyz vel_xyz];
            pvtEstmtsL2.DOP     = [pvtEstmtsL2.DOP DOP];
            pvtEstmtsL2.clkCorr     = [pvtEstmtsL2.clkCorr cdtu];
            pvtEstmtsL2.prError     = [pvtEstmtsL2.prError sum(abs(prError))];
            pvtEstmtsL2.pvtSats = [pvtEstmtsL2.pvtSats  [size(activChn_raim_bds,2);size(activChn_raim_gps,2)]];
            
            pvtEstmtsL2.estCnt = estCnt2;
            mmPvtEstmts.pvtEstmtsL2 =  pvtEstmtsL2;
            % level 3 correction
            if Hight>-50 && Hight<100
                estCnt3 = estCnt3 +1;
                pvtEstmtsL3.PRN.sat_actv(estCnt3).BDS = activChn_raim_bds(2,:);
                pvtEstmtsL3.PRN.sat_actv(estCnt3).GPS = activChn_raim_gps(2,:);
                pvtEstmtsL3.pos_xyz = [pvtEstmtsL3.pos_xyz pos_xyz];
                pvtEstmtsL3.vel_xyz = [pvtEstmtsL3.vel_xyz vel_xyz];
                pvtEstmtsL3.DOP     = [pvtEstmtsL3.DOP DOP];
                pvtEstmtsL3.clkCorr     = [pvtEstmtsL3.clkCorr cdtu];
                pvtEstmtsL3.prError     = [pvtEstmtsL3.prError sum(abs(prError))];
                pvtEstmtsL3.pvtSats = [pvtEstmtsL3.pvtSats  [size(activChn_raim_bds,2);size(activChn_raim_gps,2)]];
                
                pvtEstmtsL3.estCnt = estCnt3;
                mmPvtEstmts.pvtEstmtsL3 =  pvtEstmtsL3;
                % level 4 correction
                if (Hight>0) && (DOP(1)<20) && (Hight<50)
                    estCnt4= estCnt4 +1;
                    pvtEstmtsL4.PRN.sat_actv(estCnt4).BDS = activChn_raim_bds(2,:);
                    pvtEstmtsL4.PRN.sat_actv(estCnt4).GPS = activChn_raim_gps(2,:);
                    pvtEstmtsL4.pos_xyz = [pvtEstmtsL4.pos_xyz pos_xyz];
                    pvtEstmtsL4.vel_xyz = [pvtEstmtsL4.vel_xyz vel_xyz];
                    pvtEstmtsL4.DOP     = [pvtEstmtsL4.DOP DOP];
                    pvtEstmtsL4.clkCorr     = [pvtEstmtsL4.clkCorr cdtu];
                    pvtEstmtsL4.prError     = [pvtEstmtsL4.prError sum(abs(prError))];
                    pvtEstmtsL4.pvtSats = [pvtEstmtsL4.pvtSats  [size(activChn_raim_bds,2);size(activChn_raim_gps,2)]];
                    
                    pvtEstmtsL4.estCnt = estCnt4;
                    mmPvtEstmts.pvtEstmtsL4 =  pvtEstmtsL4;
                 end % level4
            end %  level 3
        end % level 2                               
end
