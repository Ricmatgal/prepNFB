function create_ini(subID, watchFolder, projFolder, prepNFBpath, Sess, sessNR, mriID)
    
    % set some paths
    roiPath     = [projFolder, filesep, subID, filesep, 'Localizer', filesep, 'ROIs', filesep, Sess, filesep 'ROI_1'];
    epiPath     = [projFolder, filesep, subID, filesep, Sess, filesep, 'EPI_Template_D1'];
    structPath  = [projFolder, filesep, subID, filesep, Sess, filesep, 'T1'];
    
    % select mean image AND struct to get full path
    mean_image  = spm_select('FPList', epiPath, ['^mean' '.*\.nii$']);
    struct_FP   = spm_select('FPList', structPath, ['^' '.*\.nii$']);
    
    workFolder  = [projFolder, filesep, subID, filesep, Sess];
    
    taskFolder  = [projFolder, filesep, subID, filesep, Sess, filesep, 'TaskFolder'];
%     prtFolder   = [projFolder, filesep, 'config_templates', filesep, 'protocol_last.json'];
%     prtFolder   = [projFolder, filesep, 'config_templates', filesep, 'psc', filesep, 'run1_long_bas.json'];
    prtFolder   = [projFolder, filesep, 'protocols'];
    prtFile = [prtFolder filesep 'prt_ORBIT_700.json'];
    stimFolder  = [projFolder, filesep, 'stimuli'];
    doubleBlindFolder = [projFolder, filesep, 'double_blind'];
    
    % open template and write to new ini
    %tmp_fid = fopen([projFolder, filesep, 'config_templates', filesep, 'NF_PSC_ContTask.ini'],'r+');
    tmp_fid = fopen([prepNFBpath, filesep, 'Settings', filesep, 'config_templates', filesep, 'NF_PSC_ContTask.ini'], 'r+');
    tmp_fid_w = fopen([projFolder, filesep, subID, filesep, Sess, filesep, 'Settings', filesep,...
        'Subject_' subID '_' Sess '.ini'],'w');
    
    % replace sub specific fields in new ini
    opennft_ini_data = textscan(tmp_fid, '%s');
    opennft_ini_data = opennft_ini_data{1};
    opennft_ini_data{3}  = ['SubjectID=' subID];                                    % subID
    opennft_ini_data{4}  = ['WatchFolder=' strrep(watchFolder, '\', '\\')];         % WatchFolder
    opennft_ini_data{8}  = ['FirstFileNameTxt=' mriID '_{Image Series No:06}_{#:06}.dcm'];% Forst file name
    opennft_ini_data{10} = ['nrOfVolumes=' int2str(510)];
    opennft_ini_data{11} = ['nrSkipVol=' int2str(1)];
    opennft_ini_data{13} = ['TR=' int2str(1000)];
    opennft_ini_data{14} = ['MatrixSizeX=' int2str(84)];
    opennft_ini_data{15} = ['MatrixSizeY=' int2str(84)];
    opennft_ini_data{16} = ['NrOfSlices=' int2str(51)];
    opennft_ini_data{17} = ['WorkFolder=' strrep(workFolder, '\', '\\')];           % Workfolder 
    opennft_ini_data{18} = ['StimulationProtocol=' strrep(prtFile, '\', '\\')]; 
    opennft_ini_data{19} = ['RoiFilesFolder=' strrep(roiPath, '\', '\\')];          % ROI folder
    opennft_ini_data{23} = ['MCTempl=' strrep(mean_image, '\', '\\')];                 % EPI template
    opennft_ini_data{24} = ['StructBgFile=' strrep(struct_FP, '\', '\\')];         % Struct folder
    opennft_ini_data{25} = ['TaskFolder=' strrep(taskFolder, '\', '\\')];           % Task folder
    opennft_ini_data{26} = ['StimFolder=' strrep(stimFolder, '\', '\\')];           % Task folder
    opennft_ini_data{49} = ['ProjectFolder=' strrep(projFolder, '\', '\\')];        % Project folder
    opennft_ini_data{50} = ['DoubleBlindDir=' strrep(doubleBlindFolder, '\', '\\')];    % Double blind folder
    opennft_ini_data{51} = ['SessionNumber=' strcat('0',sessNR)];    % Double blind folder

    % optional, change ffa and ofa toggles. for now i prefer to indicitate
    % this in openNFT GUI
%     opennft_ini_data{29} = regexpr(opennft_ini_data{29}, ; % FFA
%     opennft_ini_data{30} = regexpr(opennft_ini_data{30}, ; % OFA
    
	% Write the new ini and close files
    fprintf(tmp_fid_w,'%s\n',opennft_ini_data{:});
    fclose(tmp_fid);
    fclose(tmp_fid_w);
    
    % report back to user
    settings_dir = [projFolder, filesep, subID, filesep, Sess, filesep, 'Settings', filesep,...
        'Subject_' subID '_' Sess];
    user_fb_update({['.ini file created for subject ' subID]},1,1)
    user_fb_update({'See: '; settings_dir},0,1)
end

