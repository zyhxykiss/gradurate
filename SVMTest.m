function proValue = SVMTest(alpha, offset, X, Y, Xt)
K = X*Xt';
tmp = (alpha.*Y)'*K;
proValue = sign(tmp+offset);