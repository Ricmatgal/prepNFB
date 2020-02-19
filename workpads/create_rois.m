% load the SPM
clear all

load SPM
Fgraph = spm_figure('GetWin','Graphics');
% ========================================================================
% From spm_getSPM variables (needed for running spm_results_gui)
% ========================================================================

% this opens the contrast manages showing the con names available and asks
% for user input wrt masking, p corrections and extend of clusters shown.
% THis is what we want to 'bypass' or more specifically have defined in the
% roi window. 
% [SPM,xSPM] = spm_getSPM(SPM)
xX   = SPM.xX;                      %-Design definition structure
XYZ  = SPM.xVol.XYZ;                %-XYZ coordinates
S    = SPM.xVol.S;                  %-search Volume {voxels}
R    = SPM.xVol.R;                  %-search Volume {resels}
M    = SPM.xVol.M(1:3,1:3);         %-voxels to mm matrix
VOX  = sqrt(diag(M'*M))';           %-voxel dimensions

Ic = 1; % first con
nc        = length(Ic); 
n = 1;
IcAdd = [];
Im = [];
SPM  = spm_contrasts(SPM, unique([Ic, Im, IcAdd])); % not sure if needed

xCon     = SPM.xCon;
STAT     = xCon(Ic(1)).STAT;        % Ic will determine which con is selected, we will use this tnavigate and show the correct con image
VspmSv   = cat(1,xCon(Ic).Vspm);    % loads con hdr

df     = [xCon(Ic(1)).eidf xX.erdf];
str = '';
STATstr = sprintf('%s%s_{%.0f}','T',str,df(2));

%-Compute conjunction as minimum of SPMs
%--------------------------------------------------------------------------
Z     = Inf;
for i = Ic
    Z = min(Z,spm_data_read(xCon(i).Vspm,'xyz',XYZ));
end

%-Copy of Z and XYZ before masking, for later use with FDR
%--------------------------------------------------------------------------
XYZum = XYZ;
Zum   = Z;

u   = -Inf;        % height threshold
k   = 0;           % extent threshold {voxels}

topoFDR = true;

% link this to gui input prepNFB tool
% spm input dlg 
% thresDesc = spm_input('p value adjustment to control','+1','b',str,[],1);
% relevant inputs:
thresDesc = 'none';
% thresDesc = 'FWE';
u = 0.001; % link to gui
switch thresDesc

    case 'FWE' % Family-wise false positive rate
        %--------------------------------------------------------------
%         try
%             u = xSPM.u;
%         catch
%             u = spm_input('p value (FWE)','+0','r',0.05,1,[0,1]);
%         end
        thresDesc = ['p<' num2str(u) ' (' thresDesc ')'];
        u = spm_uc(u,df,STAT,R,n,S); % corrected threshold
      case 'none'  % No adjustment: p for conjunctions is p of the conjunction SPM
        %--------------------------------------------------------------
%         try
%             u = xSPM.u;
%         catch
%             u = spm_input(['threshold {',STAT,' or p value}'],'+0','r',0.001,1);
%         end
        if u <= 1
            thresDesc = ['p<' num2str(u) ' (unc.)'];
            u = spm_u(u^(1/n),df,STAT); % uncorrected threshold
        else
            thresDesc = [STAT '=' num2str(u) ];
        end 
end

[up,Pp] = spm_uc_peakFDR(0.05,df,STAT,R,n,Zum,XYZum,u);

V2R        = 1/prod(SPM.xVol.FWHM(SPM.xVol.DIM > 1));
[uc,Pc,ue] = spm_uc_clusterFDR(0.05,df,STAT,R,n,Zum,XYZum,V2R,u);


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
k = 50;

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


% useful.. get conNames
conNames = {SPM.xCon.name};
conName = SPM.xCon(Ic).name;

% now we have the input needed to draw the clusters in the graphics window.
% The plan is to draw the glass brain and superimpose to thresholded t map
% on a orthogonal t1/epi and to build in a create roi button at the bottom
% that will first launch saving the cluster and than trim it down to the
% roi specifications.

% ========================================================================


% ========================================================================
% From spm_results_gui
% ========================================================================
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
% % hMIPax = axes('Parent',Fgraph,'Position',[0.05 0.60 0.55 0.36],'Visible','off');
% % 
% % % hMIPax = spm_mip_ui(xSPM.Z,xSPM.XYZmm,M,DIM,hMIPax,units); % shows glass brain
% % hMIPax = spm_mip_ui(Z,XYZmm,M,DIM,hMIPax,units); 
% % % spm_XYZreg('XReg',hReg,hMIPax,'spm_mip_ui');
% % % spm_XYZreg('XReg',Fgraph,hMIPax,'spm_mip_ui');
% % 
% % % print message in figure
% % str = 'Navigate to ROI cluster';
% % text(240,260,str,...
% %         'Interpreter','TeX',...
% %         'FontSize',FS(14),'Fontweight','Bold',...
% %         'Parent',hMIPax)
% % 
% % % prints con title on top of gui
% % hTitAx = axes('Parent',Fgraph,...
% %     'Position',[0.02 0.96 0.96 0.04],...
% %     'Visible','off');
% %  text(0.5,0.5,xSPM.title,'Parent',hTitAx,...
% %         'HorizontalAlignment','center',...
% %         'VerticalAlignment','top',...
% %         'FontWeight','Bold','FontSize',FS(14))

% draw t tmap on fn: t1/epi image (path/fn)    
% spm_sections(xSPM,hReg,fn)    
fpath = 'C:\Users\lucas\Desktop\OpenNFT_Project\myOpenNFT\rtData\ContTask_NFB\04\Session_01\T1';
img = [fpath, filesep, 's87726-0005-00001-000192-01.nii'];
% % global st prevsect
% % % st.Space = spm_matrix([0 0 0  0 0 -pi/2]) * st.Space;
% % prevsect = img;
img2='C:\Users\lucas\Desktop\OpenNFT_Project\myOpenNFT\rtData\ContTask_NFB\04\Session_01\EPI_Template_D1\meanaf87726-0006-00001-000001-01.nii';
h1 = spm_orthviews('Image', img2, [0.05 0.55 0.9 0.45]);
h2 = spm_orthviews('Image', img, [0.05 0.05 0.9 0.45]);

spm_orthviews('AddContext', h1); 
spm_orthviews('MaxBB');
spm_orthviews('AddBlobs', h1, XYZ, Z, M);

spm_orthviews('AddContext', h2); 
spm_orthviews('MaxBB');
spm_orthviews('AddBlobs', h2, XYZ, Z, M);

spm_orthviews('Redraw');

% save current cluster as mask
% [xyzmm,i] = spm_XYZreg('NearestXYZ', spm_results_ui('GetCoords'),XYZ);

[xyzmm,i] = spm_XYZreg('NearestXYZ', XYZum,XYZ);

% spm_results_ui('SetCoords',XYZmm(:,i));
     
A   = spm_clusters(XYZ);
j   = find(A == A(i));
Z   = ones(1,numel(j));
XYZ = XYZ(:,j);     

 V   = spm_write_filtered(Z, XYZ, DIM, M,...
    sprintf('SPM{%c}-filtered: u = %5.3f, k = %d',STAT,u,k),[conName '_ROI_myGUI']);
cmd = 'spm_image(''display'',''%s'')';
F   = V.fname;

fprintf('Written %s\n',spm_file(F,'link',cmd));  



