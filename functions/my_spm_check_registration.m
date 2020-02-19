function my_spm_check_registration(s, f, d, overlay_flag)
%s, f, overlay_flag

% This spm_check_registration function was adapted (simplified) for the
% prepNFB tool. The purpose of this adapted function is to visualize
% coregistration of ROIs to a template (structural, EPI) and to show this
% coregistration in relation to earlier sessions (session 1). Depending on
% the input either one or multiple images can be shown.
                
%  (Input paths to images of choice)
%  to show one template with ROIs
%  my_spm_check_registration([templ1],{[roi11;roi12],1);

%  to show two templates with corresponding ROIs
%  my_spm_check_registration([templ1;templ2],{[roi11;roi12],[roi21;roi22]},1);

%  to compare only ROI masks between session (project contours to see
%  match)
%  my_spm_check_registration([ROI1_sess1;ROI1_sess2],[],0);

% Lucas Peek 30.05.2019

% A visual check of image registration quality
% FORMAT spm_check_registration
% FORMAT spm_check_registration(images)
% Orthogonal views of one or more images are displayed. Clicking in
% any image moves the centre of the orthogonal views. Images are
% shown in orientations relative to that of the first selected image.
% The first specified image is shown at the top-left, and the last at
% the bottom right. The fastest increment is in the left-to-right
% direction (the same as you are reading this).
%__________________________________________________________________________
% Copyright (C) 1997-2014 Wellcome Trust Centre for Neuroimaging


% John Ashburner
% $Id: spm_check_registration.m 6245 2014-10-15 11:22:15Z guillaume $

SVNid = '$Rev: 6245 $';

% filter out the non-empty cell contents. This is useful when not all
% fields are filled (i.e. user only want to show one session)
s={s{find(~cellfun(@isempty,s))}}';

images = char(s);

if ischar(images), images = spm_vol(images); end
if numel(images) > 24
    if ~isdeployed, addpath(fullfile(spm('Dir'),'spm_orthviews')); end
    img = cell(1,numel(images));
    for ii=1:numel(images)
        img{ii} = [images(ii).fname ',' num2str(images(ii).n(1))];
    end
    spm_ov_browser('ui',char(img));
    return
end
images = images(1:min(numel(images),24));

%-Display
%--------------------------------------------------------------------------
spm_figure('GetWin','Graphics'); % opens or activates new spm graphics window
spm_figure('Clear','Graphics');  % if already open it clears the window
spm_orthviews('Reset');          % resetting the orthogonal view  

mn = length(images);
n  = round(mn^0.4);
m  = ceil(mn/n);
w  = 1/n;
h  = 1/m;
ds = (w+h)*0.02;
for ij=1:mn
    ii = 1-h*(floor((ij-1)/n)+1);
    j = w*rem(ij-1,n);
    handle = spm_orthviews('Image', images(ij),...
        [j+ds/2 ii+ds/2 w-ds h-ds]);
    if ij==1, spm_orthviews('Space'); end
    spm_orthviews('AddContext',handle);
end

% superimpose ROIs to a chosen template 
if overlay_flag
%     f = cellstr(f);
%     ff={cellstr(f{find(~cellfun(@isempty,f'))})};
    ff={f{find(~cellfun(@isempty,f'))}};
    colours = [1 0 0;1 1 0;0 1 0;0 1 1;0 0 1;1 0 1]; % 6 colors are hard coded!
    cc=[1:6];
    for sess=1:numel(ff)
        % for each image ;
        tmpf = cellstr(ff{sess});
        for roi = 1:numel(tmpf)
            tmpf{roi};
            % for each blob
            c = cc(roi);
            spm_orthviews('AddColouredImage',sess,tmpf{roi},colours(c,:));
        end
    end
    
    dd={d{find(~cellfun(@isempty,d'))}};
    colours = [0 0.2 0.9]; % 6 colors are hard coded!
    cc=[1:6];
    for sess=1:numel(dd)
        % for each image ;
        tmpd = cellstr(dd{sess});
        for roi = 1:numel(tmpd)
            tmpd{roi};
            % for each blob
            c = cc(roi);
            spm_orthviews('AddColouredImage',sess,tmpd{roi},colours(1,:));
        end
    end
end

% prints con title on top of gui
% hTitAx = axes('Parent',spm_figure('GetWin','Graphics'),...
%     'Position',[0.02 0.96 0.96 0.04],...
%     'Visible','off');
%  text(0.5,0.5,'title TEST','Parent',hTitAx,...
%         'HorizontalAlignment','center',...
%         'VerticalAlignment','top',...
%         'FontWeight','Bold','FontSize',12)
%     
% % print message in figure
% hMIPax = axes('Parent',spm_figure('GetWin','Graphics'),'Position',...
%     [0.05 0.60 0.55 0.36],'Visible','off');%
% 
% str = 'Navigate to ROI cluster';
% text(240,260,str,...
%         'Interpreter','TeX',...
%         'FontSize',12,'Fontweight','Bold',...
%         'Parent',hMIPax)
