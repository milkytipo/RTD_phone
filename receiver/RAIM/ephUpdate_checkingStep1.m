function [gpsat_eph_para, updateSuccess, ionoequal_2] = ephUpdate_checkingStep1(SYST, gpsat_eph_para, last_pos, last_transmitime, prn)


% eph update success flag: 0 - fail; 1 - success.
updateSuccess = 0;
ionoequal_2 = 0;

if gpsat_eph_para.ephUpdate.health == 0
    if gpsat_eph_para.ephReady == 0 % ephReady==0 indicates it is the first time to update this sat's eph info
        %--------- 'ephReady==0' step 1 -----------
        % check if the ephUpdate para lies in the pre-defined reasonable extent
        extentPass = ephPara_extentChecking(SYST, gpsat_eph_para.ephUpdate);
        
        %--------- 'ephReady==0' step 2 -----------
        if extentPass
            % When passing the eph_extent checking procedure, ephTrustLevel
            % becomes 1.
            gpsat_eph_para.ephUpdateTrustLevel = 1;
            
            %--------- 'ephReady==0' step 3 -----------
            % check if the range from the sat's pos to the earth center
            % lies in the reasonable extent.
            if isempty(last_transmitime)
                range2OPass = range2O_checking(SYST, gpsat_eph_para.ephUpdate, gpsat_eph_para.ephUpdate.toe, prn);
            else
                range2OPass = range2O_checking(SYST, gpsat_eph_para.ephUpdate, last_transmitime, prn);
            end
            
            if range2OPass
                gpsat_eph_para.ephUpdateTrustLevel = 2;
                %In the case that this is the first time for tis sat to
                %receive a full subframe eph info, the integrety checking
                %for this eph info is finished up to this phase. So we set
                %the flag updateSuccess as 1 and return.
                updateSuccess = 1;
            end %EOF "if range2OPass"
        end %EOF "if extentPass"
    else % ephReady!=0 indicates that there is already a historical eph info for this sat
        % In the case that there is already a trustable historical eph, we
        % will do the pseudorange cross check procedure for the updated
        % eph. During this, the ephUpdateTrustLevel can be increasing up
        % to 3.
        % We only consider the case of ephUpdate different than eph. If
        % not, we will not update any lately received eph into the current
        % eph structure.
      switch SYST
          case 'GPS_L1CA'
          if gpsat_eph_para.ephUpdate.IODE ~= gpsat_eph_para.eph.IODE     % if ~isequal(gpsat_eph_para.eph, gpsat_eph_para.ephUpdate);
            %--------- 'ephReady==1' step 1 -----------
            extentPass = ephPara_extentChecking(SYST, gpsat_eph_para.ephUpdate);
            
            if extentPass
                gpsat_eph_para.ephUpdateTrustLevel = 1;
                ephsatorbit_upd_raid_equal = ephSatOrbitPara_equalcheck(SYST, gpsat_eph_para.ephUpdate, gpsat_eph_para.ephRaid);
                
                if ephsatorbit_upd_raid_equal
                    % ephUpdate and ephRaid are checked equal.
                    % ephUpdate.IODE ~= eph.IODE. All this means that the
                    % eph has been updated by the satellite, and it can be
                    % saved into the eph.
                    gpsat_eph_para.ephUpdateTrustLevel = 4;
                    updateSuccess = 1;
                else
                    % ephUpdate and ephRaid are checked not equal. This
                    % means there might be some errors in the decoded
                    % navbits, so we wait for next frame ephUpdate to
                    % fulfill a crosscheck again.
                    gpsat_eph_para.ephRaid = ephsatorbit_cpy(SYST, gpsat_eph_para.ephRaid, gpsat_eph_para.ephUpdate);
                end
%                 if isempty(last_pos)
%                     %--------- 'ephReady==1' step 2 -----------
%                     if isempty(last_transmitime)
%                         range2OPass = range2O_checking(SYST, gpsat_eph_para.ephUpdate, gpsat_eph_para.ephUpdate.toe);
%                     else
%                         range2OPass = range2O_checking(SYST, gpsat_eph_para.ephUpdate, last_transmitime);
%                     end
%                     
%                     if range2OPass
%                         gpsat_eph_para.ephUpdateTrustLevel = 2;
%                         updateSuccess = 1;
%                     end
%                 else
%                     %--------- 'ephReady==1' step 3 -----------
%                     % When there is last_pos, we can do the pseudorange
%                     % cross check with historical eph. (in this case, the
%                     % last_transmitime) is also available.
%                     satPseudorange_crossCheckPass = satPseudorange_crossChecking(SYST, gpsat_eph_para.eph, gpsat_eph_para.ephUpdate, last_pos, last_transmitime);
%                     
%                     if satPseudorange_crossCheckPass
%                         gpsat_eph_para.ephUpdateTrustLevel = 3;
%                         updateSuccess = 1;
%                     end
%                 end %EOF "if isempty(last_pos)"
            end %EOF "if extentPass"
          end %EOF "if gpsat_eph_para.ephUpdate.IODE ~= gpsat_eph_para.eph.IODE"
          
          case 'BDS_B1I'
              ephsatorbit_upd_eph_equal = ephSatOrbitPara_equalcheck(SYST, gpsat_eph_para.ephUpdate, gpsat_eph_para.eph);
              
              if ephsatorbit_upd_eph_equal ~= 1
                  ephsatorbit_upd_raid_equal = ephSatOrbitPara_equalcheck(SYST, gpsat_eph_para.ephUpdate, gpsat_eph_para.ephRaid);
              
                  if ephsatorbit_upd_raid_equal
                    % ephUpdate and ephRaid are checked equal.
                    % ephUpdate.IODE ~= eph.IODE. All this means that the
                    % eph has been updated by the satellite, and it can be
                    % saved into the eph.
                    gpsat_eph_para.ephUpdateTrustLevel = 4;
                    updateSuccess = 1;
                  else
                    % ephUpdate and ephRaid are checked not equal. This
                    % means there might be some errors in the decoded
                    % navbits, so we wait for next frame ephUpdate to
                    % fulfill a crosscheck again.
                    gpsat_eph_para.ephRaid = ephsatorbit_cpy(SYST, gpsat_eph_para.ephRaid, gpsat_eph_para.ephUpdate);
                  end
              end
      end %EOF "switch SYST"
        
        % Check if the ionosphere parameters are updated
        ionoequal_1 = ephionoPara_equalcheck(SYST, gpsat_eph_para.ephUpdate, gpsat_eph_para.eph);
        if ~ionoequal_1
            ionoequal_2 = ephionoPara_equalcheck(SYST, gpsat_eph_para.ephUpdate, gpsat_eph_para.ephRaid);
            if ionoequal_2
                % ephUpdate.iono == ephRaid.iono
                % ephUpdate.iono != eph.iono
                % iono parameters are updated and checked correct. it can
                % be saved into eph.
                gpsat_eph_para.eph = ephiono_cpy(SYST, gpsat_eph_para.eph, gpsat_eph_para.ephUpdate);
            else
                % ephUpdate.iono != eph.iono
                % ephUpdate.iono != ephRaid.iono
                % In this case, it might be the first time the updated iono
                % parameters are received by the ephUpdate, so it needs to
                % be saved into ephRaid for the next crosscheck. Or it
                % might has some received errors in the received iono
                % parameters in eigher ephUpdate or ephRaid. Then we just
                % wait for the next info.
                gpsat_eph_para.ephRaid = ephiono_cpy(SYST, gpsat_eph_para.ephRaid, gpsat_eph_para.ephUpdate);
            end
        end %EOF "if ~ionoequal_1"
      
    end %EOF "if gpsat_eph_para.ephReady == 0"
end %EOF "if gpsat_eph_para.ephUpdate.health == 0"

return;