function snr=SNR (I,In)
%
%I:original signal(include noise)
% In: Noise + original signal
% snr = 10*log(sigma2(I2)/sigma2(I2-I1))
% Ps =1/length(I)* sum(I.^2);
% Pn = 1/length(I)* sum((I-In).^2);
Ps=sum(sum((I-mean(mean(I))).^2));%signal power
Pn=sum(sum((I-In).^2));%noise power

snr=10*log10(Ps/Pn);