%%——endpoint_detection.m   sound=endpoint_detection(x)——连续词端点检测————%%
function sound=endpoint_detection_tiao_f(x) %返回值sound是一个结构体,.begin和.end分别代表
                                            %有用语音段的开始和结束帧，x为原始直接语音输入
N=length(x);                                %在mfcc里面将其装入一个矩阵
L=256;                                      %短时窗长，窗长选用256,即帧长
k=128;                                      %帧移k,一般取帧长的一半

E=sum((abs(enframe(x,L,k))).^2, 2);         %计算短时能量

tmp1=enframe(x(1:length(x)-1),L,k);         %计算过零率
tmp2=enframe(x(2:length(x)),L,k);
signs=(tmp1.*tmp2)<0;
diffs=(tmp1-tmp2)>0.02;
Z=sum(signs.*diffs,2);

%端点检测：系数值0.3,0.05,0.02要根据自己的语音设置
ZeroLevel=0.3;                              %设置短时过零率门限,0.3是自已通过试验设置的
ZL=max(Z)*ZeroLevel;
ET=0.05*max(E);                             %能量较高门限，用于能量第一次判决                              
EL=0.02*max(E);                             %能量较低（次高）门限，用于能量第二次判决

voiceIndex=find(E>=ET);                     %根据较高的门限ET初步判断

kk=1;
sound(kk).begin=voiceIndex(1);              %sound结构体：第kk段语音，begin和end标记起止位置
for i=2:length(voiceIndex)-1                %判断条件：voiceIndex中连续帧
    if voiceIndex(i+1)-voiceIndex(i)>1
        sound(kk).end=voiceIndex(i);
        sound(kk+1).begin=voiceIndex(i+1);
        kk=kk+1;
    end
end
sound(kk).end=voiceIndex(end);
index=[];
for i=1:length(sound)                       %忽略细节：sound语音剔除持续低于3个帧的话语段(认为是噪声)
    if sound(i).end-sound(i).begin<3        %有变更，最初是3：持续低于4个帧
        index=[index,i];
    end
end
sound(index)=[];

for i=1:length(sound)                       %根据较低的门限EL进一步判断：
     head=sound(i).begin;                   %E[sound(i).begin-1]>=EL则sound(i).begin=sound(i).begin-1;
     while (head-1)>=1&&E(head-1)>=EL       %E[sound(i).end+1]>EL则sound(i).end=sound(i).end+1;
         head=head-1;
     end
     sound(i).begin=head;
     tail=sound(i).end;
     while (tail+1)<=length(E)&&E(tail+1)>EL
         tail=tail+1;
     end
     sound(i).end=tail;
 end
 
 for i=1:length(sound)                      %根据过零率门限ZL进一步判断：
     head=sound(i).begin;                   %Z[sound(i).begin-1]>=ZL则sound(i).begin=sound(i).begin-1;
     while (head-1)>=1&&Z(head-1)>=ZL       %Z[sound(i).end+1]>ZL则sound(i).end=sound(i).end+1;
         head=head-1;
     end
     sound(i).begin=head;
     tail=sound(i).end;
     while (tail+1)<=length(Z)&&Z(tail+1)>ZL;
         tail=tail+1;
     end
     sound(i).end=tail;
 end

if ~isempty(sound)                          %删去重复的话语段：话语段起止帧均相等表示为重复话语段
    index=[];
    for i=1:length(sound)-1
        if sound(i).begin==sound(i+1).begin&&sound(i).end==sound(i+1).end
            index=[index,i];
        end
    end
    sound(index)=[];
end

if ~isempty(sound)                          %sound话语段（以帧数为单位）处理为out话语段（以采样点为单位）
    for i=1:length(sound)
        out(i).begin=(sound(i).begin-1)*(L-k)+1;
        out(i).end=(sound(i).end)*(L-k)+k;
    end
else
    out=[];
end
