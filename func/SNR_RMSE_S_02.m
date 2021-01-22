function  [SNR,RMSE,S]=SNR_RMSE_S_02(signoise,signal,length)

% SNR=10*log(sum(signoise.^2)/sum((signoise-sigout).^2));
SNR=10*log(sum(signal.^2)/sum((signoise-signal).^2));

RMSE=sqrt(sum((signoise-signal).^2)/length);

sum1=0;
sum2=0;
temp=0;
for i=1:1:(length-1)
    temp=(signoise(i+1)-signoise(i))^2;
    sum1=temp+sum1;
    temp=(signal(i+1)-signal(i))^2;
    sum2=temp+sum2;
end

S=sqrt(sum2/sum1);