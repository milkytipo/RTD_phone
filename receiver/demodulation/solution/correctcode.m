%function[bch]=correctcode(data,G,HT)
function[bch,flag]=correctcode(data)
% decode 15bit [11 data,4 check]
% data=[0 1 1 0 1    1 0 1 1 1 1     1 1 0 1];
G=[1 0 0 1 1 0 0 0 0 0 0 0 0 0 0];
H=[1 1 1 1 0 1 0 1 1 0 0 1 0 0 0;0 1 1 1 1 0 1 0 1 1 0 0 1 0 0;0 0 1 1 1 1 0 1 0 1 1 0 0 1 0;1 1 1 0 1 0 1 1 0 0 1 0 0 0 1];
HT=H.';
k=0;
 for i=1:15
        if  data(i)==1
             k=i;
            break
        end
 end
 
g=circshift(G,[0 k-1]);%×óÁÐÒÆk-1

g1=g;
c=data;

for n=1:15
    c=xor(c,g1);%Ä£2¼Ó
   
    h=0;
    for i=1:15
        if c(i)==0
             h=h+1;
        end
    end
    
    if h==15
        break
    end
    
    g1=G;
    for i=1:15
        if c(i)==1
             kk=i;
             break
        end
    end
   if  kk>11
       break
   end
    g1=circshift(g1,[0 kk-1]);
end

k1=0;
 for i=1:15
        if c(i)==1
             k1=k1+1;
        end
 end
 
 if k1==0
     bch=data;
     %--xqj add---
     flag = 0;
     %------------
 else
     %--xqj add---
     flag = 1;
     disp('NAVBIT have wrong bits,need BCH correction');
     %------------
     for i=1:4
         s(i)=c(11+i);
     end
     for j=1:15
           ht(j,:)=xor(s,HT(j,:));
           k2=0;
           for  i=1:4; 
                if ht(j,i)==0
                    k2=k2+1;
                end
                if k2==4
                    k3=j;
                    break
                end
           end
     end
     for i=1:15
         e(i)=0;
     end
     e(k3)=1;
     bch=xor(data,e);
 end