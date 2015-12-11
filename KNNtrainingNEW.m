% ini untuk pembangunan model KNN.

clear all
clc

%% inisialisasi parameter
T = 10;
FxRadius = 3;
FyRadius = 3;
TInterval = 3;
TimeLength = 3;
BorderLength = 3;
NeighborPoints = [8 8 8];

Offset = [0 1] * 4;

%% read folder
folder = dir('Dataset/Dataset Latih/*.avi');
index = 1;
for i=1:size(folder,1)
    splitnama = strsplit(folder(i).name,'.');
    namavideo = splitnama{1};
    path = ['Dataset/Dataset Latih/' namavideo '.avi'];
    clearvars volumedata_RGB;
    clearvars volumedata_gray;
    [ video_source, volumedata_RGB, volumedata_gray ] = bacavideo(path);
    for j=1+T:10:size(volumedata_gray,3)-T
        [Planes,feature] = LBPTOPGLCM(volumedata_gray(:,:,j-T:j+T), FxRadius, FyRadius, TInterval, NeighborPoints, TimeLength, BorderLength, Offset);
%         [Planes,feature] = LBPTOPGLCM_mex(volumedata_gray(:,:,j-T:j+T), FxRadius, FyRadius, TInterval, NeighborPoints, TimeLength, BorderLength);
        FeatureData(index,:) = feature;
        nama = strsplit(namavideo,'_');
        if strcmp(nama{1},'fire')
            classtrain(index) = 1;
        else
            classtrain(index) = 0;
        end
        index = index + 1;
        disp(index);
    end
end

% save variabel
save('Dataset/kNNModel.mat', 'FeatureData', 'classtrain');
