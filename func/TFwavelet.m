function TFwavelet(fs,Z)

l = length(Z);
Ts = l / fs;
x = 1:1:l;
Tt = 1/fs .* x;
t=Ts:1/fs:Ts;
s=Z; %两个不同频率正弦信号合成的仿真信号
%%%%%%%%%%%%%%%%%小波时频图绘制%%%%%%%%%%%%%%%%%%
wavename='sym4';
totalscal=512; %尺度序列的长度，即scal的长度
wcf=centfrq(wavename); %小波的中心频率
cparam=2*wcf*totalscal; %为得到合适的尺度所求出的参数
a=totalscal:-1:1; 
scal=cparam./a; %得到各个尺度，以使转换得到频率序列为等差序列
coefs=cwt(s,scal,wavename); %得到小波系数
f=scal2frq(scal,wavename,1/fs); %将尺度转换为频率
% f=scal2frq(scal,wavename,fs); %将尺度转换为频率

% figure;
% subplot(2,1,1);
% plot(Tt,s);
% xlabel('Time / s');
% ylabel('Amplitude');
% subplot(2,1,2);
h=imagesc(Tt,f,abs(coefs)); %绘制色谱图
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