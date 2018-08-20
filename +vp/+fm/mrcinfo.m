function Information = mrcinfo(Filename)

spliting=strsplit(Filename, '__');
DatasetName=spliting{2};
MRCinformation = {'mrc',DatasetName};
MRCinformationStruct = cell2struct(MRCinformation,{'Format','Dataset'},2);
Information = MRCinformationStruct;

end