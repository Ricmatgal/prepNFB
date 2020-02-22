function [] = user_fb_update(message, main_module_flag)
    user_fb = evalin('base','user_fb');
    
%     t = datestr(datetime);
%     t = t(end-7:end-3);
 
    message_a = {};
    for ii = 1:size(message,1)
        if isempty(message{ii}) || ii > 1
            t = '';
        else
            t = datestr(datetime);
            t = [t(end-7:end-3) ' '];
        end
        
        message_a = [message_a; t message{ii}];
        
%         fprintf(['\n' message{ii}])
        fprintf('%s\n', message{ii})
    end
    
    if main_module_flag == 0
        user_fb = [user_fb; message_a; '  ']; 
    elseif main_module_flag == 1
        user_fb = [user_fb; '---------------------------------'; '  '; message_a; '  '];
    end
    
    handles.lb_feedback_window=findall(0,'tag','fb_window');
    set(handles.lb_feedback_window, 'String', user_fb);
    assignin('base', 'user_fb', user_fb);
    
    
end

