function creat_fam_param(subID, projFolder, Sess)

%     rng('shuffle');

    % how many 1-back repititions? 
    rep_per_class = 5;

    % prepare stimulation order
    % we take 10 out of 50 for faces and 10 out of 35 for the contrast
    % condition
    encoded_faces      = randperm(39,10);      % select and shuffle face stims for familiarization
    encoded_contr      = randperm(35,10);

    % each stim will be reapeated three times?
    face_stims  =    repmat(encoded_faces(randperm(numel(encoded_faces))),1,4);
    contr_stims =    repmat(encoded_contr(randperm(numel(encoded_contr))),1,4);

    stim_list = [ones(1,numel(face_stims)) ones(1,numel(contr_stims))+1];   % stim class in row one (faces=1)
    stim_list = [stim_list; face_stims contr_stims];                        % stim id in row two

    shuffle = randperm(size(stim_list,2));      % make shuffle indexer
    stim_list_shuff = stim_list(:,shuffle);     % use to shuffle stim mat

    face_id  = find(stim_list_shuff(1,:)==1);        % retrieve all face positions in list
    contr_id = find(stim_list_shuff(1,:)==2);        % retrieve all contr positions in list

    % randomly select which stims to repeat
    % we randomly select a X amount of indices within the total_stim_list of each class
    % here we make sure that equal nr of classes are repeated.
    repeat_face     = face_id(randperm(length(face_id),rep_per_class));
    repeat_contr    = contr_id(randperm(length(contr_id),rep_per_class));

    repeated_face_ids   = stim_list_shuff(2,repeat_face);
    repeated_contr_ids  = stim_list_shuff(2,repeat_contr);

    stim_list_final = [];
    deleted_faces = [];
    deleted_contr = [];
    for ii = 1:size(stim_list_shuff,2)
        if stim_list_shuff(1,ii) == 1
            
            if ismember(ii, repeat_face) 
                % here we compare the trial number with whether it was included
                % in the repeat_face vector. The repeat face vector contains a
                % random selection of the cells within the total stim vecor
                % that contain faces.  So if the first value in repeat_face is
                % a 9, it means the 9th element in the total stim vector is a
                % face and we should repeat it.
                stim_list_final = [stim_list_final stim_list_shuff(:,ii) stim_list_shuff(:,ii)];

            elseif ismember(stim_list_shuff(2,ii),repeated_face_ids) && ~ismember(ii, repeat_face)...
                    && sum(deleted_faces == stim_list_shuff(2,ii)) < sum(repeated_face_ids == stim_list_shuff(2,ii))
                % here we check wether to skip the current item or not. The
                % goal is to correct for the repetitions so that no stimulus is
                % presented more than the other. it's ugly bit it works.
                % - if the current face id is part of the to be repeated stims
                % ( in which case we might have to skipp the current ii) AND if
                % it is not actually the one that needs to be repeated AND if
                % the times this face was skipped ( in case of doubles ) is
                % still less than the number of times it will be repeated, we
                % skip it and we add the skip to the deleted_faces variable.          
                deleted_faces = [deleted_faces stim_list_shuff(2,ii)];
            else
                % for all the other instances we simply add to the final list
                stim_list_final = [stim_list_final stim_list_shuff(:,ii)];
            end
        elseif stim_list_shuff(1,ii) == 2
            
            if ismember(ii, repeat_contr)
                stim_list_final = [stim_list_final stim_list_shuff(:,ii) stim_list_shuff(:,ii)];

            elseif ismember(stim_list_shuff(2,ii),repeated_contr_ids) && ~ismember(ii, repeat_contr)...
                    && sum(deleted_contr == stim_list_shuff(2,ii)) < sum(repeated_contr_ids == stim_list_shuff(2,ii))  
                
                deleted_contr = [deleted_contr stim_list_shuff(2,ii)];
            else
                stim_list_final = [stim_list_final stim_list_shuff(:,ii)];
            end
        end

    end
    % save encoded stim to be loaded prior to NFB runs
    save([projFolder, filesep subID, filesep, Sess, filesep, 'TaskFolder', filesep,...
        'stimParams', filesep, 'encStims_sub' subID '_' Sess], 'encoded_faces', 'encoded_contr')
    % save the familiarization paramters to be run for the fam task
    save([projFolder, filesep subID, filesep, Sess, filesep, 'TaskFolder', filesep,...
        'stimParams', filesep, 'FAM_task_param_' subID '_' Sess])
    
    % report back to user
    user_fb_update({'Encode stimuli and famTask parameters: SAVED'}, 0, 1)
end