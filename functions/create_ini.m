function create_ini(subID, watchFolder, projFolder, Sess)
    
    % set some paths
    roiPath     = [projFolder, filesep, subID, filesep, 'Localizer', filesep, 'ROIs', filesep, Sess];
    epiPath     = [projFolder, filesep, subID, filesep, Sess, filesep, 'EPI_Template_D1'];
    
    % select mean image and get full path
    mean_image  = spm_select('FPList', epiPath, ['^mean' '.*\.nii$']);
    
    workFolder  = [projFolder, filesep, subID, filesep, Sess];
    structPath  = [projFolder, filesep, subID, filesep, Sess, filesep, 'T1'];
    taskFolder  = [projFolder, filesep, subID, filesep, Sess, filesep, 'TaskFolder'];
    prtFolder   = [projFolder, filesep, 'config_templates', filesep, 'NF_PSC_ContTask.json'];
    
    % open template and write to new ini
    tmp_fid = fopen([projFolder, filesep, 'config_templates', filesep, 'NF_PSC_ContTask.ini'],'r+');
    tmp_fid_w = fopen([projFolder, filesep, subID, filesep, Sess, filesep, 'Settings', filesep,...
        'Subject_' subID '_' Sess '.ini'],'w');
    
    % replace sub specific fields in new ini
    opennft_ini_data = textscan(tmp_fid, '%s');
    opennft_ini_data = opennft_ini_data{1};
    opennft_ini_data{3}  = ['SubjectID=' subID];                                    % subID
    opennft_ini_data{4}  = ['WatchFolder=' strrep(watchFolder, '\', '\\')];         % WatchFolder
    opennft_ini_data{8}  = ['FirstFileNameTxt=001_{Image Series No:06}_{#:06}.dcm'];% Forst file name
    opennft_ini_data{17} = ['WorkFolder=' strrep(workFolder, '\', '\\')];           % Workfolder 
    opennft_ini_data{18} = ['StimulationProtocol=' strrep(prtFolder, '\', '\\')]; 
    opennft_ini_data{19} = ['RoiFilesFolder=' strrep(roiPath, '\', '\\')];          % ROI folder
    opennft_ini_data{23} = ['MCTempl=' strrep(mean_image, '\', '\\')];                 % EPI template
    opennft_ini_data{24} = ['AnatBgFolder=' strrep(structPath, '\', '\\')];         % Struct folder
    opennft_ini_data{25} = ['TaskFolder=' strrep(taskFolder, '\', '\\')];           % Task folder
    
    % optional, change ffa and ofa toggles. for now i prefer to indicitate
    % this in openNFT GUI
%     opennft_ini_data{29} = regexpr(opennft_ini_data{29}, ; % FFA
%     opennft_ini_data{30} = regexpr(opennft_ini_data{30}, ; % OFA
    
	% Write the new ini and close files
    fprintf(tmp_fid_w,'%s\n',opennft_ini_data{:});
    fclose(tmp_fid);
    fclose(tmp_fid_w);
    
    % report back to user
    fprintf(['\nini file created for subject ' subID ' in Settings folder. Please review before NFB!\n'])

end

