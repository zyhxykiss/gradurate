function [addr_a1, addr_a2, jobdown] = seletVar(X, Y, C, aOld, E, wx, b)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Input:
    %   X-Feature Matrix
    %   Y-Label Vector
    %   aOld-Lagrangian Mutiplier
    %   E-Difference value between fact value and predicted value
    %   w-Coefficient Vector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n = length(aOld);
flag = true;
flagUnbound = true;
jobdown = false;%����Υ��KKT������ai����jobdown = Ture������ΪFalse
i = 1;
temp = 0;
addr_a1 = 1;%��һ��������a�е�ά��
addr_a2 = 1;%�ڶ���������a�е�ά��

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%���һ��������ά��
while flag && i~=n
    if aOld(i)>0 && aOld(i)<C && flagUnbound
        if Y(i)*(wx(i)+b)-1 ~= 0
            if abs(Y(i)*(wx(i)+b)-1)>abs(Y(addr_a1)*(wx(addr_a1)+b-1))
                addr_a1 = i;
                flag = false;
            end
        end
        if i==n && flagUnbound
            i = 1;
            flagUnbound = false;
        end
        if ~flagUnbound
            if aOld(i) == 0 && Y(i)*(wx(i)+b)<1
                if abs(Y(i)*(wx(i)+b)-1)>abs(Y(addr_a1)*(wx(addr_a1)+b-1))
                    addr_a1 = i;
                    flag = false;
                end
            elseif aOld(i) == C && Y(i)*(wx(i)+b)>1
                if abs(Y(i)*(wx(i)+b)-1)>abs(Y(addr_a1)*(wx(addr_a1)+b-1))
                    addr_a1 = i;
                    flag = false;
                end
            end
        end
        if i==n && ~flagUnbound && flag
            jobdown = true;
            return;
        end
    end
    i = i+1;
end

EMin = 1;
EMax = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%���E�������Сֵ��λ��
for j=1:n
    if E(j) > E(EMax)
        EMax = j;
    end
    if E(j) < E(EMin)
        EMin = j;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%��ڶ���������ά��
if E(addr_a1)>0
    addr_a2 = EMin;
elseif E(addr_a1)<0
    addr_a2 = EMax;
else
    if abs(E(EMax)) > abs(E(EMin))
        addr_a2 = EMax;
    else
        addr_a2 = EMin;
    end
end
        
    