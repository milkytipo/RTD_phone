%function Pcode = generatePcode(PRN)

%--- Pick right shift for the given PRN number ----------------------------
x2shift = 1;

%--- Initial states of foure registers ------------------------------------
x1a_reset = [1,1,-1,1,1,-1,1,1,-1,1,1,1];
x1b_reset = [1,-1,1,-1,1,-1,1,-1,1,-1,1,1];
x2a_reset = [-1,1,1,-1,1,1,-1,1,1,-1,1,-1];
x2b_reset = [1,-1,1,-1,1,-1,1,-1,1,-1,1,1];

%--- Generate X1A code ----------------------------------------------------

%--- Initialize x1a output to speed up the function ---
x1a = zeros();

%--- Load shift register ---
reg1a = x1a_reset;

%--- Generate all X1A signal chips based on the X1A feedback polynomial -----
for i=1:4092
	x1a(i)      = reg1a(12);
	saveBit     = reg1a(6)*reg1a(8)*reg1a(11)*reg1a(12);
	reg1a(2:12)   = reg1a(1:11);
	reg1a(1)      = saveBit;
end

%--- Generate X1B code ----------------------------------------------------

%--- Initialize x1b output to speed up the function ---
x1b = zeros();

%--- Load shift register ---
reg1b = x1b_reset;

%--- Generate all X1B signal chips based on the X1B feedback polynomial -----

for i=1:4092
	x1b(i)      = reg1b(12);
	saveBit     = reg1b(1)*reg1b(2)*reg1b(5)*reg1b(8)*reg1b(9)*reg1b(10)*reg1b(11)*reg1b(12);
	reg1b(2:12)   = reg1b(1:11);
	reg1b(1)      = saveBit;
end

x1 = x1a .* x1b;

%--- Generate X2A code ----------------------------------------------------

%--- Initialize x2a output to speed up the function ---
x2a = zeros();

%--- Load shift register ---
reg2a = x2a_reset;

%--- Generate all X2A signal chips based on the X2A feedback polynomial -----
for i=1:4092
	x2a(i)      = reg2a(12);
	saveBit     = reg2a(1)*reg2a(3)*reg2a(4)*reg2a(5)*reg2a(7)*reg2a(8)*reg2a(9)*reg2a(10)*reg2a(11)*reg2a(12);
	reg2a(2:12)   = reg2a(1:11);
	reg2a(1)      = saveBit;
end

%--- Cut off ---


%--- Generate X2B code ----------------------------------------------------

%--- Initialize x2b output to speed up the function ---
x2b = zeros();

%--- Load shift register ---
reg2b = x2b_reset;

%--- Generate all X2B signal chips based on the X2B feedback polynomial -----

for i=1:4092
    x2b(i)      = reg2b(12);
	saveBit     = reg2b(2)*reg2b(3)*reg2b(4)*reg2b(8)*reg2b(9)*reg2b(12);
	reg2b(2:12)   = reg2b(1:11);
	reg2b(1)      = saveBit;
end

%--- Cut off ---

x2 = x2a .* x2b;

%--- Shift X2 code --------------------------------------------------------
%The idea: x2 = concatenate[ x2_right_part, x2_left_part ];
k     = 4092;
x2s   = [1, x2(1:k-x2shift)];
x2s   = x2;

%--- Form single sample C/A code by multiplying G1 and G2 -----------------
Pcode = (x1 .* x2s);
p = (Pcode-1)/(-2);