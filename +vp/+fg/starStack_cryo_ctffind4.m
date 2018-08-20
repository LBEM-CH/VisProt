function flag = starStack_cryo_ctffind4(obj)
% Writes particle stack .STAR file for Cryo-EM data. Reads CTF parameters estimated with CTFFIND4.


flag = system( sprintf(['echo ''\n'...
                 'data_ \n \n'...
                 'loop_ \n'...
                 '_rlnMicrographName #1 \n'...
                 '_rlnCoordinateX #2 \n'...
                 '_rlnCoordinateY #3 \n'...
                 '_rlnImageName #4 \n'...
                 '_rlnDefocusU #5 \n'...
                 '_rlnDefocusV #6 \n'...
                 '_rlnDefocusAngle #7 \n'...
                 '_rlnVoltage #8 \n'...
                 '_rlnSphericalAberration #9 \n'...
                 '_rlnAmplitudeContrast #10'' >stackCryo.star']) );

file = fopen('stackCryo.star','a'); % Append to the existing file
ParticleFolder = dir(['output/Particle_extraction/all_particles/*.mrc']);
NumberParticlesTot = length(ParticleFolder);

namesSort = vp.fg.natsort({ParticleFolder.name})';

for particleID = 1:NumberParticlesTot
    names = strsplit(namesSort{particleID},{'___','__','.'});
    ParticleMicrograph(particleID,:) = names;
end

coordinates = obj.ParprocessClass.coordinatesRelion;
last = 0;
for datasetID = 1:size(coordinates,2)
    for fileID = 1:size(coordinates,1)
        NumberParticles{fileID, datasetID} = length(coordinates{fileID, datasetID});
        for particleID = 1:NumberParticles{fileID, datasetID}
            ParticleMicrograph(last+particleID,5) = {coordinates{fileID, datasetID}(particleID,1)};
            ParticleMicrograph(last+particleID,5) = {ParticleMicrograph{last+particleID,5}};
            ParticleMicrograph(last+particleID,6) = {coordinates{fileID, datasetID}(particleID,2)}; 
            ParticleMicrograph(last+particleID,6) = {ParticleMicrograph{last+particleID,6}};
        end
        last = last + particleID;
    end
end


for particleID = 1:NumberParticlesTot

    ctffind_file = fopen(['RawMicrographs/',ParticleMicrograph{particleID,2},'/diag_',ParticleMicrograph{particleID,1},'.txt'],'r');
    DefocusValues = textscan(ctffind_file,'%d %d %d %d %d %d %d','CommentStyle','#');
    fclose(ctffind_file);

    
    ParticleName{particleID,1} = sprintf(['RawMicrographs/',ParticleMicrograph{particleID,1},'.mrc']);
    ParticleName{particleID,2} = sprintf('%f',ParticleMicrograph{particleID,5});
    ParticleName{particleID,3} = sprintf('%f',ParticleMicrograph{particleID,6});
    ParticleName{particleID,4} = sprintf(['output/Particle_extraction/all_particles/',namesSort{particleID}]);
    ParticleName{particleID,5} = cell2mat(DefocusValues(2));
    ParticleName{particleID,6} = cell2mat(DefocusValues(3));
    ParticleName{particleID,7} = cell2mat(DefocusValues(4));
    ParticleName{particleID,8} = obj.kv;
    ParticleName{particleID,9} = obj.cs;
    ParticleName{particleID,10} = obj.ac;
    
    fprintf(file,'%s  %s   %s %s %f %f    %f   %f    %f    %f \n',ParticleName{particleID,:});

end



end
