function [ind,MAic] = aic_pick(x,o)
%    P-PHASE ARRIVAL TIME PICKER BASED ON AKAIKE INFORMATION CRITERION
%
%    Computes P-phase arrival time in windowed digital single-component
%    acceleration or broadband velocity record without requiring threshold
%    settings. Returns P-phase arrival time index.
%
%    An abbreviated form of the Akaike Information Criterion is used
%    since we are interested in the global minimum. See paper by
%    Maeda, N. (1985). A method for reading and checking phase times in
%    autoprocessing system of seismic wave data, ZisinJishin 38, 365?379.
%
%   Syntax:
%          ind = aic_pick(x,'whole') consider whole seismogram to be picked.
%
%          ind = aic_pick(x,'to_peak') consider part of seismogram from 1
%          to peak value of x.
%
%   Input:
%          x = raw broadband velocity or acceleration data in
%              single-column format
%
%   Output:
%          ind = Index of pick in x; pick is the min(AIC(n)) + 1
%
%          AIC(n) = k*log(var(x[1,k])) + (n-k-1)*log(var(x[k+1,n])) where k
%          goes from 1 to length(x)
%
%   Acknowledgment: Modified from Bill Ellsworth's Fortran and R codes.
%
%   Comment blocks and equation references in this function correspond to
%   the following publication:
%
%   Kalkan, E. (2016). "An automatic P-phase arrival time picker", Bull. of
%   Seismol. Soc. of Am., 106, No. 3, doi: 10.1785/0120150111
%
%   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER "AS IS" AND ANY
%   EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
%   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER BE LIABLE
%   FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
%   BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
%   WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
%   OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
%   ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
%   Written by Dr. Erol Kalkan, P.E. (ekalkan@usgs.gov)
%   $Revision: 1.0 $  $Date: 2016/09/29 01:26:00 $




x = x - median(x); % remove median of x and window
switch o
    case {0,'1','to_peak'}
        ind_peak = find(abs(x) == max(abs(x)));
        xnew = x(1:ind_peak);
    otherwise
        xnew = x;
end

nt = length(xnew);
junk = zeros(nt, 1);
MAic = zeros(nt, 1);
junk = aicval(xnew);

MAic = junk;

if junk ~= 0;
    ind = find(junk == min(junk))+1; % pick is one more than divide point
else
    ind = 0;
end
return



function [a] = aicval(x)
% a = double(zeros(0));
if ~isempty(x)
    n = length(x);
    for i=1:n-1;
        %compute variance in first part
        s1 = var(x(1:i));
        if s1 <= 0;
            s1 = 0;
        else
            s1=log(s1);
        end
        %compute variance in second part
        s2 = var(x(i+1:n));
        if s2 <= 0;
            s2 = 0;
        else
            s2=log(s2);
        end
        a(i) = i*(s1) + (n-i+1)*(s2);
    end
else
    a = 0;
end
return