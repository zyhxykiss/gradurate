function doeextra()
file = 'audioData\traning_example\positive_simple\1_M_����_����ǰ003.wav';
[x, Fs] = audioread(file);%��ȡ��Ƶ�ļ�
extrafeature(x,Fs);
