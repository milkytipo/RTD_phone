function [downSis, preFilt] = PreFiltering(preFilt, sis, N)


carrindx = mod( (0:N-1)'*preFilt.IF1/preFilt.fs + preFilt.phase, 1 );

preFilt.phase = mod(N*preFilt.IF1/preFilt.fs + preFilt.phase, 1);

locarrIF1 = exp(-2*pi*carrindx);

downSis = sis .* locarrIF1;

[downSis, preFilt.zi] = filter(preFilt.Hd, 1, downSis, preFilt.zi);
