function [wavfile, files]  = read_simple(floders)
L = length(floders);
wavfile = [];
for n=1:L
    floder = char(floders(n));
    files = dir(floder);%获取*.wav件名
    files(1:2,:) = [];%删除前两个无效文件名
    for i = 1:length(files)
        file = [floder,'\',files(i).name];%将文件路径与文件名合并
        wavinfo(i).file = file;%定义*.wav文件信息列表
        try
            [x, Fs] = audioread(file);%读取音频文件
            wavinfo(i).x = x;
            wavinfo(i).Fs = Fs;
        catch
            warning('读取文件出错，可能是文件路径不正确！');
        end
    end
    wavfile=[wavfile wavinfo];
end
