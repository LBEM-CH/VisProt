function obj = VisProtGui

if ismac
    obj = vp.fg.VisProtGui_OS;
else
    obj = vp.fg.VisProtGui_Linux;
end


