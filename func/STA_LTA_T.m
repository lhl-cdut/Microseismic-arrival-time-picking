function [FlagS,R] = STA_LTA_T(X,Y,Z,Th)
%%STA/LTA_Method_in_Akram's_Paper
Fs = 4000;                   % Sampling frequency
T = 1/Fs;                    % Sample time
L = length(Z);
%%����Ϊ�����������
%CF������������ֵ
%SS�������������г���
%LL�������������г���
% SS = input('������Short Window Length:');%Short Time points
% LL = input('������Long Window Length:');%Long Time points
% Th = input('��������ֵ:');%Long Time points
SS = 30;
LL = 180;

%Start_Time = datestr(now,'mmmm dd,yyyy HH:MM:SS.FFF AM')
% X = reshape(X,L,1);
% Y = reshape(Y,L,1);
% Z = reshape(Z,L,1);
CF = sqrt(X.^2 + Y.^2 + Z.^2);

% for i =1:1:LL
%      CM = CF(i);
%      AverCM = mean(CM);
%  end
%  CFadd = AverCM + (AverCM/100)*rand(LL-1,1);
%  CFnew = [CFadd;CF];
% ����LTA��STA
STA = zeros(1,L);
LTA = zeros(1,L);
R = zeros(1,L);
for i = LL:1:L
    LTA(i) = mean(CF(i-LL+1:i));
    STA(i) = mean(CF(i-SS+1:i));
end

for i = 1:1:SS
    R(i) = 1;
end
for i = SS+1:1:LL-1
    R(i) = (mean(CF(i-SS+1:i)))/(mean(CF(1:i)));
end
for i = LL:1:L
    R(i) = STA(i)/LTA(i);
end


A = find(R>Th);
if ~isempty(A)
    FlagS = A(1);
else
    FlagS = 0;
end


% %End_Time = datestr(now,'mmmm dd,yyyy HH:MM:SS.FFF AM')
% figure
% %subplot(311);plot(X,'r');hold on;plot(Y,'g');plot(Z);hold off;
% %subplot(312);
% plot(R); title({['Short Time Window=',num2str(SS)],['Long Time Window=',num2str(LL)]});
% %subplot(313);plot(CF);