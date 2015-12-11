function [show, flag, finalBbox] = nextFrame( volumedata_RGB, volumedata_gray, thFrame, threshold, interval, minimumPixel, parameterLBPTOP, Offset )
% fungsi untuk memproses frame, semua hasil pendeteksian dilakukan disini.
% - threshold dan interval merupakan paramter untuk three-frame differencing.
% - volumedata_RGB dan gray merupakan data keseluruhan frame pada video.
% - thFrame merupakan index frame keberapa yg akan diproses.
% - minimumPixel adalah nilai minimum luas dari bounding box
% - parameterLBPTOP sudah jelas
% - Offset sudah jelas (penjelasan ada di fungsi LBPTOPGLCM mungkin)
%
%
% output : 
% - show, dibagi menjadi 3, threeframe, firecolor, dan lbptopglcm.
% merupakan hasil frame yg telah dideteksi lengkap dengan informasi
% bounding boxnya, yg posisinya terdapat di variabel finalBbox.
% - flag, dibagi menjadi 2, moving dan fire, menunjukkan jika dia terdapat
% gerakan/api pada frame jika berisi nilai 1, dan tidak ada jika berisi
% nilai 0. strukturnya liat di bagian 'init output' di bawah.

load('Dataset/kNNModel.mat');
%% parameterLBPTOP
FxRadius = parameterLBPTOP(1);
FyRadius = parameterLBPTOP(2);
TInterval = parameterLBPTOP(3);
TimeLength = parameterLBPTOP(4);
BorderLength = parameterLBPTOP(5);
NeighborPoints = [parameterLBPTOP(6) parameterLBPTOP(7) parameterLBPTOP(8)];
T = parameterLBPTOP(9);

%% read frame
m1 = uint8(volumedata_RGB(:,:,:,thFrame-interval-interval));
m2 = uint8(volumedata_RGB(:,:,:,thFrame-interval));
m3 = uint8(volumedata_RGB(:,:,:,thFrame));

%% init output
show = struct('threeframe',m3,'firecolor',m3,'lbptopglcm',m3);
flag = struct('moving',0,'fire',0);

%% three frame differencing
lokasi = threeframe(m1,m2,m3,threshold);

% bounding box untuk hasil three frame differencing
bbox = regionprops(lokasi,'BoundingBox');
area = regionprops(lokasi,'Area');
jumshow_threeframe = 0;     % jumlah kotak dari hasil threeframe
for k = 1 : length(bbox)
    thisArea = area(k).Area;
    thisBbox = uint8(bbox(k).BoundingBox);

    if thisArea>=minimumPixel   % jika ukuran boundingbox < minimumPixel gak diproses
        flag.moving = 1;
        jumshow_threeframe = jumshow_threeframe+1;
        show.threeframe = insertShape(show.threeframe,'Rectangle',[thisBbox(1),thisBbox(2),thisBbox(3),thisBbox(4)], 'color', 'red');
    end
end
show.threeframe = insertText(show.threeframe,[1 1],strcat('jumlah kotak : ',int2str(jumshow_threeframe)),'FontSize',10,'BoxOpacity',1);

%% fire color
lokasi_filtered = findFirePixel(lokasi,m3);

% bwmorph
lokasi_filtered = bwmorph(lokasi_filtered,'bridge');
%     lokasi_filtered = bwmorph(lokasi_filtered,'clean');
%     lokasi_filtered = bwmorph(lokasi_filtered,'close');
lokasi_filtered = bwmorph(lokasi_filtered,'majority');

% bounding box untuk hasil fire color dan LBPTOP-GLCM
finalBbox = [];
bbox = regionprops(lokasi_filtered,'BoundingBox');
area = regionprops(lokasi_filtered,'Area');

    % blob analysis
    jumshow_firecolor = 0;      % jumlah kotak dari hasil firecolor
    jumshow_lbptopglcm = 0;     % jumlah kotak dari hasil lbptopglcm
    for k = 1 : length(bbox)
        thisArea = area(k).Area;
        thisBbox = uint8(floor(bbox(k).BoundingBox));
        if thisBbox(1) == 0     % cek ada yg mulai di pixel ke 0 atau tidak
            thisBbox(1) = 1;
        end
        if thisBbox(2) == 0     % karena index di matlab mulai dari 1
            thisBbox(2) = 1;
        end

        %% LBPTOP
        if thisArea >= minimumPixel
            % ambil volume data yg didalam bounding box, trus lakukan lbptopglcm
            volData = volumedata_gray(thisBbox(2):thisBbox(2)+thisBbox(4),thisBbox(1):thisBbox(1)+thisBbox(3),thFrame-T-T:thFrame);
            [~,Feature] = LBPTOPGLCM(volData, FxRadius, FyRadius, TInterval, NeighborPoints, TimeLength, BorderLength, Offset);
            % klasifikasi
            Sample = Feature;
            Group  = knnclassify(Sample, FeatureData, classtrain, 10);
            if Group == 1   % jika dia api
                flag.fire = 1;
                jumshow_lbptopglcm = jumshow_lbptopglcm + 1;
                show.lbptopglcm = insertShape(show.lbptopglcm, 'Rectangle',[thisBbox(1),thisBbox(2),thisBbox(3),thisBbox(4)], 'color','red');
                finalBbox(jumshow_lbptopglcm,:) = thisBbox;
            end
            jumshow_firecolor = jumshow_firecolor+1;
            show.firecolor = insertShape(show.firecolor,'Rectangle',[thisBbox(1),thisBbox(2),thisBbox(3),thisBbox(4)], 'color', 'red');
        end
    end
    show.firecolor = insertText(show.firecolor,[1 1],strcat('jumlah kotak : ',int2str(jumshow_firecolor)),'FontSize',10,'BoxOpacity',1);
    show.lbptopglcm = insertText(show.lbptopglcm,[1 1],strcat('jumlah kotak : ',int2str(jumshow_lbptopglcm)),'FontSize',10,'BoxOpacity',1);
end