function [cxyz] = find_center(space, clust_nr)

   % finds linear center of a mask within 2 or 3D space

%     space = my_atlas_vol;
%     space = ffa_vol;

%     clust_nr = 1;
    
    [r,c,v] = ind2sub(size(space),find(space == clust_nr));
    
    cx = round(mean(r));
    cy = round(mean(c));
    cz = round(mean(v));
    
    cxyz = [cx;cy;cz];
%     
%     [rows, cols] = ndgrid(1:size(originalmatrix, 1), 1:size(originalmatrix, 2));
%     rowcentre = sum(rows(binarisedmatrix) .* originalmatrix(binarisedmatrix)) / sum(originalmatrix(binarisedmatrix));
%     colcentre = sum(cols(binarisedmatrix) .* originalmatrix(binarisedmatrix)) / sum(originalmatrix(binarisedmatrix));
    
end

    
    