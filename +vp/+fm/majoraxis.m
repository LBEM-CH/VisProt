function [micrographMajorAxis] = majoraxis(Im_ParticleDetect, microg)
% Calculates the average major axis blob length per micrograph

labeledImage = bwlabel(Im_ParticleDetect, 8);    % Label each blob so we can make measurements of it

% Get all the blob properties.  Can only pass in originalImage in version R2008a and later.
blobMeasurements = regionprops(labeledImage, microg, 'all');
numberOfBlobs = size(blobMeasurements, 1);

% Estimation of mean MajorAxes of all particles.
SumthisBlobsMajorAxisLength = 0;
for k = 1 : numberOfBlobs;   % Loop through all blobs.
        thisBlobsMajorAxisLength = blobMeasurements(k).MajorAxisLength;
        SumthisBlobsMajorAxisLength = SumthisBlobsMajorAxisLength + thisBlobsMajorAxisLength;
end;

micrographMajorAxis = SumthisBlobsMajorAxisLength/numberOfBlobs;
