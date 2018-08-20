function flag = starStack_cryo_gctf(obj)
% Writes particle stack .STAR file for Cryo-EM data. Reads CTF parameters estimated with Gctf.


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
                 '_rlnAmplitudeContrast #10 \n'...
                 '_rlnMagnification #11 \n'...
                 '_rlnDetectorPixelSize #12 \n'...
                 '_rlnCtfFigureOfMerit #13'' >stackCryo.star']) );

file = fopen('stackCryo.star','a'); % Append to the existing file
ParticleFolder = dir(['output/Particle_extraction/all_particles/*.mrc']);
NumberParticlesTot = length(ParticleFolder);

namesSort = vp.fm.natsort({ParticleFolder.name})';

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
    
    [status FinalValues] = system(sprintf(['grep -a "Final Values" RawMicrographs/',ParticleMicrograph{particleID,2},'/',ParticleMicrograph{particleID,1},'_*.log ']));
    FinalValues = strsplit(FinalValues);
    if isempty(FinalValues{1})
        FinalValues(1) = [];
    end
    
    [status XMAG] = system(sprintf(['grep -a -A 1 XMAG RawMicrographs/',ParticleMicrograph{particleID,2},'/',ParticleMicrograph{particleID,1},'_*.log | sed "1d"'])); 
    XMAG = strsplit(XMAG);
    if isempty(XMAG{1})
        XMAG(1) = [];
    end
    
    ParticleName{particleID,1} = sprintf(['RawMicrographs/',ParticleMicrograph{particleID,1},'.mrc']);
    ParticleName{particleID,2} = sprintf('%f',ParticleMicrograph{particleID,5});
    ParticleName{particleID,3} = sprintf('%f',ParticleMicrograph{particleID,6});
    ParticleName{particleID,4} = sprintf(['output/Particle_extraction/all_particles/',namesSort{particleID}]);
    ParticleName{particleID,5} = str2num(cell2mat(FinalValues(1)));
    ParticleName{particleID,6} = str2num(cell2mat(FinalValues(2)));
    ParticleName{particleID,7} = str2num(cell2mat(FinalValues(3)));
    ParticleName{particleID,8} = str2num(cell2mat(XMAG(2)));
    ParticleName{particleID,9} = str2num(cell2mat(XMAG(1)));
    ParticleName{particleID,10} = str2num(cell2mat(XMAG(3)));
    ParticleName{particleID,11} = str2num(cell2mat(XMAG(4)));
    ParticleName{particleID,12} = str2num(cell2mat(XMAG(5)));
    ParticleName{particleID,13} = str2num(cell2mat(FinalValues(4)));
    if isnan(ParticleName{particleID,13})
        ParticleName{particleID,13} = 0;
    end
    fprintf(file,'%s  %s   %s %s %f %f    %f   %f    %f    %f %2.6e    %f    %f \n',ParticleName{particleID,:});

end



end
