% close all; clear all; clc;
%% This matlab file is used to read data from excel.
% The excel file should be in a required format.

% alldata = xlsread('C:\Users\fangxr\Desktop\北航数据处理295-end_PRN10');

%% Sampling code
% d1 = [];
% axis = 0.1;
% cnt = 1;
% 
% for i = 1:38024
%     if abs(alldata(i,1) - axis) < 0.0001
%         d1(cnt,:) = alldata(i,:);
%         axis = axis + 0.1;
%         cnt = cnt + 1;
%     end
% end

%% SNR code
% cnt2 = 1;
% for i = 1:(cnt-1)
%     for j = 1:1425
%         if abs(alldata2(j,1) - d1(i,1)) < 0.03
%             sampledata2(cnt2,1) = sampledata(i,1);
%             sampledata2(cnt2,2:4) = alldata2(j,2:4);
%             cnt2 = cnt2 + 1;
%         end
%     end
% end

%% Convert 0 to NaN
% for i = 1:7364
%     for j = 1:6
%         if d1(i,j) == 0
%             d1(i,j) = NaN;
%         end
%     end
% end

%% Smooth carrier phase
% for i = 7180:7364
%     if d1(i,6) <= 0
%         d1(i,6) = d1(i,6) + 360;
%     end 
% end

%% Seperate mp
% for i = 9360:9426
%     sampledata(i,3) = sampledata(i,2);
%     sampledata(i,6) = sampledata(i,5);
%     
%     sampledata(i,2) = NaN;
%     sampledata(i,5) = NaN;
%     
% end

%% Rearrange SNR
% cnt = 1;
% 
% for i = 1:2994
%     if isnan(snrr(i,1)) == 0
%         snrr1(cnt, [1 2 3 4]) = snrr(i, [4 1 2 3]);
%         cnt = cnt + 1;
%     end
% end

%%
% for i = 1:5400
%     if d1(i,3) ~= 0
%         d1(i,2) = d1(i,3);
%         d1(i,5) = d1(i,6);
%     end
% end
