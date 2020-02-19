 % ROIs session 1 versus ROIs session 2 on STRUCTURAL before pruning
    %         my_spm_check_registration([s_sess1;s_sess2],{[ROI1;ROI2],[hdr_ROI_1_sess2.fname;hdr_ROI_2_sess2.fname]});
    % ROIs session 1 versus ROIs session 2 on STRUCTURAL after pruning
    my_spm_check_registration({handles.visuals.s_sess1;handles.visuals.s_sess2},...
        {[handles.visuals.ROI1;handles.visuals.ROI2],[handles.visuals.ROI1_sess2;handles.visuals.ROI2_sess2]},1);

    % ROIs session 1 versus ROIs session 2 on EPI template after pruning
    my_spm_check_registration({handles.visuals.EPItempl1;handles.visuals.EPItempl2},...
        {[handles.visuals.ROI1;handles.visuals.ROI2],[handles.visuals.ROI1_sess2;handles.visuals.ROI2_sess2]},1);

     % session 2 ROIs on struct before fine tuning
    %         my_spm_check_registration(s_sess2,{[hdr_ROI_1_sess2.fname;hdr_ROI_2_sess2.fname]});
    % session 2 ROIs on struct after fine tuning
    my_spm_check_registration(handles.visuals.s_sess2,{[handles.visuals.ROI1_sess2;handles.visuals.ROI2_sess2]},1);

    % session 2 ROIs on EPI template before fine tuning!)
    %         my_spm_check_registration(hdr_EPItempl2.fname,{[hdr_ROI_1_sess2.fname;hdr_ROI_2_sess2.fname]},1);    
    % session 2 ROIs on EPI template (after fine tuning!)
    my_spm_check_registration(handles.visuals.EPItempl2,{[handles.visuals.ROI1_sess2;handles.visuals.ROI2_sess2]},1);

    % compare only ROI masks (project contours to chech for overlap)
    my_spm_check_registration({handles.visuals.ROI1;handles.visuals.ROI1_sess2},[],0);
    my_spm_check_registration({handles.visuals.ROI2;handles.visuals.ROI2_sess2},[],0);