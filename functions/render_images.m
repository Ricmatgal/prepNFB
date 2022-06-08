function render_images(info)

    % About this function: 
    % This function creates new stimuli sets from one or more 'base' sets. First
    % a pseudo random combination of stims is put together, afterwhich the
    % images selected (absolute paths) are ran through a scrambling pipeline 
    % creating multiple images per stim of increasing noise level. Two sources
    % of noise are introduced per image: (1) A gaussian blurr filter that
    % smooths the images (this takes out the high spatial frequencie parts of
    % the stimulus) and (2) a phase scrambling routine, introducing complex
    % noise to the image. Each new itteration the same filters are applied but
    % are slightly weaker than the previous iteration. As such the image
    % creating in the last itteration will contain almost no noise. Stimuli are
    % superimposed on noisy backgrounds with their center of mass centered on
    % one of 8 locations of a circle around the centre of the final image. 
    
    % dependencies: SPM12 (for spm_select function), find_center (for
    % finding center of mass of stims)

    % Set directories, specify fixed variables and unpack subject information here:
    subID       = info.subID;
    projFolder  = info.projFolder;
    sessions    = info.session;  
    runs        = info.runs;    
    
    % specify image type here:
    imType = 'png';
    
    % Evaluate if there are no rendered images for this subject yet. If not
    % we are good to go, otherwise stop the routine. Report back to user.
    rootSubFolder   = [projFolder, filesep, subID];
    checkDir        = [rootSubFolder, filesep, 'Session_01', filesep, 'TaskFolder', filesep, 'StimSets'];
    check4files     = dir(fullfile(checkDir, '**', '*.png'));
    
    workspaceDir2save2 = [projFolder, filesep, subID, filesep, 'Session_01', filesep, 'TaskFolder',...
        filesep, 'StimSets',];
    workspace_file = [workspaceDir2save2, filesep 'StimSets_sub_' num2str(subID) '.mat'];
    
    % record onset of process
    tic;
    
    % preset answer so it exist even when no input is required
    answer = '';
    
    % If images are detected display dlg window with options.
    % check if images were already rendered. If so determine if the sets
    % are complete. If complete give option to abort or create new. If
    % incomplete give options to abort, continue or create new. 
    if ~isempty(check4files)
        filesFoundIn={check4files.folder}';  
        if exist(workspace_file,'file') == 2
            load(workspace_file)
            if totTrialCounter < totNrtrials 
                user_fb_update({'Stimuli DETECTED in: '; unique(filesFoundIn)';'';...
                    ['Stim rendering incomplete: ' num2str(totTrialCounter) '/' num2str(totNrtrials)];...
                    'What would you like to do?'},0,2);  
                
                answer = questdlg('Stims Detected and rendering INCOMPLETE! what would you like to do?', ...
                'Choice options', ...
                'Abort','Continue Rendering','Create NEW (delete existing!)','Abort');
                % Handle response
                switch answer
                    case 'Abort'
                        user_fb_update({'Rendering ABORTED by user'},0,2);
                        return
                    case 'Continue Rendering'
                        user_fb_update({'Continue Rendering...'},0,2);
                        compile_new_stimSets        = 0; 
                        render_stimSets             = 1;
                    case 'Create NEW (delete existing!)' 
                        % delete stimset routine
                        for sess2del = 1:str2double(sessions)
                            tmpdir = [rootSubFolder, filesep, 'Session_0', num2str(sess2del),...
                                      filesep, 'TaskFolder', filesep, 'StimSets'];
                            dinfo = dir(tmpdir);
                            delete([dinfo(1).folder, filesep, '*.mat']); % delete the mat file
                            % delete the folders within StimSets and their
                            % contents (start from 3 to skip . and ..
                            for ii = 3:size(dinfo,1)
                                tmp = [dinfo(ii).folder, filesep, dinfo(ii).name];
                                if isfolder(tmp)
                                    rmdir(tmp, 's')
                                end     
                            end      
                        end
                        
                        user_fb_update({'Creating NEW stimSets...'},0,2);
                        compile_new_stimSets        = 1; 
                        render_stimSets             = 1;
                end
            elseif totTrialCounter >= totNrtrials 
                user_fb_update({'Stimuli DETECTED in: '; unique(filesFoundIn)';'';...
                    ['Stim rendering COMPETED: ' num2str(totTrialCounter) '/' num2str(totNrtrials)];...
                    'What would you like to do?'},0,2);
                 
                answer = questdlg('Stims Detected and rendering COMPLETED! what would you like to do?', ...
                'Choice options', ...
                'Abort','Create NEW (delete existing!)','Abort)');
                % Handle response
                switch answer
                    case 'Abort'
                        user_fb_update({'Rendering ABORTED by user'},0,2);
                        return
                    case 'Create NEW (delete existing!)'
                        
                        % delete stimset routine
                        for sess2del = 1:str2double(sessions)
                            tmpdir = [rootSubFolder, filesep, 'Session_0', num2str(sess2del),...
                                      filesep, 'TaskFolder', filesep, 'StimSets'];
                            dinfo = dir(tmpdir);
                            delete([dinfo(1).folder, filesep, '*.mat']); % delete the mat file
                            % delete the folders within StimSets and their
                            % contents (start from 3 to skip . and ..
                            for ii = 3:size(dinfo,1)
                                tmp = [dinfo(ii).folder, filesep, dinfo(ii).name];
                                if isfolder(tmp)
                                    rmdir(tmp, 's')
                                end     
                            end      
                        end
                        
                        user_fb_update({'Creating NEW stimSets...'},0,2);                      
                        compile_new_stimSets        = 1; 
                        render_stimSets             = 1;
                end
            end
        elseif exist(workspace_file,'file') == 0
            user_fb_update({'Stimuli DETECTED in: '; unique(filesFoundIn); 'Rendering ABORTED'},0,3);
            compile_new_stimSets        = 0; 
            render_stimSets             = 0;
            return
        end
    % else if there are no files/images found continue without notifacation
    % and exectue both the compilcation and the rendering routine. 
    elseif isempty(check4files)
            compile_new_stimSets        = 1; 
            render_stimSets             = 1;
    end
    
    % preset some progress variables. These remain unchanged when user opts
    % for a fresh rendering. If continue rendering is selected these
    % will be changed according to the variable values in the loaded
    % matfile.
    if strcmp(answer,'Continue Rendering') == 0
        totTrialCounter = 1;
        stimClass_s     = 1;
    end
    
       
    if  compile_new_stimSets == 1
        % =================================================================
        % ================= STIMULI SELECTION ROUTINE =====================
        % Info:
        % Here we pseudo randomly compile the stimuli for the subject from
        % the large original_stimuli parent sets. We counter balance for
        % gender within single sessions and for faces chosen from the 
        % different parent sets.
        % =================================================================
        
        % report to user
        user_fb_update({'Rendering Task Stimuli';['Subject: ', subID];...
            'Sit back, this will take some time'},1,1)
        
        % set directories from the PARENT sets
        rootDir     = projFolder;
        rootFaces   = [rootDir, filesep, 'original_stims', filesep, 'FACES'];
        rootOther   = [rootDir, filesep, 'original_stims', filesep, 'OTHER'];
        rootBGs     = [rootDir, filesep, 'original_stims', filesep, 'BACKGROUNDS'];

        % folder names for images to be written to
        folder_names = {['FACES', filesep, 'male'], ['FACES', filesep, 'female'], 'OTHER'};

        % How many stimuli sets available
        setsAvailable = 2;

        % Get full paths of stims available in different categories for each set
        for set = 1:setsAvailable 
            faces_male{set}     = cellstr(spm_select('FPList', [rootFaces, filesep, 'Set' num2str(set), filesep, 'male', filesep], imType));
            faces_female{set}   = cellstr(spm_select('FPList', [rootFaces, filesep, 'Set' num2str(set), filesep, 'female', filesep], imType));  
        end

        % single set categories
        distractors     = cellstr(spm_select('FPList', [rootOther, filesep, filesep], [imType]));
        backgrounds     = cellstr(spm_select('FPList', [rootBGs, filesep, filesep], [imType]));

        % prepare stim presentation order here:
        nrStimSets2generate     = str2double(sessions);    % total sim sets to be generated
        nrRuns                  = str2double(runs);        % nr of runs per session/stimset
        stimsPerRun             = 7;%10;                   % nr of stims per run

        % specify variables per session
        stimsPerSess        = stimsPerRun*nrRuns;
        percentTargets      = 0.70;
        percentDistractors  = 0.30;
        nrTargets           = 35; % stimsPerSess*percentTargets;
        nrDistractors       = 14; % stimsPerSess*percentDistractors;

        totNrtrials         =  nrStimSets2generate*stimsPerSess; 

        % Randomly select if more male or female in sess1 and reverse for
        % sess2. If nrTargets can be devided in two this operation will have no
        % effect and the nr male female are equal.
        rolDice = randperm(2,1);
        if rolDice == 1
            males2select(1,1)            = ceil(nrTargets*0.5);
            females2select(1,1)          = floor(nrTargets*0.5);
        elseif rolDice == 2
            males2select(1,1)            = floor(nrTargets*0.5);
            females2select(1,1)          = ceil(nrTargets*0.5);
        end
        % reverse NR for session 2
        males2select(1,2)             = females2select(1,1);
        females2select(1,2)           = males2select(1,1);

        % Determine actual stims for each sub specific stim set to be processed
        % below. Keep in mind: stims chosen for session 1 CANNOT be used in session
        % 2!!

        % initiate seperate variables for each category where we will keep the
        % selected absolute paths
        faces_male_selection    = cell(1,nrStimSets2generate);
        faces_female_selection  = cell(1,nrStimSets2generate);
        distractor_selection    = cell(1,nrStimSets2generate);
        background_selection    = cell(1,nrStimSets2generate);

        % contruct pool vectors for each stim set seperated by gender and stim set
        % these are used below to keep track of the stims already selected during
        % the previous sessions (once a stim is chosen its corresponding nr is
        % flipped to 1 and will de ignored for the subsequent random draw)
        for this_set = 1:setsAvailable 
            POOLS.faces_M{this_set}     = zeros(1,size(faces_male{this_set},1));
            POOLS.faces_F{this_set}     = zeros(1,size(faces_female{this_set},1));
        %     POOLS.distractors{this_set} = zeros(1,size(distractors,1));
        end
        POOLS.distractors   = zeros(1,size(distractors,1));
        % POOLS.backgrounds   = zeros(1,size(backgrounds,1));

        % Absolute path selection of the stims to be used for the generation of the
        % new stimsets. We counter balance gender and evenly select stims for both
        % sets (as much as we can).
        for sess = 1:nrStimSets2generate

            % Determine how many males/females of each set should be selected for
            % this session

            % devide NR of males for this session in even parts 
            int_male    = fix(males2select(sess)/setsAvailable);
            int_female  = fix(females2select(sess)/setsAvailable);

            % see if there is a remainder 
            rem_male    = rem(males2select(sess),setsAvailable); 
            rem_female  = rem(females2select(sess),setsAvailable); 

            % create vector with males to select for each set available
            % females are different currently, as we have only 12 females in set 1
            males2selectPerSet                  = repmat(int_male, 1, setsAvailable);
        %     females2selectPerSet                = repmat(int_female, 1, setsAvailable);

            % randomly add the remainder to one of the sets (if none remains 0
            % will be added and nothing changes
            males2selectPerSet(randperm(2,1))   = int_male+rem_male;
        %     females2selectPerSet(randperm(2,1)) = int_female+rem_female;

            % HARDCODED! we have only 12 females in set 1 so in each session we
            % will pick 6 and get the remainder from set 2
            females2selectPerSet = [6 (females2select(sess)-6)];

            % Determine AND select which males/females are chosen from the sets for
            % each session. We need to take into account that stimuli selected for
            % one session cannot apear in the other session!
            for set = 1:setsAvailable
                % randomly chose n amount of males faces from POOLS (0's are
                % available)
                stims2select_males{sess}{set} = datasample(find(POOLS.faces_M{set}==0),...
                                                            males2selectPerSet(set),'Replace',false);
                                                                   
                % set the choses indices to 1 so they won't be sampled next
                % iteration
                POOLS.faces_M{set}(stims2select_males{sess}{set}) = 1;

                % select and store the full paths to those images/stimuli
                faces_male_selection{sess} = [faces_male_selection{sess}; faces_male{set}(stims2select_males{sess}{set})];

                % FEMALES
                 stims2select_females{sess}{set} = datasample(find(POOLS.faces_F{set}==0),...
                                                              females2selectPerSet(set),'Replace',false);

                % set the choses indices to 1 so they won't be sampled next
                % iteration
                POOLS.faces_F{set}(stims2select_females{sess}{set}) = 1;

                % select and store the full paths to those images/stimuli
                faces_female_selection{sess} = [faces_female_selection{sess}; faces_female{set}(stims2select_females{sess}{set})];

            end

            % distractor selection without repetition between sessions
            stims2select_distractors{sess} = datasample(find(POOLS.distractors==0),...
                  nrDistractors,'Replace',false);  
            POOLS.distractors(stims2select_distractors{sess}) = 1;
            distractor_selection{sess} = [distractor_selection{sess}; distractors(stims2select_distractors{sess})];

            % for back grounds we randomly sample stimsPerSess integers from the 
            % total of different backgrounds we have WITH replacement 
            stims2select_backgrounds{sess}  = datasample([1:numel(backgrounds)], stimsPerSess,'Replace',true);
            background_selection{sess}      = backgrounds(stims2select_backgrounds{sess});

        end % of stimuli selection routine

        % assamble the stims to be processed in one structure with a cell for each
        % stim category. This variable will be looped over below.
        stims2process{1}        = faces_male_selection;
        stims2process{2}        = faces_female_selection;
        stims2process{3}        = distractor_selection;
        backgrounds2process     = background_selection;
        
        % create logical structure for looping
        stims2process_logical = {};
        for ii = 1:length(stims2process)
            class_logical(ii) = 1;
            for jj = 1:length(stims2process{ii})
                sess_logical(ii,jj) = 1;
                tmpNR = length(stims2process{ii}{jj});
                stims2process_logical{ii}{jj} = ones(1,tmpNR);
            end
        end
                       
        % =================================================================
        % ================= STIMULI POSITION SELECTION ====================
        % Info:
        % Here we will create a vector that pseudo randomizes the stimuli
        % position on the background (equal reps per location, randomized)
        % =================================================================

        % Pseudo randomize screen position of stimulus. We will have 8 possible
        % locations. 8 locations should be used about equally within each session.
        % Create vector with about equal intergers to 8 
        nr_locations        = 8;
        fixed_repsPerSess   = fix(stimsPerSess/nr_locations); % each loc is repeated at least this many times
        remainder           = rem(stimsPerSess,nr_locations); % this is the remainder to be allocated to one of the locs

        % nr of reps per location per session 
        repsPerSessVec          = repmat(fixed_repsPerSess, 1, nr_locations); 
        
        repsPerSess = [];
        for this_sess = 1:nrStimSets2generate     
            %(re)-set to minimal reps per session
            tmpVec = repsPerSessVec;         
            % randomly select remainder amount of locations
            tmpDice                 = randperm(nr_locations, remainder);                  
            % add one rep to those locations
            tmpVec(tmpDice) = tmpVec(tmpDice) + 1;  
            % save in variable 
            repsPerSess = [repsPerSess; tmpVec];
            
        end
        % here we loop over nr of locations (8) and for each loctions we add the
        % location nr to a long vector stim_pos repsPerSessVec amount of time. 
        % now we have nr trials long vector with the location nr's repeated x
        % amount of time: [1 1 1 1 1 1 2 2 2 2 2 2 3 3 3 3 3 3 ...] (3 repeats one
        % more time than the others as determined by tmpDice.
        tc = 1;
        for dd = 1:size(repsPerSess,1)
            for ii = 1:nr_locations
                for jj = 1:repsPerSess(dd,ii)
                    stim_pos(1,tc) = ii;
                    tc = tc+1;
                end
            end
        end

        % shuffel stim_pos order and done! 
        stim_pos_shuffeled = stim_pos(randperm(numel(stim_pos),numel(stim_pos)));
        
    end
    
    if render_stimSets  == 1
        
        % =================================================================
        % ================= STIMULI RENDERING ROUTINE =====================
        % Info:
        % Below we will construct the above constructed daughter stim set
        % for this subject. The routine involves looping over the different
        % classes, copying and pasting the the stims to their backgrounds
        % at the predetermined screen locations before passing that final
        % stim through the noise pipeline X amount of times.
        % =================================================================
        
        f = waitbar(0,'1','Name', ['Rendering Stimuli...'],...
                    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
        setappdata(f,'canceling',0);
       
        % For each stimulus class (seperate cells in stims2process)
        for stimclass = find(class_logical==1)
%         for stimclass = 1:numel(stims2process)
            
            % for each session (cells in stims2process(stimclass)
            for session = find(sess_logical(stimclass,:)==1)
%             for session = 1:numel(stims2process{stimclass}) 
                user_fb_update({['Working on: StimClass ' num2str(stimclass) ' | Session ' num2str(session)]},0,1);
                
                % root directory for current session
                rootDir2go =  [projFolder, filesep, subID, filesep, 'Session_0' num2str(session),...
                               filesep, 'TaskFolder' ,filesep, 'StimSets'];

                % for each unique stimulus (full paths, row wise)
                for thisStim = find(stims2process_logical{stimclass}{session}==1)
%                 for thisStim = 1:size(stims2process{stimclass}{session},1)

                    % Specify stimulus directories
                    % directory: Renderings (the final clean renderings)
                    stim_dir_renderings         = [rootDir2go, filesep, 'BaseSets', filesep, 'Renderings',...
                                                   filesep, folder_names{stimclass}];

                    % directory: Stimuli (the untouched stimuli selected for this sub)
                    stim_dir_stimuli            = [rootDir2go, filesep, 'BaseSets', filesep, 'Stimuli',...
                                                  filesep, folder_names{stimclass}];

                    % directory: NoisedRenderings (the final images with different noise levels used for the task)
                    stim_dir_noisedRenderings   = [rootDir2go, filesep, 'TaskStims', filesep, folder_names{stimclass},...
                                                   filesep, num2str(thisStim)];

                    % create stim dir's if they don't exist (probably the case at first iteration))
                    if ~exist(stim_dir_renderings, 'dir'), mkdir(stim_dir_renderings),end
                    if ~exist(stim_dir_stimuli, 'dir'), mkdir(stim_dir_stimuli),end
                    if ~exist(stim_dir_noisedRenderings, 'dir'), mkdir(stim_dir_noisedRenderings),end

                    % get the stimulus paths, the background to use and the screen
                    % position of the current trial. 
                    stim_fname  = stims2process{stimclass}{session}{thisStim};
                    bg_fname    = backgrounds2process{session}{thisStim};
                    screenPos   = stim_pos_shuffeled(totTrialCounter);

                    % Read the images into working space and resize them 
                    % Stimulus
                    im_stim     = imread(stim_fname);
                    im_stim     = imresize(im_stim,1.5);

                    % Background
                    im_bg = imread(bg_fname);
                    im_bg = imresize(im_bg,3.5);

                    % copy background to new image variable
                    new_stim = im_bg;
                    new_edge = zeros(size(im_bg));

                    % get size of the image background (final stims size)
                    stim_size = size(im_bg);

                    % get xy coords of a circle of specific radius
                    radius      = 120;
                    theta       = linspace(0,2*pi,400); % 400 is nr of points on circle
                    x           = radius*cos(theta);
                    y           = radius*sin(theta);

                    % select several along this line (8 is HARDCODED!)
                    x_sel       = round(x(1,1:(numel(x)/8):end));   
                    y_sel       = round(y(1,1:(numel(y)/8):end));

                    % store in XY locations used for copy pasting stim to bg
                    % Note: Circle coords run counter clockwise starting North East
                    XYs         = [x_sel' y_sel'];

                    % update xy coords to center on center of BG image
                    XYs(:,1)    = XYs(:,1) + stim_size(1)/2;
                    XYs(:,2)    = XYs(:,2) + stim_size(2)/2;

                    % [xx,yy] = ind2sub(size(im_stim),1:numel(im_stim));  
                    % xx_yy = [xx' yy'];

                    % get first stim mask (this includes the black countour and potential zero stim elements)
                    stim_mask = im_stim~=0;

                    % EDGE based mask routine: set stim 0 elements back to one
                    edge1        = edge(stim_mask,'Canny', [0.1 0.99]); % detect edge of stim
                    
                    % make sure that the edge is continuous (some complex
                    % shapes are broken). This works but is not perfect! 
                    se      = strel('disk',1,0);
                    edge1   = imclose(edge1,se); 
                    
                    % fill the edge (we have a mask)
                    edge_filled = imfill(edge1, 'holes');              
                    
                    % differential mask gives us: zero pixels that are
                    % within the edges of the actual stim.
                    % --- --- --- --- --- --- --- --- --- --- --- --- --- 
                    % stim_mask may contain zero elements that are part of
                    % the stim (e.g. black in the eyes). Edge filled holds
                    % ones for stim related pixels. Subtracting them
                    % results in idntifying those pixels: 1 - 0 = 1
                    % other are: 1 - 1 = 0, and 0 - 0 = 0;
                    differential_mask = edge_filled - stim_mask;
                    
                    % set the differential_mask pixels back to one: they
                    % are part of the stimulus
                    stim_mask(differential_mask==1) = 1;

                    % now shave off line by line the edges nrPass amount of passes,
                    % this we do to get rid of annoying black line around stims..
                    nrPass = 5;
                    for pass = 1:nrPass
                        % detect edge of mask - logical matrix with 1's for edge pixels
                        edge_stim               = edge(stim_mask,'Canny', [0.1 0.99]);

                        % set those edge pixels to 0 (black) this effectivley moves up the edge
                        % by one pixel for the next itteration/pass
                        stim_mask(edge_stim)    = 0;

                        % show the line detection
        %                 figure; imshow(edge_stim);
                    end

                    % now we find all the non-zeros elements of the stimulus image - seperates
                    % stim from black background (0's)
                    [stim_r, stim_c] = find(stim_mask==1); % returns row = y and col = x
                    stim_xy = [stim_c, stim_r];
                    
                    [edge_r, edge_c] = find(edge_stim==1); % returns row = y and col = x
                    edge_xy = [edge_c, edge_r];

                    stim_values = im_stim(stim_mask);
                    stim_centre = find_center(stim_mask, 1)'; % stim_centre(1) = column = y

                    % first center xy coords of image to it's center of mass
                    % Note: stim_centre(2) = row = x AND stim_centre(1) = column = y
                    stim_xy_centred = [stim_xy(:,1)-stim_centre(2) stim_xy(:,2)-stim_centre(1)];
                    edge_xy_centred = [edge_xy(:,1)-stim_centre(2) edge_xy(:,2)-stim_centre(1)];

                    % now change the xy coords relative to the center position on the gb image
                    new_stim_xy = [stim_xy_centred(:,1) + XYs(screenPos ,1),...
                                   stim_xy_centred(:,2) + XYs(screenPos ,2)];
                               
                    new_edge_xy = [edge_xy_centred(:,1) + XYs(screenPos ,1),...
                                   edge_xy_centred(:,2) + XYs(screenPos ,2)];                               
                               

                    % get the (bg dimension) indeces with those xy coords
                    I = sub2ind(size(new_stim),new_stim_xy(:,2),new_stim_xy(:,1));
                    
                    I2 = sub2ind(size(new_stim),new_edge_xy(:,2),new_edge_xy(:,1));

                    % change bg vixel values with the stim values (copy & pasting)
                    new_stim(I)     = stim_values;
                    new_edge(I2)    = 1;
                    
                    % smooth the edges of the stimulus into the background
                    if stimclass == 3
                        smoothKernel    = 2;
                        blurRadius      = 4;
                    else
                        smoothKernel    = 3;
                        blurRadius      = 7;
                    end
                    
                    [new_stim] = smooth_edges( new_stim, new_edge, smoothKernel, blurRadius);
               
                    % add white square to visualize center of mass
                    % new_stim([XYs(4,1)-5:XYs(4,1)+5], [XYs(4,2)-5:XYs(4,2)+5]) = 255;

                    % draw the new stim and visualize the circle and the possible stim
                    % locations on the image
        %             figure;imshow(new_stim)
        %             hold on
        %             scatter(XYs(:,1), XYs(:,2), 'filled', 'y')
        %             plot(XYs(:,1), XYs(:,2), 'LineWidth', 2)

                    % at this point we want to save the rendered image to subject
                    % specific stims folder where the untouched 'base' stimuli are
                    % kept
                    imwrite(new_stim, [stim_dir_renderings, filesep, num2str(thisStim) '.png'])

                    % save the stimulus as well for the familiarization task.
                    imwrite(im_stim, [stim_dir_stimuli, filesep, num2str(thisStim) '.png'])

                    % ------------------------------------------------------------------------
                    % Noising Routine
                    % ------------------------------------------------------------------------

                    % create blurr filters of different strengths for uniform blurr
                    % filter - we don't use this one
        %             filter_sizes = [100:-1:1];
        %             for filter = 1:numel(filter_sizes)
        %                 tmp_sz = filter_sizes(filter);
        %                 tmp_div = filter_sizes(filter)*filter_sizes(filter);
        % 
        %                 tmp_f=ones(tmp_sz,tmp_sz)/tmp_div;
        % 
        %                 all_filters{filter} = tmp_f;
        %             end

                    % gaussian kernel sizes for gaussian filter - this one is
                    % implemented
% %                     sigmas          = 10:-0.1:0.1;      
                    sigmas          = 10:-0.083:0.083;

                    % degree of phase scramble
%                     noisetoasses    = 0.4:0.0023:0.75;
%                     noisetoasses    = 0.2:0.0037:0.75;

                    noisetoasses    = 0.25:0.0025:0.7475;

                    % Specify some presets for phase scrambling routine
                    a                   = 0;
                    b                   = 0;
                    stretchfactorSize1  = 2;
                    stretchfactor       = stretchfactorSize1;

                    original_image = double(new_stim); % imna mes{unique_image};
                    % original_image = new_stim;

                    % here the images of different noise/phase scrambling are
                    % created and written to final destination
%                     tic
                    for single_im = 1:numel(noisetoasses)
                        
                        % check for cancelling image rendering routine by
                        % user
                        if getappdata(f,'canceling')
                            delete(f)
                            user_fb_update({'Image Rendering CANCELLED by user!'},0,2)    
                            
                            % savew process untill now
                            save([workspaceDir2save2, filesep, 'StimSets_sub_' num2str(subID)])
                            return
                        end
                        
                        % Update waitbar and message
                        waitbar(totTrialCounter/totNrtrials,f,...
                            ['Rendering stimulus: ' num2str(totTrialCounter) '/' num2str(totNrtrials)...
                             ' | image: ' num2str(single_im) '/' num2str(numel(noisetoasses))])
                        
                        % ------------- Guassian Smoothing Routine (Start) --------

                        % we only blurr the image for the number of sigmas
                        % specified in sigmas. The remaining images will not be
                        % blurred but only phase scrambled. 
                        if single_im < numel(sigmas)   % numel(all_filters)
                            image = imgaussfilt(original_image,sigmas(single_im));
                        else 
                            % when we are out of sigma's we take the original
                            % (clear) image and run that through the phase
                            % scrambling routine
                            image = original_image;
                        end

                        % ------------- Guassian Smoothing Routine (End) ----------

                        % ------------- Phase Scrambling Routine (Start) ----------

                        image       = image-mean(image(:));
                        imagefft    = fft2(image);
                        imageamp    = abs(imagefft);
                        imageph     = angle(imagefft);
                        [n,m]       = size(imageamp);
                        rmsc        = std2(image);
                        ctRect      = [a-n/2*stretchfactor b-m/2*stretchfactor a+n/2*stretchfactor b+m/2*stretchfactor];
                        randphase   = 2*pi*rand(n,m)-pi;
                        Sphase      = noisetoasses(single_im).*sin(imageph)+(1-noisetoasses(single_im)).*sin(randphase);
                        Cphase      = noisetoasses(single_im).*cos(imageph)+(1-noisetoasses(single_im)).*cos(randphase);

                        for row = 1:n
                            for column = 1:m
                                if 	Sphase(row,column) > 0 && Cphase(row,column) > 0
                                    imageph_rand(row,column) = atan(Sphase(row,column)./Cphase(row,column));
                                elseif Cphase(row,column) < 0
                                    imageph_rand(row,column) = atan(Sphase(row,column)./Cphase(row,column)) + pi;
                                elseif Sphase(row,column) < 0 && Cphase(row,column) > 0
                                    imageph_rand(row,column) = atan(Sphase(row,column)./Cphase(row,column)) + 2.*pi;
                                end
                            end
                        end
                        image_rand = real(ifft2(imageamp.*exp(sqrt(-1)*imageph_rand)));
                        image_rand = image_rand.*sqrt((rmsc.^2)/(std2(image_rand)).^2);
                        image_rand = image_rand+98; % add 98 to scale back to 255 color range
                        image_rand = uint8(image_rand);

                        % ------------- Phase Scrambling Routine (End) ----------

                        % Write the signle noised renderings to stim_dir         
                        imwrite(image_rand,[stim_dir_noisedRenderings, filesep, num2str(single_im) '.png'], 'png')

                    %   image = image / 255;
                    %   imwrite(image, [currdir, filesep, num2str(single_im) '.png'],'png');% 

                       clear image_rand
                    end
%                     toc

                    totTrialCounter = totTrialCounter  + 1;
                    
                    % mark stim as rendered
                    stims2process_logical{stimclass}{session}(thisStim) = 0;
                    
                    % trial by trial save excluding graphics handles.. 
                    % Get a list of all variables
                    allvars = whos;

                    % Identify the variables that ARE NOT graphics handles. This uses a regular
                    % expression on the class of each variable to check if it's a graphics object
                    tosave = cellfun(@isempty, regexp({allvars.class}, '^matlab\.(ui|graphics)\.'));

                    % Pass these variable names to save
                    save([workspaceDir2save2, filesep, 'StimSets_sub_' num2str(subID)], allvars(tosave).name)    
                
                end
                
                % mark session as completed
                sess_logical(stimclass,session) = 0;
                
            end
            
            % mark stim class as completed
            class_logical(stimclass) = 0 ;
        end
      
        endTime = toc;  
        user_fb_update({['Image Rendering COMPLETED in: ' num2str(endTime/60) ' minutes']},0,4)
        delete(f)
        
        % save workspace to TaskFolder session one (contains information on
        % both StimSets for both sessions
        save([workspaceDir2save2, filesep, 'StimSets_sub_' num2str(subID)])
    end
   
end