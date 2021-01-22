
addpath(genpath(pwd));

clf;
clear all;
close all;
clc;
global sampfre;
sampfre = 1;
global noiseGps; % Noise groups
[filename, pathname] = uigetfile({'*.*';'*.sg2';'*.sgy';'*.sac';'*.xls';'*.xlsx'}, 'load seismic data','MultiSelect','on'); %选择波形文件
   % 'MultiSelect','on'-----only for opening SAC file
if isequal(filename,0) 
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
    case {'.sgy','.SGY'}
        
        if(iscell(filename))
            samptrace = 0;
            for f = 1:1:filenums   % For separate X/Y/Z Files, Must be same length
                [sdata,samplen, sampfre,strace,Theader] = altreadsegy(pathfile{1,f},'textheader','yes','fpformat','ieee');
                for m = 1:1:strace   
                    datout(:,((m-1)*3+f)) = sdata(:,m);
                end
                samptrace = samptrace + strace;
            end
            if (samptrace > 24)  % Cut 24 traces
                datout = datout(:,(1:24));
                samptrace = 24;
            end
        else
            [datout, samplen, sampfre, samptrace, traceheaders,  textheader] = altreadsegy(pathfile,'textheader','yes','fpformat','ieee');
        end
        
        %=====================================================================
        % Add colored noise for synthetic data
        % Please open the original data with no noise
        %=====================================================================
        dataout = datout(1:1600,:);
%         plot(dataout(:,3));
        samplen = 1600;
        syndata = double(zeros(0));
        DIYsnr = -8;
        noiseGps = 100;
        %-------------------------------------------------

        signal_powerz = 1/length(dataout(:,3))*sum(dataout(:,3).*dataout(:,3));
        noise_variancez = signal_powerz / ( 10^(DIYsnr/10) );
        for m = 1:noiseGps % define 10 groups
            NOISE = randn(size(dataout(:,3))); % add Gaussian white noise
%             NOISE=bluenoise(size(dataout(:,3))); % add blue noise
            NOISE = NOISE-mean(NOISE);
            NOISEz = sqrt(noise_variancez)/std(NOISE)*NOISE;
            syndata(:,m) = dataout(:,3) + NOISEz;
        end
        %=====================================================================
        fprintf('the value of SNR2 is %6.2f\n',DIYsnr);
    otherwise
        [X,Y,Z] = textread(pathfile,'%f,%f,%f','headerlines',1);
        dataX = X;
        dataY = Y;
        dataZ = Z;

        sampfre = 1;
end

%=====================================================================
Pnew = zeros(1,noiseGps);
PAaic = zeros(1,noiseGps);
POaic = zeros(1,noiseGps);
PAsta = zeros(1,noiseGps);
POsta = zeros(1,noiseGps);

tPWT = zeros(1,noiseGps);
tOA = zeros(1,noiseGps);
tAA = zeros(1,noiseGps);
tOS = zeros(1,noiseGps);
tAS = zeros(1,noiseGps);

hbar=waitbar(0,'Starting...','Name','Progress');
set(findobj(hbar,'type','patch'), ...
'edgecolor','r','facecolor','b');
for m = 1:1:noiseGps
    [Pnew(m),POaic(m),PAaic(m),POsta(m),PAsta(m),tPWT(m),tOA(m),tAA(m),tOS(m),tAS(m)] = new_aic_fun(syndata(:,m));
    strwb = ['Calculating...',num2str(m/noiseGps*100),'%'];
    waitbar(m/noiseGps,hbar,strwb);
end
delete(hbar);

ave_pnew = round(mean(Pnew));
ave_POaic = round(mean(POaic));
ave_PAaic = round(mean(PAaic));
ave_POsta = round(mean(POsta));
ave_PAsta = round(mean(PAsta));

sum_tPWT = sum(tPWT);
sum_tOA = sum(tOA);
sum_tAA = sum(tAA);
sum_tOS = sum(tOS);
sum_tAS = sum(tAS);

fprintf('POsta\t PAsta\t POaic\t PAaic\t Pnew\n');
fprintf('%d\n',ave_POsta);
fprintf('%d\n',ave_PAsta);
fprintf('%d\n',ave_POaic);
fprintf('%d\n',ave_PAaic);
fprintf('%d\n',ave_pnew);

fprintf('tPWT\t tOAic\t tAAic\t tOSTA\t tASTA\n');
fprintf('%f\n',sum_tPWT);
fprintf('%f\n',sum_tOA);
fprintf('%f\n',sum_tAA);
fprintf('%f\n',sum_tOS);
fprintf('%f\n',sum_tAS);

figure
plot(POaic,'k-square','MarkerFaceColor','k');
hold on;
plot(PAaic,'g-^','MarkerFaceColor','g');
hold on ;
plot(POsta,'b-o','MarkerFaceColor','b');
hold on ;
plot(PAsta,'m-v','MarkerFaceColor','m');
hold on;
plot(Pnew,'r-diamond','MarkerFaceColor','r');

xlabel('SNR(dB)')
ylabel('Picked point')
legend('AIC(Ori)','AIC(Pre)','STA/LTA(Ori)','STA/LTA(Pre)','New method');
