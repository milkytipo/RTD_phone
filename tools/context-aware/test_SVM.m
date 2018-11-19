valPredi_KNN_Num = zeros(N, 1);
valPredi_SVM_Num = zeros(N, 1);
standard_Num = zeros(N, 1);
figure();
scatter(x_index, valScores_KNN(:,1),'.');
hold on;
scatter(x_index, valScores_KNN(:,2),'.');
hold on;
scatter(x_index, valScores_KNN(:,3),'.');
hold on;
scatter(x_index, valScores_KNN(:,4),'.');
hold on;
scatter(x_index, valScores_KNN(:,5),'.');
for j = 1 : N
    switch valPredi_KNN(j)
        case categorical({'viaduct_down'})
            valPredi_KNN_Num(j) = 1;
        case categorical({'viaduct_up'})
            valPredi_KNN_Num(j) = 2;
        case categorical({'urban'})
            valPredi_KNN_Num(j) = 3;
        case categorical({'boulevard'})
            valPredi_KNN_Num(j) = 4;
        case categorical({'surburb'})
            valPredi_KNN_Num(j) = 5;
    end
    
    switch valPredi_SVM(j)
        case categorical({'viaduct_down'})
            valPredi_SVM_Num(j) = 1;
        case categorical({'viaduct_up'})
            valPredi_SVM_Num(j) = 2;
        case categorical({'urban'})
            valPredi_SVM_Num(j) = 3;
        case categorical({'boulevard'})
            valPredi_SVM_Num(j) = 4;
        case categorical({'surburb'})
            valPredi_SVM_Num(j) = 5;
    end
    
    switch class_name(j)
        case categorical({'viaduct_down'})
            standard_Num(j) = 1;
        case categorical({'viaduct_up'})
            standard_Num(j) = 2;
        case categorical({'urban'})
            standard_Num(j) = 3;
        case categorical({'boulevard'})
            standard_Num(j) = 4;
        case categorical({'surburb'})
            standard_Num(j) = 5;
    end
    
end

figure();
plot(ENU(1, :), ENU(2, :), '.');
scatter(ENU(1, :), ENU(2, :), 7, standard_Num, 'filled');
colormap(jet(k));

figure();
plot(ENU(1, :), ENU(2, :), '.');
scatter(ENU(1, :), ENU(2, :), 7, valPredi_SVM_Num, 'filled');
colormap(jet(k));

figure();
plot(ENU(1, :), ENU(2, :), '.');
scatter(ENU(1, :), ENU(2, :), 7, valPredi_KNN_Num, 'filled');
colormap(jet(k));

parameter = paraInitial(1);
filename = 'K:\ublox_tiantai.txt';
YYMMDD = '20171123';
[parameter] = readNMEA(parameter, filename, YYMMDD);

CNR_std_ublox_novAtel_attenna = zeros(1,90);
index = zeros(1, 90);
for i = 1 : size(parameter.SOW, 2)
    for j = 1 : parameter.satNum(i)
        prn = parameter.prnNo(j, i);
        el = round(parameter.Elevation(prn, i));
        index(el) = index(el) + 1;
        CNR_std_ublox_novAtel_attenna(el) = CNR_std_ublox_novAtel_attenna(el)*((index(el)-1)/index(el)) + ...
            parameter.CNR(prn, i)*(1/index(el));
    end
end

figure();
scatter(parameter(1).satNum, parameter(1).blockNum);


aa = [0.667, 0.619, 0.921, 0.929, 0.992, 0.572;...
    0.799, 0.712, 0.975, 0.914, 0.996, 0.860;...
    0.931, 0.902, 1, 0.945, 0.999, 0.982];

figure();
plot(aa(1,:));
hold on;
plot(aa(2,:));
hold on;
plot(aa(3,:));


a = sqrt(parameter(6).ENU_error(5,:).^2 + parameter(6).ENU_error(6,:).^2) - sqrt(parameter(6).ENU_error(1,:).^2 + parameter(6).ENU_error(2,:).^2);




aa = zeros(4, 200);
aaa = zeros(2, 200);
for i = 1 : 200
    [~, col] = ismember(parameter(6).SOW(1, i)-2, calibration(6).SOW(1,:));
    aa(1:3, i) = xyz2enu(parameter(6).pos_xyz(:, i), calibration(6).pos_xyz(:, col));
    % ！！！！！！！！！！！！ 悳列餓 ！！！！！！！！！！！！！！%
    aa(4, i) = norm(aa(1:3, i));
    aaa(:, i) = [sin(parameter(6).vel_angle(i)); cos(parameter(6).vel_angle(i))];
end
figure;plot(aa(end,:))


figure();
plot(parameter(6).pos_enu(1, :), parameter(6).pos_enu(2, :), '.');

a = atan(parameter(6).ENU_error(1,:)./parameter(6).ENU_error(2,:))*180+180;


boxName = zeros(sum(timeLen(1:6)), 1);
boxName(1:timeLen(1)) = 1;
boxName((timeLen(1)+1):sum(timeLen(1:2))) = 2;
boxName((sum(timeLen(1:2))+1):sum(timeLen(1:3))) = 3;
boxName((sum(timeLen(1:3))+1):sum(timeLen(1:4))) = 4;
boxName((sum(timeLen(1:4))+1):sum(timeLen(1:5))) = 5;
boxName((sum(timeLen(1:5))+1):sum(timeLen(1:6))) = 6;
% boxName((sum(timeLen(1:6))+1):sum(timeLen(1:7))) = 7;
figure()
boxplot(feaCluster.paraRaw(:, 3), idxExp);
figure()
boxplot(feaCluster.paraRaw(:, 4), idxExp);
figure()
boxplot(feaCluster.paraRaw(:, 5), idxExp);
figure()
boxplot(feaCluster.paraRaw(:, 7), idxExp);
figure()
boxplot(feaCluster.paraRaw(:, 8), idxExp);
figure()
boxplot(feaCluster.paraRaw(:, 9), idxExp);

idxExp_temp = idxExp;
k_center_temp = k_center;
idxExp_temp(idxExp==2) = 3;
k_center_temp(3, :) = k_center(2, :);
idxExp_temp(idxExp==3) = 2;
k_center_temp(2, :) = k_center(3, :);
idxExp_temp(idxExp==6) = 4;
k_center_temp(4, :) = k_center(6, :);
idxExp_temp(idxExp==5) = 6;
k_center_temp(6, :) = k_center(5, :);
idxExp_temp(idxExp==4) = 5;
k_center_temp(5, :) = k_center(4, :);
idxExp = idxExp_temp;
k_center = k_center_temp;

feaEachClu_temp = feaEachClu;
feaEachClu_temp(3) = feaEachClu(2);
feaEachClu_temp(2) = feaEachClu(3);
feaEachClu_temp(4) = feaEachClu(6);
feaEachClu_temp(5) = feaEachClu(4);
feaEachClu_temp(6) = feaEachClu(5);
feaEachClu = feaEachClu_temp;




for i = 1 : 10
    para_mu_var(2*i-1,1) = mean(feaEachClu(i).paraRaw(:, 3));
    para_mu_var(2*i-1,2) = mean(feaEachClu(i).paraRaw(:, 4));
    para_mu_var(2*i-1,3) = mean(feaEachClu(i).paraRaw(:, 7));
    para_mu_var(2*i-1,4) = mean(feaEachClu(i).paraRaw(:, 8));
    para_mu_var(2*i-1,5) = mean(feaEachClu(i).paraRaw(:, 5));
    para_mu_var(2*i,1) = var(feaEachClu(i).paraRaw(:, 3));
    para_mu_var(2*i,2) = var(feaEachClu(i).paraRaw(:, 4));
    para_mu_var(2*i,3) = var(feaEachClu(i).paraRaw(:, 7));
    para_mu_var(2*i,4) = var(feaEachClu(i).paraRaw(:, 8));
    para_mu_var(2*i,5) = var(feaEachClu(i).paraRaw(:, 5));
end

for i = 1 : 10
    pos_err = feaEachClu(i).paraRaw(:, 9);
    pos_err = sort(pos_err);
    pos_err_N = round(0.9*length(pos_err));
    pos_accu(i) = pos_err(pos_err_N);
end


idxExp_test = idxExp(10102:10833);
idxExp_test(100:150) = 4;
prob_vector = zeros(1, 10);
markov_mat = zeros(10, 10);
Num_idx = length(idxExp_test);
for i = 2 : Num_idx
    idx_temp = idxExp_test(i);
    idx_temp_pre = idxExp_test(i-1);
    prob_vector(idx_temp) = prob_vector(idx_temp) + 1;
    markov_mat(idx_temp_pre, idx_temp) = markov_mat(idx_temp_pre, idx_temp) + 1;
end
prob_vector = prob_vector / (Num_idx);
markov_mat = markov_mat / (Num_idx);


yfit_Num_temple = yfit_Num(5656:6146);
predictResult_temp = zeros(6,1);
for i = 1 : 6
    predictResult_temp(i) = sum(yfit_Num_temple==i)/length(yfit_Num_temple);
end

