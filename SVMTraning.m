function svm = SVMTraning()

X = xlsread('X','A1:AS165');
label = xlsread('X.xlsx','AT1:AT165');
fave = mean(X);
fmax = max(X);
fmin = min(X);
n = length(label);
m = size(X,2);
for i=1:m
    X(:,i) = (X(:,i)-fave(i))/(fmax(i)-fmin(i));
end

%C = 999; 
%tic
%[alpha, offset]= my_seqminopt(X, label, C, 2000, 0.001);
%toc
%xlswrite('alpha.xlsx', alpha, 1, 'L1');

%display(offset);
alpha = xlsread('alpha','H1:H165');
Xt = xlsread('Xt','A1:AS40'); 
tureValue = xlsread('Xt','AT1:AT40');
proValue = SVMTest(alpha, -0.0811, X, label, Xt);
proValue = proValue';
xlswrite('Res.xlsx', proValue, 1, 'B2');
l = length(proValue);
R = 0;
for i=1:l
    if tureValue(i,1)==proValue(i,1)
        R = R+1;
    end
end
rate = R/l;
fprintf('正确率为：%f\%',rate*100);

