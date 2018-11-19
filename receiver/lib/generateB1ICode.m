function B1code = generateB1ICode(PRN)
% 2012-3-8
% Gene Gao
% Compass的B1频点测距码生成器
% B1频点I支路测距码由两个线性序列G1和G2模二和产生平衡Gold码后截短1chip生成
% G1序列初始相位：01010101010
% G2序列初始相位：01010101010
% PRN=1:37
% -1代表1，1代表0

% generateB1code.m generates one of the 37 Compass satellite B1 codes.
%
% B1code = generateB1code(PRN)
%
%   Inputs:
%       PRN         - PRN number of the sequence.
%
%   Outputs:
%       B1code      - a vector containing the desired B1 code sequence 
%                   (chips).  

%--- Make the code shift array. The shift depends on the PRN number -------
% The g2s vector holds the appropriate shift of the g2 code to generate
% the B1 code (ex. for SV#1 - use a G2 shift of g2s(1) = 1335)
g2s = [1335, 466, 633, 497, 1466, 1276, 736, 1004, 498, 1688, 1337, 468, ...
        499, 944, 1468,  1278, 1689, 1338, 636, 500, 945, 1469, 1690, 470, ...
        637, 501, 946, 1340, 471, 638, 502, 1693, 1342, 473, 1694, 1343, 1695];

%--- Pick right shift for the given PRN number ----------------------------
g2shift = g2s(PRN);

%--- Generate G1 code -----------------------------------------------------

%--- Initialize g1 output to speed up the function ---
g1 = zeros(1, 2047);
%--- Load shift register ---
reg = [1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1];

%--- Generate all G1 signal chips based on the G1 feedback polynomial -----
for i=1:2047
    g1(i)       = reg(11);
    saveBit     = reg(1)*reg(7)*reg(8)*reg(9)*reg(10)*reg(11);
    reg(2:11)   = reg(1:10);
    reg(1)      = saveBit;
end

%--- Generate G2 code -----------------------------------------------------

%--- Initialize g2 output to speed up the function ---
g2 = zeros(1, 2047);
%--- Load shift register ---
reg = [1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1];

%--- Generate all G2 signal chips based on the G2 feedback polynomial -----
for i=1:2047
    g2(i)       = reg(11);
    saveBit     = reg(1)*reg(2)*reg(3)*reg(4)*reg(5)*reg(8)*reg(9)*reg(11);
    reg(2:11)   = reg(1:10);
    reg(1)      = saveBit;
end

%--- Shift G2 code --------------------------------------------------------
%The idea: g2 = concatenate[ g2_right_part, g2_left_part ];
g2 = [g2(2047-g2shift+1 : 2047), g2(1 : 2047-g2shift)];

%--- Form single sample B1 code by multiplying G1 and G2 ------------------
B1code = -(g1 .* g2);
%--- Cut off 1 chip to Achieve 2046 chips ---------------------------------
B1code(end)=[];