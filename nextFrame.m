function [show, flag, finalBbox] = nextFrame( volumedata_RGB, volumedata_gray, thFrame, threshold, interval, minimumPixel, parameterLBPTOP, Offset )

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

%% three frame differencing
lokasi = threeframe(m1,m2,m3,threshold);

%% init output
show = struct('threeframe',m3,'firecolor',m3,'lbptopglcm',m3);
flag = struct('moving',0,'fire',0);

%% bounding box untuk hasil three frame differencing
bbox = regionprops(lokasi,'BoundingBox');
area = regionprops(lokasi,'Area');
jumshow_threeframe = 0;
for k = 1 : length(bbox)
    thisArea = area(k).Area;
    thisBbox = uint8(bbox(k).BoundingBox);

    if thisArea>=minimumPixel
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

%% bounding box untuk fire color dan LBPTOP-GLCM
finalBbox = [];
bbox = regionprops(lokasi_filtered,'BoundingBox');
area = regionprops(lokasi_filtered,'Area');

    %% blob analysis
    jumshow_firecolor = 0;
    jumshow_lbptopglcm = 0;
    for k = 1 : length(bbox)
        thisArea = area(k).Area;
        thisBbox = uint8(floor(bbox(k).BoundingBox));
        if thisBbox(1) == 0
            thisBbox(1) = 1;
        end
        if thisBbox(2) == 0
            thisBbox(2) = 1;
        end

        %% LBPTOP
        if thisArea >= minimumPixel
            volData = volumedata_gray(thisBbox(2):thisBbox(2)+thisBbox(4),thisBbox(1):thisBbox(1)+thisBbox(3),thFrame-T-T:thFrame);
            [~,Feature] = LBPTOPGLCM(volData, FxRadius, FyRadius, TInterval, NeighborPoints, TimeLength, BorderLength, Offset);
            %% klasifikasi
            Sample = Feature;
            Group  = knnclassify(Sample, FeatureData, classtrain, 10);
            %%
            if Group == 1
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