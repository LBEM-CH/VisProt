classdef Data2d
    properties 
        Datanorm
        Dataerrornorm
        Xname
        NumberSavedClasses
        Sel
        Datanorm_sel
        Dataerrornorm_sel
        Selected_Averages
    end
    methods
        function obj = Data2d(nbrDatasets, rawfolder, last_file, nbrFiles)
            % Get data
            [obj.Datanorm, obj.Dataerrornorm, obj.Xname, obj.NumberSavedClasses] = vp.fm.getdata(nbrDatasets, rawfolder, last_file, nbrFiles);  % PCA for selecting significant averages
            % PCA for selecting significant classes
            [obj.Sel, obj.Datanorm_sel, obj.Dataerrornorm_sel, obj.Selected_Averages] = vp.fm.pcasel(obj.Datanorm, obj.Dataerrornorm, obj.Xname);
        end
        function plotdata(obj, rawfolder, nbrDatasets, axis1, axis2)
            % Plot data
            a1 = axis1;
            bar(a1, obj.Datanorm,'stacked');
            set(a1,'xtick',[1:obj.NumberSavedClasses],'XLim',[0 obj.NumberSavedClasses+1],'xticklabel',obj.Xname,'FontSize', 6); legend(a1,{rawfolder.name});
            title(a1,'All classes');
            xlabel(a1,'Class ID', 'Fontsize', 8);
            ylabel(a1,'Norm. particles', 'Fontsize', 8);
            % Save file
            f1 = figure('Visible','off');
            bar(obj.Datanorm,'stacked');
            hold on;
            e = errorbar(cumsum((obj.Datanorm)')',obj.Dataerrornorm,'.k');
%             nbrClasses = size(obj.Datanorm, 1);
%             groupwidth = min(0.8, nbrDatasets/(nbrDatasets + 1.5));
%             for datasetID = 1:nbrDatasets
%                 errorbar(([1:nbrClasses]-(groupwidth/2)+(2*datasetID-1)*(groupwidth/(2*nbrDatasets))), obj.Datanorm(:,datasetID), obj.Dataerrornorm(:,datasetID), 'k', 'linestyle', 'none');
%             end           
            
            
            set(gca,'xtick',[1:obj.NumberSavedClasses],'XLim',[0 obj.NumberSavedClasses+1],'xticklabel',obj.Xname,'FontSize', 6); legend({rawfolder.name});
            title('All classes');
            xlabel('Class ID', 'Fontsize', 8);
            ylabel('Norm. particles', 'Fontsize', 8);
            savefig('BarPlot_norm.fig');
            print(f1, '-dpng', '-r300', 'BarPlot_norm.png');
            hold off;

            
            % Selected classes
            a2 = axis2;
            bar(a2, cell2mat(obj.Datanorm_sel),1);
            set(a2,'xtick',[1:length(obj.Datanorm(obj.Selected_Averages,:))],'xticklabel',obj.Sel,'FontSize', 6); legend(a2,{rawfolder.name});
            title(a2,'Significant classes');            
            xlabel(a2,'Class ID', 'Fontsize', 8);
            ylabel(a2,'Norm. particles', 'Fontsize', 8);
            % Save file
            f2 = figure('Visible','off');
            bar(cell2mat(obj.Datanorm_sel),1);
            hold on;
            
            nbrClasses = size(cell2mat(obj.Datanorm_sel), 1);
            % Calculating the width for each bar group (by Mathworks support)
            groupwidth = min(0.8, nbrDatasets/(nbrDatasets + 1.5));
            for datasetID = 1:nbrDatasets
                % Center of each bar
                errorbar(([1:nbrClasses]-(groupwidth/2)+(2*datasetID-1)*(groupwidth/(2*nbrDatasets))), cell2mat(obj.Datanorm_sel(:,datasetID)), cell2mat(obj.Dataerrornorm_sel(:,datasetID)), 'k', 'linestyle', 'none');
            end       
            set(gca,'xtick',[1:length(obj.Datanorm(obj.Selected_Averages,:))],'xticklabel',obj.Sel,'FontSize', 6); legend({rawfolder.name});
            title('Significant classes');            
            xlabel('Class ID', 'Fontsize', 8);
            ylabel('Norm. particles', 'Fontsize', 8);
            savefig('BarPlot_norm_sel.fig');
            print(f2, '-dpng', '-r300', 'BarPlot_norm_sel.png');
            hold off;
            
        end
    end
end
