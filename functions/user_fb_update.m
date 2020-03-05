function user_fb_update(message, main_module_flag,color_flag)
    user_fb = evalin('base','user_fb'); % for html 
    
    if color_flag == 1
        color = [255 255 255];  % white: normal notification
    elseif color_flag == 2
        color = [255 140 0];    % orange: changes made by user
    elseif color_flag == 3
        color = [255 0 0];      % red: error messages
    elseif color_flag == 4
        color = [34 139 34];      % green: completion messages
    end
    
    pre = '<HTML><FONT color="';
    post = '</FONT></HTML>';
    
    % unpack message and color code each line if multiple
    message_a = {}; 
    % for each line
    for ii = 1:size(message,1)
        % if the current line is a cell
        if iscell(message{ii})
            % we loop over those cell elements first (when printing steps
            % of preprocessing for instance..
            for jj = 1:size(message{ii},2)
                tmp = [pre rgb2Hex(color) '">' '-' message{ii}{1,jj} post];
                message_a = [message_a; tmp];
                fprintf('%s\n', message{ii}{1,jj})
            end
        % Otherwiese we just color code this cell element
        else
            tmp = [pre rgb2Hex(color) '">' message{ii} post];
%             tmp = message{ii};
            message_a = [message_a; tmp];
            fprintf('%s\n', message{ii})
        end
    end
    
    % depending on the type of message we change the layout of the print
    t = datestr(datetime);
    t = [t(end-7:end-3) ' '];
    % if just a normal message 
    if main_module_flag == 0 && (color_flag == 1 || color_flag == 4)
        user_fb = [user_fb; message_a; '  ']; 
    % if error message
    elseif main_module_flag == 0 && color_flag == 2
        t = [pre rgb2Hex(color) '">' [t '!!!'] post];
        dashes = [pre rgb2Hex(color) '">' '----------------------------------------' post];
        
        user_fb = [user_fb; t; dashes ;message_a; dashes;'  '];
        
    % if error message
    elseif main_module_flag == 0 && color_flag == 3 
        t = [pre rgb2Hex(color) '">' [t 'ERROR'] post];
        dashes = [pre rgb2Hex(color) '">' '----------------------------------------' post];
        
        user_fb = [user_fb; t; dashes ;message_a; dashes;'  '];
    % if title message of a main action
    elseif main_module_flag == 1
        dashes = [pre rgb2Hex(color) '">' '----------------------------------------' post];
        
%         user_fb = [user_fb; t; dashes ;message_a; '  '];
        message_b = [pre rgb2Hex(color) '">' [t message_a{:}] post];
        user_fb = [user_fb; message_b; dashes;  '  '];
    end
    
    handles.lb_feedback_window=findall(0,'tag','fb_window');
    set(handles.lb_feedback_window, 'String', user_fb);
    
    set(handles.lb_feedback_window,'ListboxTop',size(get(handles.lb_feedback_window,'String'),1))
    set(handles.lb_feedback_window,'Value', size(get(handles.lb_feedback_window,'String'),1))
    
    % prevent queing
    drawnow()
    
    assignin('base', 'user_fb', user_fb);
end

