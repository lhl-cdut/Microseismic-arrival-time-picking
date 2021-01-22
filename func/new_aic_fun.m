
function [P1,P2,P3,P4,P5,tpwt2,tOA2,tAA2,tOSTA2,tASTA2] = new_aic_fun(dataZ)
% P1 = Pnew; P2 = Oaic; P3 = Aaic; P4 = OSTA; P5 = ASTA
addpath(genpath(pwd));
%================================================
%% EEMD
twt1 = cputime;
IMFAZ = eemd(dataZ,0.1,100);
[~,n] = size(IMFAZ);
IMFz = IMFAZ(:,2:n);  % IMF1 is original data
twt2 = cputime-twt1;
tp1 = cputime;
Row_imfZ = length(IMFz(:,1));
Column_imfZ = length(IMFz(1,:));

SampEnVal_Z=zeros(1,Column_imfZ);
for j=1:1:Column_imfZ
    [SampEnVal_Z(:,j)] = SampEn_2(IMFz(:,j)', 1, 0.15*std(dataZ));
end

PZ_1=zeros(Row_imfZ,1);
for  j=1:1:Column_imfZ
    if round(SampEnVal_Z(:,j))<=0.2
            PZ_1=PZ_1+IMFz(:,j);  
    end
end
tp2 = cputime-tp1;

%% Pnew
tpwt1 = cputime;
[~,B]=max(PZ_1);
if B>10
    [Find,~] = M_aic(PZ_1(1:B));
    P1 = Find-1;
else
    [Find,MAic] = M_aic(PZ_1); %M-AIC
    P1 = Find-1; %Corresponding to seiers
end
tpwt2 = cputime-tpwt1 + twt2 + tp2;

%% POaic
tOA1 = cputime;
[Find2,~] = M_aic(dataZ); %M-AIC
P2 = Find2-1;
tOA2 = cputime-tOA1;

%%  PAaic
tAA1 = cputime;
[Find3,~] = M_aic(PZ_1); %M-AIC
P3 = Find3-1;
tAA2 = cputime-tAA1 + twt2;

%% POsta
tOSTA1 = cputime;
[FlagS1,RRSL1] = STA_LTA_single(dataZ,1.3);
P4 = FlagS1;
tOSTA2 = cputime-tOSTA1;

%% PAsta
tASTA1 = cputime;
[FlagS2,RRSL2] = STA_LTA_single(PZ_1,1.5);
P5 = FlagS2;
tASTA2 = cputime-tASTA1 + twt2;


