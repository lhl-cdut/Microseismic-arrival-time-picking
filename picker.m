
addpath(genpath(pwd));
close all;
clear;
clc;

% Curve color
gcolorR1 = [0.5 0 0];
gcolorR = [0.72 0.15 0.2];
gcolorG = [0.25 0.45 0.2];
gcolorB = [0 0.44 0.74];

%% 1.Read data: Select Pure_E.sgy after running
global isOpenSAC;
isOpenSAC = 0;

[filename, pathname] = uigetfile({'*.*';'*.mat';'*.asc';'*.csv';'*.dat';...
    '*.sg2';'*.sgy';'*.sac';'*.xls';'*.xlsx'}, 'load seismic data','MultiSelect','on'); %选择波形文件
   % 'MultiSelect','on'-----only for opening SAC file
if isequal(filename,0)   %判断是否选择
    msgbox('Choose no file');
    return;
else
    pathfile=fullfile(pathname, filename);  %获得波形路径   
    if (iscell(filename)) %for Multi sac files reading
        [exa,exb,exc]=fileparts(pathfile{1,1});
        filenums = size(filename,2);  %for Multi sac files reading
    else
        [exa,exb,exc]=fileparts(pathfile);%for Multi sac files reading
    end
end

switch exc
    case '.dat'
        msgbox('pleas waiting');

    case {'.sg2','.SG2'}
        [filehdr,trchdr,trctxt,data] = seg2read(pathfile, 'want','filehdr,trchdr,trctxt,data');
        vslen = trchdr(1).number_of_samples;
        vtrace = filehdr.number_of_traces_in_file;
        vsfre = str2num(trctxt(1).sample_interval)*1000; %s->ms
        vseisdata = data;

        %------------------------------------------------------------------------
        
    case {'.sgy','.SGY'}
        [dataout, samplen, sampfre, samptrace, varargoutr] = altreadsegy(pathfile,'textheader','yes','fpformat','ieee');
        vseisdata=dataout;

    case '.mat'

        sydata = importdata(pathfile);
        vseisdata(:,1) = sydata.X;
        vseisdata(:,2) = sydata.Y;
        vseisdata(:,3) = sydata.Z;
        vtrace = 3;
        vslen = length(vseisdata(:,3));
        vsfre = 1/6;
        
    case '.asc'
        
        [X,Y,Z] = textread(pathfile,'%f,%f,%f','headerlines',1);
        vseisdata(:,1) = X;
        vseisdata(:,2) = Y;
        vseisdata(:,3) = Z;
        vtrace = 3;
        vslen = length(vseisdata(:,3));
        vsfre = 1/6 ;
        sampfre=6000;
    case '.csv'

        numerric = csvread(pathfile,1);
        [m,n]=size(numerric);
        %vseisdata = numerric(:,11:end);
        vseisdata = numerric;
        vtrace = n;
        vslen = m;
        vsfre = 1 ;
        
    case {'.sac','.SAC'}
        isOpenSAC = 1;
        if(iscell(filename))
            
            for f = 1:1:filenums
                [vseisdata(:,f),tlen,headsac] = rdsac(pathfile{1,f});
            end
        else
            [vseisdata,tlen,headsac] = rdsac(pathfile);
        end
        
        vtrace = size(vseisdata,2);
        vslen = size(vseisdata,1);
        vsfre = headsac.DELTA*1000 ; %0.005s->ms
        
    case {'.mseed','.MSEED'}

        if(iscell(filename))
            
            for f = 1:1:filenums
                [X,I] = rdmseed(pathfile{1,f});
                un = unique(cellstr(char(X.ChannelFullName)));
                nc = numel(un); % traces nums
                for i = 1:nc
                    k = I(i).XBlockIndex; 
                    d(:,i+(f-1)*3) = cat(1,X(k).d);           
                end
            end
            
            vtrace = nc*f;
        else
            [X,I] = rdmseed(pathfile);
            un = unique(cellstr(char(X.ChannelFullName)));
            nc = numel(un); % traces nums
            for i = 1:nc
                k = I(i).XBlockIndex;
                d(:,i) = cat(1,X(k).d);
            end
            vtrace = nc;
        end
        vseisdata = d;
        vslen = size(d,1);
        vsfre = 1/unique(cat(1,X.SampleRate))*1000; %Hz->s->ms

        
    case {'.xls','.xlsx'} %for yangning data

        
        if(iscell(filename))
            
            for f = 1:1:filenums
                fulldata = (xlsread(pathfile{1,f}))';
                tnums = size(fulldata,2);% traces of signle file
                for m = 1:1:tnums
                    vseisdata(:,tnums*(f-1)+m) = fulldata(:,m); %track one trace
                end
            end
        else
            vseisdata = (xlsread(pathfile))';
        end
        
        vtrace = size(vseisdata,2);
        vslen = size(vseisdata,1);
        vsfre = 2; %2ms  for yang forward data
     
    case {'.txt','.TXT'} %for mengxiaobo-Fracturing log data

                if(iscell(filename))
                    
                    for f = 1:1:filenums
                        [tdata,vdata] = textread(pathfile{1,f},'%f %f');
                        vseisdata(:,f) = vdata; %track one trace
                    end
                else
                    [~,vseisdata] = textread(pathfile,'%f %f');
                end
                
                vtrace = size(vseisdata,2);
                vslen = size(vseisdata,1);
                vsfre = 0.5; %0.5ms/2kHz for mengxiaobo fracturing log data
                isOpennum = 1;
                g_format = '.txt';
    otherwise
        
        msgbox('Please choose a right format file');
        return;
        
end
        dataZ = vseisdata(:,3);
%% load real microseismic data
% dataZ = cell2mat(struct2cell(load('C:\Users\Administrator\Desktop\Pick_code\data\DATA_SHICE')));
% Y=dataZ';
% L=length(Y);

%% 2 add Gaussian white noise
dataZ=dataZ';
Zs=dataZ(1:2000);
L=length(Zs);
Y_noise=randn(L,1);%add blue noise:Y_noise= = bluenoise(L,1);
Zs=Zs';
[Y,NOISE]=add_noisem(Zs,Y_noise,-11);%add_noisem(Original data,Y_noise,a):Noisy data with SNR of a
snr=SNR (Zs,Y);
%% 3 EEMD decomposition
[IMFz, ~]=eemd_319(Y',0.2,100,100);IMFz=IMFz';
 [mz,nz] = size(IMFz);
figure(1);
[ha, pos] = tight_subplot(nz+1,1,[.02 .02],[.08 .01],[.15 .02]);
cm = hsv(max([6, 111, nz]));
for k = 1:1:nz+1
    axes(ha(k));
  if k==1
      h=plot((1:L),Y,'color',gcolorB,'LineWidth',1);
      g=get(h,'Parent');
      set(g,'lineWidth',0.5);
      set(ha(k),'XTick',0:300:(L-1),'xticklabel',[]);
      ylabel(sprintf('Data'))
      hold on;
  elseif k>1 && k<nz+1
          h=plot((1:L),IMFz(:,k-1),'color',gcolorB,'LineWidth',1);
          g=get(h,'Parent');
          set(g,'lineWidth',0.5);
          hold on;
          set(ha(k),'XTick',0:300:(L-1),'xticklabel',[]);
          ylabel(sprintf('IMF%d',k-1))
  elseif k==nz+1
        h=plot((1:L),IMFz(:,k-1),'color',gcolorB,'LineWidth',1);
        g=get(h,'Parent');
        set(g,'lineWidth',0.5);
        hold on;
        set(ha(k),'XTick',0:300:(L-1),'xticklabel',[]);
        ylabel(sprintf('Residual'))
   end
end

hold off;
set(ha(k),'XTick',0:500:(L-1),'XTickLabel',0:500:(L-1),'ticklength',[0.005 0.0025],'FontSize',10);
hxlab1 = xlabel('Samples','fontname','Times New Roman','FontSize',12);

%% 4 SamEn
[Row_imfZ,Column_imfZ]=size(IMFz(:,1:end-1));
SampEnVal_Z=zeros(1,Column_imfZ);
for i=1:1:Column_imfZ
[SampEnVal_Z(:,i)] = SampEn_2(IMFz(:,i)', 1, 0.15*std(Y(:,1)));
end
PZ_1=zeros(Row_imfZ,1);
for  i=1:1:Column_imfZ
    if round(SampEnVal_Z(:,i))<=0.2
    PZ_1=PZ_1+IMFz(:,i);  
    end
end
figure(2)
h=plot(SampEnVal_Z,'b*-','lineWidth',1.2);
ymin=min(SampEnVal_Z);
ymax=max(SampEnVal_Z);
axis([1 Column_imfZ ymin ymax])
g = get (h, 'parent');
set(g, 'linewidth',1.4);
xlabel('IMF Components','fontname','Times New Roman','FontSize',12)
ylabel('SamEn','fontname','Times New Roman','FontSize',12)


%% 5 time-frequency analysis
figure (3)
[ha,pos]=tight_subplot(3,1,[.1 .1],[.08 .01],[.15 .02]);
 axes(ha(1))
 h=plot(Y,'color',gcolorR,'linewidth',1);
 ymin=min(Y);
ymax=max(Y);
axis([1 L ymin ymax])
g=get(h,'Parent');
set(g,'linewidth',1.6)
set(ha(1),'XTick',0:200:(L-1),'xticklabel',0:200:(L-1),'ticklength',[0.005 0.0025],'FontSize',12)
 xlabel('Samples','fontname','Times New Roman','FontSize',12);
 ylabel('Amplitude','fontname','Times New Roman','FontSize',12);
 
axes(ha(2));
sampfre=0.25;
fs = (1/sampfre)*1000;
L=length(Y);
n = 0:L/2-1;
yff = fft(Y,L);
mag = abs(yff);
fre = n'*fs/L;
[ma, I]=max(mag); % Dominant frequency
h=plot(fre,mag(1:L/2),'color',gcolorG,'LineWidth',1);
g=get(h,'parent');
set(g,'linewidth',1.6)
dfre = sprintf('Principal Frequency =%.2fHz\n', I/L*fs);
text(I,ma,dfre,'FontSize',16,'color',gcolorG); 
set(ha(2), 'GridLineStyle' ,'--','xgrid','on','ygrid','on');
h_leg2 = legend(ha(2),'Spectrum','Location','SouthWest');
set(h_leg2,'color',gcolorG,'TextColor',gcolorG,'FontName','Times New Roman','FontSize',12);
set(h_leg2,'Units','Normalized','FontUnits','Normalized')%这是防止变化时，产生较大的形变。
 xlabel('Frequency/Hz','fontname','Times New Roman','FontSize',12);
 ylabel('Amplitude','fontname','Times New Roman','FontSize',12);
legend boxoff;

axes(ha(3))
fs=1/sampfre*1000;
TFwavelet(sampfre,Y)

figure (4)
[ha,pos]=tight_subplot(3,1,[.1 .1],[.08 .01],[.15 .02]);
 axes(ha(1))
 h=plot(PZ_1,'color',gcolorR,'linewidth',1);
 ymin=min(Y);
ymax=max(Y);
axis([1 L ymin ymax])
g=get(h,'Parent');
set(g,'linewidth',1.6)
set(ha(1),'XTick',0:200:(L-1),'xticklabel',0:200:(L-1),'ticklength',[0.005 0.0025],'FontSize',10)
 xlabel('Samples','fontname','Times New Roman','FontSize',12);
 ylabel('Amplitude','fontname','Times New Roman','FontSize',12);
 
 axes(ha(2));
fs = (1/sampfre)*1000;
L=length(PZ_1);
n = 0:L/2-1;
yff = fft(PZ_1,L);
mag = abs(yff);
fre = n'*fs/L;
[ma, I]=max(mag); % Dominant frequency
h=plot(fre,mag(1:L/2),'color',gcolorG,'LineWidth',1);
g=get(h,'parent');
set(g,'linewidth',1.6)
dfre = sprintf('Principal Frequency =%.2fHz\n', I/L*fs);
text(I,ma,dfre,'FontSize',12,'color',gcolorG); 
set(ha(2), 'GridLineStyle' ,'--','xgrid','on','ygrid','on');
h_leg2 = legend(ha(2),'Spectrum','Location','SouthWest');
set(h_leg2,'color',gcolorG,'TextColor',gcolorG,'FontName','Times New Roman','FontSize',12);
set(h_leg2,'Units','Normalized','FontUnits','Normalized')%这是防止变化时，产生较大的形变。
 xlabel('Frequency/Hz','fontname','Times New Roman','FontSize',12);
 ylabel('Amplitude','fontname','Times New Roman','FontSize',12);
legend boxoff;

axes(ha(3))
sampfre=6000;
TFwavelet(sampfre,PZ_1)

%% 6
% ============================================================
%AIC picked compare
%============================================================
figure(5);
[ha, pos] = tight_subplot(5,1,[.02 .05],[.08 .01],[.15 .02]);
axes(ha(1));
h=plot((1:L),Y,'color',gcolorB,'LineWidth',1);
g=get(h,'parent');
set(g,'linewidth',1.6)
set(ha(1),'XTick',0:200:(L-1),'XTickLabel',[],'ticklength',[0.005 0.0025]);
maxytick = max(Y);
set(ha(1),'YLim',[-maxytick maxytick],'YTickMode','manual','YTick',...
            [-maxytick:maxytick:maxytick]);
set(ha(1), 'GridLineStyle' ,'--','xgrid','on','ygrid','on');
h_leg1 = legend(ha(1),'Z-Component','Location','SouthWest');
set(h_leg1,'color',gcolorB,'TextColor',gcolorB,'FontName','Times New Roman','FontSize',12);
set(h_leg1,'Units','Normalized','FontUnits','Normalized')%这是防止变化时，产生较大的形变。
legend boxoff;

axes(ha(2));
h=plot((1:L),PZ_1,'color',gcolorB,'LineWidth',1);
g=get(h,'parent');
set(g,'linewidth',1.6)
set(ha(2),'XTick',0:200:(L-1),'XTickLabel',[],'ticklength',[0.005 0.0025]);
maxytick = max(PZ_1);
set(ha(2),'YLim',[-maxytick maxytick],'YTickMode','manual','YTick',...
            [-maxytick:maxytick:maxytick]);
set(ha(2), 'GridLineStyle' ,'--','xgrid','on','ygrid','on');
h_leg1 = legend(ha(2),'Z-Denoising','Location','SouthWest');
set(h_leg1,'color',gcolorB,'TextColor',gcolorB,'FontName','Times New Roman','FontSize',12);
set(h_leg1,'Units','Normalized','FontUnits','Normalized')%这是防止变化时，产生较大的形变。
legend boxoff;

[A,B]=max(PZ_1);
[Find,FFAic] = aic_pick(PZ_1(1:B),'whole');
min_FFAIC = min (FFAic);
base_line = ones(1,L)*min_FFAIC;
FAic = double(zeros(1,B));
FAic = FFAic;
FAic(B) = FFAic(B-1);%补偿少一位数据造成的横坐标刻度不对称
axes(ha(3));
plot (base_line,'color','w','linewidth',0.1);
hold on
h=plot(FAic,'color',gcolorG,'LineWidth',1);
g=get(h,'parent');
set(g,'linewidth',1.6)
set(ha(3),'XTick',0:200:(L-1),'XTickLabel',[],'ticklength',[0.005 0.0025]);
set(ha(3), 'GridLineStyle' ,'--','xgrid','on','ygrid','on');
h_leg5 = legend(ha(3),'New Method','Location','SouthWest');
set(h_leg5,'color',gcolorG,'TextColor',gcolorG,'FontName','Times New Roman','FontSize',12);
set(h_leg5,'Units','Normalized','FontUnits','Normalized')
legend boxoff;


FAic = double(zeros(1,L));
[Find,FFAic] = aic_pick(Y,'whole');
FAic = FFAic;
FAic(L) = FFAic(L-1);
axes(ha(4));
h=plot((1:L),FAic(1:L),'color',gcolorG,'LineWidth',1);
g=get(h,'parent');
set(g,'linewidth',1.6)
set(ha(4),'XTick',0:200:(L-1),'XTickLabel',[],'ticklength',[0.005 0.0025]);
set(ha(4), 'GridLineStyle' ,'--','xgrid','on','ygrid','on');
h_leg5 = legend(ha(4),'M-AIC(Ori)','Location','SouthWest');
set(h_leg5,'color',gcolorG,'TextColor',gcolorG,'FontName','Times New Roman','FontSize',12);
set(h_leg5,'Units','Normalized','FontUnits','Normalized')
legend boxoff;

FAic = double(zeros(1,L));
[Find,FFAic] = aic_pick(PZ_1,'whole');
FAic = FFAic;
FAic(L) = FFAic(L-1);
axes(ha(5));
h=plot((1:L),FAic(1:L),'color',gcolorG,'LineWidth',1);
g=get(h,'parent');
set(g,'linewidth',1.6)
set(ha(5),'XTick',0:200:(L-1),'ticklength',[0.005 0.0025]);
set(ha(5), 'GridLineStyle' ,'--','xgrid','on','ygrid','on');
h_leg5 = legend(ha(5),'M-AIC(Pre)','Location','SouthWest');
set(h_leg5,'color',gcolorG,'TextColor',gcolorG,'FontName','Times New Roman','FontSize',12);
set(h_leg5,'Units','Normalized','FontUnits','Normalized')
hxlab1 = xlabel('Samples','fontname','Times New Roman','FontSize',12);
hxlab2 = ylabel('Amplitude','fontname','Times New Roman','FontSize',12,'LineWidth',2);
legend boxoff;


