% 产生标准扩频码
clear; clc;close all;
prn = 2;
sys = 'GPS_L1CA';
sample_persec = 10;
corrShape_x = -4:0.1:4;
codeTable = generateGoldCode(sys, prn);
if strcmp(sys, 'GPS_L1CA')
    codePhase = 1023;
else
    codePhase = 2046;
end
samplePos = [1:codePhase*sample_persec];
samplePhase = ceil(samplePos/sample_persec);
codeSample = codeTable(samplePhase);
corrShape = zeros(1, length(codeSample));
for i = 1 : length(codeSample)
    codeSample_2 = circshift(codeSample',i-sample_persec*10)';
    corrShape(i) = sum(codeSample.*codeSample_2);
end
figure();
corrShape_y = corrShape(sample_persec*6:sample_persec*14);
plot(corrShape_x, corrShape_y);
title('corrShape_y_standard');
grid on
grid minor

