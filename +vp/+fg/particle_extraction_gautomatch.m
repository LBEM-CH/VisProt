function [numberOfBlobs_inBorder, coordsRelionFin] = particle_extraction_gautomatch(ob, ob_VisProt, datasetid, handlesvpg)
% Extracts Gautomatch-detected particles to .MRC files for Negative-staining and Cryo-EM data


boxSize = ob.BoxSizepx;
boxSize = 401;
MicrogEdge = ob.SizeIm;
MinMicrogEdge = 1;
MaxMicrogEdgei = MicrogEdge(1);
MaxMicrogEdgej = MicrogEdge(2);



for micrographID = 1:ob.NumberFiles  

    microg2 = ob.imds2{datasetid}.readimage(micrographID);

    
    [s o] = system(['grep -a -A5000 "_rlnAutopickFigureOfMerit #5"  RawMicrographs/',ob_VisProt.RawFolder(datasetid).name,'/',ob_VisProt.last_file{datasetid}{micrographID},'_automatchAll.star | grep -v "_rlnAutopickFigureOfMerit #5"']);
    o = strsplit(o);
    o = cellfun(@(x) str2num(x), o, 'UniformOutput',0);
    o = cell2mat(o);
    o2 = o;
    o2(find((~mod(o,1)==0)|o==1|o==2|o==3))=0; % _rlnAutopickFigureOfMerit can sometimes also have no division remainder (range 0-3)
    o2(find(o2==0))=[]; 
    oFin = reshape(o2,2,[])';
    
    coordsRelion{micrographID, datasetid} = oFin;
    coordsmatlab{micrographID, datasetid}(:,1) = coordsRelion{micrographID, datasetid}(:,1);
    coordsmatlab{micrographID, datasetid}(:,2) = round(ob.SizeIm(1) - coordsRelion{micrographID, datasetid}(:,2)); % Relion counts y coordinate from bottom while Matlab starts from top.
    clear o; clear o2; clear oFin;
    

    numberOfBlobs = length(coordsmatlab{micrographID, datasetid});    
    numberOfBlobs_inBorder{micrographID} = 0;
    for k = 1 : numberOfBlobs;
        BlobCenter = coordsmatlab{micrographID, datasetid}(k,:);
        BlobCenterRelion = coordsRelion{micrographID, datasetid}(k,:);

        if ((BlobCenter(1)-(boxSize/2))>=MinMicrogEdge) && ((BlobCenter(2)-(boxSize/2))>=MinMicrogEdge) && ((BlobCenter(1)+(boxSize/2))<=MaxMicrogEdgej) && ((BlobCenter(2)+(boxSize/2))<=MaxMicrogEdgei)

            coordsRelionFin{micrographID, datasetid}(k,:) = [BlobCenterRelion];
            numberOfBlobs_inBorder{micrographID} = numberOfBlobs_inBorder{micrographID} + 1;

            subImage = microg2(BlobCenter(2)-(boxSize/2):BlobCenter(2)+(boxSize/2), BlobCenter(1)-(boxSize/2):BlobCenter(1)+(boxSize/2));

            switch ob_VisProt.module;
            case 'Cryo-EM'
                subImage = imcomplement(subImage); % for cryo-EM.
            end
            subImageNorm = vp.fg.particlenorm2(subImage);
            SubFilename_mrc = (['output/Particle_extraction/all_particles/',ob_VisProt.last_file{datasetid}{micrographID},'___',ob_VisProt.RawFolder(datasetid).name,'__',num2str(k),'.mrc']);
            vp.fg.WriteMRC(subImageNorm, 1, SubFilename_mrc);

        end

    end

end

warning ('off','all');

end

