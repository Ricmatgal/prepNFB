function [popped_list] = poplist(full_list, idx_2_pop)

    poplist = ones(1,length(full_list));
    
    for this2pop = 1:numel(idx_2_pop)
        whereabouts     = ismember(full_list, idx_2_pop(this2pop));
        whereabouts_idx = find(whereabouts==1);

        pop_one = whereabouts_idx(randperm(numel(whereabouts_idx),1));
        poplist(pop_one) = 0;

    end
    
    popped_list = full_list(find(poplist==1));

end

