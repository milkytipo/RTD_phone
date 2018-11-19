function [subframeout,flag] = decode_onesubframe(subframein)
    in=subframein;
    out=zeros(1,300);
    out2=zeros(1,30);
    out(1:15)=in(1:15);
    [out(16:30),flag1]=correctcode(in(16:30));
    for i=1:9
        out2=in(30*i+1:30*(i+1));
        [out(30*i+1:30*(i+1)),flag2]=debchcode(out2);
        flag = flag1 + flag2;
    end
    subframeout=out;
end

