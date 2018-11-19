function [Seq_Extengded] = Based2_Extengding(Seq, N)

power = ceil(log2(N));

Len = 2^power;

Seq_Extengded = zeros(1, Len);

Seq_Extengded(1,1:N) = Seq(1:N);

