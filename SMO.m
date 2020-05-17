function SVM = SMO(X, Y, ker, C, aOld,  preb)
%--------------------------------------%
%Input:
    %   X-Feature Matrix
    %   Y-Label Vector
    %   ker-kernel function parameter
    %   aOld-Lagrangian Mutiplier
    %   preb-threshold value
%--------------------------------------%

n = length(Y);%样本数
dem = size(X,2);%特征数
wx = zeros(n,1);%系数与变量的乘积
a1New = 0;
a2New = 0;
newb = 0;
%--------------------------------------------------------%
%利用高斯核函数进行升维
K = MercerK(X',X',ker);

while 1
    %---------------------------------------------------------%
    %计算w,每次循环都必须更新，因为alpha向量会迭代更新
    for i=1:n
       x = X(i,:);
       wx = (aOld(i)*Y(i)*MercerK(x', X', ker))'+wx;
    end
    
    %-------------------------------- ------------------------%
    %计算预测值与真实值的差
    E = (wx+preb)-Y;
    
    %--------------------------------------------------------%
    %计算两个选定的需要更新的变量，flag的值若为Ture，
    %则表示所有alpha均不违背KKT条件，迭代完成
    [addr1, addr2, flag] = seletVar(X,Y,C,aOld,E,wx,preb);
    if flag
        break;
    end
    
   
    %--------------------------------------------------------%
    %计算更新后的alpha1与alpha2
    iota = K(addr1,addr1)+K(addr2,addr2)-2*K(addr1,addr2);
    
    %-------------------------------------------------------%
    %if的含义：若正定且方程有极小值，则计算最小值即可
    %否则，在边界上取最小值
    if iota>0
        a2NewUnclipped = aOld(addr2)+(Y(addr2)*(E(addr1)-E(addr2)))/iota;%未修剪的alpha2
        
        %----------------------------------------------------------%
        %对alpha2进行截断
        if Y(addr1)~=Y(addr2)
            diffY = aOld(addr2)-aOld(addr1);
            L = max(0,diffY);
            H = min(C,C+diffY);
        else
            diffY = aOld(addr1)+aOld(addr2);
            L = max(0,diffY-C);
            H = min(C,diffY);
        end
        if a2NewUnclipped>H
            a2New = H;
        elseif a2NewUnclipped<L
            a2New = L;
        else
            a2New = a2NewUnclipped;
        end
        a1New = aOld(addr1)+Y(addr1)*Y(addr2)*(aOld(addr2)-a2New);%利用更新后的alpha2更新alpha1
    else
        s = Y(addr1)*Y(addr2);
        f1 = Y(addr1)*(E(addr1)-preb)-aOld(addr1)*MercerK(X(addr1,:),X(addr1,:))-s*aOld(addr2)*MercerK(X(addr1,:),X(addr2,:));
        f2 = Y(addr2)*(E(addr2)-preb)-s*aOld(addr1)*MercerK(X(addr1,:),X(addr2,:))-aOld(addr2)*MercerK(X(addr2,:),X(addr2,:));
        
        a2New = L;
        a1New = aOld(addr1)+Y(addr1)*Y(addr2)*(aOld(addr2)-a2New);
        Phi1 = a1New*f1+a2New*f2+(1/2)*(a1New^2)* MercerK(X(addr1,:),X(addr1,:))+(1/2)*(a2New^2)* MercerK(X(addr2,:),X(addr2,:))+s*(a2New)*(a1New)* MercerK(X(addr1,:),X(addr2,:));
        a2New = H;
        a1New = aOld(addr1)+Y(addr1)*Y(addr2)*(aOld(addr2)-a2New);
        Phi2 = a1New*f1+a2New*f2+(1/2)*(a1New^2)* MercerK(X(addr1,:),X(addr1,:))+(1/2)*(a2New^2)* MercerK(X(addr2,:),X(addr2,:))+s*(a2New)*(a1New)* MercerK(X(addr1,:),X(addr2,:));
        if Phi1<=Phi2
            a2New = L;
        else
            a2New = H;
        end
        a1New = aOld(addr1)+Y(addr1)*Y(addr2)*(aOld(addr2)-a2New);
    end
    
    %----------------------------------------------------------%
    %更新阈值b
    %阈值每次迭代都需要更新，因为阈值涉及到w的计算
    newb1 = -E(addr1)-Y(addr1)*K(addr1,addr1)*(a1New-aOld(addr1))-Y(addr2)*K(addr2,addr1)*(a2New-aOld(addr2))+preb;
    newb2 = -E(addr2)-Y(addr1)*K(addr1,addr2)*(a1New-aOld(addr1))-Y(addr2)*K(addr2,addr2)*(a2New-aOld(addr2))+preb;

    if (a1New>0 && a1New<C) && (a2New==0 || a2New==C)
        newb = newb1;
    elseif ((a2New>0 && a2New<C) && (a1New==0 || a1New==C)) || ((a2New>0 && a2New<C) && (a1New>0 && a1New<C))
        newb = newb2;
    else
        newb = (newb1+newb2)/2;
    end
    aOld(addr1) = a1New;
    aOld(addr2) = a2New;
    preb = newb;
    
end
SVM.alpha = aOld;
SVM.b = preb;
SVM.w = w;
SVM.ker = ker;
 