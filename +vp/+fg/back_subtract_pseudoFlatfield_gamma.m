function [normalizedImage] = back_subtract_pseudoFlatfield_gamma(microg)
% Performs pseudo-flat field correction of un-even background illumination

% Normalize image to mean=0 & std=1 (equivalent to commented below)
ImageLin = reshape(microg, [1, size(microg,1)*size(microg,2)]);
standard = zscore(ImageLin(:));
ImageNorm = reshape(standard,size(microg,1),size(microg,2));

gauss_filt = imgaussfilt(ImageNorm, 50);
open_Im = imopen(gauss_filt, strel('disk',200));

Im_after = ImageNorm-open_Im;

% Gamma for increasing particles' contrast
gamma = 1;
Im_gamma = imadjust(Im_after,[],[],gamma);
Im_gamma_inv = imcomplement(Im_gamma);

normalizedImage = Im_after-Im_gamma_inv;

end
