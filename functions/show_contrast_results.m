function show_contrast_results(subinfo, ROI)
	
    % get paths 
    subjStructDir   = subinfo.subjStructDir;
    statsdir        = subinfo.statsdir;
    roiPath         = subinfo.roiPath; 
    
    % load SPM.mat 
    load([statsdir, filesep, 'SPM.mat']);
    
    %  open or get spm's graphic window
    Fgraph = spm_figure('GetWin','Graphics'); % opens or activates new spm graphics window
    spm_figure('Clear','Graphics');  % if already open it clears the window
    spm_orthviews('Reset');          % resetting the orthogonal view  

    % get con info from SPM.mat file
    xX   = SPM.xX;                      %-Design definition structure
    XYZ  = SPM.xVol.XYZ;                %-XYZ coordinates
    S    = SPM.xVol.S;                  %-search Volume {voxels}
    R    = SPM.xVol.R;                  %-search Volume {resels}
    M    = SPM.xVol.M(1:3,1:3);         %-voxels to mm matrix
    VOX  = sqrt(diag(M'*M))';           %-voxel dimensions
    
    % select the user selected contrast
    Ic = find(strcmp({SPM.xCon.name},ROI.conName)==1);
%     nc = length(Ic); 
    n = 1;
%     IcAdd = [];
%     Im = [];

    xCon     = SPM.xCon;
    STAT     = xCon(Ic(1)).STAT;        % get stats test cat ('T')
    VspmSv   = cat(1,xCon(Ic).Vspm);    % load con hdr  
    VspmSv.fname = [statsdir, VspmSv.fname]; 
    df     = [xCon(Ic(1)).eidf xX.erdf];

    %-Compute conjunction as minimum of SPMs
    %--------------------------------------------------------------------------
    Z     = Inf;
    Z = min(Z,spm_data_read(VspmSv,'xyz',XYZ));
%     for i = Ic
%         Z = min(Z,spm_data_read(xCon(i).Vspm,'xyz',XYZ));
%     end

    %-Copy of Z and XYZ before masking, for later use with FDR
    %--------------------------------------------------------------------------
    XYZum = XYZ;
    Zum   = Z;
    u   = -Inf;        % height threshold
    k   = 0;           % extent threshold {voxels}

%     topoFDR = true;

    if ROI.none == 1
        thresDesc = 'none';
        u = ROI.none_p;
    elseif ROI.FWE == 1
        thresDesc = 'FWE';
        u = ROI.FWE_p;
    elseif ROI.none == 1 && ROI.FWE == 1
        thresDesc = [];
        % print warnin or error message OR implement checkbox limitation to
        % only one option
    end
   
    switch thresDesc

        case 'FWE' % Family-wise false positive rate
            %--------------------------------------------------------------
            thresDesc = ['p<' num2str(u) ' (' thresDesc ')'];
            u = spm_uc(u,df,STAT,R,n,S); % corrected threshold
          case 'none'  % No adjustment: p for conjunctions is p of the conjunction SPM
            %--------------------------------------------------------------
            if u <= 1
                thresDesc = ['p<' num2str(u) ' (unc.)'];
                u = spm_u(u^(1/n),df,STAT); % uncorrected threshold
            else
                thresDesc = [STAT '=' num2str(u) ];
            end 
    end

%     [up,Pp] = spm_uc_peakFDR(0.05,df,STAT,R,n,Zum,XYZum,u);
% 
%     V2R        = 1/prod(SPM.xVol.FWHM(SPM.xVol.DIM > 1));
%     [uc,Pc,ue] = spm_uc_clusterFDR(0.05,df,STAT,R,n,Zum,XYZum,V2R,u);


    %-Peak FWE
    %----------------------------------------------------------------------
    uu      = spm_uc(0.05,df,STAT,R,n,S);
    %----------------------------------------------------------------------

    str = 'voxels';

    Q      = find(Z > u);
    %-Apply height threshold
    %--------------------------------------------------------------------------
    Z      = Z(:,Q);
    XYZ    = XYZ(:,Q);
    if isempty(Q)
        fprintf('\n');                                                      %-#
        sw = warning('off','backtrace');
        warning('SPM:NoVoxels','No %s survive height threshold at u=%0.2g',str,u);
        warning(sw);
    end

    % extend threshold in voxels
    % k = spm_input(['& extent threshold {' str '}'],'+1','r',0,1,[0,Inf]);
    % link k to gui
    k = ROI.ext_tresh;

    %-Calculate extent threshold filtering
    %----------------------------------------------------------------------
    A = spm_clusters(XYZ);
    Q     = [];
    for i = 1:max(A)
        j = find(A == i);
        if length(j) >= k, Q = [Q j]; end
    end

    % ...eliminate voxels
    %----------------------------------------------------------------------
    Z     = Z(:,Q);
    XYZ   = XYZ(:,Q);

    XYZmm = SPM.xVol.M(1:3,:)*[XYZ; ones(1,size(XYZ,2))];

    if isempty(Q)
        fprintf('\n');                                                  %-#
        sw = warning('off','backtrace');
        warning('SPM:NoVoxels','No %s survive extent threshold at k=%0.2g',str,k);
        warning(sw);
    end

    % get space information
    M   = SPM.xVol.M;
    DIM = SPM.xVol.DIM;

    % get modality
    Modality = 'FMRI';%spm('CheckModality');
    spm('defaults', Modality);

    % get data type
    % datatype = 'Volumetric (2D/3D)';
    units    = {'mm' 'mm' 'mm'};
    xSPM.units      = units;
    SPM.xVol.units  = units;

    FS     = spm('FontSizes');
    
%     Drawing results in glass brain
%     hMIPax = axes('Parent',Fgraph,'Position',[0.001 0.60 0.55 0.36],'Visible','off');%[0.05 0.60 0.55 0.36]
%     hMIPax = spm_mip_ui(Z,XYZmm,M,DIM,hMIPax,units); 
  
    if ROI.struct == 1
        img = spm_select('FPList', subinfo.subjStructDir, ['^s' '.*192-01.nii$']);
        if isempty(img)
            fprintf('\n');                                                  %-#
            error('prepNFB:create_ROIs_gui:show_contrast:fileNotFound', 'No T1 template found make sure you have one!\nPlease check: %s', subinfo.epiPath);
        end
    elseif ROI.epi == 1
        img = spm_select('FPList', subinfo.epiPath, ['^mean' '.*.nii$']);     
        if isempty(img)
            fprintf('\n');                                                  %-#
            sw = warning('off','backtrace');
            warning(['No EPI template found make sure you have one!\n']);
            warning(['Please check: ' subinfo.epiPath])
            warning(sw);
        end
    end

    h1 = my_spm_orthviews('Image', img, [0 0.2 1 0.75]);%[0.05 0.55 0.9 0.45]
    my_spm_orthviews('AddContext', h1); 
    my_spm_orthviews('MaxBB');
    my_spm_orthviews('AddBlobs', h1, XYZ, Z, M);

    % prints con title on top of gui
    hTitAx = axes('Parent',Fgraph,...
        'Position',[0.02 0.96 0.96 0.04],...
        'Visible','off');
     text(0.5,0.5,SPM.xCon(Ic).name,'Parent',hTitAx,...
            'HorizontalAlignment','center',...
            'VerticalAlignment','top',...
            'FontWeight','Bold','FontSize',FS(14))
    
    % prepate structure with data needed for saving the cluster as mask
    conInfo.XYZ = XYZ;
    conInfo.XYZum = XYZum;
    conInfo.XYZmm = XYZmm;
    conInfo.DIM = DIM;
    conInfo.M = M;
    conInfo.STAT = STAT;
    conInfo.u = u;
    conInfo.k = k;
    conInfo.conName = SPM.xCon(Ic).name;
    conInfo.conNr = Ic;
    
    % assign conInfo struct to caller ws (create_ROIs_gui.m)
    assignin('caller', 'conInfo', conInfo);
  
%     save([roiPath, filesep, 'roiPrep', filesep,'conInfo_ROI_' num2str(Ic)], 'conInfo');
    
    my_spm_orthviews('Redraw');
    
   



