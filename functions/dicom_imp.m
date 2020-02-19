function dicom_imp(sequence, subID, watchFolder, projFolder, imSer, f_flag, s_flag, Sess, expNrIms)

volumes2skip = 10;

if s_flag
    if strcmp(sequence, 'struct') == 1
        expDir    = [projFolder, filesep, subID, filesep, Sess, filesep, 'T1'];
    end
    
    s1   = spm_select('FPList',watchFolder,['001_0000' imSer '_^*.']);
   
    if ~isempty(s1) && size(s1,1) == expNrIms    
        spm_jobman('initcfg')
        
        matlabbatch{1}.spm.util.import.dicom.data = cellstr(s1);
        matlabbatch{1}.spm.util.import.dicom.root = 'flat';
        matlabbatch{1}.spm.util.import.dicom.outdir = {expDir};
        matlabbatch{1}.spm.util.import.dicom.protfilter = '.*';
        matlabbatch{1}.spm.util.import.dicom.convopts.format = 'nii';
        matlabbatch{1}.spm.util.import.dicom.convopts.icedims = 0;

        fprintf(['\nDicom2nii: importing structural for subject: ' subID '...\n'])
        spm_jobman('run', matlabbatch);
        clear matlabbatch
        
        % copy past structural to session 2 as well
%         copyfile(spm_select('FPList', expDir, ['^s' '.*192-01.nii$']),...
%             [expDir2, filesep, spm_select('List', expDir, ['^s' '.*192-01.nii$'])]);
        
        % set origin
        spm_image('Display', spm_select('FPList', [expDir, filesep], ['^s' '.*192-01.nii$']));
    elseif isempty(s1)
        fprintf('\nNo structural images found, check the watchfolder or dicom series number in GUI!\n')
        return
    elseif size(s1,1) ~= 192
        fprintf('\nNot enough images found, check the watchfolder or dicom series number in GUI!\n')
        return
    end
    
end

if f_flag
    
    if strcmp(sequence, 'Localizer') == 1
        expDir    = [projFolder, filesep, subID, filesep, 'Localizer', filesep, 'func'];
        f1   = spm_select('FPList',watchFolder,['001_0000' imSer '_^*.']);
    elseif strcmp(sequence, 'RestingState') == 1
        expDir    = [projFolder, filesep, subID, filesep, Sess, filesep, 'RestingState'];
        f1   = spm_select('FPList',watchFolder,['001_0000' imSer '_^*.']);
        if size(f1,1) >= (expNrIms + volumes2skip + 1)
            % skip first couple of volumes to take into account t1
            % saturation effects
            f1   = f1((volumes2skip + 1):(volumes2skip + expNrIms),:);  
        end
    end
    
     if ~isempty(f1) && size(f1,1) ==  expNrIms

        matlabbatch{1}.spm.util.import.dicom.data = cellstr(f1);
        matlabbatch{1}.spm.util.import.dicom.root = 'flat';
        matlabbatch{1}.spm.util.import.dicom.outdir = {expDir};
        matlabbatch{1}.spm.util.import.dicom.protfilter = '.*';
        matlabbatch{1}.spm.util.import.dicom.convopts.format = 'nii';
        matlabbatch{1}.spm.util.import.dicom.convopts.icedims = 0;
        
        spm_jobman('run', matlabbatch);
        clear matlabbatch
        
     elseif isempty(f1)
         fprintf('\nNo functional images found, check the watchfolder or dicom series number in GUI!\n')
     elseif size(f1,1) ~= expNrIms
        fprintf('\nNot enough images found, check the watchfolder or dicom series number in GUI!\n')
     end

end

end
