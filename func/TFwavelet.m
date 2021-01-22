function TFwavelet(fs,Z)

l = length(Z);
Ts = l / fs;
x = 1:1:l;
Tt = 1/fs .* x;
t=Ts:1/fs:Ts;
s=Z; %������ͬƵ�������źźϳɵķ����ź�
%%%%%%%%%%%%%%%%%С��ʱƵͼ����%%%%%%%%%%%%%%%%%%
wavename='sym4';
totalscal=512; %�߶����еĳ��ȣ���scal�ĳ���
wcf=centfrq(wavename); %С��������Ƶ��
cparam=2*wcf*totalscal; %Ϊ�õ����ʵĳ߶�������Ĳ���
a=totalscal:-1:1; 
scal=cparam./a; %�õ������߶ȣ���ʹת���õ�Ƶ������Ϊ�Ȳ�����
coefs=cwt(s,scal,wavename); %�õ�С��ϵ��
f=scal2frq(scal,wavename,1/fs); %���߶�ת��ΪƵ��
% f=scal2frq(scal,wavename,fs); %���߶�ת��ΪƵ��

% figure;
% subplot(2,1,1);
% plot(Tt,s);
% xlabel('Time / s');
% ylabel('Amplitude');
% subplot(2,1,2);
h=imagesc(Tt,f,abs(coefs)); %����ɫ��ͼ
g=get(h,'Parent');
set(g,'linewidth',1.6)
colormap('summer');
axis xy;
colorbar;
%caxis([0,3000]);
% xlabel('Time / s');
% ylabel('Frequency / Hz');
xlabel('Time','fontname','Times New Roman','FontSize',10);
ylabel('Frequency','fontname','Times New Roman','FontSize',10);