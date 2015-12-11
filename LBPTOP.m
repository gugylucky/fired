function [Planes,feature] = LBPTOPGLCM(VolData, FxRadius, FyRadius, TInterval, NeighborPoints, TimeLength, BorderLength)
%  This function is to compute the LBP-TOP features for a video sequence
%  Reference:
%  Guoying Zhao, Matti Pietikainen, "Dynamic texture recognition using local binary patterns
%  with an application to facial expressions," IEEE Transactions on Pattern Analysis and Machine
%  Intelligence, 2007, 29(6):915-928.
%
%   Copyright 2009 by Guoying Zhao & Matti Pietikainen
%   Matlab version was Created by Xiaohua Huang
%  If you have any problem, please feel free to contact guoying zhao or Xiaohua Huang.
% huang.xiaohua@ee.oulu.fi
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Function: Running this function each time to compute the LBP-TOP distribution of one video sequence.
%
%  Inputs:
%
%  "VolData" keeps the grey level of all the pixels in sequences with [height][width][Length];
%       please note, all the images in one sequnces should have same size (height and weight).
%       But they don't have to be same for different sequences.
%
%  "FxRadius", "FyRadius" and "TInterval" are the radii parameter along X, Y and T axis; They can be 1, 2, 3 and 4. "1" and "3" are recommended.
%  Pay attention to "TInterval". "TInterval * 2 + 1" should be smaller than the length of the input sequence "Length". For example, if one sequence includes seven frames, and you set TInterval to three, only the pixels in the frame 4 would be considered as central pixel and computed to get the LBP-TOP feature.
%
%
%  "NeighborPoints" is the number of the neighboring points
%      in XY plane, XT plane and YT plane; They can be 4, 8, 16 and 24. "8"
%      is a good option. For example, NeighborPoints = [8 8 8];
%
%  "TimeLength" and "BoderLength" are the parameters for bodering parts in time and space which would not
%      be computed for features. Usually they are same to TInterval and the bigger one of "FxRadius" and "FyRadius";
%
%  Output:
%
%  "Histogram": keeps LBP-TOP distribution of all the pixels in the current frame with [3][dim];
%      here, "3" deote the three planes of LBP-TOP, i.e., XY, XZ and YZ planes.
%      Each value of Histogram[i][j] is between [0,1]
%%
[Height, Width, Length] = size(VolData);

% neighbor points
XYNeighborPoints = NeighborPoints(1);
XTNeighborPoints = NeighborPoints(2);
YTNeighborPoints = NeighborPoints(3);

% normal code
nDim = 2^(YTNeighborPoints);
Histogram = zeros(3, nDim);

XYplane = uint8(zeros(Height,Width));
XTplane = uint8(zeros(Width,Length));
YTplane = uint8(zeros(Height,Length));
XYplaneLBP = uint8(zeros(Height,Width));
XTplaneLBP = uint8(zeros(Width,Length));
YTplaneLBP = uint8(zeros(Height,Length));
    
% pad the VolData
newVolData = zeros(Height+2*BorderLength, Width+2*BorderLength, Length+2*TimeLength);
newVolData(1+BorderLength:Height+BorderLength, 1+BorderLength:Width+BorderLength, 1+TimeLength:Length+TimeLength)=VolData;
VolData = newVolData;
[Height, Width, Length] = size(VolData);

for i = 1 + TimeLength : Length - TimeLength

    for yc = 1 + BorderLength : Height - BorderLength

        for xc = 1 + BorderLength : Width - BorderLength

            CenterVal = VolData(yc, xc, i);
            %% In XY plane
            BasicLBP = 0;
            FeaBin = 0;

            for p = 0 : XYNeighborPoints - 1
                X = floor(xc + FxRadius * cos((2 * pi * p) / XYNeighborPoints) + 0.5);
                Y = floor(yc - FyRadius * sin((2 * pi * p) / XYNeighborPoints) + 0.5);

                CurrentVal = VolData(Y, X, i);

                if CurrentVal >= CenterVal
                    BasicLBP = BasicLBP + 2 ^ FeaBin;
                end
                FeaBin = FeaBin + 1;
            end
            if i==floor(Length/2)
                XYplane(yc-BorderLength,xc-BorderLength) = CenterVal;
                XYplaneLBP(yc-BorderLength,xc-BorderLength) = BasicLBP;
            end
            Histogram(1, BasicLBP + 1) = Histogram(1, BasicLBP + 1) + 1;
            
            %% In XT plane
            BasicLBP = 0;
            FeaBin = 0;
            for p = 0 : XTNeighborPoints - 1
                X = floor(xc + FxRadius * cos((2 * pi * p) / XTNeighborPoints) + 0.5);
                Z = floor(i + TInterval * sin((2 * pi * p) / XTNeighborPoints) + 0.5);

                CurrentVal = VolData(yc, X, Z);

                if CurrentVal >= CenterVal
                    BasicLBP = BasicLBP + 2 ^ FeaBin;
                end
                FeaBin = FeaBin + 1;
            end
            if yc==floor(Height/2)
                XTplane(xc-BorderLength,i-TimeLength) = CenterVal;
                XTplaneLBP(xc-BorderLength,i-TimeLength) = BasicLBP;
            end
            Histogram(2, BasicLBP + 1) = Histogram(2, BasicLBP + 1) + 1;
            
            %% In YT plane
            BasicLBP = 0;
            FeaBin = 0;
            for p = 0 : YTNeighborPoints - 1
                Y = floor(yc - FyRadius * sin((2 * pi * p) / YTNeighborPoints) + 0.5);
                Z = floor(i + TInterval * cos((2 * pi * p) / YTNeighborPoints) + 0.5);

                CurrentVal = VolData(Y, xc, Z);

                if CurrentVal >= CenterVal
                    BasicLBP = BasicLBP + 2 ^ FeaBin;
                end
                FeaBin = FeaBin + 1;
            end
            if xc == floor(Width/2)
                YTplane(yc-BorderLength,i-TimeLength) = CenterVal;
                YTplaneLBP(yc-BorderLength,i-TimeLength) = BasicLBP;
            end
            Histogram(3, BasicLBP + 1) = Histogram(3, BasicLBP + 1) + 1;
        end
    end
end

%% hitung histogram
% Histogram normalization
for j = 1 : 3
    Histogram(j, :) = Histogram(j, :)./sum(Histogram(j, :));
end

%% gabung Histogram
feature = [Histogram(1, :),Histogram(2, :),Histogram(3, :)];
%% output planes
Planes = struct('XTplane',XTplane,'XYplane',XYplane,'YTplane',YTplane,'XTplaneLBP',XTplaneLBP,'XYplaneLBP',XYplaneLBP,'YTplaneLBP',YTplaneLBP);