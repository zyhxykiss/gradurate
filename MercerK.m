function K = MercerK(x, y, ker)
s = ker.width;
rows = size(x,2);
cols = size(y,2);
tmp = zeros(rows,cols);
for i = 1:rows
    for j = 1:cols
        tmp(i,j) = norm(x(:,i)-y(:,j));
    end
end
K = exp(-0.5*(tmp/s).^2); 