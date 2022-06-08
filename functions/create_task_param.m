function create_task_param(subID, projFolder, Sess)

%     rng('shuffle')

    imType = 'png';

    nrRuns = 7;
    sca
    
    % load the faces encoded in memory 
    load([projFolder, filesep, subID, filesep, Sess, filesep, 'TaskFolder',...
          filesep, 'stimParams', filesep, 'encStims_sub' subID '_' Sess])
     
      % root directory of the intact stims, used for the memorization task.
    rootDir2get =  [projFolder, filesep, subID, filesep, Sess, filesep, 'TaskFolder',...
                    filesep, 'StimSets', filesep, 'BaseSets', filesep, 'Stimuli'];
    
    rootDirTaskStims = [projFolder, filesep, subID, filesep, Sess, filesep,...
                        'TaskFolder', filesep, 'StimSets', filesep, 'TaskStims'];
    
    % folder names for stimuli to be retrieved from
    folder_names = {['FACES', filesep, 'male'], ['FACES', filesep, 'female'], 'OTHER'};

    check4males         = dir(fullfile([rootDir2get, filesep, folder_names{1}], '**', ['*.' imType]));
    check4females       = dir(fullfile([rootDir2get, filesep, folder_names{2}], '**', ['*.' imType]));
    check4distractors   = dir(fullfile([rootDir2get, filesep, folder_names{3}], '**', ['*.' imType]));
    
    total_nr_males      = numel(check4males);
    total_nr_females    = numel(check4females);
    total_nr_faces      = total_nr_males+total_nr_females;
    total_nr_distr      = numel(check4distractors);
    
    total_nr_stims      = total_nr_faces + total_nr_distr;
    stims_per_run       = total_nr_stims / nrRuns;

    % prepare stimulation order
    male_order      = randperm(total_nr_males,total_nr_males);      % shuffle face stims (we have 35 face stims)
    female_order    = randperm(total_nr_females,total_nr_females);   
    contr_order     = randperm(total_nr_distr,total_nr_distr);      % shuffle animal order

    % here we iniate the two stim classes (general_order): 1 for faces, 2 for
    % animals
    % in addition we create a task order: 1 for detection only, 2 for
    % idenity judment only, 3 for both.
% % %     general_order   = [ones(1,total_nr_males), ones(1,total_nr_females)+1, ones(1,total_nr_distr)+2];   % faces or animals
    
    % !!!
    % Alternativley we control the number of repetitions of the different
    % categories within the same run..
    
    % determine how many equal nr of males can be divided over the nr of
    % runs (depends on the total nr of males, which may vary from session
    % to session). We right away extend this nr to the nrRuns, so we can
    % loop over it below
    nr_faces_per_run    = repmat(fix(total_nr_faces / nrRuns), 1, nrRuns);
    rem_faces           = rem(total_nr_faces, nrRuns);
   
    nr_distr_per_run   = repmat(fix(total_nr_distr / nrRuns), 1, nrRuns);
    rem_distr           = rem(total_nr_distr, nrRuns);
    
    nr_males_per_run    = repmat(fix(total_nr_males / nrRuns),1,nrRuns);
    rem_males           = rem(total_nr_males, nrRuns); % the remainder that still need to be allocated
    
    nr_females_per_run   = repmat(fix(total_nr_females / nrRuns), 1, nrRuns);
    rem_females           = rem(total_nr_females, nrRuns);
    
    % randomly allocate the remainers to a run
    random_run_selection    = randperm(nrRuns,(rem_males+rem_females)); % select randomly runs
    
    % aggregate vector indicating which randomly selected runs go to which
    % gender: 0 males, 1 females --> we use this to index the right runs
    % for the right genders.
    A = [zeros(1,rem_males) ones(1,rem_females)];
    nr_males_per_run(random_run_selection(A==0))     = nr_males_per_run(random_run_selection(A==0)) + 1; 
    nr_females_per_run(random_run_selection(A==1))   = nr_males_per_run(random_run_selection(A==1)) + 1; 

    
    order_by_run = [];
    for run = 1:nrRuns
        run2add = [ones(1,nr_males_per_run(run)), ones(1,nr_females_per_run(run))+1,...
                   ones(1,nr_distr_per_run(run))+2];
               
        run2add_shuff = run2add(randperm(numel(run2add)));
        
        order_by_run    = [order_by_run; run2add_shuff];
        
    end
    
    % this is a shuffle vector that we can use to randomize our conditions and
    % tasks in a controlled manner (i.e. apply same shuffle to multiple
    % vectors)
% % %     shuf    = randperm(numel(general_order));

    % apply the shuffle
% % %     general_order   = general_order(shuf);

    % break up in X runs
% % %     general_order = reshape(general_order,total_nr_stims/nrRuns, nrRuns)';
    
    % how many images per trial?  
    stimnrs         = 1:numel(dir(fullfile(rootDirTaskStims, filesep, folder_names{1},...
                                   filesep, '1', filesep,  '**', ['*.', imType])));    
        
    % experiment loop
    male_c      = 1;
    female_c    = 1;
    contr_c     = 1;
    
    % for X runs (rows of order_by_run mat)
    for row = 1:size(order_by_run,1) % general_order
        
        user_fb_update({['Loading images run: ' num2str(row)]},0,1);        
   
        tic
        trial = 1;
        % for X trials (columns of order_by_run mat)
        for col = 1:size(order_by_run, 2) % general_order
            %select stimulus based on general order (male, female or distr) and according
            %to class order (old or new)
            % MALE
            if order_by_run(row, col) == 1 % general_order(row, col)
                this_male = male_order(male_c);
                subfolder = folder_names{1};

                % full path to stimulus
                target_path = [rootDirTaskStims, filesep, subfolder, filesep,...
                               num2str(this_male)];

                % record condition order
                results.condition_order{row, col} = 'faces_male';

                if ismember(this_male,encoded_faces_male)
                    results.key{row, col, 1} = 'face_male';    % stim class = face 
                    results.key{row, col, 2} = 'old';          % identity match with memorized (old)
                else
                    results.key{row, col, 1} = 'face_male';      % stim class = face 
                    results.key{row, col, 2} = 'new';       % identity mismatch with memorized (new)
                end

                male_c = male_c+1;

            % FEMALE    
            elseif order_by_run(row, col) == 2
                this_female = female_order(female_c);
                subfolder   = folder_names{2};

                target_path = [rootDirTaskStims, filesep, subfolder, filesep,...
                               num2str(this_female)];

                results.condition_order{row, col} = 'faces_female';

                if ismember(this_female,encoded_faces_female)
                    results.key{row, col, 1} = 'face_female';      % stim class = female face 
                    results.key{row, col, 2} = 'old';              % identity match with memorized (old)
                else
                    results.key{row, col, 1} = 'face_female';      % stim class = female face 
                    results.key{row, col, 2} = 'new';              % identity mismatch with memorized (new)
                end

                female_c = female_c + 1;

            % OTHER
            elseif order_by_run(row, col) == 3
                this_contr = contr_order(contr_c);
                subfolder  = folder_names{3};

                target_path = [rootDirTaskStims, filesep, subfolder, filesep,...
                               num2str(this_contr)];

                results.condition_order{row, col} = 'other';

                if ismember(this_contr,encoded_contr)
                    results.key{row, col, 1} = 'other';    % stim class = animal
                    results.key{row, col, 2} = 'old';       % identity match with memorized (old)
                else
                    results.key{row, col, 1} = 'other';    % face detection
                    results.key{row, col, 2} = 'new';       % identity mismatch with memorized (new)
                end

                contr_c = contr_c +1;
            end
            
            % construc full path variable to the different stims to be
            % loaded per run
            ipaths = [];
            for imgs = 1:numel(stimnrs)
                ipaths = cellstr([ipaths; target_path, filesep, num2str(imgs), '.', imType]);
            end
            I = cellfun(@imread, ipaths,'uni',false);
            
            % resizing stims (do i want this?)
%             I = cellfun(@(x) imresize(x,2), I,'uni',false);

            Stims{trial} = I;
            
            trial = trial + 1;
        end
    
        user_fb_update({['took: ' num2str(toc) ' sec']},0,1);
        
        user_fb_update({'Saving...'}, 0, 1)
        tic
        save([projFolder, filesep subID, filesep, Sess, filesep, 'TaskFolder',...
             filesep, 'stimParams', filesep, 'StimsRun_' num2str(row)], 'Stims');
        user_fb_update({['took: ' num2str(toc) ' sec']}, 0, 1);
      
    end
 
    save([projFolder, filesep subID, filesep, Sess, filesep, 'TaskFolder',...
        filesep, 'stimParams', filesep, 'NFB_task_param_' subID '_' Sess]);
    
    % report back to user
    user_fb_update({'NFB task stimuli and parameters: SAVED'},0,1)
end