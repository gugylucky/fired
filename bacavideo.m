function [ video_source, volumedata_RGB, volumedata_gray ] = bacavideo(path)
%BACAVIDEO Summary of this function goes here
%   Detailed explanation goes here

    video_source = VideoReader(path);

    width = video_source.Width;
    height = video_source.Height;
    numberOfFrames = video_source.NumberOfFrames;
    
    volumedata_RGB = zeros(height,width,3,numberOfFrames);
    volumedata_gray = zeros(height,width,numberOfFrames);
    
    % masukkan tiap frame ke volumedata
%     disp('baca video');
    h = waitbar(0,'baca video dulu');
%     tic
    for i = 1:numberOfFrames
        volumedata_RGB(:,:,:,i) = read(video_source,i);
        volumedata_gray(:,:,i) = rgb2gray(uint8(volumedata_RGB(:,:,:,i)));
        waitbar(i/numberOfFrames,h,strcat('baca video...',int2str(i*100/numberOfFrames),'%'));
    end
%     toc
    close(h);
end

