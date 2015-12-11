function [ lokasi_baru, gambarRGB ] = findFirePixel( lokasi, gambarRGB )

lokasi_baru = lokasi;
%% find white pixel
index = find(lokasi==1);
[I,J] = ind2sub([size(gambarRGB,1),size(gambarRGB,2)],index);
%% rgb2hsi
hsi = rgb2hsi(gambarRGB);
%% run through the white pixel
for i=1:size(I)
    %% get hue, saturation, and intensity for each pixel
    hue = hsi(I(i),J(i),1)*360;
    saturation = hsi(I(i),J(i),2);
    intensity = hsi(I(i),J(i),3)*256;
    %% apply fire color rule
    if hue<=60 && saturation<=1 && intensity>=127 && intensity<=255
        lokasi_baru(I(i),J(i)) = 1;
    else
        lokasi_baru(I(i),J(i)) = 0;
    end
end

end