function [subframeout,flag] = decode_60bits(subframein)
% decode 60 bits to get SOW
    in=subframein; % 45 bits
    out=zeros(1,45);
%     out2=zeros(1,30);
    out(1:15)=in(1:15);
    [out(16:30),flag1]=correctcode(in(16:30)); %decode 15 bits
    [out(31:60),flag2]=debchcode(in(31:60)); %decode 15 bits
    flag = flag1||flag2;
%     for i=1:9
%         out2=in(30*i+1:30*(i+1));
%         out(30*i+1:30*(i+1))=debchcode(out2);
%     end
    subframeout=out;
end
