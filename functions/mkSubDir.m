function mkSubDir(info)
    % link to gui where user can specify how many sessions, runs and ROIs 
    
    subID       = info.subID;
    projFolder  = info.projFolder;
    sessions    = info.session;  
    runs        = info.runs;       
    rois        = info.rois;       
    
if ~exist([projFolder, filesep, subID])
    
    mkdir([projFolder, filesep, subID])
    
    % set sub root folder
    subRootPath = [projFolder, filesep, subID];
    
    % make localizer directories
    mkdir([projFolder, filesep, subID, filesep, 'Localizer']);
    mkdir([projFolder, filesep, subID, filesep, 'Localizer', filesep, 'func']);
    mkdir([projFolder, filesep, subID, filesep, 'Localizer', filesep, 'stats']);
    mkdir([projFolder, filesep, subID, filesep, 'Localizer', filesep, 'ROIs']);
    mkdir([projFolder, filesep, subID, filesep, 'Localizer', filesep, 'beh']);
    
    % for speficfied nr of sessions
    for this_session = 1:str2double(sessions)
        
        % make session nr in str '01' '02' etc..
        sess_str = sprintf('%02d', this_session);
        
        % for specified nr of ROIs
        for this_roi = 1:str2double(rois)
            
            % make ROI dirs in roiPrep  
            mkdir([projFolder, filesep, subID, filesep, 'Localizer', filesep,...
                'ROIs', filesep, 'Session_' sess_str, filesep, 'roiPrep', filesep, 'ROI_' num2str(this_roi)]);
            
            % make final ROI dirs in session
            mkdir([projFolder, filesep, subID, filesep, 'Localizer', filesep,...
                'ROIs', filesep, 'Session_' sess_str, filesep, 'ROI_' num2str(this_roi)]);
            
        end

        % make specified nr of run folders within current_session
        for this_run = 1:str2double(runs)
            mkdir([subRootPath, filesep, 'Session_' sess_str, filesep, 'NF_Data_' num2str(this_run)]);
        end
        
        mkdir([subRootPath, filesep, 'Session_' sess_str, filesep, 'EPI_Template_D1']);
        mkdir([subRootPath, filesep, 'Session_' sess_str, filesep, 'Settings']);
        mkdir([subRootPath, filesep, 'Session_' sess_str, filesep, 'T1']);
        mkdir([subRootPath, filesep, 'Session_' sess_str, filesep, 'RestingState']);

        % task folders
        mkdir([subRootPath, filesep, 'Session_' sess_str, filesep, 'TaskFolder', filesep 'stimParams']);
        mkdir([subRootPath, filesep, 'Session_' sess_str, filesep, 'TaskFolder', filesep 'taskResults']);

    end
    
    user_fb_update({['Project directories created for subject: ', subID]},1,1)
    user_fb_update({['Sessions: ' sessions];['Training Runs: ' runs];['ROIs: ' rois]},0, 1)
else   
    user_fb_update({['Project directories for subject: ', subID, ' already exist!']},0,2)
end


end

