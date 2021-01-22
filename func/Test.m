a = [3 5 2 7 6 4 2];
b = min(a(2:end));
Ind = find(a == b);
if length(Ind)>1
    ind = Ind(1);
end