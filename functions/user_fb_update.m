function [] = user_fb_update(message)
    user_fb = evalin('base','user_fb');
    
    t = datestr(datetime);
    t = t(end-7:end-3);
 
    message_a = {};
    for ii = 1:size(message,1)
        message_a = [message_a; t ' ' message{ii}];
        
        fprintf(['\n' message{ii}])
    end
    user_fb = [user_fb; message_a; '  '];
    
    handles.lb_feedback_window=findall(0,'tag','fb_window');
    set(handles.lb_feedback_window, 'String', user_fb);
    assignin('base', 'user_fb', user_fb);
    
    
end

