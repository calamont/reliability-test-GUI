function cando_plot(type, handles, print)
    %% clear axes for new plot
    cla(handles.main_plot);
    cla(handles.small_impedance_plot);
    cla(handles.small_phase_plot);
   
    % plots graph on a new window which can then be saved as an image
    if print == 1
        hFig = figure(1);
    end
    
    %% change variables and plot preferences depending on the type of graph
    % chosen  
    
    freq = handles.freq;
    x_limits = [1E-2 1E4];
    
    days = handles.test_info(handles.batch,:);
    days(isnan(days)) = [];
    
    if (strcmp(type,'phase') == 1)
        
        data = handles.current_phase;
        
        y_label = 'Phase (°)';
        y_limits = [-160, 0];
        y_dir = 'reverse';
        y_scale = 'linear' ; 
        
    else
        
        data = handles.current_Z;
        
        y_label = 'Impedance (\Omega)';
        y_limits = [1E5 1E12];
        y_dir = 'normal';
        y_scale = 'log';
        
    end
    
    %% determine which dimension is varied. 
    % Dim 1: plots different samples in the same batch. 
    % Dim 2: plots changes in impedance/phase over time for a specific
    % sample & frequency
    % Dim 3: plots changes in impedance/phase for a specific sample as a
    % Bode plot
    
    dim = 1;
    linecol = winter(size(data,dim)+1);
    
    if (size(data,2) < size(data,3))  
        dim = 2;
        
    elseif (size(data,3) > size(data,1))      
        dim = 3;    
        linecol = parula(size(data,dim)+1);  % change colourmap to illustrate time change
        
    end
    
    %% Initialise axes depending on type of plot chosen
    
    graph_num = 1;
    
    if print == 0
        if (max(strcmp(type,{'impedance','phase'})) == 1)
            set(handles.main_plot,'visible','on')
            set(handles.small_impedance_plot,'visible','off')
            set(handles.small_phase_plot,'visible','off')
            axes(handles.main_plot);

        else
            set(handles.main_plot,'visible','off')
            set(handles.small_impedance_plot,'visible','on')
            set(handles.small_phase_plot,'visible','off')
            axes(handles.small_impedance_plot);

            graph_num = 2;
        end
    end
    
    %% Plot total number of graphs requested
    for i = 1:graph_num
        box on
        hold all
        
        % plot impedance/phase values for the specified frequency over the
        % course of the experiment
        if dim == 2
%             days = handles.test_info(handles.batch,:);
%             days(isnan(days)) = [];
            values = data(1,1,:);
            values = reshape(values,[1,size(values,3)]);
            plot(days , values ,'-','Color',[0.66 0.74 0.86], 'LineWidth',4);
            plot(days , values ,'o','MarkerSize',10,'MarkerFaceColor',[0.18 0.37 0.68],'MarkerEdgeColor',[0.18 0.37 0.68']);
            hold off
            
            xlim([0 (days(end)+30)])
            ylim(y_limits)
            xlabel('Days', 'FontSize', 16)
            ylabel(y_label, 'FontSize', 16)
            legend('off')
            set(gca, 'XScale', 'linear', 'YScale',y_scale,'YDir', y_dir,'linewidth', 2.0,'units','pixels',...
            'YGrid','on','YMinorGrid','off')
        
        else
            % Bode plot of impedance/phase values 
            for n = 1:size(data,dim)
                if dim == 1
                    plot(freq,data(n,:,1),'LineWidth',4,'Color',linecol(n,:));
                    legend('off')
                    %leg{n} = num2str(days(n));
                else 
                    plot(freq,data(1,:,n),'LineWidth',4,'Color',linecol(n,:));
                    if i == 1
                        leg{n} = num2str(days(n));
                        if graph_num == 2
                            font_size = 24-size(data,dim);
                        else
                            font_size = 16;
                        end
                        l = legend(leg,'Box','on','FontSize',font_size,'Color','w','EdgeColor','w');
                        v = get(l,'title');
                        set(v,'String','Days');
                    end
                end
                
            end
            hold off
            
            xlim(x_limits)
            ylim(y_limits)        
            xlabel('Frequency (Hz)', 'FontSize', 16)
            ylabel(y_label, 'FontSize', 16)       
            set(gca, 'XScale', 'log', 'YScale',y_scale,'YDir',y_dir,...
                'linewidth', 2.0,'units','pixels','YGrid','on','YMinorGrid','off')
        end
        
        % change axes and plot preferences if plotting both impedance and
        % phase
        if (strcmp(type,{'impedance+phase'}) == 1 && print == 0)
            set(handles.main_plot,'visible','off')
            set(handles.small_impedance_plot,'visible','on')
            set(handles.small_phase_plot,'visible','on')
            axes(handles.small_phase_plot);
            
            data = handles.current_phase;
        
            y_label = 'Phase (°)';
            y_limits = [-160, 0];
            y_dir = 'reverse';
            y_scale = 'linear' ;
      
        end
        
    end