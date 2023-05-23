function varargout = prep_NFB(varargin)
% PREP_NFB MATLAB code for prep_NFB.fig
%      PREP_NFB, by itself, creates a new PREP_NFB or raises the existing
%      singleton*.
%
%      H = PREP_NFB returns the handle to a new PREP_NFB or the handle to
%      the existing singleton*.
%
%      PREP_NFB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREP_NFB.M with the given input arguments.
%
%      PREP_NFB('Property','Value',...) creates a new PREP_NFB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before prep_NFB_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to prep_NFB_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help prep_NFB

% Last Modified by GUIDE v2.5 25-Oct-2022 16:55:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...2
                   'gui_OpeningFcn', @prep_NFB_OpeningFcn, ...
                   'gui_OutputFcn',  @prep_NFB_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before prep_NFB is made visible.
function prep_NFB_OpeningFcn(hObject, eventdata, handles, varargin)
    
    % enter debug mode
    dbstop if error
    
    % randomize seed for randomazation
%     rng('shuffle');
    rand('state',sum(100*clock));

    handles.output = hObject;
    handles.watchFolder = '';
    handles.projFolder = '';
    addpath([pwd filesep 'functions'])

    try
        load([pwd, filesep, 'Settings', filesep, 'Settings_Main.mat']);
        
        try
            % set directories
            set(handles.eb_projectFolder, 'String', settings.projFolder);
%             set(handles.eb_watchFolder, 'String', settings.watchFolder); 
            
            % set session, runs, and roi NRs
            set(handles.eb_nr_sessions, 'String', settings.NRsessions);
            set(handles.eb_nr_run, 'String', settings.NRruns);
            set(handles.eb_nr_ROIs, 'String', settings.NRrois);
            
            % set first session settings
            set(handles.eb_imp_t1_1_sn, 'String', settings.dcm.t1_1)
            set(handles.eb_analyze_loc_sn, 'String', settings.dcm.loc)
            set(handles.eb_analyze_rs_1_sn, 'String', settings.dcm.rs_1)
            
            % set >1 session settings
            set(handles.eb_session,'String', settings.sess_c);
            set(handles.eb_imp_t1_2_sn, 'String', settings.dcm.t1_2)
            set(handles.eb_analyze_rs_2_sn, 'String', settings.dcm.rs_2)
            
            set(handles.cb_old_struct, 'Value', settings.old_struct);
            set(handles.cb_new_struct, 'Value',settings.new_struct);
            set(handles.eb_imp_t1_2_sn, 'Enable', settings.dcm.t1_2_flag)
    
            
        catch
            user_fb_update({'One or more values we not correctly set';'please check the interface!'},0, 3)
        end

     catch 
         user_fb_update({'No Settings file found. Fill out the parameters and save'},0, 3)
    end
    
    set(handles.lb_feedback_window,'tag','fb_window') 
    
    % adding an image to axes (first: add axes object to the main gui)
%     axes(handles.axes1)
%     matlabImage = imread([pwd, filesep, 'Others', filesep, 'Brain_edited-removebg-preview.png']);
%     image(matlabImage)
%     axis off
%     axis image
    
    % Update handles structure
    guidata(hObject, handles);

% UIWAIT makes prep_NFB wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prep_NFB_OutputFcn(hObject, eventdata, handles) 

    varargout{1} = handles.output;
    assignin('base', 'outp', handles);
% assignin('base', 'user_fb', handles.user_fb);

% ================================================================
%% ========================== Top panel ==========================
% ================================================================

% --- Executes during object creation, after setting all properties.
function eb_subjID_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function eb_subjID_Callback(hObject, eventdata, handles)

    handles.subID = get(hObject,'String');
    message = {['Subject: ' handles.subID]};
    user_fb_update(message,1, 1);
    guidata(hObject, handles);


function eb_mriID_Callback(hObject,eventdata,handles)

    handles.mriID = get(hObject,'String');
    message = {['MRI ID: ' handles.mriID]};
    user_fb_update(message,1, 1);
    guidata(hObject,handles);

% edit button session nr    
function eb_nr_sessions_Callback(hObject, eventdata, handles)

% edit button session nr - creation func
function eb_nr_sessions_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% edit button run nr
function eb_nr_run_Callback(hObject, eventdata, handles)

% edit button run nr - creation func
function eb_nr_run_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% edit button ROI nr
function eb_nr_ROIs_Callback(hObject, eventdata, handles)


% edit button run nr - creation function
function eb_nr_ROIs_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end    
    

% --- Executes on button press in pb_initialize.
function pb_initialize_Callback(hObject, eventdata, handles)

    info.subID      = get(handles.eb_subjID, 'String');
    info.mriID      = get(handles.eb_mriID, 'String');
    info.projFolder = get(handles.eb_projectFolder,'String');
    info.session    = get(handles.eb_nr_sessions,'String');
    info.runs       = get(handles.eb_nr_run,'String');
    info.rois       = get(handles.eb_nr_ROIs,'String');
    
    mkSubDir(info)

    guidata(hObject, handles);
    
% --- Executes on button press in pb_render_stims.
function pb_render_stims_Callback(hObject, eventdata, handles)
    info.subID      = get(handles.eb_subjID, 'String');
    info.mriID      = get(handles.eb_mriID, 'String');
    info.projFolder = get(handles.eb_projectFolder,'String');
    info.session    = get(handles.eb_nr_sessions,'String');
    info.runs       = get(handles.eb_nr_run,'String');
    
    % check if directories are created for the Task Stim
    dir2write = [info.projFolder, filesep, info.subID, filesep, 'Session_01',...
                 filesep, 'TaskFolder' ,filesep, 'StimSets'];
    
    if isfolder(dir2write)
        % if the directory exist commence the rendering routine
        render_images(info)
    elseif ~isfolder(dir2write)
        % if the directory doesn't exist do nothing and notify the user
        user_fb_update({'Sub specific TaskStim directories do not';'exist yet!'},0,2)       
    end
    
    guidata(hObject, handles);

% --- Executes on button press in pb_open_subFolder.
function pb_open_subFolder_Callback(hObject, eventdata, handles)
    subID      = get(handles.eb_subjID, 'String');
    projFolder = get(handles.eb_projectFolder,'String');

    dir2open = [projFolder, filesep, subID];
    
    if isdir(dir2open)
        winopen(dir2open);
        user_fb_update({'Subject folder open in Windows'},1,1)
    else
        user_fb_update({dir2open; 'is not a directory!'},0,2)       
    end


function eb_projectFolder_Callback(hObject, eventdata, handles)

    handles.projFolder = get(hObject,'String');

    message = {['Project Folder updated: '  get(hObject,'String')]};
    user_fb_update(message, 0, 2);

    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eb_projectFolder_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in pb_browse_proj.
function pb_browse_proj_Callback(hObject, eventdata, handles)

    projFolder = uigetdir(get(handles.eb_projectFolder, 'String'));
    if projFolder 
        handles.projFolder = projFolder;
        set(handles.eb_projectFolder, 'String', handles.projFolder);


        message = {['Project Folder updated: '  handles.projFolder]};
        user_fb_update(message, 0, 2);
    end

    guidata(hObject, handles);


function eb_watchFolder_Callback(hObject, eventdata, handles)

    message = {['Watch Folder updated: '  get(hObject,'String')]};
    user_fb_update(message, 0, 2);

    handles.watchFolder = get(hObject,'String');
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eb_watchFolder_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in pb_browse_watch.
function pb_browse_watch_Callback(hObject, eventdata, handles)

%     watchFolder = uigetdir(get(handles.eb_watchFolder, 'String') ); %
    watchFolder = uigetdir('E:\TBV-input');
    if watchFolder
        handles.watchFolder = watchFolder;
        set(handles.eb_watchFolder, 'String', handles.watchFolder);

        message = {['Watch Folder updated: '  handles.watchFolder]};
        user_fb_update(message, 0, 2);
    end

    guidata(hObject, handles);
    
% --- Executes on button press in pb_open_projFolder.
function pb_open_projFolder_Callback(hObject, eventdata, handles)

    dir2open = get(handles.eb_projectFolder, 'String');

    if isdir(dir2open)
        winopen(dir2open);
        user_fb_update({'Project folder open in Windows'},1,1)
    else
        user_fb_update({dir2open; 'is not a directory!'},0,2)       
    end

% --- Executes on button press in pb_open_watchFolder.
function pb_open_watchFolder_Callback(hObject, eventdata, handles)
    
    dir2open = get(handles.eb_watchFolder, 'String');
    
    if isdir(dir2open)
        winopen(dir2open);
        user_fb_update({'Watch folder open in Windows'},1,1)
    else
        user_fb_update({dir2open; 'is not a directory!'},0,2)       
    end

% ================================================================
%% ========================== Session 1 ==========================
% ================================================================

% --- Executes on button press in pb_runLocTask.
function pb_runLocTask_Callback(hObject, eventdata, handles)
     m = 'Initiating localizer task...';
     user_fb_update({m}, 1, 1)
     subID       = get(handles.eb_subjID, 'String');
     projFolder  = get(handles.eb_projectFolder, 'String');
     if isempty(str2num(subID)) 
        user_fb_update({'Subject ID not specified!';'Check settings and re-launch'},0, 3)
        return
    elseif isdir(projFolder) == 0 
        user_fb_update({'Project Folder does not exist!';'Check path and re-launch'},0, 3)
        return
     else
%         flicker_RightLeft_ce(subID, projFolder)
        flicker_RightLeft_ce_Gabor(subID, projFolder, 1, 1);
55%         run_V1_loc_flicker_fmri(subID, projFolder)
    end
    
function pb_import_t1_1_Callback(hObject, eventdata, handles)
    user_fb_update({'Importing T1 to session 1...'},1, 1)
    user_fb_update({'Get ready to set origin at AC!'},0, 2)
    mriID           = get(handles.eb_mriID, 'String');
    subID           = get(handles.eb_subjID, 'String');
    projFolder      = get(handles.eb_projectFolder,'String');
    watchFolder     = get(handles.eb_watchFolder,'String');
    impT1_1_sn      = get(handles.eb_imp_t1_1_sn, 'String');
%     
    dicom_imp('struct', subID, mriID, watchFolder, projFolder,...
        impT1_1_sn, 0, 1, 'Session_01', 1);

function eb_imp_t1_1_sn_Callback(hObject, eventdata, handles)

    handles.impT1_1_sn = get(hObject,'String');
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function eb_imp_t1_1_sn_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    handles.impT1_1_sn = get(hObject,'String');
    guidata(hObject, handles);


% --- Executes on button press in pb_analyze_loc.
function pb_analyze_loc_Callback(hObject, eventdata, handles)
    m = 'Localizer Tool..';
    user_fb_update({m},1, 1);
    
    subinfo.subID       = get(handles.eb_subjID, 'String');
    subinfo.mriID       = get(handles.eb_mriID, 'String');
    subinfo.projFolder  = get(handles.eb_projectFolder, 'String');
    subinfo.watchFolder = get(handles.eb_watchFolder, 'String');  
    subinfo.dcmSeries   = get(handles.eb_analyze_loc_sn, 'String');
    if isempty(str2num(subinfo.subID)) 
        user_fb_update({'Subject ID not specified!'},0, 3)
        return
    elseif isdir([subinfo.projFolder, filesep, subinfo.subID]) == 0 
        user_fb_update({'Subject directory does not exist!'},0, 3)
        return
    elseif isdir(subinfo.projFolder) == 0 
        user_fb_update({'Project Folder does not exist!'},0, 3)
        return
    elseif isdir(subinfo.watchFolder) == 0 
        user_fb_update({'Watch Folder does not exist!'},0, 3)
        return
    else 
%         user_fb_update({['WatchFolder: ' subinfo.watchFolder]; ['dcm series: ' subinfo.dcmSeries]},0, 1)
        analyze_loc(subinfo) 
    end

function eb_analyze_loc_sn_Callback(hObject, eventdata, handles)

    handles.analyze_loc_sn = get(hObject,'String');
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eb_analyze_loc_sn_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    handles.analyze_loc_sn = get(hObject,'String');
    guidata(hObject, handles);
    
% --- Executes on button press in pb_ROI.
function pb_ROI_Callback(hObject, eventdata, handles)
    user_fb_update({'Initiating ROI analyses..'},1, 1)
%     create_ROIs(handles.subID, handles.projFolder) 
    subinfo.subID           = get(handles.eb_subjID, 'String');
    subinfo.projFolder      = get(handles.eb_projectFolder, 'String');
    if isempty(subinfo.subID) || isdir(subinfo.projFolder) == 0 
        user_fb_update({'Subject ID and/or Project Folder not (correctly) specified!'; 'Check Settings'}, 0, 3)
        return
    else 
        create_ROIs_gui(subinfo)      
    end


% --- Executes on button press in pb_analyze_rs_1.
function pb_analyze_rs_1_Callback(hObject, eventdata, handles)

    % %     fprintf('\nAnalyzing first images of resting state to get EPI template...')
    % %     analyze_rs(handles.subID, handles.watchFolder, handles.projFolder, handles.analyze_rs_1_sn,...
    % %         'Session_01');
     user_fb_update({'Button deactivated!'},1,2)

function eb_analyze_rs_1_sn_Callback(hObject, eventdata, handles)

    handles.analyze_rs_1_sn = get(hObject,'String');
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eb_analyze_rs_1_sn_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    % This is there to set the value to default if untouched
    handles.analyze_rs_1_sn = get(hObject,'String');
    guidata(hObject, handles);

% --- Executes on button press in pb_create_ini_1.
function pb_create_ini_1_Callback(hObject, eventdata, handles)
    subID       = get(handles.eb_subjID, 'String');
    projFolder  = get(handles.eb_projectFolder,'String');
    watchFolder = get(handles.eb_watchFolder,'String');
    prepNFBpath = pwd;
    
    create_ini(subID, watchFolder, projFolder,prepNFBpath, 'Session_01')

    

% --- Executes on button press in cb_beh_task_lang_1.
function cb_beh_task_lang_1_Callback(hObject, eventdata, handles)

    handles.cb_beh_task_1_lang = get(hObject,'Value');
    guidata(hObject, handles);

   

% --- Executes on button press in pb_run_behtask_1.
function pb_run_behtask_1_Callback(hObject, eventdata, handles)
    
    user_fb_update({'Running behavioral task...'},1,1)
    
    subID       = get(handles.eb_subjID, 'String');
    projFolder  = get(handles.eb_projectFolder,'String');
    
    if isfield(handles,'cb_beh_task_1_lang')
        if handles.cb_beh_task_1_lang == 1
            version = 'FR';
        end
    else
        version = 'EN';  
    end
    
    trainBlock = true;
    nBlocksRep = 10;
    maxNTargets = 10;
    fullScreen = true;
    keyboard = 'mri'; % we use 1 and 2
    screenid = 2;
    sessionID = '01';
    path_output = strcat(projFolder,filesep,subID,filesep,'Session_',sessionID,'\TaskFolder\TaskResults');

    run_beh_task(trainBlock,nBlocksRep,maxNTargets,fullScreen,keyboard,screenid,subID,sessionID,path_output,version)

% ================================================================
%% ========================== Session > 1 ==========================
% ================================================================

function eb_session_Callback(hObject, eventdata, handles)

    handles.sessionNR = get(hObject,'String');
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eb_session_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in cb_old_struct.
function cb_old_struct_Callback(hObject, eventdata, handles)

    if get(handles.cb_new_struct,'Value') == 1
        set(handles.cb_new_struct,'Value', 0);
    end
    
    if get(hObject,'Value') == 1
        set(handles.eb_imp_t1_2_sn, 'Enable', 'off')
    end
    
    % log changes and report to user
    sessNR          = get(handles.eb_session, 'String');
    subID           = get(handles.eb_subjID, 'String');
    mriID           = get(handles.eb_mriID, 'String');
    projFolder      = get(handles.eb_projectFolder, 'String');
    getDir          = [projFolder, filesep, subID, filesep, 'Session_01', filesep, 'T1'];
    oldStruct       = spm_select('FPList', getDir, ['^s' '.*192-01.nii']);;
    
    message = {['Session ' sessNR ': T1 = OLD']; oldStruct};
    user_fb_update(message, 0, 2);

function cb_new_struct_Callback(hObject, eventdata, handles)

    if get(handles.cb_old_struct,'Value') == 1
        set(handles.cb_old_struct,'Value', 0);
    end
    if get(hObject,'Value') == 1
        set(handles.eb_imp_t1_2_sn, 'Enable', 'on');
    end
    
    % log changes and report to user
    sessNR          = get(handles.eb_session, 'String');
    message = {['Session ' sessNR ': T1 = NEW']; ['dcm: ' get(handles.eb_imp_t1_2_sn, 'String')]};
    user_fb_update(message, 0, 2);
    
% --- Executes on button press in pb_import_t1_2.
function pb_import_t1_2_Callback(hObject, eventdata, handles)
    
    subID           = get(handles.eb_subjID, 'String');
    mriID           = get(handles.eb_mriID, 'String');
    projFolder      = get(handles.eb_projectFolder, 'String');
    watchFolder     = get(handles.eb_watchFolder, 'String'); 
    currentSession  = sprintf('%02s', get(handles.eb_session,'String'));
    
    if get(handles.cb_old_struct,'Value') == 1 

        %copy t1 session 1 to current session (for template) 
        getDir    = [projFolder, filesep, subID, filesep, 'Session_01', filesep, 'T1'];
        goDir     = [projFolder, filesep, subID, filesep, ['Session_' currentSession], filesep, 'T1'];

%         struct2copy   = spm_select('List', getDir, ['^s' '.*192-01.nii']);
        struct2copy   = spm_select('List', getDir, ['^MF' '.*.nii']);
        
        % check if dir is empty
        if numel(dir(goDir))>2 % skip 2 to take into account two dots..
            a = dir(goDir);
            filenames = {a.name};
            
            user_fb_update({'T1 folder should be but is NOT empty!';'';'Files found:';...
                {filenames{3:end}};'';['Dir: ' goDir];'';'Import aborted'},0,3);
            
            % open windows explorer for user to inspect folder contents
            winopen(goDir);
            
            return
        else
                 
            copyfile([getDir, filesep, struct2copy], [goDir, filesep, struct2copy])
            user_fb_update({['T1 copied: Session 1 --> Session ' currentSession]; 'Please check/re-set the origin.'},1 , 1)


            spm_image('Display', [goDir, filesep, struct2copy]) 
        end
        
    % if a new T1 is taken for each session 
    elseif get(handles.cb_new_struct,'Value') == 1
        user_fb_update({['Importing T1 to session ' currentSession]},1,1)
        user_fb_update({'Get ready to set origin at AC!'},0, 2)
        
        dicom_imp('struct', subID, mriID, watchFolder, projFolder,...
            get(handles.eb_imp_t1_2_sn, 'String'), 0, 1, ['Session_' sprintf('%02s', get(handles.eb_session,'String'))], 1);
    end
    
    
function eb_imp_t1_2_sn_Callback(hObject, eventdata, handles)
    handles.impT1_2_sn = get(hObject,'String');

    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eb_imp_t1_2_sn_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end    
    handles.impT1_2_sn = get(hObject,'String');
    guidata(hObject, handles);

% --- Executes on button press in pb_analyze_rs_2.
function pb_analyze_rs_2_Callback(hObject, eventdata, handles)
    user_fb_update({'Creating MC template...'},1,1)
    
    subinfo.subID       = get(handles.eb_subjID, 'String');
    subinfo.mriID       = get(handles.eb_mriID, 'String');
    subinfo.projFolder  = get(handles.eb_projectFolder, 'String');
    subinfo.watchFolder = get(handles.eb_watchFolder, 'String');  
    subinfo.dcmSeries   = get(handles.eb_analyze_rs_2_sn, 'String');
    subinfo.session     = ['Session_' sprintf('%02s', get(handles.eb_session,'String'))];
    subinfo.new_struct  = get(handles.cb_new_struct,'Value');
    subinfo.old_struct  = get(handles.cb_old_struct,'Value');
    
    if isempty(str2num(subinfo.subID)) 
        user_fb_update({'Subject ID not specified!';'Check settings and re-launch'},0, 3)
        return
    elseif isdir(subinfo.projFolder) == 0 
        user_fb_update({'Project Folder does not exist!';'Check path and re-launch'},0, 3)
        return
    elseif isdir(subinfo.watchFolder) == 0
        user_fb_update({'Watch Folder does not exist!';'Check path and re-launch'},0, 3)
        return
    else 
        analyze_rs(subinfo);
    end

function eb_analyze_rs_2_sn_Callback(hObject, eventdata, handles)
    handles.analyze_rs_2_sn = get(hObject,'String');
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function eb_analyze_rs_2_sn_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    % This is there to set the value to default if untouched
    handles.analyze_rs_2_sn = get(hObject,'String');
    guidata(hObject, handles);
    
% --- Executes on button press in pb_coreg_rois.
function pb_coreg_rois_Callback(hObject, eventdata, handles)

    if isempty(str2num(get(handles.eb_subjID,'String')))
        user_fb_update({'Subject ID not specified!'},0,3)
    else
        subinfo.subID       = get(handles.eb_subjID,'String');
        subinfo.session     = str2double(get(handles.eb_session,'String'));
        subinfo.projFolder  = get(handles.eb_projectFolder, 'String');
        
        user_fb_update({['Coreg ROIs: Sess 1 --> Sess ' num2str(subinfo.session)]},1,1)
        Coreg_ROIs_gui(subinfo);
    end
    
% --- Executes on button press in pb_coreg_results.
function pb_coreg_results_Callback(hObject, eventdata, handles)
    subinfo.subID       = get(handles.eb_subjID,'String');
    subinfo.projFolder  = get(handles.eb_projectFolder, 'String');
    
    user_fb_update({'ROI visualization..'}, 1,1)
    
    coreg_results(subinfo)
    

% --- Executes on button press in pb_create_ini_2.
function pb_create_ini_2_Callback(hObject, eventdata, handles)
    subID       = get(handles.eb_subjID,'String');
    projFolder  = get(handles.eb_projectFolder, 'String');
    watchFolder = get(handles.eb_watchFolder, 'String'); 
    sessNR          = get(handles.eb_session,'String');
    prepNFBpath = pwd;
    
    create_ini(subID, watchFolder, projFolder,prepNFBpath, ['Session_0' sessNR])

% --- Executes on button press in cb_beh_task_lang_2.
function cb_beh_task_lang_2_Callback(hObject, eventdata, handles)

    handles.cb_beh_task_2_lang = get(hObject,'Value');
    guidata(hObject, handles);


% --- Executes on button press in pb_run_behtask_2.
function pb_run_behtask_2_Callback(hObject, eventdata, handles)
    user_fb_update({'Running behavioral task...'},1,1)
    
    subID       = get(handles.eb_subjID, 'String');
    projFolder  = get(handles.eb_projectFolder,'String');
    session     = get(handles.eb_session, 'String' );
    
    if isfield(handles,'cb_beh_task_2_lang')
        if handles.cb_beh_task_2_lang == 1
            version = 'FR';
        end
    else
        version = 'EN';  
    end
    
    trainBlock = true;
    nBlocksRep = 10;
    maxNTargets = 10;
    fullScreen = true;
    keyboard = 'mri'; % we use 1 and 2
    screenid = 2;
    sessionID = strcat('0',session);
    disp(sessionID)
    path_output = strcat(projFolder,filesep,subID,filesep,'Session_',sessionID,'\TaskFolder\TaskResults');

    run_beh_task(trainBlock,nBlocksRep,maxNTargets,fullScreen,keyboard,screenid,subID,sessionID,path_output,version)


    
%     run_fam_task(subID, projFolder, 'Session_02')
%     run_fam_task(subID, projFolder, ['Session_0' sessNR])

% --- Executes on button press in pb_quit.
function pb_quit_Callback(hObject, eventdata, handles)
   
   pb_save_log_Callback(handles.pb_save_log, [], handles)
   quit_dlg()
   


% --- Executes on button press in pb_save_settings.
function pb_save_settings_Callback(hObject, eventdata, handles)

    settings.projFolder       = get(handles.eb_projectFolder, 'String');
    settings.watchFolder      = get(handles.eb_watchFolder, 'String');
    settings.NRsessions       = get(handles.eb_nr_sessions,'String'); 
    settings.NRruns           = get(handles.eb_nr_run,'String');
    settings.NRrois           = get(handles.eb_nr_ROIs,'String');

    settings.dcm.t1_1         = get(handles.eb_imp_t1_1_sn, 'String');
    settings.dcm.loc          = get(handles.eb_analyze_loc_sn, 'String');
    settings.dcm.rs_1         = get(handles.eb_analyze_rs_1_sn, 'String');
 
    settings.sess_c           = get(handles.eb_session, 'String'); 
    settings.dcm.t1_2         = get(handles.eb_imp_t1_2_sn, 'String');
    settings.dcm.rs_2         = get(handles.eb_analyze_rs_2_sn, 'String');
    settings.old_struct       = get(handles.cb_old_struct, 'Value');
    settings.new_struct       = get(handles.cb_new_struct, 'Value');
    settings.dcm.t1_2_flag    = get(handles.eb_imp_t1_2_sn, 'Enable');
    
    save([pwd, filesep, 'Settings', filesep, 'Settings_Main'], 'settings')
    user_fb_update({'Settings main window saved'},1,1)


% --- Executes on selection change in lb_feedback_window.
function lb_feedback_window_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function lb_feedback_window_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','black');
    end

    pfolder = 'None';
    wfolder = 'None';
    try 
        load([pwd, filesep, 'Settings', filesep, 'Settings_Main.mat']);
        pfolder = settings.projFolder;
        wfolder = settings.watchFolder; 
    catch

    end

    % opening message log file
    handles.user_fb{1,1} = 'prepNFB log';
    handles.user_fb{2,1} = datestr(datetime);
    handles.user_fb{3,1} = '---------------------------------';
    handles.user_fb{4,1} = '';
    handles.user_fb{5,1} = '- Enter Subject ID';
    handles.user_fb{6,1} = '- Double check watch folder!';
    handles.user_fb{7,1} = '';
    handles.user_fb{9,1} = '=================================';
    handles.user_fb{10,1} = '';
    handles.user_fb{11,1} = ['Project Folder: ' pfolder];
%     handles.user_fb{12,1} = ['Watch Folder: ' wfolder];
    handles.user_fb{13,1} = '';
    % handles.user_fb = {'prepNFB log';datestr(datetime);'---------------------------------';...
    %     ''; '- Enter Subject ID';'- Double check watch folder!';'';'=================================';''};

    set(hObject, 'String', handles.user_fb);

    assignin('base', 'user_fb', handles.user_fb);


% --- Executes on button press in pb_save_log.
function pb_save_log_Callback(hObject, eventdata, handles)
    
    subID       = get(handles.eb_subjID,'String');
    projFolder  = get(handles.eb_projectFolder, 'String');
    
    save_dir    = [projFolder, filesep, subID];
    file_name   = ['logfile_' datestr(now,'dd-mm-yyyy HH-MM') '.txt'];
    
    if isdir(save_dir)
        user_fb_update({['logfile saved in: ' save_dir]},1, 1);
        user_fb     = evalin('base','user_fb');
        fid = fopen([save_dir, filesep, file_name],'w');
        
        % clean user_fb html so it can be saved in txt file
        txt = regexprep(user_fb,'<script.*?/script>','');
        txt = regexprep(txt,'<style.*?/style>','');
        txt = regexprep(txt,'<.*?>','');
        
%         CT = user_fb.';
        CT = txt.';
        fprintf(fid,'%s\n', CT{:});
        fclose(fid);   
    else
        user_fb_update({'cant save logfile, directory invalid'},1, 3);
    end
        
% --- Executes on button press in pb_prt_manager.
function pb_prt_manager_Callback(hObject, eventdata, handles)

    user_fb_update({'NFB Protocol Manager'}, 1, 1);
    
    projFolder  = get(handles.eb_projectFolder, 'String');
    
    create_protocol({projFolder})
    


% --- Executes during object creation, after setting all properties.
function eb_mriID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_mriID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

