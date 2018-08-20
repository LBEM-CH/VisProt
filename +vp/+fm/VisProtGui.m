classdef VisProtGui < handle
    % Visual Proteomics interface
    properties
        RawFolder
        NumberDatasets
        ParprocessClass
        min
        max
        kv 
        cs 
        ac 
        px
        module
        last_file
        avgrelerror_norm
        p
        pU
        hIm
        data
    end
    methods
        function obj  = VisProtGui % Gui initialization
        
            Figure = figure('Menubar','none','NumberTitle','off','Name','VisProt','Position',[360,500,1010,620],'Visible','off');
            movegui(Figure,'center');

            
            % --Creation of tabs--
            tgroup = uitabgroup('Parent', Figure);
            tab1 = uitab('Parent',tgroup, 'Title', '<html><b><Font color="#21545F" face="Helvetica">Particle picking</Font></b>');
            tab2 = uitab('Parent',tgroup, 'Title', '<html><b><Font color="#21545F" face="Helvetica">2D classification</Font></b>');
            tab3 = uitab('Parent',tgroup, 'Title', '<html><b><Font color="#21545F" face="Helvetica">Data analysis</Font></b>');
            
            
            % --Tab1: Data panel--
            panData = uipanel(tab1,'Title','Initialization','BorderType','beveledout','ForegroundColor',[.28 .34 .75],'FontName','AvantGarde','Units','Normalized','Position',[.05 .75 .3 .2]);
            textSData = uicontrol(panData,'Style','text','String','Micrograph selection','Units','Normalized','Position',[.1 .554 .3 .35]);
            textEData = uicontrol(panData,'Style','edit','String',[pwd,'/RawMicrographs'],'Units','Normalized','Position',[.4 .6 .5 .25],'Tag','eData','Callback','@eData_Callback');
            bSetData = uicontrol(panData,'Style','pushbutton','String','Set','Units','Normalized','Position',[.4 .2 .2 .24],'Callback',{@SetData_Callback});
            set(bSetData,'tooltip','Import and pre-process data');
            jbSetData = java(vp.fm.findjobj(bSetData));
            jbSetData.setCursor(java.awt.Cursor(java.awt.Cursor.HAND_CURSOR));
            
            
            % --Tab1: Image panel--
            panImg = uipanel(tab1,'Title','Image viewer','BorderType','beveledout','ForegroundColor',[.28 .34 .75],'FontName','AvantGarde','Units','Normalized','Position',[.4 .22 .55 .73]);
            bZinoutImg = uicontrol(panImg,'Style','pushbutton','String','+/-','Units','Normalized','Position',[.02 .9 .07 .08],'Callback',{@bZinout_Callback});
            set(bZinoutImg,'tooltip','Zoom in/out');
            jbZinoutImg = java(vp.fm.findjobj(bZinoutImg));
            jbZinoutImg.setCursor(java.awt.Cursor(java.awt.Cursor.HAND_CURSOR));
            % bpanImg = uicontrol(panImg,'Style','pushbutton','String','<->','Units','Normalized','Position',[.05 .82 .07 .08],'Callback',{@bpan_Callback});

            
            % --Tab1: Progress panel--
            panProg = uipanel(tab1,'Title','Progress log','BorderType','beveledout','ForegroundColor',[.28 .34 .75],'FontName','AvantGarde','Units','Normalized','Position',[.4 .05 .55 .15]);
            textProg = uicontrol(panProg,'Style','text','String','','ForegroundColor',[.3 .3 .3],'Units','Normalized','Position',[.01 .35 .7 .3],'Tag','sProg');

            
            % --Tab1: Particle picking panel--
            panPick = uipanel(tab1,'Title','Picking settings','BorderType','beveledout','ForegroundColor',[.28 .34 .75],'FontName','AvantGarde','Units','Normalized','Position',[.05 .05 .3 .65]);
            obj.min = '20'; 
            obj.max = '60';
            obj.kv = '120'; 
            obj.cs = '2.6'; 
            obj.ac = '0.1'; 
            obj.px = '2.03';
            textSMinpick = uicontrol(panPick,'Style','text','String','Min diameter (px)','Units','Normalized','Position',[.1 .675 .31 .15]);
            textEMinpick = uicontrol(panPick,'Style','edit','String',obj.min,'Units','Normalized','Position',[.45 .765 .3 .06],'Tag','eMinpick');
  
            textSMaxpick = uicontrol(panPick,'Style','text','String','Max diameter (px)','Units','Normalized','Position',[.1 .565 .31 .15]);
            textEMaxpick = uicontrol(panPick,'Style','edit','String',obj.max,'Units','Normalized','Position',[.45 .655 .3 .06],'Tag','eMaxpick');
             
            textSkv = uicontrol(panPick,'Style','text','String','kV','Units','Normalized','Position',[.1 .445 .31 .15]);
            textEkv = uicontrol(panPick,'Style','edit','String',obj.kv,'Units','Normalized','Position',[.45 .545 .3 .06],'Tag','ekv');
  
            textScs = uicontrol(panPick,'Style','text','String','Spherical aberration','Units','Normalized','Position',[.1 .360 .31 .15]);
            textEcs = uicontrol(panPick,'Style','edit','String',obj.cs,'Units','Normalized','Position',[.45 .435 .3 .06],'Tag','ecs');
 
            textSac = uicontrol(panPick,'Style','text','String','Amplitude contrast','Units','Normalized','Position',[.1 .255 .31 .15]);
            textEac = uicontrol(panPick,'Style','edit','String',obj.ac,'Units','Normalized','Position',[.45 .330 .3 .06],'Tag','eac');

            textSpx = uicontrol(panPick,'Style','text','String','Pixel size (A)','Units','Normalized','Position',[.1 .120 .31 .15]);
            textEpx = uicontrol(panPick,'Style','edit','String',obj.px,'Units','Normalized','Position',[.45 .225 .3 .06],'Tag','epx');
 
             
            popSModule  = uicontrol(panPick,'Style','text','String','Select module','FontWeight','bold','Units','Normalized','Position',[.1 .820 .3 .14]);          
            popEModule = uicontrol(panPick,'Style','popupmenu','Units','Normalized','Position',[.45 .890 .3 .07],'String',{'Negative stain','Cryo-EM'},'Tag','popup_Module');            

            bOkPick = uicontrol(panPick,'Style','pushbutton','String','Start picking','Units','Normalized','Position',[.33 .105 .35 .08],'Interruptible','on','Callback',{@OkPick_Callback});
            set(bOkPick,'tooltip','Start particle picking in Matlab');
            jbOkPick = java(vp.fm.findjobj(bOkPick));
            jbOkPick.setCursor(java.awt.Cursor(java.awt.Cursor.HAND_CURSOR));
            bCancelPick = uicontrol(panPick,'Style','pushbutton','String','Cancel','Units','Normalized','Position',[.35 .015 .3 .08],'BusyAction','cancel','Callback',{@CancelPick_Callback});
            set(bCancelPick,'tooltip','Cancel particle picking');
            jbCancelPick = java(vp.fm.findjobj(bCancelPick));
            jbCancelPick.setCursor(java.awt.Cursor(java.awt.Cursor.HAND_CURSOR));
            
            
            
            
 
            
            % --Tab2: Extraction panel--
            panExtract = uipanel(tab2,'Title','Particle extraction','BorderType','beveledout','ForegroundColor',[.28 .34 .75],'FontName','AvantGarde','Units','Normalized','Position',[.05 .75 .3 .2]);
            textSClass = uicontrol(panExtract,'Style','text','String','Box size:','Units','Normalized','Position',[.1 .52 .65 .35],'Tag','tExtract');
            bExtract = uicontrol(panExtract,'Style','pushbutton','String','Extract','Units','Normalized','Position',[.375 .20 .225 .245],'Callback',{@bExtract_Callback});
            set(bExtract,'tooltip','<html>Extract particles from micrographs<br>and write particle .STAR file');
            jbExtract = java(vp.fm.findjobj(bExtract));
            jbExtract.setCursor(java.awt.Cursor(java.awt.Cursor.HAND_CURSOR));


            % --Tab2: Class panel--
            panClass = uipanel(tab2,'Title','Classification settings','BorderType','beveledout','ForegroundColor',[.28 .34 .75],'FontName','AvantGarde','Units','Normalized','Position',[.05 .05 .3 .65]);
            panRun = uipanel(panClass,'BorderType','beveledout','Units','Normalized','Position',[.1 .43 .8 .53]);
            bClassWindow = uicontrol(panRun,'Style','pushbutton','String','Open settings window','Units','Normalized','Position',[.18 .71 .64 .14],'Callback',{@bClassWindow_Callback});
            set(bClassWindow,'tooltip','Set parameters for 2D classification in RELION');
            jbClassWindow = java(vp.fm.findjobj(bClassWindow));
            jbClassWindow.setCursor(java.awt.Cursor(java.awt.Cursor.HAND_CURSOR));
            bClassRun = uicontrol(panRun,'Style','pushbutton','String','Run','Units','Normalized','Position',[.34 .46 .27 .14],'Callback',{@bClassRun_Callback});
            set(bClassRun,'tooltip','Submit particle classification job in queue');
            jbClassRun = java(vp.fm.findjobj(bClassRun));
            jbClassRun.setCursor(java.awt.Cursor(java.awt.Cursor.HAND_CURSOR));
            bClassDisplay = uicontrol(panRun,'Style','pushbutton','String','Save classes','Units','Normalized','Position',[.28 .21 .4 .14],'Callback',{@bClassDisplay_Callback});            
            set(bClassDisplay,'tooltip','Select 2D classes');
            jbClassDisplay = java(vp.fm.findjobj(bClassDisplay));
            jbClassDisplay.setCursor(java.awt.Cursor(java.awt.Cursor.HAND_CURSOR));
            
            sLibDisplay = uicontrol(panClass,'Style','text','String','Select libraries to display','Units','Normalized','Position',[.09 .25 .8 .1]);
            eLibDisplay = uicontrol(panClass,'Style','edit','String','','Units','Normalized','Position',[.33 .21 .3 .07],'Tag','eLib');
            bLibDisplay = uicontrol(panClass,'Style','pushbutton','String','Display libraries','Units','Normalized','Position',[.28 .1 .4 .075],'Callback',{@bLibDisplay_Callback});
            set(bLibDisplay,'tooltip','Open selected classes');
            jbLibDisplay = java(vp.fm.findjobj(bLibDisplay));
            jbLibDisplay.setCursor(java.awt.Cursor(java.awt.Cursor.HAND_CURSOR));
            
            
            % --Tab2: Image panel--
            panImg2 = uipanel(tab2,'Title','Image viewer','BorderType','beveledout','ForegroundColor',[.28 .34 .75],'FontName','AvantGarde','Units','Normalized','Position',[.4 .22 .55 .73]);

            % --Tab2: Progress panel--
            panProg2 = uipanel(tab2,'Title','Progress log','BorderType','beveledout','ForegroundColor',[.28 .34 .75],'FontName','AvantGarde','Units','Normalized','Position',[.4 .05 .55 .15]);
            textProg2 = uicontrol(panProg2,'Style','text','String','','ForegroundColor',[.3 .3 .3],'Units','Normalized','Position',[.01 .35 .7 .3],'Tag','sProg2');

            
                
            
            
            % --Tab3: Image panel--
            panImg3 = uipanel(tab3,'Title','Viewer','BorderType','beveledout','ForegroundColor',[.28 .34 .75],'FontName','AvantGarde','Units','Normalized','Position',[.09 .22 .81 .73]);
            % textProg3 = uicontrol(panImg3,'Style','text','String','','Units','Normalized','Position',[.25 .2 .5 .3],'Tag','sProg3');
            con1 = uiflowcontainer('v0',panImg3,'Units','Normalized','Position',[.0001 .001 .52 1]);
            con2 = uiflowcontainer('v0',panImg3,'Units','Normalized','Position',[.47 .001 .52 1]);

            
            % --Tab3: Buttons panel--
            panButton = uipanel(tab3,'Title','','BorderType','beveledout','Units','Normalized','Position',[.09 .05 .81 .15]);            
            bButton = uicontrol(panButton,'Style','pushbutton','String','Plot','Units','Normalized','Position',[.45 .39 .1 .32],'Callback',{@bButton_Callback});
            set(bButton,'tooltip','Plot results of quantitative analysis');
            jbButton = java(vp.fm.findjobj(bButton));
            jbButton.setCursor(java.awt.Cursor(java.awt.Cursor.HAND_CURSOR));  



            %---Background image (If commented, remove  "BorderType" from uipanels also?)
            axes('Parent',tab1,'Units','normalized','Position',[-0.1 -0.13 1.3 1.3]);
            imshow(imread('+vp/back.png'))
            axes('Parent',tab2,'Units','normalized','Position',[-0.1 -0.13 1.3 1.3]);
            imshow(imread('+vp/back.png'))
            axes('Parent',tab3,'Units','normalized','Position',[-0.1 -0.13 1.3 1.3]);
            imshow(imread('+vp/back.png'))
            %axes('Parent',tab3,'Units','normalized','Position',[-0.23 0 2 2]);
            %imshow(imread('t1.jpg'))
            %--------------------------------------------------------------------------
            Figure.Visible = 'on';
            bgcolor = [.97 .97 .98];
            %[.92 .92 .92]; 
            btncolor = [.99 .99 .99];
            %[.97 .97 .97];
            set(Figure,'Color',bgcolor)
            set(findobj(Figure,'-property','BackgroundColor'), 'BackgroundColor', bgcolor); 
            set(findobj(Figure,'style','pushbutton'),'BackgroundColor',btncolor);
            set(findobj(Figure,'style','popupmenu'),'BackgroundColor',btncolor);            
            set(findobj(Figure,'style','edit'),'BackgroundColor','w');  
            
            
            
            % --Callbacks--
            handles = guihandles;
            % uiwait;
            
            function SetData_Callback(source,eventdata)
                get(handles.('eData'),'String');
                obj.RawFolder = dir([handles.('eData').String]);
                obj.RawFolder(find(ismember({obj.RawFolder.name},'.') | ismember({obj.RawFolder.name},'..') | ismember({obj.RawFolder.name},'.DS_Store'))) = [];
                obj.NumberDatasets = length(obj.RawFolder);
                obj.ParprocessClass = vp.fm.ParProcess_acc(obj.NumberDatasets, obj.RawFolder, handles);
                
                axes('Parent',panImg,'Units','normal','Position',[0 0 1 1]);
                imshow(obj.ParprocessClass.imds{1}.preview,[]) % Display 1st frame from 1st dataset
                obj.hIm = obj.ParprocessClass.imds{1}.preview;
                
                obj.ParprocessClass = preprocess(obj.ParprocessClass, obj.NumberDatasets, obj.RawFolder, handles);
                imshow(obj.ParprocessClass.LPFiles{1}.preview,[]) % Display 1st frame from 1st dataset
                obj.hIm = obj.ParprocessClass.LPFiles{1}.preview;
                uiresume;
            end
            
            set(handles.('eMinpick'),'String',obj.min);
            set(handles.('eMaxpick'),'String',obj.max);
            set(handles.('ekv'),'String',obj.kv);
            set(handles.('ecs'),'String',obj.cs);
            set(handles.('eac'),'String',obj.ac);
            set(handles.('epx'),'String',obj.px);
            % uiwait;
            
                            
            function OkPick_Callback(source,eventdata) 
                obj.ParprocessClass.stopProp = 0;
                contents = handles.('popup_Module').String;
                obj.min = str2double(handles.('eMinpick').String);
                obj.max = str2double(handles.('eMaxpick').String);
                obj.kv = str2double(handles.('ekv').String);
                obj.cs = str2double(handles.('ecs').String);
                obj.ac = str2double(handles.('eac').String);
                obj.px = str2double(handles.('epx').String);
                obj.module = contents{handles.('popup_Module').Value};
                
                for datasetID = 1:obj.NumberDatasets
                    obj.last_file{datasetID} = obj.ParprocessClass.imds{datasetID}.Files;
                    for microgID = 1:obj.ParprocessClass.NumberFiles;
    %                     exe_path = obj.last_file{1}{1};
    %                     exe_path = strsplit(exe_path,'/');
    %                     exe_path = exe_path{2};
                        obj.last_file{datasetID}{microgID}(end-3:end) = [];
                        obj.last_file{datasetID}{microgID} = strsplit(obj.last_file{datasetID}{microgID},'RawMicrographs');
                        obj.last_file{datasetID}{microgID} = obj.last_file{datasetID}{microgID}{2};
                        obj.last_file{datasetID}{microgID} = strsplit(obj.last_file{datasetID}{microgID},'/');
                        obj.last_file{datasetID}{microgID} = obj.last_file{datasetID}{microgID}{3};
                    end
                end
                
                
                ax = axes('Parent',panImg, 'Units','normal','Position',[0 0 1 1],'Visible','off');
                obj.ParprocessClass = parpick(obj.ParprocessClass, obj, handles, ax);
                
                set(handles.('tExtract'),'String',['Box size: ',num2str(obj.ParprocessClass.BoxSize),' (px)']);
                
                % CTF estimation with CTFFIND4
                set(handles.('sProg'),'String','Estimating CTF...');
                drawnow;
                
                if (strcmp(obj.module,'Cryo-EM')) & (boolean(~exist(['RawMicrographs/',obj.RawFolder(obj.NumberDatasets).name,'/diag_',obj.last_file{obj.NumberDatasets}{obj.ParprocessClass.NumberFiles},'.txt'])))
                    ctfParameters = vp.fm.ctffind4;
                    ctffind4_run(ctfParameters,obj.RawFolder,'scicore','apix',obj.px,'kv',obj.kv,'cs',obj.cs,'ac',obj.ac);
                end
                set(handles.('sProg'),'String','');
                drawnow;
                
                guidata(source,handles);
                uiresume;
            end
            
            function CancelPick_Callback(source,eventdata) 
                obj.ParprocessClass.stopProp = 1;
                error(':Particle picking terminated!');
                guidata(source,handles);
                uiresume;
            end
            
            function bZinout_Callback(source,eventdata) 
                axes('Parent',panImg,'Units','normal','Position',[0 0 1 1],'Visible','off');
                imshow(obj.hIm);
                zoom on;
                obj.hIm = getimage(gca);
                guidata(source,handles);
                uiresume;
            end       
            
            
            % function bpan_Callback(source,eventdata) 
            %    axes('Parent',panImg,'Visible','off');
            %    imshow(obj.hIm);
            %    pan on;
            %    obj.hIm = getimage(gca);
            %    guidata(source,handles);
            %    uiresume;
            % end               
            
            
            function bExtract_Callback(source,eventdata)
                particleFolder = [pwd,'/output/Particle_extraction/all_particles/*.mrc'];
                
                obj.ParprocessClass = parext(obj.ParprocessClass, obj, handles);
                addpath(genpath('output/Particle_extraction/'));
                set(handles.('sProg2'),'String','Particles extracted!');
                drawnow;   
                imds_par = imageDatastore(particleFolder,'FileExtensions','.mrc','ReadFcn',@vp.fm.ReadMRC);
                imds_par.ReadFcn = @(loc)double(padarray(vp.fm.rangeNorm(vp.fm.ReadMRC(loc)),[3 3],1));
                imds_par_mont = partition(imds_par,round(imds_par.numpartitions/25),1);
                par_mont = imds_par_mont.readall;
                par_mont2 = zeros([size(par_mont{1},1) size(par_mont{1},2) 1 25]);
                for i = 1:25
                    par_mont2(:,:,i) = par_mont{i};
                end
                
                axes('Parent',panImg2,'Units','normal','Position',[0 0 1 1]);
                mont = montage(par_mont2,'Size',[5 5]);
                set(handles.('sProg2'),'String','Writing the particle .STAR file...');
                drawnow;
                s = vp.fm.stack(obj);
                set(handles.('sProg2'),'String','Done.');
                drawnow;
                set(handles.('sProg2'),'String','');
                drawnow;
                uiresume;
            end    
            
            function bClassWindow_Callback(source,eventdata)
                set(handles.('sProg2'),'String','Waiting for input...');
                drawnow;
                obj.p = vp.fm.RelionSet_gui;
                obj.pU = gui(obj.p);
                set(handles.('sProg2'),'String','');
                drawnow;
                if obj.pU.stopset == 0;
                    set(handles.('sProg2'),'String','Writing submission script...');
                    drawnow;
                    relion2dscript(obj.pU, obj.module);
                    var = obj.pU;
                    save('2dsettings.mat','var','-v7.3');
                    
                    vp_NumberDatasets = obj.NumberDatasets;
                    vp_RawFolder = obj.RawFolder;
                    vp_data = obj.data;
                    vp_last_file = obj.last_file;
                    VPpar1 = obj.ParprocessClass.NumberFiles;
                    save('VisProt.mat','vp_NumberDatasets','vp_RawFolder','vp_data','vp_last_file','VPpar1','-v7.3');
                    
                    set(handles.('sProg2'),'String','');
                    drawnow;
                end
                uiresume;
            end  
            
            function bClassRun_Callback(source,eventdata)
                set(handles.('sProg2'),'String','Running 2D classification. Check status in terminal.');
                drawnow;   
                variable = load('2dsettings.mat');
                relion2dsubmit(variable.var);
                uiresume;
            end    
            
            function bClassDisplay_Callback(source,eventdata)
                set(handles.('sProg2'),'String','Displaying classes...');
                drawnow;   
                variable = load('2dsettings.mat');
                displayclasses(variable.var);
                set(handles.('sProg2'),'String','');
                drawnow; 
                uiresume;
            end            
            
            function bLibDisplay_Callback(source,eventdata)
                set(handles.('sProg2'),'String','Displaying libraries...');
                drawnow;   
                variable = load('2dsettings.mat');
                libdisp = str2double(strsplit(handles.('eLib').String,','))
                display2d(variable.var, libdisp);
                set(handles.('sProg2'),'String','');
                drawnow; 
                uiresume;
                delete('classDisplay.sh');
            end 
            
            set(con1,'Tag','0');
            set(con2,'Tag','0');
            function bButton_Callback(source,eventdata)
                variableVP = load('VisProt.mat');
                variableVP.vp_data = vp.fm.Data2d(variableVP.vp_NumberDatasets, variableVP.vp_RawFolder, variableVP.vp_last_file, variableVP.VPpar1);
                
                %if (con1.Tag=='0') && (con2.Tag=='0')
%                     set(con1,'Tag','1');
%                     set(con2,'Tag','1');
                %else
%                     delete(con1);
%                     delete(con2);
                    con1 = uiflowcontainer('v0',panImg3,'Units','Normalized','Position',[.0001 .001 .52 1]);
                    con2 = uiflowcontainer('v0',panImg3,'Units','Normalized','Position',[.47 .001 .52 1]);
%                     set(con1,'BackgroundColor',bgcolor);
%                     set(con2,'BackgroundColor',bgcolor);
                    set(con1,'Tag','1');
                    set(con2,'Tag','1');
                %end
                ax1 = axes('Parent',con1);
                ax2 = axes('Parent',con2);
                plotdata(variableVP.vp_data, variableVP.vp_RawFolder, variableVP.vp_NumberDatasets, ax1, ax2);               
                guidata(source,handles);
                uiresume;
            end             
            
            
            
        end
    end
end

