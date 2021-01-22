% This is an EMD/EEMD program
%
%   function allmode=eemd(Y,Nstd,NE)
%
% INPUT:
%       Y: Inputted data;
%       Nstd: ratio of the standard deviation of the added noise and that of Y;
              %信号中添加的白噪声序列幅值系数k(建议为0.01-0.5) 
%       NE: Ensemble number for the EEMD 执行EMD 的总次数 (建议为100)
% OUTPUT:
%       A matrix of N*(m+1) matrix, where N is the length of the input
%       data Y, and m=fix(log2(N))-1. Column 1 is the original data, columns 2, 3, ...
%       m are the IMFs from high to low frequency, and comlumn (m+1) is the
%       residual (over all trend). 
% 即输出一个N*(M+1)的矩阵，其中N是输入数据Y的长度，m=fix(log2(N))-1。第一列是原始数据，之后的是IMFs。
% residual为多次分解剩余的余项/趋势项
%
% NOTE:
%       It should be noted that when Nstd is set to zero and NE is set to 1, the
%       program degenerates to a EMD program.
%
% References can be found in the "Reference" section.
%
% The code is prepared by Zhaohua Wu. For questions, please read the "Q&A" section or
% contact
%   zwu@fsu.edu
%

function allmode=eemd(Y,Nstd,NE)
xsize=length(Y);
dd=1:1:xsize;
Ystd=std(Y);
Y=Y/Ystd;

TNM=fix(log2(xsize))-1;
TNM2=TNM+2;
for kk=1:1:TNM2, 
    for ii=1:1:xsize,
        allmode(ii,kk)=0.0;
    end
end

for iii=1:1:NE,
    for i=1:xsize,
        temp=randn(1,1)*Nstd;
        X1(i)=Y(i)+temp;
    end

    for jj=1:1:xsize,
        mode(jj,1) = Y(jj);
    end
    
    xorigin = X1;
    xend = xorigin;
    
    nmode = 1;
    while nmode <= TNM,
        xstart = xend;
        iter = 1;
   
        while iter<=10,
            [spmax, spmin, flag]=extrema(xstart);
            upper= spline(spmax(:,1),spmax(:,2),dd);
            lower= spline(spmin(:,1),spmin(:,2),dd);
            mean_ul = (upper + lower)/2;
            xstart = xstart - mean_ul;
            iter = iter +1;
        end
        xend = xend - xstart;
   
   	    nmode=nmode+1;
        
        for jj=1:1:xsize,
            mode(jj,nmode) = xstart(jj);
        end
    end
   
    for jj=1:1:xsize,
        mode(jj,nmode+1)=xend(jj);
    end
   
    allmode=allmode+mode;
    
end

allmode=allmode/NE;
allmode=allmode*Ystd;



