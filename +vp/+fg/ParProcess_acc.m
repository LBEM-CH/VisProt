classdef ParProcess_acc
    properties
        imds
        imds2
        NumberFiles
        SizeIm
        NormFiles
        LPFiles
        Detect_Particles
        BoxedFiles
        BoxSize
        BoxSizepx
        coordinatesRelion
    end
    methods
        function obj = ParProcess_acc(nbrdatasets, rawfolder, handlesVPG)
            set(handlesVPG.sProg, 'String', 'Reading data...');
            drawnow;
          
            for datasetID = 1:nbrdatasets 
                obj.imds{datasetID} = imageDatastore(['RawMicrographs/',rawfolder(datasetID).name,'/*.mrc'],'FileExtensions','.mrc','ReadFcn',@vp.fg.ReadMRC);
                obj.NumberFiles = obj.imds{datasetID}.numpartitions;
                obj.imds{datasetID}.ReadFcn = @(loc)imrotate( im2double(vp.fg.ReadMRC(loc)),90 );
            end
            
            obj.SizeIm = size(obj.imds{datasetID}.preview);
            
            set(handlesVPG.sProg, 'String', '');
            drawnow;
            
        end
        function obj = preprocess(obj, nbrdatasets, rawfolder, handlesVPG)
        
            for datasetID = 1:nbrdatasets
                progress = ['Pre-processing the micrographs.....',num2str(round(datasetID/nbrdatasets)*100),'%   (dataset ',num2str(datasetID),' of ',num2str(nbrdatasets),')'];
                set(handlesVPG.sProg, 'String', progress);
                drawnow;
                
                % Range correction imds
                obj.imds2{datasetID} = imageDatastore(['RawMicrographs/',rawfolder(datasetID).name,'/*.mrc'],'FileExtensions','.mrc','ReadFcn',@vp.fg.ReadMRC);
                obj.imds2{datasetID}.ReadFcn = @(loc)vp.fg.rangeNorm(imrotate( im2double(vp.fg.ReadMRC(loc)),90 ));
               
                
                % Background subtraction
                obj.NormFiles{datasetID} = imageDatastore(['RawMicrographs/',rawfolder(datasetID).name,'/*.mrc'],'FileExtensions','.mrc','ReadFcn',@vp.fg.ReadMRC);
                obj.NormFiles{datasetID}.ReadFcn = @(loc)vp.fg.rangeNorm(vp.fg.back_subtract_pseudoFlatfield_gamma(imrotate( im2double(vp.fg.ReadMRC(loc)),90 )));
               

                % LP filter data
                obj.LPFiles{datasetID} = imageDatastore(['RawMicrographs/',rawfolder(datasetID).name,'/*.mrc'],'FileExtensions','.mrc','ReadFcn',@vp.fg.ReadMRC);
                obj.LPFiles{datasetID}.ReadFcn =  @(loc)vp.fg.LP_filter(vp.fg.rangeNorm(vp.fg.back_subtract_pseudoFlatfield_gamma(imrotate( im2double(vp.fg.ReadMRC(loc)),90 ))));
            end

            set(handlesVPG.sProg, 'String', '');
            drawnow;
            
        end
        function obj = parpick(obj, obj_VisProt, handlesVPG)
            warning ('off','all');
            for datasetID = 1:obj_VisProt.NumberDatasets
                
                vp.fg.particle_picking_gautomatch(obj_VisProt.module, obj_VisProt.min, obj_VisProt.max, obj_VisProt.kv, obj_VisProt.cs, obj_VisProt.px, obj_VisProt.RawFolder, datasetID);
                
            end
            obj.BoxSize = round((obj_VisProt.max+obj_VisProt.max)/2) + 200;
            obj.BoxSizepx = round(obj.BoxSize/obj_VisProt.px);
            if mod(obj.BoxSizepx,2) == 0
                obj.BoxSizepx = obj.BoxSizepx + 1;
            end
             
        end
        function obj = parext(obj, obj_VisProt, handlesVPG)
            warning ('off','all');
            mkdir('output/Particle_extraction/all_particles/');
            for datasetID = 1:obj_VisProt.NumberDatasets
                
                progress = ['Extracting the particles.....',num2str(round((datasetID/obj_VisProt.NumberDatasets)*100)),'%   (dataset ',num2str(datasetID),' of ',num2str(obj_VisProt.NumberDatasets),')'];
                set(handlesVPG.sProg2, 'String', progress);
                drawnow;
                
                [nbrparticles coordinatesR] = vp.fg.particle_extraction_gautomatch(obj, obj_VisProt, datasetID, handlesVPG);
              
                for microgID = 1:obj.NumberFiles
                    coord1 = coordinatesR{microgID, datasetID};
                    vals = coord1(coord1 ~= 0);
                    coord(:,1) = vals(1:length(vals)/2,1);
                    coord(:,2) = vals(length(vals)/2+1:length(vals),1);
                    obj.coordinatesRelion{microgID, datasetID} = coord;
                    clear coord1; clear vals; clear coord;
                end
              
                % Toterrorest_norm{datasetID} = errorest_acc(obj, datasetID, nbrparticles, obj_VisProt.RawFolder, obj_VisProt.module);
                % clear nbrparticles;
            end
            set(handlesVPG.sProg2, 'String', '');
            drawnow;             
        end
    end
end




