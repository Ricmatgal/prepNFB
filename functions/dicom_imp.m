function [imported_flag] = dicom_imp(sequence, subID, watchFolder, projFolder, imSer, f_flag, s_flag, Sess, expNrIms)

volumes2skip = 10;
imported_flag = 1;

if s_flag
    if strcmp(sequence, 'struct') == 1
        expDir    = [projFolder, filesep, subID, filesep, Sess, filesep, 'T1'];
        if numel(dir(expDir))> 2 % skip 2 for two dots..
            a = dir(expDir);
            filenames = {a.name};
            
            user_fb_update({'T1 folder should be but is NOT empty!';'';'Files found:';...
                {filenames{3:end}};'';['Dir: ' expDir];'';'Import aborted'},0,3);
            
            % open windows explorer for user to inspect folder contents
            winopen(expDir);
            
            imported_flag = 0;
            return
        end
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
        
        ffn = spm_select('List',watchFolder,['001_0000' imSer '_^*.']);
        user_fb_update({'Importing Filenames:'; ffn(1,:);ffn(2,:);ffn(3,:);'.';'.';ffn(end-1,:);ffn(end,:)},0,1)        

        spm_jobman('run', matlabbatch);
        user_fb_update({'Dicom import completed'}, 0, 4)
        clear matlabbatch
        
        % copy past structural to session 2 as well
%         copyfile(spm_select('FPList', expDir, ['^s' '.*192-01.nii$']),...
%             [expDir2, filesep, spm_select('List', expDir, ['^s' '.*192-01.nii$'])]);
        
        % set origin
        spm_image('Display', spm_select('FPList', [expDir, filesep], ['^s' '.*192-01.nii$']));
    elseif isempty(s1)
        user_fb_update({'Import: No structural images found'; 'check watchfolder/dicom nr!'},0, 3)
        imported_flag = 0;
        return
    elseif size(s1,1) ~= 192
         user_fb_update({'Import: Not enough images found'; 'check watchfolder/dicom nr!'},0, 3)
         imported_flag = 0;
        return
    end
    
end

if f_flag
    
    if strcmp(sequence, 'Localizer') == 1
        expDir    = [projFolder, filesep, subID, filesep, 'Localizer', filesep, 'func'];
        if numel(dir(expDir)) > 2
            a = dir(expDir);
            filenames = {a.name};
            
            user_fb_update({'Func folder should be but is NOT empty!';'';'Files found:';...
                {filenames{3:end}};'';['Dir: ' expDir];'';'Import aborted'},0,3);
            
            % open windows explorer for user to inspect folder contents
            winopen(expDir);
            
            imported_flag = 0;
            
            return
        end
        f1   = spm_select('FPList',watchFolder,['001_0000' imSer '_^*.']);
        
    elseif strcmp(sequence, 'RestingState') == 1
        expDir    = [projFolder, filesep, subID, filesep, Sess, filesep, 'RestingState'];
        if numel(dir(expDir)) > 2
            a = dir(expDir);
            filenames = {a.name};
            
            user_fb_update({'Func folder should be but is NOT empty!';'';'Files found:';...
                {filenames{3:end}};'';['Dir: ' expDir];'';'Import aborted'},0,3);
            
            % open windows explorer for user to inspect folder contents
            winopen(expDir);
            
            imported_flag = 0;            
            
            return
        end
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
        
        ffn = spm_select('List',watchFolder,['001_0000' imSer '_^*.']);
        
        user_fb_update({'Importing Filenames:'; ffn(1,:);ffn(2,:);ffn(3,:);'.';'.';ffn(end-1,:);ffn(end,:)},0,1)        

        
        spm_jobman('run', matlabbatch);
        user_fb_update({'Dicom import completed'}, 0, 4)
        clear matlabbatch
        
     elseif isempty(f1)
         user_fb_update({'Import: No functional images found'; 'check watchfolder/dicom nr!'},0,3)      
         imported_flag = 0;         
     elseif size(f1,1) ~= expNrIms
         user_fb_update({'Import: Not enough images found'; 'check watchfolder/dicom nr!'},0,3)
         imported_flag = 0;
     end

end

end
