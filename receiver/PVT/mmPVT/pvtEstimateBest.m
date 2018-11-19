function [pos_xyz,vel_xyz,cdtu,DOP,pvtS_Num,sat_inraim_bds, sat_inraim_gps,  mmpvt_coder] = pvtEstimateBest(mmPvtEstmts,posPredicted,pvtForecast,mm_raim_coder) 
% this function selects the best estimate. Selection is based on multiple
% options
%--- 1. Multiple positions are available raim pass/raim failed
%--- 2. Single position and raim is passed
%--- 3. Single position and raim is failed

% 1. if more than one estimates are available
pvtEstmtsL1 = mmPvtEstmts.pvtEstmtsL1;
pvtEstmtsL2 = mmPvtEstmts.pvtEstmtsL2;
pvtEstmtsL3 = mmPvtEstmts.pvtEstmtsL3;
pvtEstmtsL4 = mmPvtEstmts.pvtEstmtsL4;
sat_inraim_bds = [];
sat_inraim_gps = [];
multiEstValid = 0;
validL1 = 0;
validL2 = 0;
validL3 = 0;
validL4 = 0;
mmpvt_coder = 0;
% if pvtEstmtsL1.estCnt>1
%     multiEstValid = 1;
% end 

% check final estimate level to find position
if pvtEstmtsL1.estCnt >=1
    validL1 = 1;
end
if pvtEstmtsL2.estCnt >=1
    validL2 = 1;
end
if pvtEstmtsL3.estCnt >=1
    validL3 = 1;
end
if pvtEstmtsL4.estCnt >=1
    validL4 = 1;
end

%if mm_raim_coder && multiEstValid   % if raim pass and multiple estimates are available
    if validL4   % L4 position is available
        if pvtForecast
%             posPredicted = mean(pvtEstmtsL4.pos_xyz,2);
            for n=1:pvtEstmtsL4.estCnt
                pvtL4Dist(n) = sqrt((pvtEstmtsL4.pos_xyz(1,n) - posPredicted(1))^2 + (pvtEstmtsL4.pos_xyz(2,n) - posPredicted(2))^2 + ...
                                    (pvtEstmtsL4.pos_xyz(3,n) - posPredicted(3))^2);
            end
            % in this case final position will be the one with minimum
            % distance from predicted one
            [~,id] = min(pvtL4Dist);
            pos_xyz = pvtEstmtsL4.pos_xyz(:,id);
            vel_xyz = pvtEstmtsL4.vel_xyz(:,id);
            DOP     = pvtEstmtsL4.DOP(:,id);
            pvtS_Num(1) = pvtEstmtsL4.pvtSats(1,id);
            pvtS_Num(2) = pvtEstmtsL4.pvtSats(2,id);
            cdtu = pvtEstmtsL4.clkCorr(:,id);
%             sat_inraim_bds1 = pvtEstmtsL4.nmbOfSat_inraim_bds(id,:);
%             if ~isempty(pvtEstmtsL4.PRN.sat_actv.BDS)
                sat_inraim_bds = pvtEstmtsL4.PRN.sat_actv(id).BDS;
%             else
%                 sat_inraim_bds = [];
%             end
%             sat_inraim_gps1 = pvtEstmtsL4.nmbOfSat_inraim_gps(id,:);
%             if ~siempty(pvtEstmtsL4.PRN.sat_actv.GPS)
                sat_inraim_gps =  pvtEstmtsL4.PRN.sat_actv(id).GPS;
%             else
%                 sat_inraim_gps = [];
%             end
            mmpvt_coder = 4;
        else % if L4 positions are avialble and pvtForecast is not valid
            % compute the mean position 
            pos_mean = mean(pvtEstmtsL4.pos_xyz,2);
            % compute the distance of all positions from mean positions
            for n=1:pvtEstmtsL4.estCnt
                pvtL4Dist(n) = sqrt((pvtEstmtsL4.pos_xyz(1,n) - pos_mean(1))^2 + (pvtEstmtsL4.pos_xyz(2,n) - pos_mean(2))^2 + ...
                                    (pvtEstmtsL4.pos_xyz(3,n) - pos_mean(3))^2);
                
            end
            % final position will be the one with leasr distance from mean
            % position
            [~,id] = min(pvtL4Dist);
            pos_xyz = pvtEstmtsL4.pos_xyz(:,id);
            vel_xyz = pvtEstmtsL4.vel_xyz(:,id);
            DOP     = pvtEstmtsL4.DOP(:,id);
            cdtu = pvtEstmtsL4.clkCorr(:,id);
            pvtS_Num(1) = pvtEstmtsL4.pvtSats(1,id);
            pvtS_Num(2) = pvtEstmtsL4.pvtSats(2,id);
%             sat_inraim_bds1 = pvtEstmtsL4.nmbOfSat_inraim_bds(id,:);
%             if ~isempty(pvtEstmtsL4.PRN.sat_actv.BDS)
                sat_inraim_bds = pvtEstmtsL4.PRN.sat_actv(id).BDS;
%             else
%                 sat_inraim_bds = [];
%             end
%             sat_inraim_gps1 = pvtEstmtsL4.nmbOfSat_inraim_gps(id,:);
%             if ~siempty(pvtEstmtsL4.PRN.sat_actv.GPS)
                sat_inraim_gps =  pvtEstmtsL4.PRN.sat_actv(id).GPS;
%             else
%                 sat_inraim_gps = [];
%             end
            
            mmpvt_coder = 4;
        end
    elseif ~validL4 && validL3 % L3 position is avaialbe
        if pvtForecast
            for n=1:pvtEstmtsL3.estCnt
                pvtL3Dist(n) = sqrt((pvtEstmtsL3.pos_xyz(1,n) - posPredicted(1))^2 + (pvtEstmtsL3.pos_xyz(2,n) - posPredicted(2))^2 + ...
                                    (pvtEstmtsL3.pos_xyz(3,n) - posPredicted(3))^2);
            end
            % in this case final position will be the one with minimum
            % distance from predicted one
            [~,id] = min(pvtL3Dist);
            pos_xyz = pvtEstmtsL3.pos_xyz(:,id);
            vel_xyz = pvtEstmtsL3.vel_xyz(:,id);
            DOP     = pvtEstmtsL3.DOP(:,id);
            pvtS_Num(1) = pvtEstmtsL3.pvtSats(1,id);
            pvtS_Num(2) = pvtEstmtsL3.pvtSats(2,id);
            cdtu = pvtEstmtsL3.clkCorr(:,id);
%             sat_inraim_bds1 = pvtEstmtsL3.nmbOfSat_inraim_bds(id,:);
%             if ~isempty(pvtEstmtsL3.PRN.sat_actv.BDS)
                sat_inraim_bds = pvtEstmtsL3.PRN.sat_actv(id).BDS;
%             else
%                 sat_inraim_bds = [];
%             end
%             sat_inraim_gps1 = pvtEstmtsL3.nmbOfSat_inraim_gps(id,:);
%             if ~siempty(pvtEstmtsL3.PRN.sat_actv.GPS)
                sat_inraim_gps =  pvtEstmtsL3.PRN.sat_actv(id).GPS;
%             else
%                 sat_inraim_gps = [];
%             end
            mmpvt_coder = 3;
        else % if L4 positions are avialble and pvtForecast is not valid
            % compute the mean position 
            pos_mean = mean(pvtEstmtsL3.pos_xyz,2);
            % compute the distance of all positions from mean positions
            for n=1:pvtEstmtsL3.estCnt
                pvtL3Dist(n) = sqrt((pvtEstmtsL3.pos_xyz(1,n) - pos_mean(1))^2 + (pvtEstmtsL3.pos_xyz(2,n) - pos_mean(2))^2 + ...
                                    (pvtEstmtsL3.pos_xyz(3,n) - pos_mean(3))^2);
                
            end
            % final position will be the one with leasr distance from mean
            % position
            [~,id] = min(pvtL3Dist);
            pos_xyz = pvtEstmtsL3.pos_xyz(:,id);
            vel_xyz = pvtEstmtsL3.vel_xyz(:,id);
            DOP     = pvtEstmtsL3.DOP(:,id);
            pvtS_Num(1) = pvtEstmtsL3.pvtSats(1,id);
            pvtS_Num(2) = pvtEstmtsL3.pvtSats(2,id);
            cdtu = pvtEstmtsL3.clkCorr(:,id);
%             sat_inraim_bds1 = pvtEstmtsL3.nmbOfSat_inraim_bds(id,:);
%             if ~isempty(pvtEstmtsL3.PRN.sat_actv.BDS)
                sat_inraim_bds = pvtEstmtsL3.PRN.sat_actv(id).BDS;
%             else
%                 sat_inraim_bds = [];
%             end
%             sat_inraim_gps1 = pvtEstmtsL3.nmbOfSat_inraim_gps(id,:);
%             if ~siempty(pvtEstmtsL3.PRN.sat_actv.GPS)
                sat_inraim_gps =  pvtEstmtsL3.PRN.sat_actv(id).GPS;
%             else
%                 sat_inraim_gps = [];
%             end
            mmpvt_coder = 3;
        end
        
    elseif ~validL4 && ~validL3 && validL2 % L2 posiiton is available
        if pvtForecast
            for n=1:pvtEstmtsL2.estCnt
                pvtL2Dist(n) = sqrt((pvtEstmtsL2.pos_xyz(1,n) - posPredicted(1))^2 + (pvtEstmtsL2.pos_xyz(2,n) - posPredicted(2))^2 + ...
                                    (pvtEstmtsL2.pos_xyz(3,n) - posPredicted(3))^2);
            end
            % in this case final position will be the one with minimum
            % distance from predicted one
            [~,id] = min(pvtL2Dist);
            pos_xyz = pvtEstmtsL2.pos_xyz(:,id);
            vel_xyz = pvtEstmtsL2.vel_xyz(:,id);
            DOP     = pvtEstmtsL2.DOP(:,id);
            pvtS_Num(1) = pvtEstmtsL2.pvtSats(1,id);
            pvtS_Num(2) = pvtEstmtsL2.pvtSats(2,id);
            cdtu = pvtEstmtsL2.clkCorr(:,id);
%             sat_inraim_bds1 = pvtEstmtsL2.nmbOfSat_inraim_bds(id,:);
%             if ~isempty(pvtEstmtsL2.PRN.sat_actv.BDS)
                sat_inraim_bds = pvtEstmtsL2.PRN.sat_actv(id).BDS;
%             else
%                 sat_inraim_bds = [];
%             end
%             sat_inraim_gps1 = pvtEstmtsL2.nmbOfSat_inraim_gps(id,:);
%             if ~siempty(pvtEstmtsL2.PRN.sat_actv.GPS)
                sat_inraim_gps =  pvtEstmtsL2.PRN.sat_actv(id).GPS;
%             else
%                 sat_inraim_gps = [];
%             end
            mmpvt_coder = 2;
        else % if L4 positions are avialble and pvtForecast is not valid
            % compute the mean position 
            pos_mean = mean(pvtEstmtsL2.pos_xyz,2);
            % compute the distance of all positions from mean positions
            for n=1:pvtEstmtsL2.estCnt
                pvtL2Dist(n) = sqrt((pvtEstmtsL2.pos_xyz(1,n) - pos_mean(1))^2 + (pvtEstmtsL2.pos_xyz(2,n) - pos_mean(2))^2 + ...
                                    (pvtEstmtsL2.pos_xyz(3,n) - pos_mean(3))^2);
                
            end
            % final position will be the one with leasr distance from mean
            % position
            [~,id] = min(pvtL2Dist);
            pos_xyz = pvtEstmtsL2.pos_xyz(:,id);
            vel_xyz = pvtEstmtsL2.vel_xyz(:,id);
            DOP     = pvtEstmtsL2.DOP(:,id);
            pvtS_Num(1) = pvtEstmtsL2.pvtSats(1,id);
            pvtS_Num(2) = pvtEstmtsL2.pvtSats(2,id);
            cdtu = pvtEstmtsL2.clkCorr(:,id);
%             sat_inraim_bds1 = pvtEstmtsL2.nmbOfSat_inraim_bds(id,:);
%             if ~isempty(pvtEstmtsL2.PRN.sat_actv.BDS)
                sat_inraim_bds = pvtEstmtsL2.PRN.sat_actv(id).BDS;
%             else
%                 sat_inraim_bds = [];
%             end
%             sat_inraim_gps1 = pvtEstmtsL2.nmbOfSat_inraim_gps(id,:);
%             if ~siempty(pvtEstmtsL2.PRN.sat_actv.GPS)
                sat_inraim_gps =  pvtEstmtsL2.PRN.sat_actv(id).GPS;
%             else
%                 sat_inraim_gps = [];
%             end
            mmpvt_coder = 2;
        end
    elseif ~validL4 && ~validL3 && ~validL2 && validL1 % only L1 posiiton 
        if pvtForecast
            for n=1:pvtEstmtsL1.estCnt
                pvtL1Dist(n) = sqrt((pvtEstmtsL1.pos_xyz(1,n) - posPredicted(1))^2 + (pvtEstmtsL1.pos_xyz(2,n) - posPredicted(2))^2 + ...
                                    (pvtEstmtsL1.pos_xyz(3,n) - posPredicted(3))^2);
            end
            % in this case final position will be the one with minimum
            % distance from predicted one
            [~,id] = min(pvtL1Dist);
            pos_xyz = pvtEstmtsL1.pos_xyz(:,id);
            vel_xyz = pvtEstmtsL1.vel_xyz(:,id);
            DOP     = pvtEstmtsL1.DOP(:,id);
            pvtS_Num(1) = pvtEstmtsL1.pvtSats(1,id);
            pvtS_Num(2) = pvtEstmtsL1.pvtSats(2,id);
            cdtu = pvtEstmtsL1.clkCorr(:,id);
%             sat_inraim_bds1 = pvtEstmtsL1.nmbOfSat_inraim_bds(id,:);
%             if ~isempty(pvtEstmtsL1.PRN.sat_actv.BDS)
                sat_inraim_bds = pvtEstmtsL1.PRN.sat_actv(id).BDS;
%             else
%                 sat_inraim_bds = [];
%             end
%             sat_inraim_gps1 = pvtEstmtsL1.nmbOfSat_inraim_gps(id,:);
%             if ~siempty(pvtEstmtsL1.PRN.sat_actv.GPS)
                sat_inraim_gps =  pvtEstmtsL1.PRN.sat_actv(id).GPS;
%             else
%                 sat_inraim_gps = [];
%             end
            mmpvt_coder = 1;
        else % if L4 positions are avialble and pvtForecast is not valid
           % compute the mean position 
            pos_mean = mean(pvtEstmtsL1.pos_xyz,2);
            % compute the distance of all positions from mean positions
            for n=1:pvtEstmtsL1.estCnt
                pvtL1Dist(n) = sqrt((pvtEstmtsL1.pos_xyz(1,n) - pos_mean(1))^2 + (pvtEstmtsL1.pos_xyz(2,n) - pos_mean(2))^2 + ...
                                    (pvtEstmtsL1.pos_xyz(3,n) - pos_mean(3))^2);
                
            end
            % final position will be the one with leasr distance from mean
            % position
            [~,id] = min(pvtL1Dist);
            pos_xyz = pvtEstmtsL1.pos_xyz(:,id);
            vel_xyz = pvtEstmtsL1.vel_xyz(:,id);
            DOP     = pvtEstmtsL1.DOP(:,id);
            pvtS_Num(1) = pvtEstmtsL1.pvtSats(1,id);
            pvtS_Num(2) = pvtEstmtsL1.pvtSats(2,id);
            cdtu = pvtEstmtsL1.clkCorr(:,id);
%             sat_inraim_bds1 = pvtEstmtsL1.nmbOfSat_inraim_bds(id,:);
%             if ~isempty(pvtEstmtsL1.PRN.sat_actv.BDS)
                sat_inraim_bds = pvtEstmtsL1.PRN.sat_actv(id).BDS;
%             else
%                 sat_inraim_bds = [];
%             end
%             sat_inraim_gps1 = pvtEstmtsL1.nmbOfSat_inraim_gps(id,:);
%             if ~siempty(pvtEstmtsL1.PRN.sat_actv.GPS)
                sat_inraim_gps =  pvtEstmtsL1.PRN.sat_actv(id).GPS;
%             else
%                 sat_inraim_gps = [];
%             end
            mmpvt_coder = 1;
        end
    end
    
% elseif ~mm_raim_coder && multiEstValid  % if raim failed but multiple estimates are available
    
% elseif mm_raim_coder && ~multiEstValid  % if raim is passed with only position

% elseif ~mm_raim_coder && ~multiEstValid % if raim failed with only position (a special case when only 5 satellites are active)

%end