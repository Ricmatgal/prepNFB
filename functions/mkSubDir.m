function mkSubDir(subID, projFolder)
    % link to gui where user can specify how many sessions, runs and ROIs 
    
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
    mkdir([projFolder, filesep, subID, filesep, 'Localizer', filesep,...
        'ROIs', filesep, 'Session_01', filesep, 'roiPrep', filesep, 'ROI_1']);
    mkdir([projFolder, filesep, subID, filesep, 'Localizer', filesep,...
        'ROIs', filesep, 'Session_01', filesep, 'roiPrep', filesep, 'ROI_2']);    
    mkdir([projFolder, filesep, subID, filesep, 'Localizer', filesep,...
        'ROIs', filesep, 'Session_01' filesep, 'ROI_1']);
    mkdir([projFolder, filesep, subID, filesep, 'Localizer', filesep,...
        'ROIs', filesep, 'Session_01', filesep, 'ROI_2']);
    mkdir([projFolder, filesep, subID, filesep, 'Localizer', filesep,...
        'ROIs', filesep, 'Session_02' filesep 'ROI_1']);
    mkdir([projFolder, filesep, subID, filesep, 'Localizer', filesep,...
        'ROIs', filesep, 'Session_02', filesep, 'ROI_2']);

    % struct dir 
%     mkdir([subRootPath, filesep, 'T1']);
    
    % make session 01 
    mkdir([subRootPath, filesep, 'Session_01', filesep, 'EPI_Template_D1']);
    mkdir([subRootPath, filesep, 'Session_01', filesep, 'NF_Data_1']);
    mkdir([subRootPath, filesep, 'Session_01', filesep, 'NF_Data_2']);
    mkdir([subRootPath, filesep, 'Session_01', filesep, 'NF_Data_3']);
    mkdir([subRootPath, filesep, 'Session_01', filesep, 'NF_Data_4']);
    mkdir([subRootPath, filesep, 'Session_01', filesep, 'NF_Data_5']);
    mkdir([subRootPath, filesep, 'Session_01', filesep, 'Settings']);
    mkdir([subRootPath, filesep, 'Session_01', filesep, 'T1']);
    mkdir([subRootPath, filesep, 'Session_01', filesep, 'RestingState']);
    
    % task folders
    mkdir([subRootPath, filesep, 'Session_01', filesep, 'TaskFolder', filesep 'stimParams']);
    mkdir([subRootPath, filesep, 'Session_01', filesep, 'TaskFolder', filesep 'taskResults']);
    
    % make session 02 
    mkdir([subRootPath, filesep, 'Session_02', filesep, 'EPI_Template_D1']);
    mkdir([subRootPath, filesep, 'Session_02', filesep, 'NF_Data_1']);
    mkdir([subRootPath, filesep, 'Session_02', filesep, 'NF_Data_2']);
    mkdir([subRootPath, filesep, 'Session_02', filesep, 'NF_Data_3']);
    mkdir([subRootPath, filesep, 'Session_02', filesep, 'NF_Data_4']);
    mkdir([subRootPath, filesep, 'Session_02', filesep, 'NF_Data_5']);
    mkdir([subRootPath, filesep, 'Session_02', filesep, 'Settings']);
    mkdir([subRootPath, filesep, 'Session_02', filesep, 'T1']);
    mkdir([subRootPath, filesep, 'Session_02', filesep, 'RestingState']);
     
    % task folders
    mkdir([subRootPath, filesep, 'Session_02', filesep, 'TaskFolder', filesep 'stimParams']);
    mkdir([subRootPath, filesep, 'Session_02', filesep, 'TaskFolder', filesep 'taskResults']);
    
    message = ['Project directories created for subject: ', subID];
    m_color = 1;
else 
    message = ['Project directories for subject: ', subID, ' already exist!'];
    m_color = 2;
end
    user_fb_update({message},1, m_color)
end

