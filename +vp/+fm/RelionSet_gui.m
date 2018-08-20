classdef RelionSet_gui < vp.fm.Constructor
    methods 
        function obj = RelionSet_gui
        end
        function objU = gui(obj)
            objU = gui@vp.fm.Constructor(obj);
            disp('The new settings are:') 
            disp(objU)
        end
        function relion2dscript(objU, module)
            mkdir('Class2D');
            
            % Create .settings 
            system('echo '' '' >run.gui_general.settings && echo '' '' >run.gui_class2d.settings');
            
            % Create .sh 
            if objU.gpu > 0         
                vp.fm.submit2dgpu(objU, module);
            else
                vp.fm.submit2dcpu(objU, module);
            end
        end
        function relion2dsubmit(objU)
            % Run .sh
            status_2D = system('sbatch runRELION2D.sh');
            
        end
        function displayclasses(objU)
            
                if exist([objU.('o'),'_it',sprintf('%.3d', objU.('iter')),'_model.star'])
                    system( sprintf(['echo ''#!/bin/bash \n \n'...
                                    'module load RELION \n \n'...
                                    'relion_display \\\n'...
                                    '--i ',objU.('o'),'_it',sprintf('%.3d', objU.('iter')),'_model.star \\\n'...
                                    '--allow_save --fn_parts ',pwd,'/particles.star --fn_imgs ',pwd,'/average.star --recenter \\\n'...
                                    '--scale 0.3 --black 0 --white 0 --sigma_contrast 0 \\\n'...
                                    '--display rlnReferenceImage \\\n'...
                                    '--reverse \\\n'...
                                    '--col 10 --ori_scale 1 \\\n'...
                                    '--class '' >classSave.sh']) );
                                    % '--sort rlnClassDistribution \\\n'...
                    
                    system('source classSave.sh');
                    
                    [status classnum] = system('tail -c 8 average.star');
                    classnum = strsplit(classnum(1:4));
                    delete('classSave.sh');
                    delete('backup_selection.star');
                    delete('average.star');
                    movefile('particles.star', ['class',classnum{2},'.star']);
                    
                    % h = findobj();
                    % hsub = allchild(h);
                else
                    disp(':Classification not finished.');
                end
        end
        function display2d(objU, varargin)
            % Display libraries
                system( sprintf(['echo ''#!/bin/bash \n \n'...
                                'module load RELION \n \n'...
                                'relion_display \\\n'...
                                '--i class$1.star \\\n'...
                                '--scale 0.5 --black 0 --white 0 --sigma_contrast 0 \\\n'...
                                '--display rlnImageName \\\n'...
                                '--sort rlnNormCorrection \\\n'...
                                '--reverse \\\n'...
                                '--col 5 --ori_scale 1 &'' >classDisplay.sh']) );
                for i = 1:length(varargin{:})
                    system(['source classDisplay.sh ', num2str(varargin{:}(i))]);
                end
        end
    end
end
    
