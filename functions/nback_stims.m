function [stims2rep] = nback_stims(stimlist,class_id, nback_stim_ids)

    % stimlist          = stim_list_shuff;
    % nback_stim_ids    = nback_males
    % class_id          = male_id

    stims2rep = [];

     for stim2rep = 1:numel(nback_stim_ids)
        nback_idx = intersect(class_id,find(ismember(stimlist(2,:),nback_stim_ids(stim2rep))==1));

        repthisstim = nback_idx(randperm(numel(nback_idx),1));

        stims2rep = [stims2rep repthisstim];
     end

end

