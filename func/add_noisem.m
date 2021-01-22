function [Y,NOISE]=add_noisem(X,Y_noise,SNR)
%X is signal,and its sample frequency is fs;
%Y_noise is noise datasets
%SNR is signal to noise ratio in dB

L=length(X);

Y_noise=Y_noise-mean(Y_noise);
signal_power=1/L*sum(X.*X);
noise_variance=signal_power/(10^(SNR/10));
NOISE=sqrt(noise_variance)/std(Y_noise)*Y_noise;
Y=X+NOISE;







