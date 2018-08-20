function [numberOfBlobs_inBorder, coordinate] = particle_extraction_cryo(ob, ob_VisProt, datasetid)
% Extracts MATLAB-detected particles to .MRC files for Cryo-EM data


boxSize = ob.BoxSize;


for microgID = 1:ob.NumberFiles

    Im_ParticleDetect = ob.Detect_Particles{datasetid}.readimage(microgID);
    microg = ob.imds{datasetid}.readimage(microgID); 
    microg2 = ob.imds2{datasetid}.readimage(microgID); 

    % Label each blob so we can make measurements of it.
    labeledImage = bwlabel(Im_ParticleDetect, 8);    
    % Get all the blob properties.
    blobMeasurements = regionprops(labeledImage, microg, 'Centroid');
    numberOfBlobs = size(blobMeasurements, 1);

    % mkdir(['output/Particle_extraction/',DatasetName,'/',subfolderName,'___',DatasetName]);

    MicrogEdge = size(microg);
    MinMicrogEdge = 1;
    MaxMicrogEdgei = MicrogEdge(1);
    MaxMicrogEdgej = MicrogEdge(2);
    
    % Add mrc format to the formats registry
    formatStruct = struct('ext','mrc','isa',@ismrc,'info',@mrcinfo);
    registry = imformats('update','mrc',formatStruct);

    numberOfBlobs_inBorder{microgID} = 0;
    for k = 1 : numberOfBlobs   
        % center of blob
        BlobCenter = blobMeasurements(k).Centroid;



        % Extract out this particle into it's own image.
        if ((BlobCenter(1)-(boxSize/2))>=MinMicrogEdge) && ((BlobCenter(2)-(boxSize/2))>=MinMicrogEdge) && ((BlobCenter(1)+(boxSize/2))<=MaxMicrogEdgej) && ((BlobCenter(2)+(boxSize/2))<=MaxMicrogEdgei)

            coordinate{microgID,datasetid}(k,:) = [BlobCenter];
            numberOfBlobs_inBorder{microgID} = numberOfBlobs_inBorder{microgID} + 1;

            subImage = microg2(BlobCenter(2)-(boxSize/2):BlobCenter(2)+(boxSize/2), BlobCenter(1)-(boxSize/2):BlobCenter(1)+(boxSize/2));
            subImage = imcomplement(subImage); % for cryo-EM.
            subImageNorm = vp.fm.particlenorm2(subImage);

            SubFilename_mrc = (['output/Particle_extraction/all_particles/',ob_VisProt.last_file{datasetid}{microgID},'___',ob_VisProt.RawFolder(datasetid).name,'__',num2str(k),'.mrc']);

            vp.fm.WriteMRC(subImageNorm, 1, SubFilename_mrc);



        end
    
end

warning('off', 'MATLAB:colon:nonIntegerIndex');

end

end
