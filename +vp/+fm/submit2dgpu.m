function submit2dgpu(object, mod)
% Writes a SLURM submission script for 2D classification on the GPU.


system( sprintf(['echo ''#!/bin/bash -l \n'...
                '# \n'...
                '#SBATCH -o ',pwd,'/out.%%j \n'...
                '#SBATCH -e ',pwd,'/err.%%j \n'...
                '#SBATCH --job-name=runRELION2D \n'...
                '#SBATCH --qos=emgpu \n'...
                '#SBATCH --mem-per-cpu=',num2str(object.('memory_per_thread')),'G \n'...
                '#SBATCH --nodes=',num2str(object.('MPIs')),' \n'...
                '#SBATCH --ntasks-per-node=',num2str(object.('rank')),' \n'...
                '#SBATCH --cpus-per-task=',num2str(object.('j')),' \n'...
                '#SBATCH --partition=',num2str(object.('queue')),' \n'...
                '#SBATCH --gres=gpu:',num2str(object.('gpu')),' \n \n'...
                'module load RELION/2.1b1-goolf-1.7.20_20170817_e7607a8 \n \n'...
                'time srun `which relion_refine_mpi` \\'' >runRELION2D.sh']) );
      
                
NbrParam = length(properties(object));
Mat = num2cell(zeros(NbrParam,2));
Mat(:,1) = properties(object);
for ID = 1:NbrParam
    [Mat(ID,2)] = {num2str(object.(Mat{ID,1}))};
end
anonymousParamIndex = find(strcmp(properties(object),'maskopt') | strcmp(properties(object),'zero_masking') | strcmp(properties(object),'standNorm') | strcmp(properties(object),'scaling') | strcmp(properties(object),'normal') | strcmp(properties(object),'accel'));               
[Mat(anonymousParamIndex,1)] = {''};

file = fopen('runRELION2D.sh','a'); % Append to the existing file
basicParamIndex = find(~(strcmp(properties(object),'MPIs') | strcmp(properties(object),'j') | strcmp(properties(object),'rank') | strcmp(properties(object),'memory_per_thread') | strcmp(properties(object), 'gpu') | strcmp(properties(object), 'queue') | strcmp(properties(object), 'stopset')));
for ID = 1:length(basicParamIndex);
    if strcmp(Mat{ID,1},'')
        fprintf(file,'--%s \\\n',Mat{ID,2});
    else
        fprintf(file,'--%s %s \\\n',Mat{ID,:}); 
    end
end

% file = fclose('runRELION2D.sh');
switch mod
case 'Cryo-EM'
    fprintf(file,'--ctf \\');
end
    
        
                
                
                
