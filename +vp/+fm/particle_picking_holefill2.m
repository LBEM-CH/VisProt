function Im_parDetect = particle_picking_holefill2(microg, microg_size, MinParticleDiameter, MaxParticleDiameter, microg_ID, Ormicrog, DatasetName, axis, hIm)
% MATLAB-based particle detection for Negative-staining EM data



MinParticleRadius = MinParticleDiameter/2; 
MaxParticleRadius = MaxParticleDiameter/2;
MinParticleArea = pi*MinParticleRadius^2;
MaxParticleArea = pi*MaxParticleRadius^2;

di = microg_size(1)/4;
dj = microg_size(2)/4;

func = @(block_struct) mean2(block_struct.data);
MeanInt = blockproc(microg,[di dj],func);
MeanInt = MeanInt + 0.05; % For negative stain

for i=1:microg_size(1)/di
    for j=1:microg_size(2)/dj
        Im_thres( (i-1)*di+1:i*di , (j-1)*dj+1:j*dj ) = microg( (i-1)*di+1:i*di , (j-1)*dj+1:j*dj ) > MeanInt(i,j);
    end
end



Im_thres_bw = im2bw(Im_thres, 0.5);
% Do a "hole fill" to get rid of any background pixels or "holes" inside the blobs.
binaryImage = imfill(Im_thres_bw, 'holes');
Im_op = imopen(binaryImage,strel('disk',5));
Im_desp = medfilt2(Im_op, [5 5]); % Noise despeckle
Im_er = imerode(Im_desp,strel('disk',1));
MinParticleArea = MinParticleArea - pi*1^2;
MaxParticleArea = MaxParticleArea - pi*1^2;
Im_parDetect = bwpropfilt(Im_er, 'Area', [MinParticleArea MaxParticleArea]);
stats = regionprops(Im_parDetect,'Centroid','MajorAxisLength','MinorAxisLength','Area','Orientation');

for k = 1:length(stats)
    a = stats(k).MajorAxisLength/2 + 20;
    b = stats(k).MinorAxisLength/2 + 20;
    ParticleCenterX = stats(k).Centroid(1);
    ParticleCenterY = stats(k).Centroid(2);

    cornerXm = round(ParticleCenterX-a);
    cornerXp = round(ParticleCenterX+a);
    cornerYm = round(ParticleCenterY-a);
    cornerYp = round(ParticleCenterY+a);
    
    if (0<cornerXm)&&(cornerXp<=microg_size(1)-2)&&(cornerXp<=microg_size(2)-2)&&(0<cornerYm)&&(cornerYp<=microg_size(1)-2)&&(cornerYp<=microg_size(2)-2)
        Ormicrog(cornerYm:cornerYp,cornerXm:cornerXm+2)=255;
        Ormicrog(cornerYm:cornerYp,cornerXp:cornerXp+2)=255;
        Ormicrog(cornerYp:cornerYp+2,cornerXm:cornerXp)=255;
        Ormicrog(cornerYm:cornerYm+2,cornerXm:cornerXp)=255;
   
        microg(cornerYm:cornerYp,cornerXm:cornerXm+2)=255;
        microg(cornerYm:cornerYp,cornerXp:cornerXp+2)=255;
        microg(cornerYp:cornerYp+2,cornerXm:cornerXp)=255;
        microg(cornerYm:cornerYm+2,cornerXm:cornerXp)=255;
    end
end
axis;
imshow(microg);
hIm = microg;
pause(0.00001);

Boxed_Name = (['output/Particle_picking/',DatasetName,'/Boxed_particles_',DatasetName,'_',num2str(microg_ID),'.png']);
imwrite(Ormicrog,Boxed_Name);
Detect_Name = (['output/Particle_picking/',DatasetName,'/Blobs_',DatasetName,'_',num2str(microg_ID),'.png']);
imwrite(Im_parDetect, Detect_Name);

warning('off','images:initSize:adjustingMag');
warning('off','images:im2bw:binaryInput');

end
