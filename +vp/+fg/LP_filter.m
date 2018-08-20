function [filteredImage] = LP_filter(microg)
% Applies low-pass filter to micrograph


% Get the dimensions of the image.  numberOfColorBands should be = 1.
[rows columns numberOfColorBands] = size(microg);


% Filter 7x7
LowPass_kernel5 = ones(7)/49;
% Filter the image.  Need to cast to single so it can be floating point
% which allows the image to have negative values.
filteredImage = imfilter(single(microg), LowPass_kernel5);


end
