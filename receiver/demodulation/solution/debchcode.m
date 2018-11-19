function [outdata,flag] = debchcode(inputdata)
% decode one word
%%%inputdata:one word,30bits
%%%outputdata:one word,30bits
%g=[1 0 0 1 1 0 0 0 0 0 0 0 0 0 0];
%H=[1 1 1 1 0 1 0 1 1 0 0 1 0 0 0;0 1 1 1 1 0 1 0 1 1 0 ...
 %   0 1 0 0;0 0 1 1 1 1 0 1 0 1 1 0 0 ...
  %  1 0;1 1 1 0 1 0 1 1 0 0 1 0 0 0 1];
 %HT=H.';
%inputdata=[0 0 1 1 1 1 0 0 1 1 1 1 0 0 1 1 1 1 1 1 1 1 1 1 1 1 0 0 1 1];
out=inputdata;
%load('out.txt','-ascii');
 for i=1:15
     dbch1(i)=out(2*i-1);
     dbch2(i)=out(2*i);
 end

 %bch1=correctcode(dbch1,g,HT);
 %bch2=correctcode(dbch2,g,HT);
 [bch1,flag1]=correctcode(dbch1);
 [bch2,flag2]=correctcode(dbch2);
 flag = flag1||flag2;
 if (flag1 == 1) || (flag2 == 1)
     disp('NAVBIT have wrong bits,need BCH correction');
 end
%  for i=1:15
%      m1(i)=bch1(i);
%      m2(i)=bch2(i);
%       outdata(2*i-1)=m1(i);
%      outdata(2*i)=m2(i);
%  end
 for i=1:11
     m1(i)=bch1(i);
     m2(i)=bch2(i);
      outdata(i)=m1(i);
     outdata(i+11)=m2(i);
 end
 outdata(23:30)=zeros(1,8);
end