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
jobdown = false;%若无违反KKT条件的ai，则jobdown = Ture，否则为False
i = 1;
temp = 0;
addr_a1 = 1;%第一个变量在a中的维数
addr_a2 = 1;%第二个变量在a中的维数

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%求第一个变量的维数
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
%求解E中最大最小值的位置
for j=1:n
    if E(j) > E(EMax)
        EMax = j;
    end
    if E(j) < E(EMin)
        EMin = j;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%求第二个变量的维数
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
        
    