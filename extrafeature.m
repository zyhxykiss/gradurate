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
%语音信号时域处理
function [mzcr, stzcr] = zcr(wavfile, winsize, inc)
x = wavfile - mean(wavfile);%计算直流分量
win = hamming(winsize);%窗函数
frames = enframe(x, win, inc);%分帧
fn = size(frames, 2);%获取帧数
zcr_vector = zeros(1,fn);%初始化过零点向量
for i=1:fn
    frame = frames(:,i);%获取一帧
    for j=1:(length(frame)-1)
        if frame(j)*frame(j+1)<0%判断样本点是否为过零点
            zcr_vector(i) = zcr_vector(i) + 1; 
        end
    end
    zcr_vector(i) = zcr_vector(i)/winsize;
end
mzcr = mean(zcr_vector);
stzcr = var(zcr_vector,1);

%------------------------------------------------------------------%
function [me, ste] = energy(wavfile, winsize, inc)
%获取音频特征之短时能量均值，方差；
%参数：
%    x：音频采样数组
%    Fs：取样速率
%    win_length：中期时长窗口(帧)
%    step：中期步长(帧)
x = wavfile - mean(wavfile);
win = hamming(winsize);
frames = enframe(x, win, inc);%分帧
fn = size(frames,2);
e = zeros(1,fn);
for i=1:fn
    %求短时能量
    frame = frames(:,i);
    frame2 = frame.*frame;
    e(i) = sum(frame2);
end
me = mean(e);
ste = var(e,1);

%----------------------------------------------------------%
function autoseqs = autocor(wavfile, winsize, inc)
%获取心音信号的短时自相关序列
lag = 255;
frame_mat = buffer(wavfile, winsize, inc);
fn = size(frame_mat,2);
autoseqs = [];
for i=1:fn
    [c, lags, bound] = autocorr(frame_mat(:,i),lag);
    autoseqs(:,i) = c; 
end

function amdver = amdvers(wavfile, winsize, inc)
%函数功能：获取音频信号的平均幅度差
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
%函数功能，求短时功率谱密度均值、方差
%参数：
%   x：音频取样数组
%   fra_size：帧长
%   fra_step：帧移
%   seg_size：帧内段长
%   seg_step：段移
%   nfft：每段进行fft的长度
win = hanning(winsize);
frames = enframe(wavfile, win, wininc);
fn = size(frames, 2);
for i = 1:fn
    pxx(:,i)=pwelch(frames(:,i),segsize, seginc, nfft);
end

%----------------------------------------------------------------%
function ddd = mfcc(x, Fs, p, frame_size, step)
%函数功能：对输入的语音序列x进行MFCC参数的提取，返回MFCC参数和一阶
%参数：
%   Fs：采样频率
%   p：滤波器的个数
%   frame_size：帧长
%   step：帧移
%EFT长度为帧长
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%按帧长为frame_size，mel滤波器的个数为p，采样频率为fs
bank = melbankm(p, frame_size, Fs, 0, 0.5, 'm');
%归一化mel滤波器系数
bank = full(bank);
bank = bank/max(bank(:));
%DCT系数，12*p
for i=1:12
    n=0:p-1;
    dctcofe(i,:) = cos((2*n+1)*i*pi/(2*p));
end
%归一化倒谱提升窗口 
w = 1+6*sin(pi*[1:12]./12);
w = w/max(w);
%预加重滤波器
xx = double(x);
xx = filter([1-0.9375],1,xx);
%语音信号分帧
xx = enframe(xx, frame_size, step);
fn = fix(frame_size/2)+1;
%计算每帧的MFCC参数
for i=1:size(xx,1)
    y = xx(i,:);
    s = y'.*hamming(frame_size); 
    t = abs(fft(s));
    t = t.^2;
    c1 = dctcofe*log(bank*t(1:fn));
    c2 = c1.*w';
    m(i,:) =c2';
end
%分差系数
dtm = zeros(size(m));
for i=3:size(m,1)-2
    dtm(i,:) = -2*m(i-2,:)-m(i-1,:)+m(i+1,:)+m(i+2,:);
end
dtm = dtm/3;
%合并MFCC参数和一阶分差MFCC参数
ccc = [m dtm];
%去除首尾两帧，以为这两帧的一阶分差参数为0
ccc = ccc(3:size(m,1)-2,:);
ddd = ccc(:,1:14);

