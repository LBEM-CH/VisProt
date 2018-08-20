function [DDfinal, DDerrorfinal, xnamefinal, nbrSavedClasses] = getdata(nbrdatasets, rawfolder, lastfile, nbrfiles)
% Gets number of dataset instances per class using the class .STAR file metadata.
% Matrix with saved classes in columns, DatasetName in rows. Number of
% instances in cells.

[status, SavedClasses] = system('ls class*.star');
SavedClasses = strsplit(strtrim(SavedClasses)); % To remove the space that is returned in the end
SavedClasses = vp.fg.natsortfiles(SavedClasses);
nbrSavedClasses = length(SavedClasses);
for classID = 1:nbrSavedClasses
    for datasetID = 1:nbrdatasets
        [status,D{datasetID,classID}] = system(sprintf(['grep ',rawfolder(datasetID).name,' ',SavedClasses{classID},' > found.txt && wc -l < found.txt && rm found.txt']));
    end
end
emptyCells = cellfun(@isempty,D); % If empty cell replace with zero
D(emptyCells) = {'0'};
D = cellfun(@str2num,D,'UniformOutput',0); % Convert D contents from strings to numbers for cell2mat to work
D = cell2mat(D);
DD = D';

DDerror = vp.fg.bootstrapdata(SavedClasses, nbrSavedClasses, nbrdatasets, rawfolder, lastfile, nbrfiles);

for datasetID = 1:nbrdatasets
    particleSum(datasetID) = sum(DD(:,datasetID));
    DDnorm(:,datasetID) = DD(:,datasetID)/particleSum(datasetID);
    DDerrornorm(:,datasetID) = DDerror(:,datasetID)/particleSum(datasetID);
end

for classID = 1:nbrSavedClasses 
    xname{classID} = SavedClasses{classID}(6:end-5);
end
% For sorting in plot:
Dsum = sum(DDnorm,2);
Dsum = Dsum*10000; % To get rid of decimal point issues...
Dsum = round(Dsum,5);
Dsum = num2cell(Dsum);
Dsum = cellfun(@num2str,Dsum,'UniformOutput',0);
DDnormcell = num2cell(DDnorm);
DDnormcell = cellfun(@num2str,DDnormcell,'UniformOutput',0);
DDerrornormcell = num2cell(DDerrornorm);
DDerrornormcell = cellfun(@num2str,DDerrornormcell,'UniformOutput',0);
xname_sum = [Dsum DDnormcell xname' DDerrornormcell];
xname_sum_order = xname_sum;
%xname_sum_ordercell = cellfun(@str2num,xname_sum_order,'UniformOutput',0);
[xname_sum_order(:,1) index] = vp.fg.natsortfiles(xname_sum(:,1));
xname_sum_order(:,2:end) = xname_sum_order(index,2:end);
xname_sum_order = flip(xname_sum_order,1);

DDfinal = cellfun(@str2num,xname_sum_order(:,2:1+nbrdatasets),'UniformOutput',0);
DDfinal = cell2mat(DDfinal);

DDerrorfinal = cellfun(@str2num,xname_sum_order(:,1+nbrdatasets+2:end),'UniformOutput',0);
DDerrorfinal = cell2mat(DDerrorfinal);

xnamefinal = (xname_sum_order(:,1+nbrdatasets+1))';

