function [carrierTable] = generateCarrier(IFsearch, crt)
carrierPhase = 2*pi* (IFsearch).*crt;
carrierTable = exp(-1j*carrierPhase);