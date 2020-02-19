function coreg_ROIs(subinfo, coreg)
    % to do:
    % - perform checks and touch ups: check for NaNs, etc
    
    % - two ways of session to session coregistration are impleneted here,
    %   based on structural templates and one based on EPI templates.
    % MR images extention
    rawFormat   = 'nii'; 

     % initiate spm windows for result display and process monitoring
    spm_jobman('initcfg')
    % Fmenu  = spm('CreateMenuWin','off');                 
    Finter = spm('CreateIntWin','off');           
    Fgraph = spm_figure('Create','Graphics','Graphics','off');
    set([Finter,Fgraph],'Visible','on');
    
    if coreg.struct_flag == 1
        % copy original first session MC template and corresponding ROIs to
        % current session location. We do this so the originals in session one
        % remain untouched.
        % copy EPI template: new name is 'EPI_template_sess_01.nii'
        current_sess_templ_folder = [subinfo.projFolder, filesep, subinfo.subID, filesep, 'Session_0' num2str(subinfo.session),...
            filesep, 'T1'];
        current_sess_mc_templ_folder =  [subinfo.projFolder, filesep, subinfo.subID, filesep, 'Session_0' num2str(subinfo.session),...
            filesep, 'EPI_Template_D1'];

        copyfile(coreg.sourcePath, [current_sess_templ_folder, filesep, 'struct_template_sess_01.nii']);
        % copy ROIs
        for ii = 1:size(coreg.ROIs,1)
            copyfile(char(coreg.ROIs(ii)),[current_sess_templ_folder, filesep, coreg.ROInfo.Session(1).ROI(ii).name]);
        end

        % define reference and source 
        matlabbatch{1}.spm.spatial.coreg.estimate.ref = {coreg.refPath};
        matlabbatch{1}.spm.spatial.coreg.estimate.source = {[current_sess_templ_folder, filesep, 'struct_template_sess_01.nii']};

        for ii = 1:size(coreg.ROIs,1)
            matlabbatch{1}.spm.spatial.coreg.estimate.other{ii,1} = [current_sess_templ_folder, filesep, coreg.ROInfo.Session(1).ROI(ii).name];
        end
%         matlabbatch{1}.spm.spatial.coreg.estimate.other{ii+1,1} = spm_select('FPList', [current_sess_mc_templ_folder, filesep],  '.*\.nii');
        
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'ncc'; % ncc for within modality coregistration
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
     
        % save the batch, run it and clear it
        save([subinfo.projFolder, filesep, subinfo.subID, filesep, 'Localizer',...
            filesep, 'ROIs', filesep, 'coregROIs_D2'], 'matlabbatch')
        spm_jobman('run', matlabbatch);
        clear matlabbatch

        % move new rois to their respective locations where openNFBT will
        % expect them --> ini
        % make session move nr dynamic!!
        for ii = 1:size(coreg.ROIs,1)
            tmp=dir(char(coreg.ROIs(ii)));
    %         tmpFolder2get = tmp.folder;

            tmpFolder2get = current_sess_templ_folder;

            tmpFolder2go = [subinfo.projFolder, filesep, subinfo.subID, filesep, 'Localizer',...
                filesep, 'ROIs', filesep, 'Session_02', filesep, 'ROI_' tmp.folder(end), filesep];
            % tmp.folder(end) to get the ROI nr might not be the best/safest practsise -->
            % reconsider

    %         movefile([spm_select('FPList',  tmpFolder2get, ['^sess2_' '.*\.' rawFormat '$'])], tmpFolder2go);
            movefile([spm_select('FPList',  tmpFolder2get, [coreg.ROInfo.Session(1).ROI(ii).name])], tmpFolder2go);
        end

        % delete remaining files that were created in the process to keep a
        % clean folder
        delete([current_sess_templ_folder, filesep, 'struct_template_sess_01.nii']);
 
    
    elseif coreg.epi_flag == 1
        % copy original first session MC template and corresponding ROIs to
        % current session location. We do this so the originals in session one
        % remain untouched.
        % copy EPI template: new name is 'EPI_template_sess_01.nii'
        current_sess_templ_folder = [subinfo.projFolder, filesep, subinfo.subID, filesep, 'Session_0' num2str(subinfo.session),...
            filesep, 'EPI_Template_D1'];

        copyfile(coreg.sourcePath, [current_sess_templ_folder, filesep, 'EPI_template_sess_01.nii']);
        % copy ROIs
        for ii = 1:size(coreg.ROIs,1)
            copyfile(char(coreg.ROIs(ii)),[current_sess_templ_folder, filesep, coreg.ROInfo.Session(1).ROI(ii).name]);
        end

        % define reference and source 
        matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {coreg.refPath};
        matlabbatch{1}.spm.spatial.coreg.estwrite.source = {[current_sess_templ_folder, filesep, 'EPI_template_sess_01.nii']};

        for ii = 1:size(coreg.ROIs,1)
            matlabbatch{1}.spm.spatial.coreg.estwrite.other{ii,1} = [current_sess_templ_folder, filesep, coreg.ROInfo.Session(1).ROI(ii).name];
        end
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'ncc'; % ncc for within modality coregistration
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'sess2_';

        % save the batch, run it and clear it
        save([subinfo.projFolder, filesep, subinfo.subID, filesep, 'Localizer',...
            filesep, 'ROIs', filesep, 'coregROIs_D2'], 'matlabbatch')
        spm_jobman('run', matlabbatch);
        clear matlabbatch

        % move new rois to their respective locations where openNFBT will
        % expect them --> ini

        % make session move nr dynamic!!
        for ii = 1:size(coreg.ROIs,1)
            tmp=dir(char(coreg.ROIs(ii)));
    %         tmpFolder2get = tmp.folder;

            tmpFolder2get = current_sess_templ_folder;

            tmpFolder2go = [subinfo.projFolder, filesep, subinfo.subID, filesep, 'Localizer',...
                filesep, 'ROIs', filesep, 'Session_02', filesep, 'ROI_' tmp.folder(end), filesep];
            % tmp.folder(end) to get the ROI nr might not be the best/safest practsise -->
            % reconsider

    %         movefile([spm_select('FPList',  tmpFolder2get, ['^sess2_' '.*\.' rawFormat '$'])], tmpFolder2go);
            movefile([spm_select('FPList',  tmpFolder2get, ['^sess2_' coreg.ROInfo.Session(1).ROI(ii).name])], tmpFolder2go);
        end

        % delete remaining files that were created in the process to keep a
        % clean folder
        delete([current_sess_templ_folder, filesep, 'EPI_template_sess_01.nii']);
        delete([current_sess_templ_folder, filesep, 'sess2_EPI_template_sess_01.nii']);
        for ii = 1:size(coreg.ROIs,1)
            delete([current_sess_templ_folder, filesep, coreg.ROInfo.Session(1).ROI(ii).name])
        end

        if coreg.sflag == 1

            subjStruct = coreg.structs{subinfo.session};

            % define reference (new EPI template) and source (to be coregistered struct) 
            matlabbatch{1}.spm.spatial.coreg.estimate.ref       = {coreg.refPath};
            matlabbatch{1}.spm.spatial.coreg.estimate.source    = {subjStruct};
            matlabbatch{1}.spm.spatial.coreg.estimate.other     = {''};
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi'; % nmi for between modality coregistration
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

            spm_jobman('run', matlabbatch);
            clear matlabbatch 

        end
    end
    % report back to user
    fprintf('\nCoregistration of ROIs/Structural to current head position: DONE\n')

end

