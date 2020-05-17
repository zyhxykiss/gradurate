%%����endpoint_detection.m   sound=endpoint_detection(x)���������ʶ˵��⡪������%%
function sound=endpoint_detection_tiao_f(x) %����ֵsound��һ���ṹ��,.begin��.end�ֱ����
                                            %���������εĿ�ʼ�ͽ���֡��xΪԭʼֱ����������
N=length(x);                                %��mfcc���潫��װ��һ������
L=256;                                      %��ʱ����������ѡ��256,��֡��
k=128;                                      %֡��k,һ��ȡ֡����һ��

E=sum((abs(enframe(x,L,k))).^2, 2);         %�����ʱ����

tmp1=enframe(x(1:length(x)-1),L,k);         %���������
tmp2=enframe(x(2:length(x)),L,k);
signs=(tmp1.*tmp2)<0;
diffs=(tmp1-tmp2)>0.02;
Z=sum(signs.*diffs,2);

%�˵��⣺ϵ��ֵ0.3,0.05,0.02Ҫ�����Լ�����������
ZeroLevel=0.3;                              %���ö�ʱ����������,0.3������ͨ���������õ�
ZL=max(Z)*ZeroLevel;
ET=0.05*max(E);                             %�����ϸ����ޣ�����������һ���о�                              
EL=0.02*max(E);                             %�����ϵͣ��θߣ����ޣ����������ڶ����о�

voiceIndex=find(E>=ET);                     %���ݽϸߵ�����ET�����ж�

kk=1;
sound(kk).begin=voiceIndex(1);              %sound�ṹ�壺��kk��������begin��end�����ֹλ��
for i=2:length(voiceIndex)-1                %�ж�������voiceIndex������֡
    if voiceIndex(i+1)-voiceIndex(i)>1
        sound(kk).end=voiceIndex(i);
        sound(kk+1).begin=voiceIndex(i+1);
        kk=kk+1;
    end
end
sound(kk).end=voiceIndex(end);
index=[];
for i=1:length(sound)                       %����ϸ�ڣ�sound�����޳���������3��֡�Ļ����(��Ϊ������)
    if sound(i).end-sound(i).begin<3        %�б���������3����������4��֡
        index=[index,i];
    end
end
sound(index)=[];

for i=1:length(sound)                       %���ݽϵ͵�����EL��һ���жϣ�
     head=sound(i).begin;                   %E[sound(i).begin-1]>=EL��sound(i).begin=sound(i).begin-1;
     while (head-1)>=1&&E(head-1)>=EL       %E[sound(i).end+1]>EL��sound(i).end=sound(i).end+1;
         head=head-1;
     end
     sound(i).begin=head;
     tail=sound(i).end;
     while (tail+1)<=length(E)&&E(tail+1)>EL
         tail=tail+1;
     end
     sound(i).end=tail;
 end
 
 for i=1:length(sound)                      %���ݹ���������ZL��һ���жϣ�
     head=sound(i).begin;                   %Z[sound(i).begin-1]>=ZL��sound(i).begin=sound(i).begin-1;
     while (head-1)>=1&&Z(head-1)>=ZL       %Z[sound(i).end+1]>ZL��sound(i).end=sound(i).end+1;
         head=head-1;
     end
     sound(i).begin=head;
     tail=sound(i).end;
     while (tail+1)<=length(Z)&&Z(tail+1)>ZL;
         tail=tail+1;
     end
     sound(i).end=tail;
 end

if ~isempty(sound)                          %ɾȥ�ظ��Ļ���Σ��������ֹ֡����ȱ�ʾΪ�ظ������
    index=[];
    for i=1:length(sound)-1
        if sound(i).begin==sound(i+1).begin&&sound(i).end==sound(i+1).end
            index=[index,i];
        end
    end
    sound(index)=[];
end

if ~isempty(sound)                          %sound����Σ���֡��Ϊ��λ������Ϊout����Σ��Բ�����Ϊ��λ��
    for i=1:length(sound)
        out(i).begin=(sound(i).begin-1)*(L-k)+1;
        out(i).end=(sound(i).end)*(L-k)+k;
    end
else
    out=[];
end
