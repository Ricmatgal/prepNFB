function analyze_loc_func(subinfo, data)

% subID, watchFolder, projFolder, dcmSeries, Sess, expNrIms
% (handles.subID, handles.watchFolder, handles.projFolder, handles.analyze_loc_sn, 'Session_01', 179);
subID       = subinfo.subID;
mriID       = subinfo.mriID;
watchFolder = subinfo.watchFolder;
projFolder  = subinfo.projFolder;
dcmSeries   = subinfo.dcmSeries;

 % consider adding field in gui (in case user wants to take flocalizer every session
Sess        = 'Session_01';        

subjStructDir = subinfo.subjStructDir;

funcDir = [projFolder, filesep, subID, filesep, 'Localizer', ...
                    filesep, 'func', filesep];

statsdir = [projFolder, filesep, subID, filesep, 'Localizer', ...
                filesep, 'stats', filesep];
                
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
steps = data.steps; 
stepNames = fieldnames(steps);
stepFlags = cell2mat(struct2cell(steps));
stepNames = {stepNames{find(stepFlags==1)}};

% message{1,1} = '';
message{1,1} = 'SETTINGS';
message{2,1} = ['Slices: ' num2str(nr_slices)];
message{3,1} = ['TR: ' num2str(TR)];
message{4,1} = ['Volumes: ' num2str(expNrIms)];
message{5,1} = 'Preprocessing steps: ';
message{6,1} = stepNames;
user_fb_update(message, 0, 1)
clear message

message{1,1} = 'Contrasts: ';
for ii = 1: size(data.contrasts,1)
    message{1+ii,1} = [data.contrasts{ii,1} ':      ' data.contrasts{ii,2}];
end


user_fb_update(message, 0, 1)
clear message

% uiwait();

rawFormat   = 'nii'; 
 
onset_prefix = 'Onsets_SPM';
                
spm_jobman('initcfg')
% Fmenu  = spm('CreateMenuWin','off');                 
Finter = spm('CreateIntWin','off');           
Fgraph = spm_figure('Create','Graphics','Graphics','off');
set([Finter,Fgraph],'Visible','on');%Fmenu,


start = tic;

for ii = 1:numel(stepNames)

    switch stepNames{ii}

        case 'impDcm'
            clear matlabbatch
            % import funcitonal images, call funcion:
            user_fb_update({[num2str(ii) ') Importing dicom...']}, 0, 1)

            import_flag = dicom_imp('Localizer', subID, mriID, watchFolder, projFolder, dcmSeries, 1, 0, Sess, expNrIms);

            if import_flag == 0
                user_fb_update({'Analysis aborted...'},0,3)
                return
            end

        case 'sliceTiming'
            clear matlabbatch

%            f1   = spm_select('List', funcDir, ['^f' '.*\.' rawFormat '$']);
            f1   = spm_select('List', funcDir, ['^MF' '.*\.' rawFormat '$']);
            f2  = cellstr([repmat(funcDir,size(f1,1),1) f1]);

            matlabbatch{1}.spm.temporal.st.scans = {f2}; 

            if isempty(f2{1})
                user_fb_update({['No functional images loaded in: %s\n', steps{ii}]},0,3)
%                     close Finter Fgraph
                return
            elseif size(f1,1) ~= expNrIms
                message{1,1} = 'Incorrect number of images found!';
                message{2,1} = ['Expected: ', num2str(expNrIms)];
                message{3,1} = ['Found: ', num2str(size(f1,1))];
                message{4,1} = ['Please check images_found variable in workspace'];
                user_fb_update(message, 0, 3);
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
            user_fb_update({[num2str(ii) ') Slicetime corretion...']}, 0, 1)
            tic

            spm_jobman('run', matlabbatch); 

            tEnd = toc;
            time_taken = sprintf('%d min %0.f sec', floor(tEnd/60), round(rem(tEnd,60)));
            user_fb_update({['Completed in: ' time_taken]}, 0, 4)

            clear matlabbatch

        case 'Realign'
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
            save([projFolder, filesep, subID, filesep, 'Localizer', filesep, 'realign'], 'matlabbatch')

            user_fb_update({[num2str(ii) ') Realignment...']}, 0, 1)
            tic

            spm_jobman('run', matlabbatch); 

            tEnd = toc;
            time_taken = sprintf('%d min %0.f sec', floor(tEnd/60), round(rem(tEnd,60)));
            user_fb_update({['Completed in: ' time_taken]}, 0, 4)

            clear matlabbatch

        case 'Coregistration'

            % retrieve the structural
%             f1struct        = spm_select('List', subjStructDir, ['^s' '.*192-01.' rawFormat '$']);
            f1struct        = spm_select('List', subjStructDir, ['^MF' '.*.' rawFormat '$']);
            f2struct        = cellstr([repmat(subjStructDir,size(f1struct,1),1) f1struct]);

            % retrieve the mean EPI image
            mean_image      = spm_select('List', funcDir, ['^meanMF' '.*\.' rawFormat '$']);

            % and the resliced images
%             rsim1   = spm_select('List', funcDir, ['^rf' '.*\.' rawFormat '$']);
            rsim1   = spm_select('List', funcDir, ['^rMF' '.*\.' rawFormat '$']);
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

            user_fb_update({[num2str(ii) ') Coregistration...']}, 0, 1)
            tic

            spm_jobman('run', matlabbatch); 

            tEnd = toc;
            time_taken = sprintf('%d min %0.f sec', floor(tEnd/60), round(rem(tEnd,60)));
            user_fb_update({['Completed in: ' time_taken]}, 0, 4)

            clear matlabbatch

            % Copy mean to epi template folder for MC template within
            % OpenNFT
            template2copy   = fullfile([funcDir, filesep, mean_image]);
            dir2go          = [projFolder, filesep, subID, filesep, 'Session_01', filesep, 'EPI_Template_D1'];
            copyfile(template2copy, dir2go);


        case 'Smooth'

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

            save([projFolder filesep subID filesep 'Localizer' filesep 'smooth_test'], 'matlabbatch')

            user_fb_update({[num2str(ii) ') Smoothing...']}, 0, 1)
            tic

            spm_jobman('run', matlabbatch); 

            tEnd = toc;
            time_taken = sprintf('%d min %0.f sec', floor(tEnd/60), round(rem(tEnd,60)));
            user_fb_update({['Completed in: ' time_taken]}, 0, 4)

            clear matlabbatch

        case 'Stats'

            % sepcify first level
            matlabbatch{1}.spm.stats.fmri_spec.dir = {statsdir};
            matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
            matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
            matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = RS;
            matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

            onsets_file = [projFolder filesep subID filesep 'Localizer', ...
                        filesep 'beh' filesep onset_prefix '.mat']; 

            multiple_regressors = spm_select('List', funcDir, ['rp_' '.*\.' 'txt' '$']);
%             f3 = spm_select('List', funcDir, ['^srf' '.*\.' rawFormat '$']);
            f3 = spm_select('List', funcDir, ['^srMF' '.*\.' rawFormat '$']);

        
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
            for con = 1:size(data.contrasts,1)

                matlabbatch{3}.spm.stats.con.spmmat = {[statsdir filesep 'SPM.mat']};

                matlabbatch{3}.spm.stats.con.consess{con}.tcon.name = data.contrasts{con,1};
                matlabbatch{3}.spm.stats.con.consess{con}.tcon.weights = repmat([str2num(data.contrasts{con,2}) zeros(1,6)],1,1);
                matlabbatch{3}.spm.stats.con.consess{con}.tcon.sessrep = 'none';

                matlabbatch{3}.spm.stats.con.delete = 0;

            end

            user_fb_update({[num2str(ii) ') Parameter estimation & Contrasts...']}, 0, 1)
            tic

            spm_jobman('run', matlabbatch); 

            tEnd = toc;
            time_taken = sprintf('%d min %0.f sec', floor(tEnd/60), round(rem(tEnd,60)));
            user_fb_update({['Completed in: ' time_taken]}, 0, 4)

            clear matlabbatch 

    end
end

einde = toc(start);

time_taken = sprintf('%d min %0.f sec', floor((einde)/60), round(rem((einde),60)));
user_fb_update({['Analyses completed in: ' time_taken]}, 0, 1)

end
