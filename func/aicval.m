function [a] = aicval(x)
n = length(x);
% a = double(zeros(0));
% AIC(n) = k*log(var(x[1,k])) + (n-k-1)*log(var(x[k+1,n])); %where k goes from 1 to length(x)
% for k=1:n
%     a(k) = k*log10(var(x(1:k))) + (n-k-1)*log10(var(x(k+1:n)));
% end

if ~isempty(x)
    n = length(x);
    for i=1:n-1;
        %compute variance in first part
        s1 = var(x(1:i));
        if s1 <= 0;
            s1 = 0;
        else
            s1=log10(s1);
        end
        %compute variance in second part
        s2 = var(x(i+1:n));
        if s2 <= 0;
            s2 = 0;
        else
            s2=log10(s2);
        end
        a(i) = i*(s1) + (n-i-1)*(s2);
%         a(i) = i*(s1) + (n-i+1)*(s2);
    end
else
    a = 0;
end
return