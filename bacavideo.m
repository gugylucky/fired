function [ video_source, volumedata_RGB, volumedata_gray ] = bacavideo(path)
%   fungsi ini untuk membaca file video frame per frame, dan disimpan
%   kedalam sebuah variabel volumedata_RGB supaya bisa diakses dengan mudah
%   dan cepat. frame juga sudah diubah kedalam format grayscale terlebih
%   dahulu dan disimpan ke dalam variabel juga, dan nama variabel tersebut
%   adalah volumedata_gray.
%
%   akan tetapi, output dari fungsi ini akan menghabiskan RAM anda, jauh
%   lebih parah dari Google Chrome. proceed with caution. videonya
%   semakin pendek semakin baik.

    video_source    = VideoReader(path);

    width           = video_source.Width;
    height          = video_source.Height;
    numberOfFrames  = video_source.NumberOfFrames;
    
    volumedata_RGB  = zeros(height,width,3,numberOfFrames);
    volumedata_gray = zeros(height,width,numberOfFrames);
    
    % masukkan tiap frame ke volumedata
    h = waitbar(0,'baca video dulu');
%     tic
    for i = 1:numberOfFrames
        volumedata_RGB(:,:,:,i)     = read(video_source,i);
        volumedata_gray(:,:,i)      = rgb2gray(uint8(volumedata_RGB(:,:,:,i)));
        % update waitbar
        persen = int2str(i*100/numberOfFrames);
        waitbar(i/numberOfFrames,h,['baca video...' persen '%']);
    end
%     toc
    close(h);   % close waitbar window
end

