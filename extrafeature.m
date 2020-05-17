function extrafeature(wavfile)
%-------------------------------------------------------%
winsize = 256;%frame length
inc = 128;%frame inc
segsize = 8;%segment length
seginc = 5;%segment inc
nfft = 10;%nfft
p = 24;

simpleNum = length(wavfile);
F = [];
kss1=zeros(1,simpleNum);
kss2=zeros(1,simpleNum);
kss3=zeros(1,simpleNum);

for i=1:simpleNum
    x = wavfile(i).x;
    autoseqs = autocor(x, winsize, inc);
    [P1,k1] = my_pca(autoseqs,0);
    kss1(i)=k1;
    amdver = amdvers(x, winsize, inc);
    [P2,k2] = my_pca(amdver,0);
    kss2(i)=k2;
    pxx = pspden(x, winsize, inc, segsize, seginc, nfft);
    [P3,k3] = my_pca(pxx,0);
    kss3(i)=k3;
end
%ks1 = max(kss1);
%ks2 = max(kss2);
%ks3 = max(kss3);
ks1 = 2;
ks2 = 1;
ks3 = 4;
for i=1:simpleNum
    x = wavfile(i).x;
    Fs = wavfile(i).Fs;
    [mzcr,stzcr]=zcr(x,winsize,inc);
    [me, ste] = energy(x, winsize, inc);
    autoseqs = autocor(x, winsize, inc);
    [P1,k1] = my_pca(autoseqs,ks1);
    amdver = amdvers(x, winsize, inc);
    [P2,k2] = my_pca(amdver,ks2);
    pxx = pspden(x, winsize, inc, segsize, seginc, nfft);
    [P3,k3] = my_pca(pxx,ks3);
    ddd = mfcc(x,Fs,p,winsize,inc);
    mau = mean(P1);
    stau = var(P1,1);
    mam = mean(P2);
    stam = var(P2,1);
    mp = mean(P3);
    stp = var(P3,1);
    mcc = mean(ddd);
    stcc = var(ddd,1);
    mss = [mzcr me mau mam mp mcc];
    stss =[stzcr ste stau stam stp stcc];
    ss = [mss stss];
    F(i,:)=ss;
end
xlswrite('Xt.xlsx', F, 1, 'A1');


%------------------------------------------------------%
%------------------------------------------------------%
%�����ź�ʱ����
function [mzcr, stzcr] = zcr(wavfile, winsize, inc)
x = wavfile - mean(wavfile);%����ֱ������
win = hamming(winsize);%������
frames = enframe(x, win, inc);%��֡
fn = size(frames, 2);%��ȡ֡��
zcr_vector = zeros(1,fn);%��ʼ�����������
for i=1:fn
    frame = frames(:,i);%��ȡһ֡
    for j=1:(length(frame)-1)
        if frame(j)*frame(j+1)<0%�ж��������Ƿ�Ϊ�����
            zcr_vector(i) = zcr_vector(i) + 1; 
        end
    end
    zcr_vector(i) = zcr_vector(i)/winsize;
end
mzcr = mean(zcr_vector);
stzcr = var(zcr_vector,1);

%------------------------------------------------------------------%
function [me, ste] = energy(wavfile, winsize, inc)
%��ȡ��Ƶ����֮��ʱ������ֵ�����
%������
%    x����Ƶ��������
%    Fs��ȡ������
%    win_length������ʱ������(֡)
%    step�����ڲ���(֡)
x = wavfile - mean(wavfile);
win = hamming(winsize);
frames = enframe(x, win, inc);%��֡
fn = size(frames,2);
e = zeros(1,fn);
for i=1:fn
    %���ʱ����
    frame = frames(:,i);
    frame2 = frame.*frame;
    e(i) = sum(frame2);
end
me = mean(e);
ste = var(e,1);

%----------------------------------------------------------%
function autoseqs = autocor(wavfile, winsize, inc)
%��ȡ�����źŵĶ�ʱ���������
lag = 255;
frame_mat = buffer(wavfile, winsize, inc);
fn = size(frame_mat,2);
autoseqs = [];
for i=1:fn
    [c, lags, bound] = autocorr(frame_mat(:,i),lag);
    autoseqs(:,i) = c; 
end

function amdver = amdvers(wavfile, winsize, inc)
%�������ܣ���ȡ��Ƶ�źŵ�ƽ�����Ȳ�
win = hamming(winsize);
frames = enframe(wavfile, win, inc);
[dim,fn] = size(frames);
amdvers =[];
for i=1:fn
    frame = frames(:,i);
    amdver = [];
    for j=1:dim
        amdver(j) = sum(abs(frame(j:end)-frame(1:end-j+1)));
    end
    amdvers(:,i) = amdver;
end

%-----------------------------------------------------------------------%
function pxx = pspden(wavfile, winsize, wininc, segsize, seginc, nfft)
%�������ܣ����ʱ�������ܶȾ�ֵ������
%������
%   x����Ƶȡ������
%   fra_size��֡��
%   fra_step��֡��
%   seg_size��֡�ڶγ�
%   seg_step������
%   nfft��ÿ�ν���fft�ĳ���
win = hanning(winsize);
frames = enframe(wavfile, win, wininc);
fn = size(frames, 2);
for i = 1:fn
    pxx(:,i)=pwelch(frames(:,i),segsize, seginc, nfft);
end

%----------------------------------------------------------------%
function ddd = mfcc(x, Fs, p, frame_size, step)
%�������ܣ����������������x����MFCC��������ȡ������MFCC������һ��
%������
%   Fs������Ƶ��
%   p���˲����ĸ���
%   frame_size��֡��
%   step��֡��
%EFT����Ϊ֡��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%��֡��Ϊframe_size��mel�˲����ĸ���Ϊp������Ƶ��Ϊfs
bank = melbankm(p, frame_size, Fs, 0, 0.5, 'm');
%��һ��mel�˲���ϵ��
bank = full(bank);
bank = bank/max(bank(:));
%DCTϵ����12*p
for i=1:12
    n=0:p-1;
    dctcofe(i,:) = cos((2*n+1)*i*pi/(2*p));
end
%��һ�������������� 
w = 1+6*sin(pi*[1:12]./12);
w = w/max(w);
%Ԥ�����˲���
xx = double(x);
xx = filter([1-0.9375],1,xx);
%�����źŷ�֡
xx = enframe(xx, frame_size, step);
fn = fix(frame_size/2)+1;
%����ÿ֡��MFCC����
for i=1:size(xx,1)
    y = xx(i,:);
    s = y'.*hamming(frame_size); 
    t = abs(fft(s));
    t = t.^2;
    c1 = dctcofe*log(bank*t(1:fn));
    c2 = c1.*w';
    m(i,:) =c2';
end
%�ֲ�ϵ��
dtm = zeros(size(m));
for i=3:size(m,1)-2
    dtm(i,:) = -2*m(i-2,:)-m(i-1,:)+m(i+1,:)+m(i+2,:);
end
dtm = dtm/3;
%�ϲ�MFCC������һ�׷ֲ�MFCC����
ccc = [m dtm];
%ȥ����β��֡����Ϊ����֡��һ�׷ֲ����Ϊ0
ccc = ccc(3:size(m,1)-2,:);
ddd = ccc(:,1:14);

