function flag = stack(obj_VisProt)

switch obj_VisProt.module;
case 'Negative stain'
    flag = vp.fg.starStack;
case 'Cryo-EM'
    flag = vp.fg.starStack_cryo_ctffind4(obj_VisProt);
end