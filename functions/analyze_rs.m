function analyze_rs(subinfo)

subID       = subinfo.subID;
mriID       = subinfo.mriID;
watchFolder = subinfo.watchFolder;
projFolder  = subinfo.projFolder;
imSer       = subinfo.dcmSeries;
Sess        = subinfo.session;

rawFormat   = 'nii'; 
 
smoothK = [6 6 6];

% import funcitonal images, call funcion:
user_fb_update({['0) Importing dicom...']}, 0, 1)
import_flag = dicom_imp('RestingState', subID,mriID, watchFolder, projFolder, imSer, 1, 0, Sess , 15);

if import_flag == 0
    user_fb_update({'Dir not empty: Analyses aborted..'}, 0, 3)
    return
end

% Hard coded. Make sure these correspond to the sequence specs
nr_slices = 44;
TR = 0.8;
TA = TR - (TR/nr_slices);
SO = [nr_slices:-1:1];  
RS = floor(nr_slices/2);

if subinfo.old_struct == 1
    steps = {'realign'}; %, 'coreg'
elseif subinfo.new_struct == 1
    steps = {'realign', 'coreg'}; %, 'coreg'
end
message{1,1} = 'SETTINGS';
message{2,1} = ['Slices: ' num2str(nr_slices)];
message{3,1} = ['TR: ' num2str(TR)];
message{5,1} = 'Preprocessing steps: ';
message{6,1} = steps;
user_fb_update(message, 0, 1);
clear message

subjStructDir = [projFolder, filesep ,subID filesep, Sess, filesep, 'T1', filesep];

funcDir = [projFolder, filesep, subID, filesep, Sess, ...
                    filesep, 'RestingState', filesep];

templDir = [projFolder, filesep, subID, filesep, Sess, ...
                    filesep, 'EPI_Template_D1', filesep];                
                
funcDir_loc = [projFolder, filesep, subID, filesep, 'Localizer', filesep, 'func', filesep];               
                
spm_jobman('initcfg')
% Fmenu  = spm('CreateMenuWin','off');                 
Finter = spm('CreateIntWin','off');           
Fgraph = spm_figure('Create','Graphics','Graphics','off');
set([Finter,Fgraph],'Visible','on');
for ii = 1:length(steps)
    
    start = tic;
    
    switch steps{ii}

        case 'slice_timing'
            clear matlabbatch

%             f1   = spm_select('List', funcDir, ['^f' '.*\.' rawFormat '$']);
            f1   = spm_select('List', funcDir, ['^MF' '.*\.' rawFormat '$']);
            f2  = cellstr([repmat(funcDir,size(f1,1),1) f1]);

            matlabbatch{1}.spm.temporal.st.scans = {f2}; 

            if isempty(f2{1})
                user_fb_update({'No functional images loaded in: '; steps{ii}},0,3)
                return
            end

            % variables specified above
            matlabbatch{1}.spm.temporal.st.nslices = nr_slices;
            matlabbatch{1}.spm.temporal.st.tr = TR;
            matlabbatch{1}.spm.temporal.st.ta = TA;
            matlabbatch{1}.spm.temporal.st.so = SO;
            matlabbatch{1}.spm.temporal.st.refslice = RS;
            matlabbatch{1}.spm.temporal.st.prefix = 'a';

            % save the batch, run it and clear it
            save([projFolder, filesep, subID, filesep, Sess, filesep,...
                'RestingState', filesep, 'slice_timing'], 'matlabbatch');
            
            user_fb_update({[num2str(ii) ') Slicetime corretion...']}, 0, 1)
            tic
                
            spm_jobman('run', matlabbatch); 

            tEnd = toc;
            time_taken = sprintf('%d min %0.f sec', floor(tEnd/60), round(rem(tEnd,60)));
            user_fb_update({['Completed in: ' time_taken]}, 0, 4)

            clear matlabbatch

        case 'realign'
            clear matlabbatch

%             f1   = spm_select('List', funcDir, ['^f' '.*\.' rawFormat '$']);
            f1   = spm_select('List', funcDir, ['^MF' '.*\.' rawFormat '$']);
            f2  = cellstr([repmat(funcDir,size(f1,1),1) f1]);
            matlabbatch{1}.spm.spatial.realign.estwrite.data = {f2};

            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
            matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
            matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
            matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
            matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
            matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

            % save the batch, run it and clear it
            save([projFolder filesep subID filesep Sess, filesep,...
                'RestingState', filesep 'realign'], 'matlabbatch')
            
            user_fb_update({[num2str(ii) ') Realignment...']}, 0, 1)
            tic
                
            spm_jobman('run', matlabbatch); 

            tEnd = toc;
            time_taken = sprintf('%d min %0.f sec', floor(tEnd/60), round(rem(tEnd,60)));
            user_fb_update({['Completed in: ' time_taken]}, 0, 4)
            
            clear matlabbatch
        
        % check if coregistration is added to the preprocessing steps
        % above. Most likely should not be selected..
        case 'coreg'

            % retrieve the structural
%             f1struct        = spm_select('List', subjStructDir, ['^s' '.*192-01.' rawFormat '$']);
            f1struct        = spm_select('List', subjStructDir, ['^MF' '.*.' rawFormat '$']);
            f2struct        = cellstr([repmat(subjStructDir,size(f1struct,1),1) f1struct]);

            % retrieve the mean EPI image
            mean_image      = spm_select('List', funcDir, ['^mean' '.*\.' rawFormat '$']);
            
            % retrieve coregistered mean image of localizer 
            mean_image_loc      = spm_select('List', funcDir_loc, ['^mean' '.*\.' rawFormat '$']); 
            
            % and the resliced images
            rsim1   = spm_select('List', funcDir, ['^rf' '.*\.' rawFormat '$']);
            rsim2  = cellstr([repmat(funcDir,size(rsim1,1),1) rsim1]);

            % define reference (mean EPI) and source (struct)
            matlabbatch{1}.spm.spatial.coreg.estimate.ref =  f2struct; %f2struct;
            matlabbatch{1}.spm.spatial.coreg.estimate.source = {fullfile([funcDir, filesep, mean_image])};
            matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};%rsim2;
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
%             matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
%             matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
%             matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
%             matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';

            % save the batch, run it and clear it
            save([projFolder filesep subID filesep Sess, filesep,...
                'RestingState', filesep 'coregistration'], 'matlabbatch')
            
            user_fb_update({[num2str(ii) ') Coregistration...']}, 0, 1)
            tic
                
            spm_jobman('run', matlabbatch); 

            tEnd = toc;
            time_taken = sprintf('%d min %0.f sec', floor(tEnd/60), round(rem(tEnd,60)));
            user_fb_update({['Completed in: ' time_taken]}, 0, 4)
            clear matlabbatch

        case 'smooth'

            matlabbatch{1}.spm.spatial.smooth.data = [];

            funcDir     = [funcDir filesep];
%             f1   = spm_select('List', funcDir, ['^rf' '.*\.' rawFormat '$']); 
            f1   = spm_select('List', funcDir, ['^rMF' '.*\.' rawFormat '$']); 
            f2  = cellstr([repmat(funcDir,size(f1,1),1) f1]);
            matlabbatch{1}.spm.spatial.smooth.data = [matlabbatch{1}.spm.spatial.smooth.data; f2];% [matlabbatch{1}.spm.spatial.smooth.data f2];

            matlabbatch{1}.spm.spatial.smooth.fwhm = smoothK;
            matlabbatch{1}.spm.spatial.smooth.dtype = 0;
            matlabbatch{1}.spm.spatial.smooth.im = 0;
            matlabbatch{1}.spm.spatial.smooth.prefix = 's';

             save([projFolder filesep subID filesep Sess, filesep,...
                'RestingState', filesep 'smoothing'], 'matlabbatch')
            
            user_fb_update({[num2str(ii) ') Smoothing...']}, 0, 1)
            tic
                
            spm_jobman('run', matlabbatch); 

            tEnd = toc;
            time_taken = sprintf('%d min %0.f sec', floor(tEnd/60), round(rem(tEnd,60)));
            user_fb_update({['Completed in: ' time_taken]}, 0, 4)
            
            clear matlabbatch

    end
end

mean_image      = spm_select('List', funcDir, ['^mean' '.*\.' rawFormat '$']);
copyfile([funcDir, filesep, mean_image], [templDir, filesep, mean_image])

einde = toc(start);

time_taken = sprintf('%d min %0.f sec', floor((einde)/60), round(rem((einde),60)));
user_fb_update({['Analyses completed in: ' time_taken]}, 0, 1)

end
