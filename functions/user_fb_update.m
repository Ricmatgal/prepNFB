function [] = user_fb_update(message, main_module_flag,color_flag)
    user_fb = evalin('base','user_fb'); % for html 
    
    if color_flag == 1
        color = [255 255 255];   % white
    elseif color_flag == 2
        color = [255 140 0];    % orange
    elseif color_flag == 3
        color = [255 0 0];      % red
    end
    
    pre = '<HTML><FONT color="';
    post = '</FONT></HTML>';
    
    message_a = {}; % for the html 
    for ii = 1:size(message,1)
        if isempty(message{ii}) || ii > 1
            t = '';
        else
            t = datestr(datetime);
            t = [t(end-7:end-3) ' '];
        end
        tmp = [pre rgb2Hex(color) '">' t message{ii} post];
        message_a = [message_a; tmp];
        
        fprintf('%s\n', message{ii})
    end
    
    if main_module_flag == 0
        user_fb = [user_fb; message_a; '  ']; 
    elseif main_module_flag == 1
        user_fb = [user_fb; '---------------------------------'; '  '; message_a; '  '];
    end
    
%     user_fb = [user_fb; '>>'];
    
    handles.lb_feedback_window=findall(0,'tag','fb_window');
    set(handles.lb_feedback_window, 'String', user_fb);
    
    set(handles.lb_feedback_window,'ListboxTop',size(get(handles.lb_feedback_window,'String'),1))
    set(handles.lb_feedback_window,'Value', size(get(handles.lb_feedback_window,'String'),1))
%     set(handles.lb_feedback_window,'Value', [])
    
    assignin('base', 'user_fb', user_fb);
    
    
end
