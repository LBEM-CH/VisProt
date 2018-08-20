function flag = starStack()
% Writes particle stack .STAR file for Negative-staining EM data.

flag = system( sprintf(['echo ''\n'...
                 'data_ \n \n'...
                 'loop_ \n'...
                 '_rlnImageName #1 '' >stack.star']) );

file = fopen('stack.star','a'); % Append to the existing file
ParticleFolder = dir(['output/Particle_extraction/all_particles/*.mrc']);
NumberParticlesTot = length(ParticleFolder);
for particleID = 1:NumberParticlesTot
    ParticleName{particleID} = sprintf(['output/Particle_extraction/all_particles/',ParticleFolder(particleID).name]);    
    fprintf(file,'%s \n',ParticleName{particleID});
end



end


