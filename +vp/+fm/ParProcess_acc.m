classdef ParProcess_acc < dynamicprops
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
        coordinates
        coordinatesRelion
        coordinatesLowerLeft
        stopProp
    end
    methods
        function obj = ParProcess_acc(nbrdatasets, rawfolder, handlesVPG)
            set(handlesVPG.sProg, 'String', 'Reading data...');
            drawnow;
          
            for datasetID = 1:nbrdatasets 
                obj.imds{datasetID} = imageDatastore(['RawMicrographs/',rawfolder(datasetID).name,'/*.tif'],'FileExtensions','.tif','ReadFcn',@imread); % Also change in NormFiles & LPFiles & Detect_particles
                obj.NumberFiles = obj.imds{datasetID}.numpartitions;
                obj.imds{datasetID}.ReadFcn = @(loc)im2double(imread(loc));
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
                
                % Range for imds
                obj.imds2{datasetID} = imageDatastore(['RawMicrographs/',rawfolder(datasetID).name,'/*.tif'],'FileExtensions','.tif','ReadFcn',@imread);
                obj.imds2{datasetID}.ReadFcn = @(loc)vp.fm.rangeNorm( im2double(imread(loc)) );
               
                % Background subtraction
                obj.NormFiles{datasetID} = imageDatastore(['RawMicrographs/',rawfolder(datasetID).name,'/*.tif'],'FileExtensions','.tif','ReadFcn',@imread);
                obj.NormFiles{datasetID}.ReadFcn = @(loc)vp.fm.rangeNorm(vp.fm.back_subtract_pseudoFlatfield_gamma( im2double(imread(loc)) ));
               

                % LP filter data
                obj.LPFiles{datasetID} = imageDatastore(['RawMicrographs/',rawfolder(datasetID).name,'/*.tif'],'FileExtensions','.tif','ReadFcn',@imread);
                obj.LPFiles{datasetID}.ReadFcn =  @(loc)vp.fm.LP_filter(vp.fm.rangeNorm(vp.fm.back_subtract_pseudoFlatfield_gamma( im2double(imread(loc)) )));
            end

            set(handlesVPG.sProg, 'String', '');
            drawnow;

        end
        function obj = parpick(obj, obj_VisProt, handlesVPG, axisVPG)
             
            for datasetID = 1:obj_VisProt.NumberDatasets
                progress = ['Picking particles.....',num2str(round((datasetID/obj_VisProt.NumberDatasets)*100)),'%   (dataset ',num2str(datasetID),' of ',num2str(obj_VisProt.NumberDatasets),')'];
                set(handlesVPG.sProg, 'String', progress);
                drawnow;
                
                mkdir(['output/Particle_picking/',obj_VisProt.RawFolder(datasetID).name]); 
                
                obj.Detect_Particles{datasetID} = imageDatastore(['RawMicrographs/',obj_VisProt.RawFolder(datasetID).name,'/*.tif'],'FileExtensions','.tif','ReadFcn',@imread);
                
                switch obj_VisProt.module;
                case 'Negative stain'    
                    for microgID = 1:obj.NumberFiles
                        obj.Detect_Particles{datasetID}.ReadFcn =  @(loc)vp.fm.particle_picking_holefill2( vp.fm.LP_filter(vp.fm.rangeNorm(vp.fm.back_subtract_pseudoFlatfield_gamma(im2double(imread(loc))))), obj.SizeIm, obj_VisProt.min, obj_VisProt.max, microgID, obj.imds{datasetID}.readimage(microgID), obj_VisProt.RawFolder(datasetID).name, axisVPG, obj_VisProt.hIm);
                        % Calculate maximum major axis length from particles of all micrographs.
                        % This will be used as box size for extraction with particle_extraction_....m
                        MaxSizePerMicrog{datasetID}(microgID) = vp.fm.particle_MajorLength(obj.Detect_Particles{datasetID}.readimage(microgID), obj.imds{datasetID}.readimage(microgID));
                        if obj.stopProp==1
                            break;
                        end  
                    end
                case 'Cryo-EM'
                    for microgID = 1:obj.NumberFiles
                        obj.Detect_Particles{datasetID}.ReadFcn =  @(loc)vp.fm.particle_picking_cryo( vp.fm.LP_filter(vp.fm.rangeNorm(vp.fm.back_subtract_pseudoFlatfield_gamma(im2double(imread(loc))))), obj.SizeIm, obj_VisProt.min, obj_VisProt.max, microgID, obj.imds{datasetID}.readimage(microgID), obj_VisProt.RawFolder(datasetID).name, axisVPG, obj_VisProt.hIm);
                        MaxSizePerMicrog{datasetID}(microgID) = vp.fm.particle_MajorLength(obj.Detect_Particles{datasetID}.readimage(microgID), obj.imds{datasetID}.readimage(microgID));
                        if obj.stopProp==1
                            break;
                        end  
                    end
                end
                
                if obj.stopProp==0
                    MaxSize{datasetID} = round(max(MaxSizePerMicrog{datasetID}));
                else
                    break
                end

            end
            if obj.stopProp==0
                obj.BoxSize = max([MaxSize{:}]);
                if mod(obj.BoxSize,2) == 0
                    obj.BoxSize = obj.BoxSize + 1;
                end
            end
            
            set(handlesVPG.sProg, 'String', '');
            drawnow;  
        end
        function obj = parext(obj, obj_VisProt, handlesVPG)
           
            mkdir('output/Particle_extraction/all_particles/');
            
            for datasetID = 1:obj_VisProt.NumberDatasets
                progress = ['Extracting the particles.....',num2str(round((datasetID/obj_VisProt.NumberDatasets)*100)),'%   (dataset ',num2str(datasetID),' of ',num2str(obj_VisProt.NumberDatasets),')'];
                set(handlesVPG.sProg2, 'String', progress);
                drawnow;
                
                obj.Detect_Particles{datasetID} = imageDatastore(['output/Particle_picking/',obj_VisProt.RawFolder(datasetID).name,'/Blobs_*.png'],'FileExtensions','.png','ReadFcn',@imread);

                switch obj_VisProt.module
                case 'Negative stain' 
                     [nbrparticles, coordinates1] = vp.fm.particle_extraction_bin(obj, obj_VisProt, datasetID);
                    
                case 'Cryo-EM'
                      [nbrparticles, coordinates1] = vp.fm.particle_extraction_cryo(obj, obj_VisProt, datasetID);

                end  
                
                
                for microgID = 1:obj.NumberFiles
                    coord1 = coordinates1{microgID, datasetID};
                    vals = coord1(coord1 ~= 0);
                    coord(:,1) = vals(1:length(vals)/2,1);
                    coord(:,2) = vals(length(vals)/2+1:length(vals),1);
                    obj.coordinates{microgID, datasetID} = coord;
                    obj.coordinatesRelion{microgID, datasetID}(:,1) = round(obj.coordinates{microgID, datasetID}(:,1));
                    obj.coordinatesRelion{microgID, datasetID}(:,2) = round(obj.SizeIm(1) - obj.coordinates{microgID, datasetID}(:,2)); % Relion counts y coordinate from bottom while Matlab starts from top.
                    obj.coordinatesLowerLeft{microgID, datasetID}(:,1) = obj.coordinatesRelion{microgID, datasetID}(:,1) - (obj.BoxSize+1)/2;
                    obj.coordinatesLowerLeft{microgID, datasetID}(:,2) = obj.coordinatesRelion{microgID, datasetID}(:,2) - (obj.BoxSize+1)/2;
                    clear coord;
                end             
                
            end
            set(handlesVPG.sProg2, 'String', '');
            drawnow;             
        end
    end
end




