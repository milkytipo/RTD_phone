
function [DigitalSig] = ADC(Sig)

global Constants

L = length(Sig);

flag = sign(Sig);

modulus = flag.*Sig;

DigitalSig = flag.*floor( (modulus + Constants.DELTA/2)/Constants.DELTA );

for i = 1:L
    
    if DigitalSig(i) > 2^(Constants.B)-1
        DigitalSig(i) = 2^(Constants.B)-1;
    end
    if DigitalSig(i) < -2^(Constants.B)
        DigitalSig(i) = -2^(Constants.B);
    end
end







