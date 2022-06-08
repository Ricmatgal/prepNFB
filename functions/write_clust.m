function write_clust(subinfo, ROIinfo)

    % load the crosshair XYZ which is continuasly updated when moving the
    % crosshair through the slices in the graphical window
% % % % %     load outcentre
    % Alternatively use:
    % FORMAT spm_orthviews('Pos') to get XYZ directly!
    
    % to keep variable name writing short below
    XYZ         = ROIinfo.conInfo.XYZ;
    
%     if size(outcentre,2) > 1, outcentre = outcentre'; end
%     centre      = outcentre;

    centre      = spm_orthviews('Pos');
    
    XYZum       = ROIinfo.conInfo.XYZ;
    XYZmm       = ROIinfo.conInfo.XYZmm;
    DIM         = ROIinfo.conInfo.DIM;
    M           = ROIinfo.conInfo.M;
    STAT        = ROIinfo.conInfo.STAT;
    u           = ROIinfo.conInfo.u;
    k           = ROIinfo.conInfo.k;
    conName     = ROIinfo.conInfo.conName;       
    conNr       = ROIinfo.conInfo.conNr;
    clustSize   = ROIinfo.clustSize;
    
    statsdir = subinfo.statsdir;
    
    if ROIinfo.FWE == 1
        correction = 'FWE';
        pval = ROIinfo.FWE_p;
    elseif ROIinfo.none == 1
        correction = 'none';
        pval = ROIinfo.none_p;
    end
    
    
    % set path to write .nii mask to 
    mskPath = [subinfo.roiPath, filesep, 'roiPrep', filesep, 'ROI_' num2str(conNr)];
    
    % go to nearest XYZ within cluster (centre holds coords)
    % i corresponds to nearest listed active voxel we call it SELECTED VOXEL
    % XYZ holds the XYZ coords of the active voxels in volume space
    [xyzmm,i] = spm_XYZreg('NearestXYZ', centre, XYZmm); 
    A   = spm_clusters(XYZ);    % get cluster index/region nr for each active voxel coord
    j   = find(A == A(i));      % find the other group members of selected voxel --> get whole cluster
    
    % use these lines if you want to get volume size and number of elements
    % in volume based on a contrast/tmap image (same as using DIM)
% %     tmap_con       = spm_read_vols(spm_vol([statsdir, filesep, 'spmT_000' num2str(conNr) '.nii']));   % tmap
% %     [xx,yy,zz]     = ind2sub(size(tmap_con),1:numel(tmap_con));

    % get xyz subscripts for entire volume
    [xx,yy,zz]     = ind2sub(DIM',1:(DIM(1)*DIM(2)*DIM(3)));
    
    % find the whole brain xyz coord for selected voxel
    xyz_i = XYZ(:,i);
    
    % get eucl distance whole brain to selected voxel
    eucl_dist = sqrt((xx'-xyz_i(1)).^2 +(yy'-xyz_i(2)).^2 + (zz'-xyz_i(3)).^2); % 
    
    % get xyz coords for the cluster that selected voxel belongs to
    xyz_cluster = XYZ(:,j);
    
    % get the whole brain linear indices of this cluster (size(tmap_con))
% %      idx_cluster = sub2ind(size(tmap_con), xyz_cluster(1,:), xyz_cluster(2,:), xyz_cluster(3,:))';
    idx_cluster = sub2ind(DIM', xyz_cluster(1,:), xyz_cluster(2,:), xyz_cluster(3,:))';
    
    % find the eucl distance of cluster voxels to selected voxel
    eucl_dist_cluster = eucl_dist(idx_cluster);
    
    % sort the cluster voxels according to their distance to the selected
    % voxel
    [eucl_dist_cluster_sorted_val, eucl_dist_cluster_sorted_idx] = sort(eucl_dist_cluster, 'ascend');
    
    % select N number of voxels closest to the selected voxel: FINAL CLUSTER!
    if numel(eucl_dist_cluster_sorted_idx) >= clustSize
        jj = eucl_dist_cluster_sorted_idx(1:clustSize,1); 
%         jj = idx_cluster(eucl_dist_cluster_sorted_idx(1:clustSize,1)); 

    elseif numel(eucl_dist_cluster_sorted_idx) < clustSize
        user_fb_update({'Selected cluster size exeeds functional'; 'cluster! What would you like to do?'}, 0, 2)
        
        answer = questdlg(['Selected cluster size exeeds functional cluster! what would you like to do? (Max: ' num2str(numel(eucl_dist_cluster_sorted_idx)) ')'], 'Choice options', ...
            'Trim to Max','Adjust Cluster Size','Abort', 'Abort');
        
            % Handle response
            switch answer
                case 'Trim to Max'
                    jj = eucl_dist_cluster_sorted_idx(1:end,1);
                    user_fb_update({'Trimed cluster to Max'; ['Adjusted cluster size: ', num2str(numel(jj))]},0,2);

                case 'Adjust Cluster Size'
                    adj_clustSize = str2double(inputdlg(['New Cluster Size (Max: ' num2str(numel(eucl_dist_cluster_sorted_idx)) ')']));
                    jj = eucl_dist_cluster_sorted_idx(1:adj_clustSize,1);
                    user_fb_update({['Adjusted cluster size: ', num2str(numel(jj))]},0,2);

                case 'Abort'
                    user_fb_update({'Cluster Selection ABORTED by user'},0,2);
                    return              
            end          
    end
    
    % find back the whole brain XYZ coords for the FINAL CLUSTER
    Z   = ones(1,numel(jj));     % binary vector(ones) of same size as clust
%     XYZ_fin = XYZ(:,jj);             % get the actual XYZ for slectec cluster
     XYZ_fin = xyz_cluster(:,jj);
    
     % write the FINAL CLUSTER to ROI path (extention is _msk to indicate the pre
    % ROI state of the .nii)
     V   = spm_write_filtered(Z, XYZ_fin, DIM, M, sprintf('SPM{%c}-filtered: u = %5.3f, k = %d',STAT,u,k),...
         [mskPath, filesep, 'msk_' conName]);
    
    % prep visualisation
%     templ1  = spm_select('FPList', subinfo.subjStructDir, ['^s' '.*192-01.nii$']);
    templ1  = spm_select('FPList', subinfo.subjStructDir, ['^MF' '.*.nii$']);
    ROI     = spm_select('FPList', mskPath, ['^', 'msk_' conName, '.*.nii$']);

% %     roiCon  = spm_select('FPList', subinfo.statsdir, ['con_000' num2str(conNr) '.nii']);
% %     % prepare clipped conimage for visualisation BUT see spm_orthviews('AddBlobs',handle,XYZ,Z,mat,name)
% %     roiConHdr = spm_vol(roiCon);
% %     roiConVol = spm_read_vols(roiConHdr);
% %     roiConVol_thresh = zeros(size(roiConVol));
% %     XYZ_index = sub2ind(size(roiConVol), XYZ(1,:), XYZ(2,:), XYZ(3,:));
% %     roiConVol_thresh(XYZ_index) = roiConVol(XYZ_index);
% %     roiConHdr.fname = [subinfo.statsdir, 'con_000', num2str(conNr), '_thresh.nii'];
% %     spm_write_vol(roiConHdr,roiConVol_thresh);
    
    % launch visualization
    my_spm_check_registration([{templ1}],{ROI},{}, 1);

%     spm_orthviews('AddBlobs',roiCon,XYZmm,roiConVol(XYZ_index),M,'test')
%     my_spm_check_registration([{templ1}],{ROI},{roiConHdr.fname}, 1);
    
    % snap cross-hairs back to centre
%     spm_orthviews('Reposition',outcentre);
    spm_orthviews('Reposition',xyzmm);
    
    % print message (voxelsize) in figure and in command window
    cmd = 'spm_image(''display'',''%s'')';
    str ={['Contrast: ' conName];['Mask size: ' num2str(numel(jj)) ' functional voxels']};
    str2 = {['Contrast: ' conName];['Correction: ' correction ' at p = ' num2str(pval)];['Mask size: ' num2str(numel(jj)) ' functional voxels'];...
        ['at xyz coords: ' num2str(centre')];'Mask written:';[spm_file(V.fname,'link',cmd)]};
    user_fb_update(str2, 0, 1)
    
    % report to user that mask was saved in specific location (provide
    % link)
     hMIPax = axes('Parent',spm_figure('GetWin','Graphics'),'Position',...
        [0.05 0.60 0.55 0.36],'Visible','off');
    text(1, -0.5,str,...
            'Interpreter','TeX',...
            'FontSize',12,'Fontweight','Bold',...
            'Parent',hMIPax)

    % assign final centre coords to caller ws so that it can be added to
    % the ROInfo struct. We need these coords later during final roi
    % saving.
    outp.clustSize = numel(jj);
%     outp.centre = centre; % this will take the dropped crosshair position
    outp.centre = xyzmm;    % this will take the nearest XYZ to dropped crosshair
    outp.path = ROI;
    assignin('caller', 'outp', outp)
