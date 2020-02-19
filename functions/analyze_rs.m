function analyze_rs(subinfo)

subID       = subinfo.subID;
watchFolder = subinfo.watchFolder;
projFolder  = subinfo.projFolder;
imSer       = subinfo.dcmSeries;
Sess        = subinfo.session;

rawFormat   = 'nii'; 
 
smoothK = [6 6 6];

% import funcitonal images, call funcion:
dicom_imp('RestingState', subID, watchFolder, projFolder, imSer, 1, 0, Sess , 15);

nr_slices = 35;
TR = 2;
TA = TR - (TR/nr_slices);
SO = [nr_slices:-1:1];  
RS = floor(nr_slices/2);

steps = {'slice_timing', 'realign'}; %, 'coreg'

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

    switch steps{ii}

        case 'slice_timing'
            clear matlabbatch

            f1   = spm_select('List', funcDir, ['^f' '.*\.' rawFormat '$']);
            f2  = cellstr([repmat(funcDir,size(f1,1),1) f1]);

            matlabbatch{1}.spm.temporal.st.scans = {f2}; 

            if isempty(f2{1})
                fprintf('\nNo functional images loaded in: %s\n', steps{ii})
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
            spm_jobman('run', matlabbatch);
            clear matlabbatch

        case 'realign'
            clear matlabbatch

            f1   = spm_select('List', funcDir, ['^af' '.*\.' rawFormat '$']);
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
            spm_jobman('run', matlabbatch);
            clear matlabbatch

        case 'coreg'

            % retrieve the structural
            f1struct        = spm_select('List', subjStructDir, ['^s' '.*192-01.' rawFormat '$']);
            f2struct        = cellstr([repmat(subjStructDir,size(f1struct,1),1) f1struct]);

            % retrieve the mean EPI image
            mean_image      = spm_select('List', funcDir, ['^mean' '.*\.' rawFormat '$']);
            
            % retrieve coregistered mean image of localizer 
            mean_image_loc      = spm_select('List', funcDir_loc, ['^mean' '.*\.' rawFormat '$']); 
            
            % and the resliced images
            rsim1   = spm_select('List', funcDir, ['^raf' '.*\.' rawFormat '$']);
            rsim2  = cellstr([repmat(funcDir,size(rsim1,1),1) rsim1]);

            % define reference (mean EPI) and source (struct)
            matlabbatch{1}.spm.spatial.coreg.estwrite.ref =  {fullfile([funcDir_loc, filesep, mean_image_loc])}; %f2struct;
            matlabbatch{1}.spm.spatial.coreg.estwrite.source = {fullfile([funcDir, filesep, mean_image])};
            matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};%rsim2;
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';

            % save the batch, run it and clear it
            save([projFolder filesep subID filesep Sess, filesep,...
                'RestingState', filesep 'coregistration'], 'matlabbatch')
            spm_jobman('run', matlabbatch);
            clear matlabbatch

        case 'smooth'

            matlabbatch{1}.spm.spatial.smooth.data = [];

            funcDir     = [funcDir filesep];
            f1   = spm_select('List', funcDir, ['^raf' '.*\.' rawFormat '$']); 
            f2  = cellstr([repmat(funcDir,size(f1,1),1) f1]);
            matlabbatch{1}.spm.spatial.smooth.data = [matlabbatch{1}.spm.spatial.smooth.data; f2];% [matlabbatch{1}.spm.spatial.smooth.data f2];

            matlabbatch{1}.spm.spatial.smooth.fwhm = smoothK;
            matlabbatch{1}.spm.spatial.smooth.dtype = 0;
            matlabbatch{1}.spm.spatial.smooth.im = 0;
            matlabbatch{1}.spm.spatial.smooth.prefix = 's';

             save([projFolder filesep subID filesep Sess, filesep,...
                'RestingState', filesep 'smoothing'], 'matlabbatch')
            spm_jobman('run', matlabbatch);
            clear matlabbatch

    end
end

mean_image      = spm_select('List', funcDir, ['^mean' '.*\.' rawFormat '$']);
copyfile([funcDir, filesep, mean_image], [templDir, filesep, mean_image])

end
