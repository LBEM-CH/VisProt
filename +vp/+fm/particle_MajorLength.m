function [MajorLength] = particle_MajorLength(Im_ParticleDetect, microg)
% Calculates the max major axis blob length per micrograph


labeledImage = bwlabel(Im_ParticleDetect, 8);    % Label each blob so we can make measurements of it

% Get all the blob properties.  Can only pass in originalImage in version R2008a and later.
blobMeasurements = regionprops(labeledImage, microg, 'all');
numberOfBlobs = size(blobMeasurements, 1);

for k = 1 : numberOfBlobs
    BlobMajorLengths(k) = blobMeasurements(k).MajorAxisLength;
end
MajorLength = max(BlobMajorLengths);


end
