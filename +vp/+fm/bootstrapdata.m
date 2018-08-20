function DDerror = bootstrapdata(SavedClasses, nbrSavedClasses, nbrdatasets, rawfolder, last_file, nbrfiles)
% Calculates of errors in quantitative analysis using the bootstrapping method.

for datasetID = 1:nbrdatasets
    for classID = 1:nbrSavedClasses
        for microgID = 1:nbrfiles
            [status,dvalues{microgID,classID}] = system(sprintf(['grep ',last_file{datasetID}{microgID},'___',rawfolder(datasetID).name,' ',SavedClasses{classID},' > found.txt && wc -l < found.txt && rm found.txt']));
        end
    end
    emptyCells = cellfun(@isempty,dvalues); % If empty cell replace with zero
    dvalues(emptyCells) = {'0'};
    dvalues = cellfun(@str2num,dvalues,'UniformOutput',0); % Convert D contents from strings to numbers for cell2mat to work
    dvalues = cell2mat(dvalues);
    DDvalues{datasetID} = dvalues';
    clear dvalues;
end

for datasetID = 1:nbrdatasets
    for classID = 1:nbrSavedClasses
        bootstat = bootstrp(1000,@sum,DDvalues{datasetID}(classID,:));
        DDerror{classID,datasetID} = round(std(bootstat));
    end
end

DDerror = cell2mat(DDerror);
