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
reg = x1a_reset;

%--- Generate all X1A signal chips based on the X1A feedback polynomial -----
for z=1:403200
	for j=1:3750
		for i=1:4092
			m           = 15345000*(z-1)+(4092*(j-1)+i);
			x1a(m)      = reg(12);
			saveBit     = reg(6)*reg(8)*reg(11)*reg(12);
			reg(2:12)   = reg(1:11);
			reg(1)      = saveBit;
		end
		reg = x1a_reset;
	end
end

%--- Generate X1B code ----------------------------------------------------

%--- Initialize x1b output to speed up the function ---
x1b = zeros();

%--- Load shift register ---
reg = x1b_reset;

%--- Generate all X1B signal chips based on the X1B feedback polynomial -----
for z=1:403200
	for j=1:3749
		for i=1:4093
			m           = 15345000*(z-1)+(4093*(j-1)+i);
			x1b(m)      = reg(12);
			saveBit     = reg(1)*reg(2)*reg(5)*reg(8)*reg(9)*reg(10)*reg(11)*reg(12);
			reg(2:12)   = reg(1:11);
			reg(1)      = saveBit;
		end
		reg = x1b_reset;
	end

	for m=(15345000*(z-1)+15344658):(15345000*(z-1)+15345000)
		x1b(m)          = x1b(15345000*(z-1)+15344657);
	end
end	

x1 = x1a .* x1b;

%--- Generate X2A code ----------------------------------------------------

%--- Initialize x2a output to speed up the function ---
x2a = zeros();

%--- Load shift register ---
reg = x2a_reset;

%--- Generate all X2A signal chips based on the X2A feedback polynomial -----
for z=1:403200
	for j=1:3750
		for i=1:4092
			m           = 15345037*(z-1)+(4092*(j-1)+i);
			x2a(m)      = reg(12);
			saveBit     = reg(1)*reg(3)*reg(4)*reg(5)*reg(7)*reg(8)*reg(9)*reg(10)*reg(11)*reg(12);
			reg(2:12)   = reg(1:11);
			reg(1)      = saveBit;
		end
		reg = x2a_reset;
	end

	for m=(15345037*(z-1)+15345001):(15345037*(z-1)+15345037)
		x2a(m)          = x2a(15345037*(z-1)+15345000);
	end
end

%--- Cut off ---
k = 403200*3750*4092;
x2as = zeros(1,k);
x2as(1:k) = x2as(1:k);

%--- Generate X2B code ----------------------------------------------------

%--- Initialize x2b output to speed up the function ---
x2b = zeros();

%--- Load shift register ---
reg = x2b_reset;

%--- Generate all X2B signal chips based on the X2B feedback polynomial -----
for z=1:403200
	for j=1:3749
		for i=1:4093
			m           = 15345037*(z-1)+(4093*(j-1)+i);
			x2b(m)      = reg(12);
			saveBit     = reg(2)*reg(3)*reg(4)*reg(8)*reg(9)*reg(12);
			reg(2:12)   = reg(1:11);
			reg(1)      = saveBit;
		end
		reg = x2b_reset;
	end

	for m=(15345037*(z-1)+15344658):(15345037*(z-1)+15345037)
		x2b(m)          = x2b(15345037*(z-1)+15344657);
	end	
end

%--- Cut off ---
x2bs        = zeros(1,k);
x2bs(1:k)   = x2b(1:k);

x2 = x2as .* x2bs;

%--- Shift X2 code --------------------------------------------------------
%The idea: x2 = concatenate[ x2_right_part, x2_left_part ];
x2s = [x2(k-x2shift+1:k), x2(1:k-x2shift)];

%--- Form single sample C/A code by multiplying G1 and G2 -----------------
Pcode = x1 .* x2s;
