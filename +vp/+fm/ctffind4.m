classdef ctffind4 
    properties
        apix = 1.000;
        kv = 300;
        cs = 2.0;
        ac = 0.10;
        minres = 50; % in A
        maxres = 5;
        mindef = 5000; % in A
        maxdef = 50000; 
        defstep = 500;
        imsize  = 1024;
    end
    methods
        function ctffind4_run(obj,dataset,exepath,varargin)
            
            if nargin > 3
                for argID = 1:2:nargin-3
                    obj.(varargin{argID}) = varargin{argID+1};
                end
            end
            
            for datasetID = 1:length(dataset)
                d = dir(['RawMicrographs/',dataset(datasetID).name,'/*.mrc']);
                for i = 1:length(d)
                    % generate input/output filenames
                    inputfile  = ['RawMicrographs/',dataset(datasetID).name,'/',d(i).name];
                    outputfile = ['RawMicrographs/',dataset(datasetID).name,'/diag_',d(i).name];

                    % generate bash script
                    fileID = fopen('ctffind4_run.sh','w');
                    fprintf(fileID,'#!/bin/bash\n');
                    fprintf(fileID,'# run ctffind4\n');
                    fprintf(fileID,['/',exepath,'/projects/scicore-p-structsoft/ctffind4/v4.1.4/ctffind <<EOF\n']);
                    fprintf(fileID,[inputfile '\n']);
                    %fprintf(fileID,'no\n');
                    fprintf(fileID,[outputfile '\n']);
                    fprintf(fileID,[num2str(obj.apix,'%.3f') '\n']);
                    fprintf(fileID,[num2str(obj.kv)  '\n']);
                    fprintf(fileID,[num2str(obj.cs,'%.1f')  '\n']);
                    fprintf(fileID,[num2str(obj.ac,'%.2f')  '\n']);
                    fprintf(fileID,[num2str(obj.imsize)  '\n']);
                    fprintf(fileID,[num2str(obj.minres)  '\n']);
                    fprintf(fileID,[num2str(obj.maxres)  '\n']);
                    fprintf(fileID,[num2str(obj.mindef)  '\n']);
                    fprintf(fileID,[num2str(obj.maxdef)  '\n']);
                    fprintf(fileID,[num2str(obj.defstep) '\n']);
                    fprintf(fileID,'no\n');
                    fprintf(fileID,'no\n');
                    fprintf(fileID,'yes\n');
                    fprintf(fileID,'200\n');
                    fprintf(fileID,'no\n');
                    fprintf(fileID,'no\n');
                    fprintf(fileID,'EOF\n');
                    %fprintf(fileID,'done\n');
                    fclose(fileID);

                    % run bash script
                    system('bash ctffind4_run.sh');
                end
            end
        end
    end
end