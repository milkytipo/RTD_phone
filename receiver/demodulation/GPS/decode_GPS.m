function [out,flag] = decode_GPS(in)
    out = zeros(1,300);   % 一子帧数据
    out2 = zeros(1,30);   % 一个字数据
    last_twobit = in(29:30);
    out(1:30) = in(1:30); %TLW字不进行校验
    flag = 1;
    for i=1:9
            in2 = in(30*i+1:30*(i+1));
            out2(1:24) = xor(in2(1:24), last_twobit(2));
            out2(25:30) = in2(25:30);
            D25 = mod((last_twobit(1)+out2(1)+out2(2)+out2(3)+out2(5)+out2(6)+out2(10)+out2(11)...
                +out2(12)+out2(13)+out2(14)+out2(17)+out2(18)+out2(20)+out2(23)),2);
            D26 = mod((last_twobit(2)+out2(2)+out2(3)+out2(4)+out2(6)+out2(7)+out2(11)+out2(12)...
                +out2(13)+out2(14)+out2(15)+out2(18)+out2(19)+out2(21)+out2(24)),2);
            D27 = mod((last_twobit(1)+out2(1)+out2(3)+out2(4)+out2(5)+out2(7)+out2(8)+out2(12)...
                +out2(13)+out2(14)+out2(15)+out2(16)+out2(19)+out2(20)+out2(22)),2);
            D28 = mod((last_twobit(2)+out2(2)+out2(4)+out2(5)+out2(6)+out2(8)+out2(9)+out2(13)...
                +out2(14)+out2(15)+out2(16)+out2(17)+out2(20)+out2(21)+out2(23)),2);
            D29 = mod((last_twobit(2)+out2(1)+out2(3)+out2(5)+out2(6)+out2(7)+out2(9)+out2(10)...
                +out2(14)+out2(15)+out2(16)+out2(17)+out2(18)+out2(21)+out2(22)+out2(24)),2);
            D30 = mod((last_twobit(1)+out2(3)+out2(5)+out2(6)+out2(8)+out2(9)+out2(10)+out2(11)...
                +out2(13)+out2(15)+out2(19)+out2(22)+out2(23)+out2(24)),2);
            number = xor([D25, D26, D27, D28, D29, D30], out2(25:30));
           
            %% correct the single wrong bit
            
                if number == [0 0 0 0 0 0]
                    flag = 0;
                elseif number == [1 0 1 0 1 0]
                    out2(1) = not(out2(1));
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [1 1 0 1 0 0]
                    out2(2) = not(out2(2));
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [1 1 1 0 1 1]
                    out2(3) = not(out2(3));  
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [0 1 1 1 0 0]
                    out2(4) = not(out2(4));     
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [1 0 1 1 1 1]
                    out2(5) = not(out2(5));    
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [1 1 0 1 1 1]
                    out2(6) = not(out2(6));    
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [0 1 1 0 1 0]
                    out2(7) = not(out2(7));  
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [0 0 1 1 0 1]
                    out2(8) = not(out2(8));    
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [0 0 0 1 1 1]
                    out2(9) = not(out2(9));      
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [1 0 0 0 1 1]
                    out2(10) = not(out2(10));      
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [1 1 0 0 0 1]
                    out2(11) = not(out2(11));     
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [1 1 1 0 0 0]
                    out2(12) = not(out2(12));   
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [1 1 1 1 0 1]
                    out2(13) = not(out2(13));   
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [1 1 1 1 1 0]
                    out2(14) = not(out2(14));   
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [0 1 1 1 1 1]
                    out2(15) = not(out2(15)); 
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [0 0 1 1 1 0]
                    out2(16) = not(out2(16));  
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [1 0 0 1 1 0]
                    out2(17) = not(out2(17));  
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [1 1 0 0 1 0]
                    out2(18) = not(out2(18));   
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [0 1 1 0 0 1]
                    out2(19) = not(out2(19));   
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [1 0 1 1 0 0]
                    out2(20) = not(out2(20));   
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [0 1 0 1 1 0]
                    out2(21) = not(out2(21));   
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [0 0 1 0 1 1]
                    out2(22) = not(out2(22));  
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [1 0 0 1 0 1]
                    out2(23) = not(out2(23));   
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [0 1 0 0 1 1]
                    out2(24) = not(out2(24));    
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [1 0 0 0 0 0]
                    out2(25) = not(out2(25));    
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [0 1 0 0 0 0]
                    out2(26) = not(out2(26));
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [0 0 1 0 0 0]
                    out2(27) = not(out2(27));
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [0 0 0 1 0 0]
                    out2(28) = not(out2(28));    
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [0 0 0 0 1 0]
                    out2(29) = not(out2(29));    
                    flag = 0;
                    disp('NAVBIT have correction');
                elseif number == [0 0 0 0 0 1]
                    out2(30) = not(out2(30));     
                    flag = 0;
                    disp('NAVBIT have correction');
                else
                    flag = 1;
                    disp('NAVBIT is wrong');
                end  
            last_twobit = out2(29:30);
            out(30*i+1:30*(i+1)) = out2;
            
    end