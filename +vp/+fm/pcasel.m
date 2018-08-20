function [sel, DDnorm_sel, DDerrornorm_sel, selected_averages] = pcasel(DDnorm, DDerrornorm, xname)
% Performs Pricipal Component Analsysis on quantitative results of saved classes.

Data_vect = DDnorm;
C = (1/size(Data_vect,2))*Data_vect'*Data_vect;
[V,K] = eig(C);
for datasetID = 1:size(Data_vect,2)
   eigenval(datasetID) = K(datasetID,datasetID);
end
% Classes in rows & PCs in columns. 
% From an initial n-dimensional space defined by number of datasets where each class is a point, 
% we reduce to a PC-space with PC-axes where if we plot the classes as points we see 
% that some are grouped together(similar to each other, not interesting) and some are separated (significant)
for eigenID = 1:size(Data_vect,2)
    F(:,eigenID) = Data_vect*V(:,eigenID);
end
for eigenID = 1:size(Data_vect,2)
    energy(eigenID) = sum(F(:,eigenID));
end
% Fourier Analysis in alternative way
for datasetID = 1:size(Data_vect,2)
    for eigenID = 1:size(Data_vect,2)
        www(eigenID,datasetID) = (1/energy(eigenID))*sum(sum(Data_vect(:,datasetID)'*F(:,eigenID)));
    end;
end;
% To find the corresponding averages to the PCs/eigenvectors:
for eigenID = 1:size(Data_vect,2)
    PCaverages(eigenID) = strcat('class',xname(find(abs(F(:,eigenID))==max(abs(F(:,eigenID))))));
end
% for all:
[Fs,indices]=sort(abs(F),'descend');
for eigenID = 1:size(Data_vect,2)
    PCaverages_all(:,eigenID) = strcat('class',xname(indices(:,eigenID))');
end
for eigenID = 1:size(Data_vect,2)
    PCaverages_all2(:,eigenID) = xname(indices(:,eigenID));
end
sel_length = round(size(Data_vect,1)/2);
sel = PCaverages_all2(1:sel_length,1:eigenID); % Take the first half results (with the highest variance) from all PCs
sel = sel(:); % Concatenate columns
sel = tabulate(sel);
occurance_percentages = unique(cell2mat(sel(:,3)));
significant_percentages = occurance_percentages( end-round(length(occurance_percentages)/3)+1 : end ); % Take the 1/3 highest occurance percentages 
sel = sel(find( sum(bsxfun(@eq,[sel{:,3}],significant_percentages)',2) )); % Extract significant classes

selected_averages = ismember(xname,sel);
sel = xname(selected_averages);
DDnorm_sel = num2cell(DDnorm(selected_averages,:));
DDerrornorm_sel = num2cell(DDerrornorm(selected_averages,:));

