function imgOut = rangeNorm(imgIn)
% Normalizes particle intensity to range of [0,1]

imgIn = imgIn - min(min(imgIn));
imgIn = imgIn / max(max(imgIn));

imgOut = imgIn;
