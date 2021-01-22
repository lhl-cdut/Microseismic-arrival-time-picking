%% 

load('I:\小论文程序 改进\forth\ZS.mat')%模拟信号Zs
Zs=Zs';
gcolorR1 = [0.5 0 0];
gcolorR = [0.72 0.15 0.2];
gcolorG = [0.25 0.45 0.2];
gcolorB = [0 0.44 0.74];

 L=length(Zs);
Y_noise=randn(L,1);

for i=-10:1:-6
[Y(:,i+11),NOISE(:,i+11)]=add_noisem(Zs,Y_noise,i);%Y为加噪声后的数据
end
% % 测试信号的信噪比
for i=1:1:5
snr(i)=SNR (Zs,Y(:,i));
end

[IMFz_1, ~]=eemd_319(Y(:,1)',0.2,100,100);IMFz_1=IMFz_1';
[IMFz_2, ~]=eemd_319(Y(:,2)',0.2,100,100);IMFz_2=IMFz_2';
[IMFz_3, ~]=eemd_319(Y(:,3)',0.2,100,100);IMFz_3=IMFz_3';
[IMFz_4, ~]=eemd_319(Y(:,4)',0.2,100,100);IMFz_4=IMFz_4';
[IMFz_5, ~]=eemd_319(Y(:,5)',0.2,100,100);IMFz_5=IMFz_5';
%% -10dB

[Row_imfZ,Column_imfZ]=size(IMFz_1);
SampEnVal_Z_1=zeros(1,Column_imfZ);
for i=1:1:Column_imfZ
[SampEnVal_Z_1(:,i)] = SampEn_2(IMFz_1(:,i)', 1, 0.15*std(Y(:,1)));
end

PZ_1=zeros(Row_imfZ,1);
for  i=1:1:Column_imfZ
    if round( SampEnVal_Z_1(:,i))<=0.2
    PZ_1=PZ_1+IMFz_1(:,i);  
    end
end
snr(1,1)=SNR (Zs,PZ_1);
figure (1)
[ha,pos]=tight_subplot(2,1,[.02 .02],[.08 .01],[.15 .02])
axes (ha (1))
h=plot(Y(:,1),'b-','lineWidth',1);
g=get(h,'Parent');
set(g,'lineWidth',1.4);
set(ha(1),'xtick',0:100:(L-1),'xticklabel',[],'ticklength',[0.005 0.0025],'FontSize',10)

axes(ha(2))
h=plot(PZ_1,'r-','LineWidth',1);
g=get(h,'Parent');
set(g,'lineWidth',1.4);
set(ha(2),'xtick',0:100:L-1,'xticklabel',0:100:(L-1),'ticklength',[0.005 0.0025],'Fontsize',10)
xlabel('采样点','fontname','黑体','fontsize',12);
ylabel('振幅（m/s）','fontname','黑体','fontsize',12)

% % 小波多尺度处理
[CZ_1, LZ_1]=wavedec(Y(:,1),3,'db10'); %多尺度分解
ZA3_1=wrcoef('a',CZ_1,LZ_1,'db10',3); %重构低频系数
snr(2,1)=SNR (Zs,ZA3_1);

figure (2)
[ha,pos]=tight_subplot(2,1,[.02 .02],[.08 .01],[.15 .02])
axes (ha (1))
h=plot(Y(:,1),'b-','lineWidth',1);
g=get(h,'Parent');
set(g,'lineWidth',1.4);
set(ha(1),'xtick',0:100:(L-1),'xticklabel',[],'ticklength',[0.005 0.0025],'FontSize',10)

axes(ha(2))
h=plot(ZA3_1,'r-','LineWidth',1);
g=get(h,'Parent');
set(g,'lineWidth',1.4);
set(ha(2),'xtick',0:100:L-1,'xticklabel',0:100:(L-1),'ticklength',[0.005 0.0025],'Fontsize',10)
xlabel('采样点','fontname','黑体','fontsize',12);
ylabel('振幅（m/s）','fontname','黑体','fontsize',12)





%% -9dB

[Row_imfZ,Column_imfZ]=size(IMFz_2);
SampEnVal_Z_2=zeros(1,Column_imfZ);
for i=1:1:Column_imfZ
[SampEnVal_Z_2(:,i)] = SampEn_2(IMFz_2(:,i)', 1, 0.15*std(Y(:,2)));
end


PZ_2=zeros(Row_imfZ,1);
for  i=1:1:Column_imfZ
    if SampEnVal_Z_2(:,i)<0.2
    PZ_2=PZ_2+IMFz_2(:,i);  
    end
end
snr(1,2)=SNR (Zs,PZ_2);

figure (3)
[ha,pos]=tight_subplot(2,1,[.02 .02],[.08 .01],[.15 .02])
axes (ha (1))
h=plot(Y(:,2),'b-','lineWidth',1);
g=get(h,'Parent');
set(g,'lineWidth',1.4);
set(ha(1),'xtick',0:100:(L-1),'xticklabel',[],'ticklength',[0.005 0.0025],'FontSize',10)

axes(ha(2))
h=plot(PZ_2,'r-','LineWidth',1);
g=get(h,'Parent');
set(g,'lineWidth',1.4);
set(ha(2),'xtick',0:100:L-1,'xticklabel',0:100:(L-1),'ticklength',[0.005 0.0025],'Fontsize',10)
xlabel('采样点','fontname','黑体','fontsize',12);
ylabel('振幅（m/s）','fontname','黑体','fontsize',12)

% % 小波多尺度处理
[CZ_2, LZ_2]=wavedec(Y(:,2),3,'db10'); %多尺度分解
ZA3_2=wrcoef('a',CZ_2,LZ_2,'db10',3); %重构低频系数
snr(2,2)=SNR (Zs,ZA3_2);

figure (4)
[ha,pos]=tight_subplot(2,1,[.02 .02],[.08 .01],[.15 .02])
axes (ha (1))
h=plot(Y(:,2),'b-','lineWidth',1);
g=get(h,'Parent');
set(g,'lineWidth',1.4);
set(ha(1),'xtick',0:100:(L-1),'xticklabel',[],'ticklength',[0.005 0.0025],'FontSize',10)

axes(ha(2))
h=plot(ZA3_2,'r-','LineWidth',1);
g=get(h,'Parent');
set(g,'lineWidth',1.4);
set(ha(2),'xtick',0:100:L-1,'xticklabel',0:100:(L-1),'ticklength',[0.005 0.0025],'Fontsize',10)
xlabel('采样点','fontname','黑体','fontsize',12);
ylabel('振幅（m/s）','fontname','黑体','fontsize',12)

%% -8dB

[Row_imfZ,Column_imfZ]=size(IMFz_3);
SampEnVal_Z_3=zeros(1,Column_imfZ);
for i=1:1:Column_imfZ
[SampEnVal_Z_3(:,i)] = SampEn_2(IMFz_3(:,i)', 1, 0.15*std(Y(:,3)));
end


PZ_3=zeros(Row_imfZ,1);
for  i=1:1:Column_imfZ
    if SampEnVal_Z_3(:,i)<0.2
    PZ_3=PZ_3+IMFz_3(:,i);  
    end
end
snr(1,3)=SNR (Zs,PZ_3);

figure (5)
[ha,pos]=tight_subplot(2,1,[.02 .02],[.08 .01],[.15 .02])
axes (ha (1))
h=plot(Y(:,3),'b-','lineWidth',1);
g=get(h,'Parent');
set(g,'lineWidth',1.4);
set(ha(1),'xtick',0:100:(L-1),'xticklabel',[],'ticklength',[0.005 0.0025],'FontSize',10)

axes(ha(2))
h=plot(PZ_3,'r-','LineWidth',1);
g=get(h,'Parent');
set(g,'lineWidth',1.4);
set(ha(2),'xtick',0:100:L-1,'xticklabel',0:100:(L-1),'ticklength',[0.005 0.0025],'Fontsize',10)
xlabel('采样点','fontname','黑体','fontsize',12);
ylabel('振幅（m/s）','fontname','黑体','fontsize',12)

%%小波多尺度处理
[CZ_3, LZ_3]=wavedec(Y(:,3),3,'db10'); %多尺度分解
ZA3_3=wrcoef('a',CZ_3,LZ_3,'db10',3); %重构低频系数
snr(2,3)=SNR (Zs,ZA3_3);

figure (6)
[ha,pos]=tight_subplot(2,1,[.02 .02],[.08 .01],[.15 .02])
axes (ha (1))
h=plot(Y(:,3),'b-','lineWidth',1);
g=get(h,'Parent');
set(g,'lineWidth',1.4);
set(ha(1),'xtick',0:100:(L-1),'xticklabel',[],'ticklength',[0.005 0.0025],'FontSize',10)

axes(ha(2))
h=plot(ZA3_3,'r-','LineWidth',1);
g=get(h,'Parent');
set(g,'lineWidth',1.4);
set(ha(2),'xtick',0:100:L-1,'xticklabel',0:100:(L-1),'ticklength',[0.005 0.0025],'Fontsize',10)
xlabel('采样点','fontname','黑体','fontsize',12);
ylabel('振幅（m/s）','fontname','黑体','fontsize',12)


%% 4、 -7dB


[Row_imfZ,Column_imfZ]=size(IMFz_4);
SampEnVal_Z_4=zeros(1,Column_imfZ);
for i=1:1:Column_imfZ
[SampEnVal_Z_4(:,i)] = SampEn_2(IMFz_4(:,i)', 1, 0.15*std(Y(:,4)));
end


PZ_4=zeros(Row_imfZ,1);
for  i=1:1:Column_imfZ
    if SampEnVal_Z_4(:,i)<0.2
    PZ_4=PZ_4+IMFz_4(:,i);  
    end
end
snr(1,4)=SNR (Zs,PZ_4);

figure (7)
[ha,pos]=tight_subplot(2,1,[.02 .02],[.08 .01],[.15 .02])
axes (ha (1))
h=plot(Y(:,4),'b-','lineWidth',1);
g=get(h,'Parent');
set(g,'lineWidth',1.4);
set(ha(1),'xtick',0:100:(L-1),'xticklabel',[],'ticklength',[0.005 0.0025],'FontSize',10)

axes(ha(2))
h=plot(PZ_4,'r-','LineWidth',1);
g=get(h,'Parent');
set(g,'lineWidth',1.4);
set(ha(2),'xtick',0:100:L-1,'xticklabel',0:100:(L-1),'ticklength',[0.005 0.0025],'Fontsize',10)
xlabel('采样点','fontname','黑体','fontsize',12);
ylabel('振幅（m/s）','fontname','黑体','fontsize',12)

%%小波多尺度处理
[CZ_4, LZ_4]=wavedec(Y(:,4),3,'db10'); %多尺度分解
ZA3_4=wrcoef('a',CZ_4,LZ_4,'db10',3); %重构低频系数
snr(2,4)=SNR (Zs,ZA3_4);

figure (6)
[ha,pos]=tight_subplot(2,1,[.02 .02],[.08 .01],[.15 .02])
axes (ha (1))
h=plot(Y(:,4),'b-','lineWidth',1);
g=get(h,'Parent');
set(g,'lineWidth',1.4);
set(ha(1),'xtick',0:100:(L-1),'xticklabel',[],'ticklength',[0.005 0.0025],'FontSize',10)

axes(ha(2))
h=plot(ZA3_4,'r-','LineWidth',1);
g=get(h,'Parent');
set(g,'lineWidth',1.4);
set(ha(2),'xtick',0:100:L-1,'xticklabel',0:100:(L-1),'ticklength',[0.005 0.0025],'Fontsize',10)
xlabel('采样点','fontname','黑体','fontsize',12);
ylabel('振幅（m/s）','fontname','黑体','fontsize',12)




%% 5 -6dB


[Row_imfZ,Column_imfZ]=size(IMFz_5);
SampEnVal_Z_5=zeros(1,Column_imfZ);
for i=1:1:Column_imfZ
[SampEnVal_Z_5(:,i)] = SampEn_2(IMFz_5(:,i)', 1, 0.15*std(Y(:,5)));
end

PZ_5=zeros(Row_imfZ,1);
for  i=1:1:Column_imfZ
    if SampEnVal_Z_5(:,i)<0.2
    PZ_5=PZ_5+IMFz_5(:,i);  
    end
end
snr(1,5)=SNR (Zs,PZ_5);

figure (9)
[ha,pos]=tight_subplot(2,1,[.02 .02],[.08 .01],[.15 .02])
axes (ha (1))
h=plot(Y(:,5),'b-','lineWidth',1);
g=get(h,'Parent');
set(g,'lineWidth',1.4);
set(ha(1),'xtick',0:100:(L-1),'xticklabel',[],'ticklength',[0.005 0.0025],'FontSize',10)

axes(ha(2))
h=plot(PZ_5,'r-','LineWidth',1);
g=get(h,'Parent');
set(g,'lineWidth',1.4);
set(ha(2),'xtick',0:100:L-1,'xticklabel',0:100:(L-1),'ticklength',[0.005 0.0025],'Fontsize',10)
xlabel('采样点','fontname','黑体','fontsize',12);
ylabel('振幅（m/s）','fontname','黑体','fontsize',12)


%%小波多尺度分解
[CZ_5, LZ_5]=wavedec(Y(:,5),3,'db10'); %多尺度分解
ZA3_5=wrcoef('a',CZ_5,LZ_5,'db10',3); %重构低频系数
snr(2,5)=SNR (Zs,ZA3_5);

figure (10)
[ha,pos]=tight_subplot(2,1,[.02 .02],[.08 .01],[.15 .02])
axes (ha (1))
h=plot(Y(:,5),'b-','lineWidth',1);
g=get(h,'Parent');
set(g,'lineWidth',1.4);
set(ha(1),'xtick',0:100:(L-1),'xticklabel',[],'ticklength',[0.005 0.0025],'FontSize',10)

axes(ha(2))
h=plot(ZA3_5,'r-','LineWidth',1);
g=get(h,'Parent');
set(g,'lineWidth',1.4);
set(ha(2),'xtick',0:100:L-1,'xticklabel',0:100:(L-1),'ticklength',[0.005 0.0025],'Fontsize',10)
xlabel('采样点','fontname','黑体','fontsize',12);
ylabel('振幅（m/s）','fontname','黑体','fontsize',12)


