function mkSubDir(info)
    % link to gui where user can specify how many sessions, runs and ROIs 
    
    subID       = info.subID;
    projFolder  = info.projFolder;
    sessions    = info.session;  
    runs        = info.runs;       
    rois        = info.rois;       
    
if ~exist([projFolder, filesep, subID], 'dir')
    
    mkdir([projFolder, filesep, subID])
    
    % set sub root folder
    subRootPath = [projFolder, filesep, subID];
    
    % make localizer directories
    mkdir([subRootPath, filesep, 'Localizer']);
    mkdir([subRootPath, filesep, 'Localizer', filesep, 'func']);
    mkdir([subRootPath, filesep, 'Localizer', filesep, 'stats']);
    mkdir([subRootPath, filesep, 'Localizer', filesep, 'ROIs']);
    mkdir([subRootPath, filesep, 'Localizer', filesep, 'beh']);
    
    % EyeTracker file Directory
    mkdir([subRootPath, filesep, 'EyeTracker']); 
    
    % for specified nr of sessions
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
        
        curr_dir = pwd;
        copyfile([curr_dir filesep 'Settings' filesep 'ACC.nii'],[projFolder, filesep, subID, filesep, 'Localizer', filesep,...
                'ROIs', filesep, 'Session_' sess_str, filesep, 'ROI_' num2str(this_roi)]);

        % make specified nr of run folders within current_session
        for this_run = 1:str2double(runs)
            mkdir([subRootPath, filesep, 'Session_' sess_str, filesep, 'NF_Data_' num2str(this_run)]);
        end
        
        mkdir([subRootPath, filesep, 'Session_' sess_str, filesep, 'EPI_Template_D1']);
        mkdir([subRootPath, filesep, 'Session_' sess_str, filesep, 'Settings']);
        mkdir([subRootPath, filesep, 'Session_' sess_str, filesep, 'T1']);
        mkdir([subRootPath, filesep, 'Session_' sess_str, filesep, 'RestingState']);

        % task related folders
        mkdir([subRootPath, filesep, 'Session_' sess_str, filesep, 'TaskFolder', filesep 'stimParams']);
        mkdir([subRootPath, filesep, 'Session_' sess_str, filesep, 'TaskFolder', filesep 'taskResults']);
        mkdir([subRootPath, filesep, 'Session_' sess_str, filesep, 'TaskFolder', filesep, 'StimSets']);
        mkdir([subRootPath, filesep, 'Session_' sess_str, filesep, 'TaskFolder', filesep, 'StimSets', filesep, 'BaseSets']);
        mkdir([subRootPath, filesep, 'Session_' sess_str, filesep, 'TaskFolder', filesep, 'StimSets', filesep, 'BaseSets', filesep, 'Renderings']);
        mkdir([subRootPath, filesep, 'Session_' sess_str, filesep, 'TaskFolder', filesep, 'StimSets', filesep, 'BaseSets', filesep, 'Stimuli']);
        mkdir([subRootPath, filesep, 'Session_' sess_str, filesep, 'TaskFolder', filesep, 'StimSets', filesep, 'TaskStims']);

    end

%     % make config templates folder
%     mkdir([projFolder, filesep, 'config_templates'])

    % make double blind folder
    mkdir([projFolder, filesep, 'double_blind'])

    % make stimulus folder
    mkdir([projFolder, filesep, 'stimuli'])

    % make protocol folder
    mkdir([projFolder, filesep, 'protocols'])


    
    user_fb_update({['Project directories created for subject: ', subID]},1,1)
    user_fb_update({['Sessions: ' sessions];['Training Runs: ' runs];['ROIs: ' rois]},0, 1)
else   
    user_fb_update({['Project directories for subject: ', subID, ' already exist!']},0,2)
end


end

