function write_clust(subinfo, ROIinfo)

    % load the crosshair XYZ which is continuasly updated when moving the
    % crosshair through the slices in the graphical window
    load outcentre
    % Alternatively use:
    % FORMAT spm_orthviews('Pos', i)
    % Return the voxel co-ordinate of the crosshairs in the image in the ith
    % orthogonal section.
    % and convert the voxel coord to XYZ
    
    % to keep variable name writing short below
    XYZ     = ROIinfo.conInfo.XYZ;
    centre  = outcentre;
    XYZum   = ROIinfo.conInfo.XYZ;
    XYZmm   = ROIinfo.conInfo.XYZmm;
    DIM     = ROIinfo.conInfo.DIM;
    M       = ROIinfo.conInfo.M;
    STAT    = ROIinfo.conInfo.STAT;
    u       = ROIinfo.conInfo.u;
    k       = ROIinfo.conInfo.k;
    conName = ROIinfo.conInfo.conName;       
    conNr   = ROIinfo.conInfo.conNr;
    
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
    [xyzmm,i] = spm_XYZreg('NearestXYZ', centre, XYZmm); % i corresponds to nearest listed active voxel
    A   = spm_clusters(XYZ);    % get cluster index/region nr for each active voxel coord
    j   = find(A == A(i));      % find the other group members --> get whole cluster
    Z   = ones(1,numel(j));     % binary vector(ones) of same size as clust
    XYZ = XYZ(:,j);             % get the actual XYZ for slectec cluster
    
    % write the cluster to ROI path (extention is _msk to indicate the pre
    % ROI state of the .nii)
     V   = spm_write_filtered(Z, XYZ, DIM, M, sprintf('SPM{%c}-filtered: u = %5.3f, k = %d',STAT,u,k),...
         [mskPath, filesep, 'msk_' conName]);
    
    % prep visualisation
    templ1 = spm_select('FPList', subinfo.subjStructDir, ['^s' '.*192-01.nii$']);
    ROI = spm_select('FPList', mskPath, ['^', 'msk_' conName, '.*.nii$']);
    
    % launch visualization
    my_spm_check_registration([{templ1}],{ROI},{}, 1);
    
    % snap cross-hairs back to centre
    spm_orthviews('Reposition',outcentre);
    
    % print message (voxelsize) in figure and in command window
    cmd = 'spm_image(''display'',''%s'')';
    str ={['Contrast: ' conName];['Mask size: ' num2str(numel(j)) ' functional voxels']};
    str2 = {['Contrast: ' conName];['Correction: ' correction ' at p = ' num2str(pval)];['Mask size: ' num2str(numel(j)) ' functional voxels'];...
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
    outp.centre = centre;
    outp.path = ROI;
    assignin('caller', 'outp', outp)
