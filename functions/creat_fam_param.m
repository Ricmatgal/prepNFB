function creat_fam_param(subID, projFolder, Sess)

    % Below a subset of stims is selected from the daughter stimset of this
    % session for this subject. The selected stimuli are used for the
    % familiarization task which is a simple 1-back task. After the
    % inidivudal stims are selected an ordering is generated whereby a
    % certain number of each sub category are reapeated back to back (the
    % one back trials). The selected stimuli here are referred to as the
    % encoded_stimuli. These are encoded_stimuli are saved in a mat file
    % that is later on loaded by the create_task_param.mat function. Here
    % the encoded_stims are marked in the results.key structure so we can
    % later find them back. 
    
    % image type of the stimuli used
	imType = 'png';
    
    % stims to be selected for the familiarization task per category. It is
    % expressed as a percentage of the total number of stimuli available in
    % each category. The totals are determined below based on how many
    % stimuli are found in each folder. In effect, the actual NRs are
    % dictated by how many images are generated. This is done so we don't
    % unnecaseraly render more images than needed and because during the
    % rendering gender and parent set are already balanced. 
    frac_faces2remember = 0.50; % percent of all faces
    frac_distr2remember = 0.50; % percent of all distractors
    frac_males          = 0.50; % percent of male_faces to remember (of faces2remeber)
    frac_females        = 0.50; % percent of female_faces to remember (of faces2remeber)
    
    % root directory of the intact stims, used for the memorization task.
    % These were seperataly saved during the rendering process..
    rootDir2get =  [projFolder, filesep, subID, filesep, Sess, filesep, 'TaskFolder',...
        filesep, 'StimSets', filesep, 'BaseSets', filesep, 'Stimuli'];
    
    % folder names for stimuli to be retrieved from
    folder_names = {['FACES', filesep, 'male'], ['FACES', filesep, 'female'], 'OTHER'};
    
    % Read in all the stims 'pyshisically' available in the stimset folders
    check4males         = dir(fullfile([rootDir2get, filesep, folder_names{1}], '**', ['*.' imType]));
    check4females       = dir(fullfile([rootDir2get, filesep, folder_names{2}], '**', ['*.' imType]));
    check4distractors   = dir(fullfile([rootDir2get, filesep, folder_names{3}], '**', ['*.' imType]));
    
    % Count how many stimuli per category we have to our disposal
    total_nr_males      = numel(check4males);
    total_nr_females    = numel(check4females);
    total_nr_faces      = total_nr_males+total_nr_females;
    total_nr_distr      = numel(check4distractors);
    
    % Determine how many faces and distractors to select for the n-back
    nr_faces2select     = ceil(total_nr_faces*frac_faces2remember);
    nr_distr2select     = ceil(total_nr_distr*frac_distr2remember);
    
    % Randomly select if more male or female in sess1 and reverse for
    % sess2. If nrTargets can be devided in two this operation will have no
    % effect and the nr male female are equal.
    rolDice = randperm(2,1);
    if rolDice == 1
        males2select             = ceil(nr_faces2select*frac_males);
        females2select           = floor(nr_faces2select*frac_females);
    elseif rolDice == 2
        males2select            = floor(nr_faces2select*frac_males);
        females2select          = ceil(nr_faces2select*frac_females);
    end
   
    % prepare stimulation order
    encoded_faces_male        = randperm(total_nr_males,males2select);      % select and shuffle face stims for familiarization
    encoded_faces_female      = randperm(total_nr_females,females2select);
    encoded_contr             = randperm(total_nr_distr,nr_distr2select);

    % how many 1-back repititions per class? 
    reps_per_class  = 1/3;  % proportion of class
    stim_reps       = 3;    % total number all stims are repeated during the task
    
    nback_faces     = ceil(nr_faces2select*reps_per_class);
    nback_males     = encoded_faces_male(randperm(males2select, round(nback_faces/2)));
    nback_females   = encoded_faces_female(randperm(females2select, round(nback_faces/2)));
    nback_distr     = encoded_contr(randperm(nr_distr2select, ceil(nr_distr2select*reps_per_class)));
    
    % each stim will be reapeated stim_reps amount of times
    % encoded stim vectors are repeated X amount of times.
    male_stims      =    repmat(encoded_faces_male(randperm(numel(encoded_faces_male))),1,stim_reps);
    female_stims    =    repmat(encoded_faces_female(randperm(numel(encoded_faces_female))),1,stim_reps);
    contr_stims     =    repmat(encoded_contr(randperm(numel(encoded_contr))),1,stim_reps);
   
    % pop 1 random instance of the nback stims from the full list to
    % correct for the nback repetition implemeneted below. 
    male_stims      = poplist(male_stims, nback_males);
    female_stims    = poplist(female_stims, nback_females);
    contr_stims     = poplist(contr_stims, nback_distr);
    
    % here we assamble total stim list with all the stims per category
    % repeated stims_rep times. The category is indicated in row 1: 1 for
    % males, 2 for females and 3 for animals/distractors.
    stim_list = [ones(1,numel(male_stims)), ones(1,numel(female_stims))+1 ones(1,numel(contr_stims))+2];   % stim class in row one (faces=1)
    % the second row points to the indiviudal stim/image number within that
    % category. If (1,1) = 1 and (2,1) = 15. The first stimulus is male nr 15 
    stim_list = [stim_list; male_stims, female_stims, contr_stims];                        % stim id in row two
    
    % The stim_list is currently ordered by category (we entered males
    % first, then females and then animals). Here we shuffle the entire
    % list randomly so we have a nice random presentation mix.
    shuffle = randperm(size(stim_list,2));      % make shuffle indexer
    stim_list_shuff = stim_list(:,shuffle);     % use to shuffle stim mat
    
    % here we will record which trials will need to be repeated: 1's. This
    % will result in a controlled way of assembling the final stim list.
    repeat_vector = zeros(1,length(stim_list_shuff));
    
    % we want to know the column indices of the different catefories in the
    % shuffled complete stimulation lists. This so we can repeate a random
    % selection of each category below
    male_id     = find(stim_list_shuff(1,:)==1);        % retrieve all male positions in list
    female_id   = find(stim_list_shuff(1,:)==2);        % retrieve all female positoins in list
    contr_id    = find(stim_list_shuff(1,:)==3);        % retrieve all contr positions in list
    
    % Select in a controlled fashion which stims need to be nbacked
    males2rep   = nback_stims(stim_list_shuff,male_id, nback_males);
    females2rep = nback_stims(stim_list_shuff,female_id, nback_females);
    contr2rep   = nback_stims(stim_list_shuff,contr_id, nback_distr);
    
    % set those trials to one in the repeat vector
    repeat_vector(males2rep)    = 1;
    repeat_vector(females2rep)  = 1;
    repeat_vector(contr2rep)    = 1;
    
    % Randomly select, by cateogry, which stims to repeat
    % we randomly select a X amount of indices within the total_stim_list of each class
    % here we make sure that equal nr of classes are repeated.
    % E.g. male ID contains the abolsute IDx of all males in the whole stim_list_shuffled
    % At this moment it is possible that the same individual stimuli
    % (within class) are selected to  be repeated more then once!
% % %     repeat_male     = male_id(randperm(length(male_id),reps_per_class));    
% % %     repeat_female   = female_id(randperm(length(female_id),reps_per_class));
% % %     repeat_contr    = contr_id(randperm(length(contr_id),reps_per_class));
    
    % retrieve stimuli ID number corresponding to their nr within the
    % category (and file name in folder!).
% % %     repeated_male_ids       = stim_list_shuff(2,repeat_male);
% % %     repeated_female_ids     = stim_list_shuff(2,repeat_female);
% % %     repeated_contr_ids      = stim_list_shuff(2,repeat_contr);
    
    % here we start to assamble the final stimuli list ordering. It's a bit
    % of a complicated routine but it works! We start by initializing some
    % variables that we will fill as we go along. 
    stim_list_final     = [];
    
    % Because we will repeat certain individuals we we also need to delete
    % that individual up the list (stim_list_shuff)in the list to guarantee 
    % that we do not repeat the same individual more than the stims_rep value.
% % %     deleted_males       = [];
% % %     deleted_females     = [];
% % %     deleted_contr       = [];
    % we start looping over stim_list entries column wise (trial by trial) 
    for ii = 1:size(stim_list_shuff,2)
        
        if repeat_vector(1,ii) == 1
            stim_list_final = [stim_list_final stim_list_shuff(:,ii) stim_list_shuff(:,ii)];
        else
            stim_list_final = [stim_list_final stim_list_shuff(:,ii)];
        end

    end
    
    % save encoded stim to be loaded prior to NFB runs
    save([projFolder, filesep subID, filesep, Sess, filesep, 'TaskFolder', filesep,...
        'stimParams', filesep, 'encStims_sub' subID '_' Sess], 'encoded_faces_male', 'encoded_faces_female', 'encoded_contr')
    
    % save the familiarization paramters to be run for the fam task
    save([projFolder, filesep subID, filesep, Sess, filesep, 'TaskFolder', filesep,...
        'stimParams', filesep, 'FAM_task_param_' subID '_' Sess])
    
    % report back to user
    user_fb_update({'Encode stims / famTask parameters: SAVED'}, 0, 1)
end