classdef Constructor
    properties
        o
        i
        particle_diameter
        angpix
        iter
        tau2_fudge
        K
        maskopt
        zero_masking
        oversampling
        psi_step
        offset_range
        offset_step
        standNorm
        scaling
        normal
        accel
        pool
        scratch_dir
        MPIs
        j
        rank
        gpu
        memory_per_thread
        queue
        stopset
    end
    methods 
        function obj = Constructor
            obj.o = 'Class2D/run1';
            obj.i = 'stack.star';
            obj.particle_diameter = 220;
            obj.angpix = 2.6; 
            obj.iter = 20;
            obj.tau2_fudge = 2;
            obj.K = 150;
            obj.maskopt = 'flatten_solvent';
            obj.zero_masking = 'zero_mask';
            obj.oversampling = 1;
            obj.psi_step = 5;
            obj.offset_range = 5;
            obj.offset_step = 1;
            obj.standNorm = 'norm';
            obj.scaling = 'scale';
            obj.normal = 'dont_check_norm';
            obj.accel = 'gpu ""';
            obj.pool = 3;
            obj.scratch_dir = '/scratch/';
            obj.MPIs = 1;
            obj.j = 3;
            obj.rank = 9;
            obj.gpu = 4;            
            obj.memory_per_thread = 18;
            obj.queue = 'titanx';
            obj.stopset = 0;
        end
        function objU = gui(obj)
          
            promptAdv = {'Output:','Input:','Mask diameter (A):','Pixel size (A):','Iterations:',...
                         'Classes:','MPIs:','threads:','rank:','GPUs:','RAM:','Queue:'};   
            propertyListAdv = {'o','i','particle_diameter','angpix','iter','K','MPIs','j','rank','gpu','memory_per_thread','queue'};
            
            promptDef = {'Regularization (tau):','Mask opt.:','Mask with zeros:','Oversampling:','Angular step:',...
                         'Offset range:','Offset step:','Norm standard:','Scaling:','Normalization:','GPU acceleration:','Pooled particles:','Scratch directory:'};   
            propertyListDef = {'tau2_fudge','maskopt','zero_masking','oversampling','psi_step','offset_range','offset_step','standNorm','scaling','normal','accel','pool','scratch_dir'};
           
            maxlength = max(length(propertyListAdv),length(propertyListDef));
            
            % Scale figure
            fs = 100;
            for indexAdv = 1:maxlength
                f = figure('Visible','off','Position',[360,500,850,fs]);
                fs = fs+150;                
            end
            % Scale panels
            for indexAdv = 1:maxlength
                panAdv = uipanel(f,'Title','Advanced parameters',...
                                 'TitlePosition', 'centertop',...
                                 'Position',[.52 .1 .4 .85]);
            end
            for indexDef = 1:maxlength
                panDef = uipanel(f,'Title','Default parameters',...
                                 'TitlePosition', 'centertop',...
                                 'Position',[.10 .1 .4 .85]);
            end
            
            panBtn = uipanel(f,'Position',[.415 .015 .2 .07]);
            
            % Place elements in panels
            b = .45;
            for indexAdv = 1:length(propertyListAdv)          
                sAdv{indexAdv} = uicontrol(panAdv,'Style','text',...
                                           'String',[promptAdv{indexAdv}],...
                                           'Units','normalized',...
                                           'Position',[.1 b .3 .5]);
                b = b-0.08;
            end
            
            b = 0.91;
            for indexAdv = 1:length(propertyListAdv)
                eAdv{indexAdv} = uicontrol(panAdv,'Style','edit',...
                                           'String',[obj.(propertyListAdv{indexAdv})],...
                                           'Units','normalized',...
                                           'Position',[.1+0.4 b .35 .05],...
                                           'Tag',['eAdv_',num2str(indexAdv)],...
                                           'Callback',['@eAdv_',num2str(indexAdv),'_Callback']);
                b = b-0.08;                
            end
 
            b = .45;
            for indexDef = 1:length(propertyListDef)
                sDef{indexDef} = uicontrol(panDef,'Style','text',...
                                           'String',[promptDef{indexDef}],...
                                           'Units','normalized',...
                                           'Position',[.1 b .3 .5]);
                b=b-0.08;
            end               

            b = 0.91;
            for indexDef = 1:length(propertyListDef)
                eDef{indexDef} = uicontrol(panDef,'Style','edit',...
                                           'String',[obj.(propertyListDef{indexDef})],...
                                           'Units','normalized',...
                                           'Position',[.1+0.4 b .35 .05],...
                                           'Tag',['eDef_',num2str(indexDef)],...
                                           'Callback',['@eDef_',num2str(indexDef),'_Callback']);
                b = b-0.08;                
            end                         

            % Initialize the GUI.
            %     % Change units to normalized so components resize automatically.
            %     set([f,sOutput,eOutput,sInput,eInput,bOk],'Units','normalized');
            % Assign the GUI a name to appear in the window title.
            set(f,'Name','Test_GUI')
            % Move the GUI to the center of the screen.
            movegui(f,'center')
            % Make the GUI visible.
            set(f,'Visible','on');
            objU = obj;

            % Without button panel
            % bOk = uicontrol(f,'Style','pushbutton',...
            %                'String','Ok',...
            %                'Units','normalized',...
            %                'Position',[.42,.04,.08,.05],... %
            %                [.47,.04,.08,.05]: Centered
            %                'Callback',{@Ok_Callback});
            % bCancel = uicontrol(f,'Style','pushbutton',...
            %                'String','Cancel',...
            %                'Units','normalized',...
            %                'Position',[.52,.04,.08,.05],...
            %                'Callback',{@Cancel_Callback});
            
            % With button panel
            bOk = uicontrol(panBtn,'Style','pushbutton',...
                            'String','Ok',...
                            'Units','normalized',...
                            'Position',[.06,.15,.4,.7],... % [.47,.04,.08,.05] without the cancel button
                            'Callback',{@Ok_Callback});
            bCancel = uicontrol(panBtn,'Style','pushbutton',...
                            'String','Cancel',...
                            'Units','normalized',...
                            'Position',[.52,.15,.4,.7],...
                            'Callback',{@Cancel_Callback});

                        
             handles = guihandles;
             for indexAdv = 1:length(propertyListAdv)
                 set(handles.(['eAdv_',num2str(indexAdv)]),'String',obj.(propertyListAdv{indexAdv}));
             end
         
            uiwait;

            % Callbacks
            %             function eAdv_1_Callback(source,eventdata,handles)
            %                get(handles.eAdv_1,'String');
            %             end

            function Ok_Callback(source,eventdata) 
                for indexAdv = 1:length(propertyListAdv)
                    get(handles.(['eAdv_',num2str(indexAdv)]),'String');
                    objU.(propertyListAdv{indexAdv}) = str2double(handles.(['eAdv_',num2str(indexAdv)]).String);
                    if isnan(objU.(propertyListAdv{indexAdv}));
                        objU.(propertyListAdv{indexAdv}) = handles.(['eAdv_',num2str(indexAdv)]).String;
                    end
                end
                for indexDef = 1:length(propertyListDef)
                    objU.(propertyListDef{indexDef}) = obj.(propertyListDef{indexDef});
                end
                guidata(source,handles);
                uiresume; 
                close;
            end
            
            function Cancel_Callback(source,eventdata)
                objU.stopset = 1;
                close;
            end           
            
        end
    end   
end