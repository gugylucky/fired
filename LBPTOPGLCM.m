function [Planes,featureBaru] = LBPTOPGLCM(VolData, FxRadius, FyRadius, TInterval, NeighborPoints, TimeLength, BorderLength, Offset)
%   fungsi ini buat menghitung LBP-TOP dan GLCM sekaligus. isinya sama cuma
%   menambahkan fungsi GLCM setelah dilakukan proses LBP-TOP, yang 
%   menghasilkan vektor ciri yang lumayan panjang, lalu digabung dengan 
%   hasil vektor ciri dari GLCM itu sendiri, sehingga menghasilkan vektor
%   ciri baru yang lebih panjang lagi. parameter inputnya juga hampir sama
%   dengan fungsi LBPTOP, tapi ada tambahan 1 parameter yaitu Offset
%
%
%   Offset, merupakan bagian dari parameter GLCM, yang menentukan arah
%   atau orientasi dari pixel dan... begitulah seterusnya.
%
%   output dari fungsi adalah Planes, yg terdiri dari 3 yaitu XY, YT, dan
%   XT. lalu featureBaru adalah vektor ciri yg lebih panjang itu tadi.

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