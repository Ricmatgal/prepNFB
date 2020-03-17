function [roiFinal] = show_ROIs(subinfo, hROI)

    %% ROI creation: saving clusters, pruning, quality control and saving
    % To do: we still hve to check for NaNs, crosscheck to see if rois are not
    % accidentally overlapping and to see if the ROI files created are
    % correct (all ones and no half values) ultimitaly we also need to see if
    % it works with OpenNFT.

    % set paths 
    subjStructDir   = subinfo.subjStructDir;
    statsdir        = subinfo.statsdir;
    roiPath         = subinfo.roiPath;
    roiSize         = hROI.size;
    roiWhichNR      = hROI.whichNR;
    nrROIs          = length(hROI.ROI);

    % Read hdrs, volumes, create empty volumes and get ROI voxIDs.
    for ii = 1:nrROIs
        %
        hdrs{ii}        = spm_vol(hROI.ROI{ii}.path);       % image hdrs
        rois{ii}        = spm_read_vols(hdrs{ii});          % binary volume
        
        rois_new{ii}    = zeros(size(rois{ii}));            % empty volumes
        voxIDs{ii}      = find(rois{ii} == 1);              % voxIDs
        tmaps{ii}       = spm_read_vols(spm_vol([statsdir, filesep, 'spmT_000' num2str(ii) '.nii']));   % tmap
        tValMasks{ii}   = tmaps{ii}(voxIDs{ii});            % t values of clust voxels
        voxCount(ii)    = numel(voxIDs{ii});                % number of voxels in clust
        
        user_fb_update({['ROI ', num2str(ii), ' cluster has: ', num2str(voxCount(ii)), ' voxels']},0,1);
    end   

     % set final roi size.
     if sum(voxCount>=roiSize) == nrROIs
        % first see if both rois have a voxel count higher than minimum. If
        % so set roisize to user input roiSize
        user_fb_update({['All voxel counts are at or supersede threshhold of: ' num2str(roiSize)];...
           'We will trim them to max, selecting the ones with highest T values'},0,1);
        C = roiSize;
     else
         % In any other case, set the final roisize to size of the smallers
         % mask
         [minCount, minROI] = min(voxCount);
         [maxCount, maxROI] = max(voxCount);
         user_fb_update({[hROI.ROI{minROI}.mskName ' is smaller than ' hROI.ROI{maxROI}.mskName]; 'Setting ROI sizes to smallest'},0,2)
         C = voxCount(minROI);
     end
     
     % select the highest activated roiSize (C) voxels within cluster
     for ii = 1:nrROIs     
        % sort t values with highest on top
        [val{ii}, pos{ii}] = sort(tValMasks{ii}, 'descend');
        % and take top roiSize ids to find real voxel ids within brain matrix
        topVox{ii} =  voxIDs{ii}(pos{ii}(1:C));
     end
    
    % Now that we have both rois we want to make sure that every roi has
    % unique voxels (no overlap). If we find overlap we remove from both.
    all_voxIDs  = cell2mat(topVox');            % put all voxels in column vec
    [ii,jj,kk]  = unique(all_voxIDs,'rows');    %
    tally       = [ii accumarray(kk,1)];
    
    %check for overlapping voxels
    if ~isempty(find(tally(:,2)>1))
        % in case there is overlap:
        user_fb_update({[num2str(sum(tally(:,2)>1)) ' overlapping voxels found!'];...
            'removing overlapping voxels from ROIs..'; 'Final ROI size: '},0,2);
      
        % find the overlapping voxel IDs 
        overlap_IDs = tally(find(tally(:,2)>1),1);
        
        % for eah roi find the non overlapping voxels and set those voxels
        % to one in empty brain mat
        for ii = 1:length(roiWhichNR)  
            % back up initial clusters for later checking
            roiBackUPs{ii} = topVox{ii};
            
            % determine which voxels IDs do NOT overlap
            keep{ii} = find(~ismember(topVox{ii}, overlap_IDs) == 1);
            
            % keep only those topVox IDs
            topVox{ii} = topVox{ii}(keep{ii});
            
            % set them to 1 in empty brain
            rois_new{ii}(topVox{ii}) = 1;   
            
            % report final roi size back to user command window
            user_fb_update({['ROI_' num2str(ii) ': ', num2str(numel(topVox{ii}))]},0,1)
        end   
    else
        % if no overlap is found simply use the equalized ROI IDs to set
        % those voxels to 1s in empty brain mat
        for ii = 1:nrROIs
            rois_new{ii}(topVox{ii}) = 1;
            
            % report final roi size back to user command window           
            user_fb_update({['Final size ' hROI.ROI{ii}.mskName ': ', num2str(numel(topVox{ii})) ' voxels']},0,1)
        end
    end
    
   
    % now we are ready to visualize the results. We write the ROIs to
    % tmpROI.nii files in roiPrep so that the spm_check_registration can display them.
    % If users are content with the results they click 'create ROI' pusch
    % button which will launch the write_ROIs function. Here subjects are
    % asks to name the ROI afterwhich the final file is saved in the
    % location expected by the openNFT.
    for ii = 1:nrROIs
        pathToROI = [roiPath, filesep, 'roiPrep', filesep, 'ROI_' num2str(roiWhichNR(ii))];
        
        % here we add the whole ROInfo struct of this ROI to the sub struct
        % roiFinal. We do this to append all info together.. but most of
        % this is redundant. 
        tmp = load([pathToROI, filesep, 'ROInfo_ROI_' num2str(roiWhichNR(ii))]);
        roiFinal.ROInfo{ii} = tmp.ROInfo;
        
        hdrs{ii}.fname = [pathToROI, filesep, 'tmpROI.nii'];
        spm_write_vol(hdrs{ii}, rois_new{ii});
        
        ROIs{ii} = hdrs{ii}.fname;
    end

    % quality check roi superimposed on native T1
    % retrieve t1 name for current sub
    templ1 = spm_select('FPList', subjStructDir, ['^s' '.*192-01.nii$']);
    
    % visualize
    my_spm_check_registration([{templ1}],{[ROIs]},{}, 1);
    
    % prep structure for saving routine
    roiFinal.hdrs = hdrs;
    roiFinal.vols = rois_new;
    
    % this will open the results gui show structurual and blobs but also
    % all the other info: header cross hair position etc.
%     spm_image('Display',s);
%     my_spm_image('addblobs',[hdr_ROI_1.fname;hdr_ROI_2.fname]);
    

%     if numel(voxId_ROI1)>numel(voxId_ROI2)
%         fprintf('\nFFA cluster is bigger than OFA cluster, we will equate FFA to match OFA size');
% 
%         tVal_con1 = tMap_ROI1(voxId_ROI1);
%         [val1, pos1] = sort(tVal_con1, 'descend');
% 
%         topVox_ROI1 = voxId_ROI1(pos1(1:numel(voxId_ROI2)));
%         topVox_ROI2 = voxId_ROI2; % we leave the other roi untouched
% 
%     end    

end