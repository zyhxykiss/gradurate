function [X, K] = my_pca(x, lable)
if lable==0
    K=pcaK(x);
    X=[];
else
    X=pca(x,lable);
    K=0;
end
end
    
function X = pca(x,K)
x=x';
m = size(x,2);
Covx = (1/m)*(x*x');
[V,D] = eig(Covx);

eigD = sum(D);
eigV = V;
n = size(eigV,1);

for  i=1:n
    addr = i;
    for j=i:n
        if eigD(j)>eigD(addr)
            addr = j;
        end
    end
    tempD = eigD(addr);
    eigD(addr) = eigD(i);
    eigD(i) = tempD;
    tempV = eigV(:,addr);
    eigV(:,addr) = eigV(:,i);
    eigV(:,i) = tempV;
end
eigV = orth(eigV);
V = eigV(1:K,:);
X = V*x;
X = X';
end

function K = pcaK(x)
x=x';
m = size(x,2);
Covx = (1/m)*(x*x');
[V,D] = eig(Covx);

eigD = sum(D);
eigV = V;
n = size(eigV,1);

for  i=1:n
    addr = i;
    for j=i:n
        if eigD(j)>eigD(addr)
            addr = j;
        end
    end
    tempD = eigD(addr);
    eigD(addr) = eigD(i);
    eigD(i) = tempD;
end

A = 0;
for i=1:n
    A = eigD(i)^2+A;
end
T = 0;
for i=1:n
    T = eigD(i)^2+T;
    if sqrt(T/A)>0.99;
        K = i;
        break;
    end
end
end
    