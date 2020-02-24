function analyze_loc_func(subinfo, data)

% subID, watchFolder, projFolder, dcmSeries, Sess, expNrIms
% (handles.subID, handles.watchFolder, handles.projFolder, handles.analyze_loc_sn, 'Session_01', 179);
subID       = subinfo.subID;
watchFolder = subinfo.watchFolder;
projFolder  = subinfo.projFolder;
dcmSeries   = subinfo.dcmSeries;
 % consider adding field in gui (in case user wants to take flocalizer every session
Sess        = 'Session_01';        

subjStructDir = subinfo.subjStructDir;
funcDir = [projFolder, filesep, subID, filesep, 'Localizer', ...
                    filesep, 'func', filesep];

% set parameters from gui
expNrIms    = data.nrVolumes;
nr_slices   = data.nrSlices;
TR          = data.TR;
TA          = TR - (TR/nr_slices);
SO          = data.sliceOrder;      %[nr_slices:-1:1];  
RS          = data.refSlice;        %floor(nr_slices/2);
smoothK     = repmat(data.smoothK,1,3);
% voxelRes    = [2 2 2];

% set the preprocessing steps
% {'slice_timing', 'realign', 'coreg', 'smooth'};
steps = data.steps; 
stepNames = fieldnames(steps);
stepFlags = cell2mat(struct2cell(steps));
stepNames = {stepNames{find(stepFlags==1)}};

message{1,1} = '';
message{2,1} = ['Slices: ' num2str(nr_slices)];
message{3,1} = ['TR: ' num2str(TR)];
message{4,1} = ['Volumes: ' num2str(expNrIms)];
message{5,1} = 'Preprocessing steps: ';

for ii = 1:size(stepNames,2)
    message{5+ii,1} = ['- ' stepNames{ii}];
end
user_fb_update(message, 0, 1)
clear message

message{2,1} = 'Contrasts: ';
for ii = 1: size(data.contrasts,1)
    message{2+ii,1} = [data.contrasts{ii,1} ':      ' data.contrasts{ii,2}];
end
user_fb_update(message, 0, 1)

% flags to preprocess and/or do stats
preprocFlag = 1;
stats = 1;

rawFormat   = 'nii'; 
 
onset_prefix = 'Onsets_SPM';
                
spm_jobman('initcfg')
% Fmenu  = spm('CreateMenuWin','off');                 
Finter = spm('CreateIntWin','off');           
Fgraph = spm_figure('Create','Graphics','Graphics','off');
set([Finter,Fgraph],'Visible','on');%Fmenu,
if preprocFlag == 1

    for ii = 1:numel(stepNames)

        switch stepNames{ii}
            
            case 'impDcm'
                clear matlabbatch
                % import funcitonal images, call funcion:
                dicom_imp('Localizer', subID, watchFolder, projFolder, dcmSeries, 1, 0, Sess, expNrIms);
                
            case 'sliceTiming'
                clear matlabbatch
        
                f1   = spm_select('List', funcDir, ['^f' '.*\.' rawFormat '$']);
                f2  = cellstr([repmat(funcDir,size(f1,1),1) f1]);
                
                matlabbatch{1}.spm.temporal.st.scans = {f2}; 

                if isempty(f2{1})
                    fprintf('\nNo functional images loaded in: %s\n', steps{ii})
%                     close Finter Fgraph
                    return
                elseif size(f1,1) ~= expNrIms
                    fprintf('\nIncorrect number of images found, check the watchfolder or dicom series number in GUI!\n')
                    fprintf(['Images expected: ', num2str(expNrIms) '\n']);
                    fprintf(['Images found: ', num2str(size(f1,1)), '\n']);
                    fprintf('Please check images_found variable in workspace\n');
                    images_found = f2;
                    assignin('base', 'images_found', images_found);
%                     close Finter Fgraph
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
                save([projFolder filesep subID filesep 'Localizer' filesep 'slice_timing'], 'matlabbatch');
                spm_jobman('run', matlabbatch);
                clear matlabbatch

            case 'Realign'
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
                save([projFolder, filesep, subID, filesep, 'Localizer', filesep, 'realign'], 'matlabbatch')
                spm_jobman('run', matlabbatch);
                clear matlabbatch

            case 'Coregistration'

                % retrieve the structural
                f1struct        = spm_select('List', subjStructDir, ['^s' '.*192-01.' rawFormat '$']);
                f2struct        = cellstr([repmat(subjStructDir,size(f1struct,1),1) f1struct]);

                % retrieve the mean EPI image
                mean_image      = spm_select('List', funcDir, ['^mean' '.*\.' rawFormat '$']);
                
                % and the resliced images
                rsim1   = spm_select('List', funcDir, ['^raf' '.*\.' rawFormat '$']);
                rsim2  = cellstr([repmat(funcDir,size(rsim1,1),1) rsim1]);
                
                % define reference (mean EPI) and source (struct)
                matlabbatch{1}.spm.spatial.coreg.estimate.ref       = f2struct;
                matlabbatch{1}.spm.spatial.coreg.estimate.source    = {fullfile([funcDir, filesep, mean_image])};
                matlabbatch{1}.spm.spatial.coreg.estimate.other     = rsim2; %{''};%;
                matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
                matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
                matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
                matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
%                 matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
%                 matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
%                 matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
%                 matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';

                % save the batch, run it and clear it
                save([projFolder filesep subID filesep 'Localizer' filesep 'coregistration'], 'matlabbatch')
                spm_jobman('run', matlabbatch);
                clear matlabbatch
                
                % Copy mean to epi template folder for MC template within
                % OpenNFT
                template2copy   = fullfile([funcDir, filesep, mean_image]);
                dir2go          = [projFolder, filesep, subID, filesep, 'Session_01', filesep, 'EPI_Template_D1'];
                copyfile(template2copy, dir2go);
                
       
            case 'Smooth'

                matlabbatch{1}.spm.spatial.smooth.data = [];

                funcDir     = [funcDir filesep];
                f1   = spm_select('List', funcDir, ['^raf' '.*\.' rawFormat '$']); 
                f2  = cellstr([repmat(funcDir,size(f1,1),1) f1]);
                matlabbatch{1}.spm.spatial.smooth.data = [matlabbatch{1}.spm.spatial.smooth.data; f2];% [matlabbatch{1}.spm.spatial.smooth.data f2];

                matlabbatch{1}.spm.spatial.smooth.fwhm = smoothK;
                matlabbatch{1}.spm.spatial.smooth.dtype = 0;
                matlabbatch{1}.spm.spatial.smooth.im = 0;
                matlabbatch{1}.spm.spatial.smooth.prefix = 's';

                save([projFolder filesep subID filesep 'Localizer' filesep 'smooth_test'], 'matlabbatch')
                spm_jobman('run', matlabbatch);
                clear matlabbatch
               
        end
    end
end

% Stats
if stats == 1
    clear matlabbatch
    
    statsdir = [projFolder filesep subID filesep 'Localizer', ...
                    filesep 'stats' filesep];

    % sepcify first level
    matlabbatch{1}.spm.stats.fmri_spec.dir = {statsdir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = RS;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

    onsets_file = [projFolder filesep subID filesep 'Localizer', ...
                filesep 'beh' filesep onset_prefix '.mat']; 

    multiple_regressors = spm_select('List', funcDir, ['rp_' '.*\.' 'txt' '$']);
    f3 = spm_select('List', funcDir, ['^sraf' '.*\.' rawFormat '$']);
    f4  = cellstr([repmat(funcDir,size(f3,1),1) f3]);

    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = f4; %{k}                   
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = cellstr([onsets_file]);
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = cellstr([funcDir filesep multiple_regressors]);
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;

    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;  
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

    % model estimastion
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = {[statsdir filesep 'SPM.mat']};
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    % cons of interest
    for ii = 1:size(data.contrasts,1)
        
        matlabbatch{3}.spm.stats.con.spmmat = {[statsdir filesep 'SPM.mat']};

        matlabbatch{3}.spm.stats.con.consess{ii}.tcon.name = data.contrasts{ii,1};
        matlabbatch{3}.spm.stats.con.consess{ii}.tcon.weights = repmat([str2num(data.contrasts{ii,2}) zeros(1,6)],1,1);
        matlabbatch{3}.spm.stats.con.consess{ii}.tcon.sessrep = 'none';
        
        matlabbatch{3}.spm.stats.con.delete = 0;
        
    end

    spm_jobman('run',matlabbatch); 
    
    clear matlabbatch 

end

end
