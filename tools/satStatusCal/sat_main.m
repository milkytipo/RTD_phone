close all;clc
if 1
    clear;
    load satPara.mat;
end
prn_all = [1:5];
sys = 1;
specular = 1;
angle_range = 1:90;
freq_fad_El_prn = zeros(length(prn_all),length(angle_range));
freq_fad_El = zeros(1,90);

% Er = 100/360*2*3.14159;
for i_prn = 1 : length(prn_all)
    prn = prn_all(i_prn);
    if sys == 1
        para = satPara.BDS(prn);
    else
        para = satPara.GPS(prn); 
    end
    vaild_Line = find(para.El>0);
    timeSow = para.SOW(vaild_Line);
    El = para.El(vaild_Line);
    Az = para.Az(vaild_Line);
    V_El = para.V_El(vaild_Line);
    V_Az = para.V_Az(vaild_Line);
    V_El_Az = para.V_El_Az(vaild_Line);
    Az_mean = mean(Az);
    Ar_All = [0 : 10 : 350];
    Ar_All = Ar_All./(360/2/3.141592654);
    delta_cosAlpha = zeros(length(timeSow), length(Ar_All));
    cosAlpha = zeros(length(timeSow), length(Ar_All));
    delay = zeros(length(timeSow), length(Ar_All));
    freq_fad = zeros(length(timeSow), length(Ar_All));



    d = 100; 
    h = 100;
    h_max = 300;
    Es_max = round(atand(h_max/d));

    Er_fix = 40/360*2*3.14159;


    for i = 1 : length(timeSow)
        for j = 1 : length(Ar_All)
            Es = El(i)/360*2*3.14159;
            As = Az(i)/360*2*3.14159;
            delta_Es = V_El(i)/360*2*3.14159;
            delta_As = V_Az(i)/360*2*3.14159;

            Ar = Ar_All(j);
            if specular
                Er = Es;
                cosAlpha_temp = cos(Es)*cos(Es)*cos(As-Ar)+sin(Es)*sin(Es);
                delta_cosAlpha_temp = 2*cos(Es)*(-sin(Es))*delta_Es*cos(As-Ar) ...
                    + (cos(Es))^2 * (-sin(As-Ar)) * delta_As * 2 ...
                    + 2*sin(Es)*cos(Es)*delta_Es;

            else
                Er = Er_fix;
                cosAlpha_temp = cos(Es)*cos(Er)*cos(As-Ar)+sin(Es)*sin(Er);
                delta_cosAlpha_temp = (-sin(Es))*(delta_Es)*cos(Er)*cos(As-Ar)...
                    + cos(Es)*cos(Er)*(-sin(As-Ar))*delta_As...
                    + cos(Es)*sin(Er)*delta_Es;
            end

            delta_cosAlpha(i, j) = delta_cosAlpha_temp;
            cosAlpha(i, j) = cosAlpha_temp;
            delay(i, j) = (d/cos(Er)) * (1 - cosAlpha_temp);
            freq_fad(i, j) = (d/cos(Er))*delta_cosAlpha_temp/0.19;
        end
    end
    delta_cosAlpha = mean(abs(delta_cosAlpha), 2);
    cosAlpha = mean(abs(cosAlpha), 2);
    delay = mean(delay, 2);
    freq_fad = mean(abs(freq_fad), 2);

    for i = 1 :length(angle_range)-1
        line1 = find((El>angle_range(i))&(El<=angle_range(i+1)));
        if ~isempty(line1)
            freq_fad_El_prn(i_prn, i) = mean(freq_fad(line1));
%             freq_fad_El_Ar(i, :) = mean(freq_fad(line1, :), 1);
        end
    end
end
freq_fad_El_prn(freq_fad_El_prn==0)=NaN;

% figure();
% mesh([0 : 10 : 350], [1:79], abs(freq_fad_El_Ar));


for i = 1:90
    line1 = find(~isnan(freq_fad_El_prn(:,i)));
    freq_fad_El(i) = mean(freq_fad_El_prn(line1,i));
end

figure();
plot(freq_fad_El, '.');

% figure();
% plot(freq_fad_El_prn(1,:), '.');

figure();
plot(freq_fad, El, 'o')


% figure();
% plot(El, delta_cosAlpha, '.');
% figure();
% plot(El, d./cos((El./(360/2/3.14159))), '.');
figure();
plot(El, V_El_Az, '.');












% for i = 1 : length(Es_All)
%     for j = 1 : length(As_All)
%         if specular
%             Es = Es_All(i)/360/2/3.14159;
%             As = As_All(j)/360/2/3.14159;
%             delta_Es = 1/360/2/3.14159;
%             delta_As = 1/360/2/3.14159;
%             
%             cosAlpha_temp = cos(Es)*cos(Es)*cos(As-Ar)+sin(Es)*sin(Es);
%             delta_cosAlpha_temp = 2*cos(Es)*(-sin(Es))*delta_Es*cos(As-Ar) ...
%                 + (cos(Es))^2 * (-sin(As-Ar)) * delta_As ...
%                 + 2*sin(Es)*cos(Es)*delta_Es;
%         else
%             Es = Es_All(i)/360/2/3.14159;
%             As = As_All(j)/360/2/3.14159;
%             delta_Es = 1/360/2/3.14159;
%             delta_As = 1/360/2/3.14159;
%             Er = atand(h/d);
%             
%             cosAlpha_temp = cos(Es)*cos(Er)*cos(As-Ar)+sin(Es)*sin(Er);
%             delta_cosAlpha_temp = (-sin(Es))*(delta_Es)*cos(Er)*cos(As-Ar)...
%                 + cos(Es)*cos(Er)*(-sin(As-Ar))*delta_As...
%                 + cos(Es)*sin(Er)*delta_Es;
%         end
%             
%         delta_cosAlpha(i, j) = delta_cosAlpha_temp;
%         cosAlpha(i, j) = cosAlpha_temp;
%         Alpha(i, j) = real(acos(cosAlpha_temp));
%         delay(i, j) = (d/cos(Es)) * (1 - cosAlpha_temp);
%     end
% end


% figure();
% mesh(As, Es, Alpha);
% figure();
% mesh(As, Es, delay);
% figure();
% delay_mean = mean(delay, 2);
% plot(Es, delay_mean, 'o');


