function flag = stack(obj_VisProt)

switch obj_VisProt.module;
case 'Negative stain'
    flag = vp.fm.starStack;
case 'Cryo-EM'
    flag = vp.fm.starStack_cryo_ctffind4(obj_VisProt);
end
