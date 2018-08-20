function normimage = particlenorm2(subimage)
% Normalizes particle intensity to mean=0 and std=1

normimage = subimage;
normimage = subimage-mean2(subimage);
normimage = normimage/std(normimage(:), 0, 1);


end
