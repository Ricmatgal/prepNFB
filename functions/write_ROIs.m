function write_ROIs(subinfo, hROI)

    hdrs = hROI.final.hdrs;
    vols = hROI.final.vols;
    ROInfo = hROI.final.ROInfo;
    
    Fgraph = spm_figure('GetWin','Graphics'); 
    
    for ii = 1:length(hdrs) 
        % snap cross-hairs back to centre
        spm_orthviews('Reposition',ROInfo{ii}.ccoords);
        
        % title the figure
         % prints con title on top of gui
        hTitAx = axes('Parent',Fgraph,...
            'Position',[0.02 0.96 0.96 0.04],...
            'Visible','off');
         text(0.5,0.5,ROInfo{ii}.conInfo.conName,'Parent',hTitAx,...
                'HorizontalAlignment','center',...
                'VerticalAlignment','top',...
                'FontWeight','Bold','FontSize',12)
        
        % ask user for name
        tmpName = inputdlg('Please name this ROI','ROI name');
        
        % update path and name in structure
        hdrs{ii}.fname = [subinfo.roiPath, filesep,...
            'ROI_' num2str(hROI.final.ROInfo{ii}.conInfo.conNr), filesep, char(tmpName) '.nii'];
        
        % write the volume
        spm_write_vol(hdrs{ii}, vols{ii});
        
        user_fb_update({['ROI: ' tmpName{1} ' written']},0,2)
    end
    
    user_fb_update({'DONE! All ROIs written to final OpenNFT directories'},0,4)