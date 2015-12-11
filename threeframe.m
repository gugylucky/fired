function [ lokasi ] = threeframe2( m1,m2,m3, threshold )
%THREEFRAME Summary of this function goes here
%   Detailed explanation goes here

    height = size(m1,1);
    width = size(m1,2);
    threshmat = ones(height, width)*threshold;
    
    %% convert into grayscale
    m1_gray = rgb2gray(m1);
    m2_gray = rgb2gray(m2);
    m3_gray = rgb2gray(m3);
    
    %% three frame differencing
    x1 = abs(m3_gray-m1_gray)>threshmat;
    x2 = abs(m3_gray-m2_gray)>threshmat;
    x3 = x1 & x2;

    lokasi = x3;
end

