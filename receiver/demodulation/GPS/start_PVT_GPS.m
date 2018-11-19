%% start PVT
% initial
function [recv_time]=start_PVT_GPS(channels, recv_cfg, recv_time, STR_FILE_CTRL) 
%% 初始化
svnum = 0;% this flag is to find whether avaliable satellite is above 4
activeChannel = [];% avaliable channels
checkNGEO=0;%%检测NGEO卫星
inte_dopp=zeros(1,30);%积分多普勒值
dopplerfre=zeros(1,30);%多普勒频移
CNR=zeros(1,30);  %输出信噪比
%更新本地时钟
% % if recv_time.recvSOW~=-1 
% %   recv_time.recvSOW=recv_time.recvSOW+0.5;  
% % end

%% start PVT
for  n=1:recv_cfg.numberOfChannels
    if channels(n).CH_B1I(1).ephReady == 1 && channels(n).CH_B1I(1).eph.health==0
        svnum = svnum + 1;
        activeChannel(1,svnum) = n;
        activeChannel(2,svnum) = channels(n).CH_B1I(1).PRNID;
%         if activeChannel(2,svnum)>5
%             checkNGEO=1;
%         end
%     
    
 %%    %%%%%%%读取多积分多普勒文件%%%%
%          fd = fopen(STR_FILE_CTRL(n).trk_carfreq,'r');
%                 [car_freq,cnt_out] = fread(fd, inf, 'double');
%          fclose(fd);   
%          if cnt_out~=0   
%             for n_dopp=1:cnt_out-1     %%%%calculate integrated doppler
%                 if channels(n).CH_B1I(1).PRNID>5
%                     inte_dopp(activeChannel(2,svnum))=inte_dopp(activeChannel(2,svnum))-car_freq(n_dopp)*0.02;
%                 else
%                     inte_dopp(activeChannel(2,svnum))=inte_dopp(activeChannel(2,svnum))-car_freq(n_dopp)*0.002;
%                 end
%             end
%                 if channels(n).CH_B1I(1).PRNID>5
%                     inte_dopp(activeChannel(2,svnum))=inte_dopp(activeChannel(2,svnum))-car_freq(cnt_out)*(0.02+channels(n).CH_B1I(1).Tcohn_cnt*0.001);
%                 else
%                     inte_dopp(activeChannel(2,svnum))=inte_dopp(activeChannel(2,svnum))-car_freq(cnt_out)*(0.002+channels(n).CH_B1I(1).Tcohn_cnt*0.001);
%                 end
%          end
%         %多普勒频移
%         dopplerfre(activeChannel(2,svnum))=car_freq(cnt_out);
%         %信噪比
%         CNR(activeChannel(2,svnum))=channels(n).CH_B1I(1).CN0_Estimator.CN0;
   end
 %%
    if svnum >=4 && n == recv_cfg.numberOfChannels 
      % find trasmition time 
       [transmitTime,WN] = findTransTime_GPS(channels,activeChannel(1,:));
       recv_time.weeknum = max(WN);  %%更新周计数
%        fprintf('Transmit time -- %.6f \n', transmitTime);
       fid = fopen('transtime.txt','a');
       fprintf(fid,'%f         ',transmitTime);
       fprintf(fid,'\n');
       fclose(fid);
      % transmitTime = [28800 28800 28800 28800];
      % Compute satellite position
        [satPositions, satClkCorr,eph_all] = GPS_calculateSatPosition(transmitTime, ...
         channels,activeChannel(1,:));
%         fprintf('Satellite pos -- %.6f \n', satPositions);
       fid = fopen('satPos.txt','a');
       fprintf(fid,'%f         ',satPositions);
       fprintf(fid,'\n');
       fclose(fid);
%         fprintf('satClkCorr -- %.6f \n', satClkCorr*299792458);
       fid = fopen('satClkCorr.txt','a');
       fprintf(fid,'%f         ',satClkCorr*299792458);
       fprintf(fid,'\n');
       fclose(fid);
      % Compute the Pseudo-range / receiver time
      if recv_time.recvSOW==-1
          rxTime = max(transmitTime) + 70*1e-3;
          recv_time.recvSOW=rxTime;
      else
          rxTime=recv_time.recvSOW;
      end
      
      
      [rawP] = calculatePseudoranges(transmitTime,rxTime,activeChannel);
%       fprintf('rawP -- %.6f \n', rawP);
       fid = fopen('rawP.txt','a');
       fprintf(fid,'%f         ',rawP);
       fprintf(fid,'\n');
       fclose(fid);
      % Performing the PVT
       [xyzdt,el,az,dop] = leastSquarePos_GPS(satPositions, ...
            rawP+ satClkCorr * recv_cfg.c,recv_cfg,transmitTime-satClkCorr,channels,activeChannel); %freqforcal,reveiver.recv_cfg);       
        queue=sort(el(2,:));
        %=== Convert to geodetic coordinates ==============================
       %-------save x,y,z to XYZ.txt-------------------------------------%
       fid = fopen('XYZ.txt','a');
       fprintf(fid,'%f%20f%20f\n',xyzdt(1),xyzdt(2),xyzdt(3));
       fclose(fid);
       %-------printf results          ----------------------------------%
       [latitude,longitude,height] = cart2geo(xyzdt(1),xyzdt(2),xyzdt(3),5);
        fprintf('Positioning -- latitude: %.6f°;longitude: %.6f°;height: %.2f \n\n', ...
             latitude,longitude,height);
       fprintf('%f   %20f  %20f\n',xyzdt(1),xyzdt(2),xyzdt(3));
       %-------save la,lon,H to LLH.txt----------------------------------% 
       fid = fopen('LLH.txt','a');
       fprintf(fid,'%f°%20f°%20.3f\n',latitude,longitude,height);
       fclose(fid);

       %%
       %计算年月日时分秒
       [BJyear,BJmonth,BJday_1]=calculate_yymmdd(recv_time.weeknum);
       [BJday_2,BJhour,BJmin,BJsec]=sow2BJT(recv_time.recvSOW);
       recv_time.year=BJyear;
       recv_time.month=BJmonth;
       recv_time.day=BJday_1+BJday_2;
       recv_time.hour=BJhour;
       recv_time.min=BJmin;
       recv_time.sec=BJsec;
       
       %%  output log file
       fid_0=fopen('rinex302.15O');
       if fid_0==-1
           rinexobs_header(xyzdt,recv_time);
       else
           fclose(fid_0);
       end
       rinexobs_data(recv_time,rawP,inte_dopp,dopplerfre,CNR,xyzdt(4),queue);
       fid_1=fopen('rinex302.15N');
       if fid_1==-1
           rinexnavi_header;
       else
           fclose(fid_1);
       end
       rinexnavi_data(eph_all,satClkCorr,queue);
       fid_2=fopen('rinex302.15MP');
       if fid_2==-1
           rinexmp_header(recv_time);
       else
           fclose(fid_2);
       end
       rinexmp_data(recv_time,channels,activeChannel);       
       %% 修正本地时间误差
       recv_time.recvSOW=recv_time.recvSOW-xyzdt(4);  %
    end
end  %  n=1:receiver.recv_cfg.numberOfChannels
      


end