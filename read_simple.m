function [wavfile, files]  = read_simple(floders)
L = length(floders);
wavfile = [];
for n=1:L
    floder = char(floders(n));
    files = dir(floder);%��ȡ*.wav����
    files(1:2,:) = [];%ɾ��ǰ������Ч�ļ���
    for i = 1:length(files)
        file = [floder,'\',files(i).name];%���ļ�·�����ļ����ϲ�
        wavinfo(i).file = file;%����*.wav�ļ���Ϣ�б�
        try
            [x, Fs] = audioread(file);%��ȡ��Ƶ�ļ�
            wavinfo(i).x = x;
            wavinfo(i).Fs = Fs;
        catch
            warning('��ȡ�ļ������������ļ�·������ȷ��');
        end
    end
    wavfile=[wavfile wavinfo];
end
