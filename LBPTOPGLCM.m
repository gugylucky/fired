function [Planes,featureBaru] = LBPTOPGLCM(VolData, FxRadius, FyRadius, TInterval, NeighborPoints, TimeLength, BorderLength, Offset)
%% LBPTOP
[Planes,feature] = LBPTOP(VolData, FxRadius, FyRadius, TInterval, NeighborPoints, TimeLength, BorderLength);

%% GLCM
glcmXY = graycomatrix(Planes.XYplane,'Offset',Offset);
glcmXT = graycomatrix(Planes.XTplane,'Offset',Offset);
glcmYT = graycomatrix(Planes.YTplane,'Offset',Offset);

statXY = graycoprops(glcmXY,'all');
statXT = graycoprops(glcmXT,'all');
statYT = graycoprops(glcmYT,'all');

if isnan(statXY.Correlation)
    statXY.Correlation = 2;
end
if isnan(statXT.Correlation)
    statXT.Correlation = 2;
end
if isnan(statYT.Correlation)
    statYT.Correlation = 2;
end

%% gabung Histogram dan GLCM
featureBaru = [feature,statXY.Contrast,statXY.Correlation,statXY.Energy,statXY.Homogeneity,statXT.Contrast,statXT.Correlation,statXT.Energy,statXT.Homogeneity,statYT.Contrast,statYT.Correlation,statYT.Energy,statYT.Homogeneity];
% featureBaru = feature;