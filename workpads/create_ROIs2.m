function create_ROIs(subID, projFolder)

    %% ROI creation: saving clusters, pruning, quality control and saving
    % To do: we still hve to check for NaNs, crosscheck to see if rois are not
    % accidentally overlapping and to see if the ROI files created are
    % correct (all ones and no half values) ultimitaly we also need to see if
    % it works with OpenNFT.

    % set paths 
    subjStructDir = [projFolder, filesep, subID, filesep, 'Session_01', filesep, 'T1', filesep];
    statsdir = [projFolder filesep subID filesep 'Localizer', filesep 'stats' filesep];
    roiPath = [projFolder, filesep, subID, filesep, 'Localizer', filesep, 'ROIs', filesep, 'Session_01'];
    roiSize = 50;
    
    spm_jobman('initcfg')
    spm('defaults','fmri')
    
    % Fmenu  = spm('CreateMenuWin','off');                 
    Finter = spm('CreateIntWin','off');           
    Fgraph = spm_figure('Create','Graphics','Graphics','off');
    set([Finter,Fgraph],'Visible','on');%Fmenu,

    % load SPM.mat 
    load([statsdir, filesep, 'SPM.mat']);
    assignin('base', 'SPM', SPM);

    % open spm results gui so user can save the clusters of
    % Instruct user what to so
    fprintf('Select the contrasts and save respective clusters as binary ROI using the spm interface\n')
    % call spm function to create the  the roi images
    evalin('base', '[hReg, xSPM, SPM] = spm_results_ui("Setup",[SPM]);')
    
    % wait until process is finished, ask user to press ente to continue
    prompt1 = 'Press enter to continue';
    contvar=input(prompt1, 's');
    
    % top voxel selection
    % load both ROIs from stats folder where they will be automatically saved
    ROI1_fp = spm_select('FPList', statsdir, 'rFFA.nii');
    ROI2_fp = spm_select('FPList', statsdir, 'rOFA.nii');
%     ROI1_fp = spm_select();
%     ROI2_fp = spm_select();

    % Read hdrs into workspace
    hdr_ROI_1 = spm_vol(ROI1_fp);
    hdr_ROI_2 = spm_vol(ROI2_fp);

    % read the actual volumes and create empty brain matrix for each
    ROI1 = spm_read_vols(hdr_ROI_1); ROI1_new = zeros(size(ROI1));
    ROI2 = spm_read_vols(hdr_ROI_2); ROI2_new = zeros(size(ROI2));

    % count nr voxels in clusters
    voxId_ROI1 = find(ROI1 == 1);
    voxId_ROI2 = find(ROI2 == 1);
    
    % report the cluster size to subjec
    fprintf(['\nFFA cluster has: ', num2str(numel(voxId_ROI1)), ' voxels']);
    fprintf(['\nOFA cluster has: ', num2str(numel(voxId_ROI2)), ' voxels']);
    
    % load the respective T maps
    tMap_ROI1 = spm_read_vols(spm_vol([statsdir, filesep, 'spmT_0001.nii']));
    tMap_ROI2 = spm_read_vols(spm_vol([statsdir, filesep, 'spmT_0002.nii']));

    %if both rois have a voxel count higher than minimum:
    if numel(voxId_ROI1)>roiSize && numel(voxId_ROI2)>roiSize
        fprintf(['\nBoth ROIs voxel count supersedes the max of: ', num2str(roiSize), ', we will trim both']);
        % extract X nr of top voxels 
        tVal_con1 = tMap_ROI1(voxId_ROI1);
        tVal_con2 = tMap_ROI2(voxId_ROI2);

        % sort t values with highest on top
        [val1, pos1] = sort(tVal_con1, 'descend');
        [val2, pos2] = sort(tVal_con2, 'descend');

        % and take top roiSize ids to find real voxel ids within brain matrix
        topVox_ROI1 = voxId_ROI1(pos1(1:roiSize));
        topVox_ROI2 = voxId_ROI2(pos2(1:roiSize));

    else
        % equate both ROIs in terms of max voxel of smallest cluster
        if numel(voxId_ROI1)>numel(voxId_ROI2)
            fprintf('\nFFA cluster is bigger than OFA cluster, we will equate FFA to match OFA size');
            
            tVal_con1 = tMap_ROI1(voxId_ROI1);
            [val1, pos1] = sort(tVal_con1, 'descend');

            topVox_ROI1 = voxId_ROI1(pos1(1:numel(voxId_ROI2)));
            topVox_ROI2 = voxId_ROI2; % we leave the other roi untouched

        elseif numel(voxId_ROI2)>numel(voxId_ROI1)
            fprintf('\nOFA cluster is bigger than FFA cluster, we will equate OFA to match FFA size');
            
            tVal_con2 = tMap_ROI2(voxId_ROI2);
            [val2, pos2] = sort(tVal_con2, 'descend');

            topVox_ROI2 = voxId_ROI2(pos2(1:numel(voxId_ROI1)));
            topVox_ROI1 = voxId_ROI1;

        end    
    end
   % save into new brain matrix and save as .nii into ROI folders.
    ROI1_new(topVox_ROI1) = 1;
    ROI2_new(topVox_ROI2) = 1;
    fprintf('\n\nfinal ROI size:')
    fprintf(['\nFFA: ', num2str(numel(topVox_ROI1))])
    fprintf(['\nOFA: ', num2str(numel(topVox_ROI2)), '\n'])

    % change header names for saving
    hdr_ROI_1.fname = [roiPath, filesep, 'ROI_1', filesep, 'rFFA_a.nii'];
    hdr_ROI_2.fname = [roiPath, filesep, 'ROI_2', filesep, 'rOFA_a.nii'];

    % write the new volumes into the ROI folders
    spm_write_vol(hdr_ROI_1, ROI1_new);
    spm_write_vol(hdr_ROI_2, ROI2_new);
    
    % quality check roi superimposed on native T1
    % retrieve t1 name for current sub
    s = spm_select('FPList', subjStructDir, ['^s' '.*192-01.nii$']);
    % this will open only the structural with blobs
    my_spm_check_registration(s,[hdr_ROI_1.fname;hdr_ROI_2.fname],{});  
    
    % this will open the results gui show structurual and blobs but also
    % all the other info: header cross hair position etc.
%     spm_image('Display',s);
%     my_spm_image('addblobs',[hdr_ROI_1.fname;hdr_ROI_2.fname]);
    
end