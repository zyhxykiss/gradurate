function SVM = SMO(X, Y, ker, C, aOld,  preb)
%--------------------------------------%
%Input:
    %   X-Feature Matrix
    %   Y-Label Vector
    %   ker-kernel function parameter
    %   aOld-Lagrangian Mutiplier
    %   preb-threshold value
%--------------------------------------%

n = length(Y);%������
dem = size(X,2);%������
wx = zeros(n,1);%ϵ��������ĳ˻�
a1New = 0;
a2New = 0;
newb = 0;
%--------------------------------------------------------%
%���ø�˹�˺���������ά
K = MercerK(X',X',ker);

while 1
    %---------------------------------------------------------%
    %����w,ÿ��ѭ����������£���Ϊalpha�������������
    for i=1:n
       x = X(i,:);
       wx = (aOld(i)*Y(i)*MercerK(x', X', ker))'+wx;
    end
    
    %-------------------------------- ------------------------%
    %����Ԥ��ֵ����ʵֵ�Ĳ�
    E = (wx+preb)-Y;
    
    %--------------------------------------------------------%
    %��������ѡ������Ҫ���µı�����flag��ֵ��ΪTure��
    %���ʾ����alpha����Υ��KKT�������������
    [addr1, addr2, flag] = seletVar(X,Y,C,aOld,E,wx,preb);
    if flag
        break;
    end
    
   
    %--------------------------------------------------------%
    %������º��alpha1��alpha2
    iota = K(addr1,addr1)+K(addr2,addr2)-2*K(addr1,addr2);
    
    %-------------------------------------------------------%
    %if�ĺ��壺�������ҷ����м�Сֵ���������Сֵ����
    %�����ڱ߽���ȡ��Сֵ
    if iota>0
        a2NewUnclipped = aOld(addr2)+(Y(addr2)*(E(addr1)-E(addr2)))/iota;%δ�޼���alpha2
        
        %----------------------------------------------------------%
        %��alpha2���нض�
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
        a1New = aOld(addr1)+Y(addr1)*Y(addr2)*(aOld(addr2)-a2New);%���ø��º��alpha2����alpha1
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
    %������ֵb
    %��ֵÿ�ε�������Ҫ���£���Ϊ��ֵ�漰��w�ļ���
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
 