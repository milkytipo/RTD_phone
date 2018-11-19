
function [Accum_complex] = Correlation_BasedOnFFT(Seq1, Seq2, DispFlag)

Accum_complex = ifft( fft(Seq1).*conj(fft(Seq2)) );

Accum = abs(Accum_complex);    

if strcmp(DispFlag,'DispYes')
    
    figure,plot(Accum);
    title('The result of CM IFFT');
    
end