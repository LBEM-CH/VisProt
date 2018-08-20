classdef ParticleSelModSize
    properties
        min 
        max
        module
    end
    methods
        function obj = ParticleSelModSize
            obj.min = '20'; % Diameter/Dimension of smallest particle in pixels (Apoferritin: 40/Heatshock: 20-30)
            obj.max = '60'; % Diameter/Dimension of largest particle in pixels (TMV: 3500/ Heatshock: 55-60)
        end
        function obj = particle_size_gui(obj)
            
            prompt = {sprintf('Minimum diameter (px)\n(Apoferritin: 40/Heatshock: 20-30)'),sprintf('Maximum diameter (px)\n(TMV: 3500/ Heatshock: 55-60)')};
            f = figure('Visible','off');
            
            pan = uipanel(f,'Title','Particle picking settings',...
                         'TitlePosition', 'centertop',...
                         'Position',[.1 .15 .8 .8]);
            
            sizemintext = uicontrol(pan,'Style','text',...
                           'String',[prompt{1}],'Units','normalized','Position',[.03,.5,.6,.3]);
            sizemaxtext = uicontrol(pan,'Style','text',...
                           'String',[prompt{2}],'Units','normalized','Position',[.022,.35,.6,.3]);
                       
                       
            sizemined = uicontrol(pan,'Style','edit',...
                           'String',[obj.min],...
                           'Tag','e_sizemin',...
                           'Units','normalized','Position',[.7,.73,.16,.06],'Callback','@e_sizemin_Callback');           
            sizemaxed = uicontrol(pan,'Style','edit',...
                           'String',[obj.max],...
                           'Tag','e_sizemax',...
                           'Units','normalized','Position',[.7,.58,.16,.06],'Callback','@e_sizemax_Callback');                      
                       
            poptext  = uicontrol(pan,'Style','text','String','Select module','FontWeight','bold','Units','normalized','Position',[.15,.4,.3,.06]);          
            poped = uicontrol(pan,'Style','popupmenu','Units','normalized','Position',[.63,.42,.3,.06],...
                              'String',{'Negative stain','Cryo-EM'},'Tag','popup_menu');
            
%             align([sizemintext,sizemaxtext,sizemined,sizemaxed,poptext,poped],'Center','None');               
            
            % Initialize the GUI.
            % Assign the GUI a name to appear in the window title.
            set(f,'Name','Particle picking settings')
            % Move the GUI to the center of the screen.
            movegui(f,'center')
            % Make the GUI visible.
            set(f,'Visible','on');
            
            
            bOk = uicontrol(pan,'Style','pushbutton',...
                            'String','Ok','Units','normalized','Position',[.35,.1,.15,.1],...
                            'Callback',{@Ok_Callback});
            bCancel = uicontrol(pan,'Style','pushbutton',...
                            'String','Cancel','Units','normalized','Position',[.55,.1,.15,.1],...
                            'Callback',{@Cancel_Callback});            
            
            handles = guihandles;
            set(handles.('e_sizemin'),'String',obj.min);
            set(handles.('e_sizemax'),'String',obj.max);
            
            uiwait;
            
            % Callbacks   
            
            function Ok_Callback(source,eventdata) 
                handles.('e_sizemin').String;
                handles.('e_sizemax').String;
                contents = handles.('popup_menu').String;
                obj.('min') = str2double(handles.('e_sizemin').String);
                obj.('max') = str2double(handles.('e_sizemax').String);
                obj.('module') = contents{handles.('popup_menu').Value};
                guidata(source,handles);
                uiresume; 
                close;
            end 
            
            function Cancel_Callback(source,eventdata)
                close;
            end  

        end
    end
end



