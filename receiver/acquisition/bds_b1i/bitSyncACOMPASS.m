function syncResults = bitSyncACOMPASS(acqResults, recv_cfg, bitSync_cfg)
%%
if recv_cfg.isSimSignal
    % Generate data
    signal = recv_cfg.signal;
else
    % Extract data from file, 30ms additional for shifting
    estDataNumber = (bitSync_cfg.length * recv_cfg.codeFreqBasis / ...
        recv_cfg.codeLength + 30) * recv_cfg.samplesPerCode;
    fseek(recv_cfg.fid,recv_cfg.skipNumberOfBytes,'bof');
    signal = fread(recv_cfg.fid, estDataNumber, recv_cfg.dataType)';
end

%%

% define output
syncResultStruct = defineSyncResult();
syncResults = repmat(syncResultStruct, 1, length(acqResults));

% retain main information of acquisition results
svNum = length(acqResults);
for i = 1:svNum 
    syncResults(i).sv = acqResults(i).sv;
    syncResults(i).codeIdx = acqResults(i).codeIdx;
    syncResults(i).doppler = acqResults(i).doppler;
    syncResults(i).codePhase = acqResults(i).codePhase;
end


% % sync for using K nav bits signal
% K = bitSync_cfg.length * recv_cfg.bitFreq;
% codenum = recv_cfg.samplesPerCode;
% corrsPerBit = 1/(recv_cfg.bitFreq * recv_cfg.codePeriod); %length of one nav data
% 
% % 1 nav bit more for shifiting , K+1
% nsamples  = 1/(recv_cfg.codePeriod * recv_cfg.bitFreq) * ...
%     (K+1) * codenum; 

% finer doppler search
frange = bitSync_cfg.freqRange;
fbin = bitSync_cfg.freqBin;     
fnum = frange/fbin + 1;


for i = 1:svNum   
    if acqResults(i).acqed == 0
        continue;
    end
       sv = acqResults(i).sv;% decide sv
        if sv<=5
            recv_cfg.bitFreq = recv_cfg.bitFreqD2;%for GEO 500
        else
            recv_cfg.bitFreq = recv_cfg.bitFreqD1;%for NGEO 50
        end
        
   for k = 1:fnum 
        %---------------------------------------------------------------
%         sv = acqResults(i).sv;
%         if sv<=5
%             recv_cfg.bitFreq = recv_cfg.bitFreqD2;%for GEO 500
%         else
%             recv_cfg.bitFreq = recv_cfg.bitFreqD1;%for NGEO 50
%         end
        % sync for using K nav bits signal
        K = bitSync_cfg.length * recv_cfg.bitFreq;
        codenum = recv_cfg.samplesPerCode;
        corrsPerBit = 1/(recv_cfg.bitFreq * recv_cfg.codePeriod); %length of one nav data
        % K nav bit 
        nsamples  = 1/(recv_cfg.codePeriod * recv_cfg.bitFreq) * ...
        K * codenum; 
        %------------------------------------------------------------------
        % calculate finer doppler
        doppler = acqResults(i).doppler + fbin*(k-1) -frange/2;
        carrierFreq = recv_cfg.IF + doppler;
        
        % code doppler
        codeDoppler = doppler/recv_cfg.carrierFreq * ... 
            recv_cfg.codeFreqBasis; 
        samples_shift = acqResults(i).codeIdx;
%         signal1 = signal(1 + samples_shift : nsamples + samples_shift);
%         t = (0 : 0 + nsamples - 1)/recv_cfg.samplingFreq;
         t = (0 : 0 + nsamples - 1)/recv_cfg.samplingFreq;
        % Causion! Sensitity loss, since we consider in K nav bit doppler is
        % constant
        codePhase = rem (floor ((recv_cfg.codeFreqBasis + ...
            codeDoppler).*t),recv_cfg.codeLength )+1; 
        carrierPhase = 2*pi* (carrierFreq).*t;
%         sv = acqResults(i).sv;
        % generate gold code with sv # and system(GPS or COMPASS)
        goldCode = generateGoldCode(recv_cfg.mode, sv);
        %--------------------------------------------------------
        nhCode = [0 0 0 0 0 1 0 0 1 1 0 1 0 1 0 0 1 1 1 0];
        nhLength = 20;
        nhCode(nhCode == 0) = -1;
        %-------------------NH doppler-------------------------
%         nhCode = kron(nhCode, ones(1, recv_cfg.samplesPerCode));
% %         nhCode = kron(nhCode,ones(1,K)); %wrong!!
%         nhCode = repmat(nhCode,1,K); 
%----------------------------------------------------------------
        nhDoppler = doppler/recv_cfg.carrierFreq * ... 
            recv_cfg.codeFreqBasis/recv_cfg.codeLength; 
        nhPhase = rem (floor ((recv_cfg.codeFreqBasis/recv_cfg.codeLength + ...
            nhDoppler).*t),nhLength )+1; 
%-------------------------------------------------------------------------
    for m = 1:corrsPerBit
        signal1 = signal(1 + samples_shift+(m-1)*codenum : nsamples + samples_shift ...
            +(m-1)*codenum);
     
        if sv<=5 % for GEO
      % Do not need to think about NH code
            signal2 = exp(1j*carrierPhase).*goldCode(codePhase).*signal1;
        else % for NGEO
            % modulate by NH code, first N codes, loss here, NH code not align to 
             % gold cold
%             nhCode = kron(nhCode, ones(1, recv_cfg.samplesPerCode));
%             nhCode = kron(nhCode,ones(1,K+1));
%             goldCode = goldCode .* nhCode; 
            signal2 = exp(1j*carrierPhase).*nhCode(nhPhase).*goldCode(codePhase).*signal1;
        end
        %--------------------------------------------------------
        % wipe off cairrer and gold code
%         signal2 = exp(1j*carrierPhase).*goldCode(codePhase).*signal1;
        
        % rerange by 1ms segments
         signal3 = reshape(signal2,codenum*corrsPerBit,[]);
        % correlation ,1ms coherent 
        if sv <=5
            yGEO(m,:) = sum(signal3,1);
            ync1(m,:)=sum(abs(yGEO(m,1:end))); 
        else
            yNGEO(m,:) = sum(signal3,1);
            ync2(m,:)=sum(abs(yNGEO(m,1:end)));   
        end
     end %for m=1:corrsPerBit
%         % bit nergy detect using corrsPerBit*K correlations
%         if sv<=5
%             y_nc(:,k) = bit_energy_detect2(y,corrsPerBit*K,corrsPerBit);%GEO
%              % find 2D peak
%         else
%             y_ncN(:,k) = bit_energy_detect2(y,corrsPerBit*K,corrsPerBit);%NGEO
%         end
%         y_test(:,k) = abs(y1(:,1));
        if sv<=5
             y1(:,k) = ync1; %for GEO
        else
             y2(:,k) = ync2; %for NGEO
        end
    end  %for k = 1:fnum
    % find 2D peak
    %-------------for test-----------------------------
%         [peak_bit_nc bit_idx_array] = max(y_test,[],1);
%         [peak_nc freq_idx]= max(peak_bit_nc,[],2);
%         bitIdx = bit_idx_array(freq_idx);
%--------------------------------------
        if sv <=5
         [peak_bit_nc bit_idx_array] = max(y1,[],1);
         [peak_nc freq_idx]= max(peak_bit_nc,[],2);
         bitIdx = bit_idx_array(freq_idx);
         delta = 0;
        else
         [peak_bit_nc bit_idx_array] = max(y2,[],1);
         [peak_nc freq_idx]= max(peak_bit_nc,[],2);
         bitIdx = bit_idx_array(freq_idx);
         %----------------improve ferquency accuracy------------------------%
         a = y2(bitIdx,freq_idx-1);
         c = y2(bitIdx,freq_idx);
         b = y2(bitIdx,freq_idx+1);
         if a>=b
             x = (c - a)/(c - b)*fbin;
             delta = (x - fbin)/2;
         else
             x = (c - b)/(c - a)*fbin;
             delta = (fbin - x)/2;
         end
         %----------------------------------------------------------%
        end
    %-------------------------------------------
    if recv_cfg.isSyncPlotMesh
        if sv<=5
         figure(200+sv);mesh(y1);
         xlabel('频率槽数/个');ylabel('比特位置/ms');zlabel('相关值')
        else
         figure(201+sv);mesh(y2);
         xlabel('频率槽数/个','fontsize',16);ylabel('比特位置/ms','fontsize',16);
         zlabel('相关值','fontsize',16)
        end
%         figure(200);mesh(y);
    end
    % bit sync index
    syncResults(i).bitIdx = bitIdx;
    % sync mark
    syncResults(i).sync =  1;
    % fine doppler
    syncResults(i).doppler = acqResults(i).doppler + ...
        fbin*(freq_idx-1) -frange/2 + delta;%

end
end