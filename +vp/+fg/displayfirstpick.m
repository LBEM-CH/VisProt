function image = displayfirstpick(ob)

maxbox = (ob.min+ob.max)/2;


while ~exist(['RawMicrographs/',ob.RawFolder(1).name,'/',ob.last_file{1}{1},'_automatchAll.star'])
    pause(1);
end


[s o] = system(['grep -a -A5000 "_rlnAutopickFigureOfMerit #5"  RawMicrographs/',ob.RawFolder(1).name,'/',ob.last_file{1}{1},'_automatchAll.star | grep -v "_rlnAutopickFigureOfMerit #5"']);
o = strsplit(o);
o = cellfun(@(x) str2num(x), o, 'UniformOutput',0);
o = cell2mat(o);
o2 = o;
o2(find(~mod(o,1)==0))=0;
o2(find(o2==0))=[]; 
oFin = reshape(o2,2,[])';
coords = oFin;
coordsmatlab(:,1) = coords(:,1);
coordsmatlab(:,2) = round(ob.ParprocessClass.SizeIm(1) - coords(:,2)); % Relion counts y coordinate from bottom while Matlab starts from top.
clear o; clear o2; clear oFin;

image = ob.ParprocessClass.LPFiles{1}.preview;
image = image-min(min(image));
image = image/max(max(image));
microg_size = ob.ParprocessClass.SizeIm;

for k = 1:length(coordsmatlab)
    a = maxbox/2;
    ParticleCenterX = coordsmatlab(k,1);
    ParticleCenterY = coordsmatlab(k,2);

    cornerXm = round(ParticleCenterX-a);
    cornerXp = round(ParticleCenterX+a);
    cornerYm = round(ParticleCenterY-a);
    cornerYp = round(ParticleCenterY+a);

     if (0<cornerXm)&&(cornerXp<=microg_size(1)-2)&&(cornerXp<=microg_size(2)-2)&&(0<cornerYm)&&(cornerYp<=microg_size(1)-2)&&(cornerYp<=microg_size(2)-2)
        image(cornerYm:cornerYp,cornerXm:cornerXm+2)=255;
        image(cornerYm:cornerYp,cornerXp:cornerXp+2)=255;
        image(cornerYp:cornerYp+2,cornerXm:cornerXp)=255;
        image(cornerYm:cornerYm+2,cornerXm:cornerXp)=255;
     end
end 

