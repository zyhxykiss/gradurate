function doeextra()
file = 'audioData\traning_example\positive_simple\1_M_阿福_手术前003.wav';
[x, Fs] = audioread(file);%读取音频文件
extrafeature(x,Fs);
