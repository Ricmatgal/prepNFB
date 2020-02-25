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

% Last Modified by GUIDE v2.5 21-Feb-2020 21:38:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
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
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prep_NFB (see VARARGIN)

handles.output = hObject;
handles.watchFolder = '';
handles.projFolder = '';
addpath([pwd filesep 'functions'])

    try
        load([pwd, filesep, 'Settings', filesep, 'Settings_Main.mat']);
        
        try
            % set directories
            set(handles.eb_projectFolder, 'String', settings.projFolder);
            set(handles.eb_watchFolder, 'String', settings.watchFolder); 
            
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
    % Update handles structure
    guidata(hObject, handles);

% UIWAIT makes prep_NFB wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prep_NFB_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
assignin('base', 'outp', handles);
% assignin('base', 'user_fb', handles.user_fb);

% ================================================================
%% ========================== Top panel ==========================
% ================================================================

% --- Executes during object creation, after setting all properties.
function eb_subjID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_subjID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function eb_subjID_Callback(hObject, eventdata, handles)
% hObject    handle to eb_subjID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eb_subjID as text
%        str2double(get(hObject,'String')) returns contents of eb_subjID as a double
handles.subID = get(hObject,'String');
message = {['Subject: ' handles.subID]};
user_fb_update(message,1, 1);
guidata(hObject, handles);


% --- Executes on button press in pb_initialize.
function pb_initialize_Callback(hObject, eventdata, handles)
% hObject    handle to pb_initialize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
subID       = get(handles.eb_subjID, 'String');
subFolder   = get(handles.eb_projectFolder,'String');
mkSubDir(subID, subFolder)

guidata(hObject, handles);

function eb_projectFolder_Callback(hObject, eventdata, handles)
% hObject    handle to eb_projectFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eb_projectFolder as text
%        str2double(get(hObject,'String')) returns contents of eb_projectFolder as a double
handles.projFolder = get(hObject,'String');

message = {['Project Folder updated: '  get(hObject,'String')]};
user_fb_update(message, 0, 2);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eb_projectFolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_projectFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_browse_proj.
function pb_browse_proj_Callback(hObject, eventdata, handles)
% hObject    handle to pb_browse_proj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
projFolder = uigetdir();
handles.projFolder = projFolder;
set(handles.eb_projectFolder, 'String', handles.projFolder);
    

message = {['Project Folder updated: '  handles.projFolder]};
user_fb_update(message, 0, 2);

guidata(hObject, handles);


function eb_watchFolder_Callback(hObject, eventdata, handles)
% hObject    handle to eb_watchFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

message = {['Watch Folder updated: '  get(hObject,'String')]};
user_fb_update(message, 0, 2);

handles.watchFolder = get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eb_watchFolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_watchFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pb_browse_watch.
function pb_browse_watch_Callback(hObject, eventdata, handles)
% hObject    handle to pb_browse_watch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
watchFolder         = uigetdir('D:\TBV_input');
handles.watchFolder = watchFolder;
set(handles.eb_watchFolder, 'String', handles.watchFolder);

message = {['Watch Folder updated: '  handles.watchFolder]};
user_fb_update(message, 0, 2);

guidata(hObject, handles);

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
        user_fb_update({'ERROR';'Subject ID not specified!';'Check settings and re-launch'},0, 3)
        return
    elseif isdir(projFolder) == 0 
        user_fb_update({'ERROR','Project Folder does not exist!';'Check path and re-launch'},0, 3)
        return
     else
        run_offa_loc(subID, projFolder)
    end
    


% --- Executes on button press in pb_import_t1_1.
function pb_import_t1_1_Callback(hObject, eventdata, handles)
    user_fb_update({'Importing T1 to session 1...'},1, 1)
    user_fb_update({'Get ready to set origin at AC!'},0, 2)
    subID           = get(handles.eb_subjID, 'String');
    projFolder      = get(handles.eb_projectFolder,'String');
    watchFolder     = get(handles.eb_watchFolder,'String');
    impT1_1_sn      = get(handles.eb_imp_t1_1_sn, 'String');
%     
    dicom_imp('struct', subID, watchFolder, projFolder,...
        impT1_1_sn, 0, 1, 'Session_01', 192);

function eb_imp_t1_1_sn_Callback(hObject, eventdata, handles)

    handles.impT1_1_sn = get(hObject,'String');
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function eb_imp_t1_1_sn_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to eb_imp_t1_1_sn (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
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

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    handles.analyze_loc_sn = get(hObject,'String');
    guidata(hObject, handles);
    
% --- Executes on button press in pb_ROI.
function pb_ROI_Callback(hObject, eventdata, handles)
    user_fb_update({'Initiating ROI analyses..'},1, 1)
%     create_ROIs(handles.subID, handles.projFolder) 
    subinfo.subID = handles.subID;
    subinfo.projFolder  = get(handles.eb_projectFolder, 'String');
    if isempty(subinfo.subID) || isdir(subinfo.projFolder) == 0 
        fprintf('Subject ID and/or Project Folder not (correctly) specified!\n')
        fprintf('Check settings and launch ROI tool again.\n')
        return
    else 
        create_ROIs_gui(subinfo)      
    end


% --- Executes on button press in pb_analyze_rs_1.
function pb_analyze_rs_1_Callback(hObject, eventdata, handles)
    % %     fprintf('\nAnalyzing first images of resting state to get EPI template...')
    % %     analyze_rs(handles.subID, handles.watchFolder, handles.projFolder, handles.analyze_rs_1_sn,...
    % %         'Session_01');
     fprintf('\nButton deactivated! See prep_NFB line 254...\n')

function eb_analyze_rs_1_sn_Callback(hObject, eventdata, handles)
    % hObject    handle to eb_analyze_rs_1_sn (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of eb_analyze_rs_1_sn as text
    %        str2double(get(hObject,'String')) returns contents of eb_analyze_rs_1_sn as a double
    handles.analyze_rs_1_sn = get(hObject,'String');
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eb_analyze_rs_1_sn_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to eb_analyze_rs_1_sn (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
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
    create_ini(subID, watchFolder, projFolder, 'Session_01')

    
% --- Executes on button press in cb_stimSet1_1.
function cb_stimSet1_1_Callback(hObject, eventdata, handles)
    % hObject    handle to cb_stimSet1_1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if get(handles.cb_stimSet2_1,'Value') == 1
        set(handles.cb_stimSet2_1,'Value', 0);
    end
    
    handles.stimSet1_1 = get(hObject,'Value');
    guidata(hObject, handles);

% --- Executes on button press in cb_stimSet2_1.
function cb_stimSet2_1_Callback(hObject, eventdata, handles)
    % hObject    handle to cb_stimSet2_1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

	if get(handles.cb_stimSet1_1,'Value') == 1
        set(handles.cb_stimSet1_1,'Value', 0);
    end
    
    handles.stimSet2_1 = get(hObject,'Value');
    guidata(hObject, handles);

    
% --- Executes on button press in pb_task_param_1.
function pb_task_param_1_Callback(hObject, eventdata, handles)
    subID       = get(handles.eb_subjID, 'String');
    projFolder  = get(handles.eb_projectFolder,'String');

    creat_fam_param(subID, projFolder, 'Session_01')
    
    create_task_param(subID, projFolder, 'Session_01')
    
% --- Executes on button press in pb_run_famTask_1.
function pb_run_famTask_1_Callback(hObject, eventdata, handles)
    fprintf('\nRunning familiarization task...')
    
    subID       = get(handles.eb_subjID, 'String');
    projFolder  = get(handles.eb_projectFolder,'String');4
    
    run_fam_task(subID, projFolder, 'Session_01')

% ================================================================
%% ========================== Session > 1 ==========================
% ================================================================

function eb_session_Callback(hObject, eventdata, handles)
% hObject    handle to eb_session (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eb_session as text
%        str2double(get(hObject,'String')) returns contents of eb_session as a double
    handles.sessionNR = get(hObject,'String');
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eb_session_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_session (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in cb_old_struct.
function cb_old_struct_Callback(hObject, eventdata, handles)
% hObject    handle to cb_old_struct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    if get(handles.cb_new_struct,'Value') == 1
        set(handles.cb_new_struct,'Value', 0);
    end
    
    if get(hObject,'Value') == 1
        set(handles.eb_imp_t1_2_sn, 'Enable', 'off')
    end
    

function cb_new_struct_Callback(hObject, eventdata, handles)
% hObject    handle to cb_new_struct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if get(handles.cb_old_struct,'Value') == 1
        set(handles.cb_old_struct,'Value', 0);
    end
    if get(hObject,'Value') == 1
        set(handles.eb_imp_t1_2_sn, 'Enable', 'on');
    end

% --- Executes on button press in pb_import_t1_2.
function pb_import_t1_2_Callback(hObject, eventdata, handles)
    
    subID           = get(handles.eb_subjID, 'String');
    projFolder      = get(handles.eb_projectFolder, 'String');
    watchFolder     = get(handles.eb_watchFolder, 'String'); 
    currentSession  = sprintf('%02s', get(handles.eb_session,'String'));
    
    if get(handles.cb_old_struct,'Value') == 1 

        %copy t1 session 1 to current session (for template) 
        getDir    = [projFolder, filesep, subID, filesep, 'Session_01', filesep, 'T1'];
        goDir     = [projFolder, filesep, subID, filesep, ['Session_' currentSession], filesep, 'T1'];

        struct2copy   = spm_select('List', getDir, ['^s' '.*192-01.nii']);

        copyfile([getDir, filesep, struct2copy], [goDir, filesep, struct2copy])
        fprintf(['Structural scan copied from Session 1 --> Session ' currentSession '.\n'])

        fprintf('Please check/re-set the origin\n')
        spm_image('Display', [goDir, filesep, struct2copy])
    
    % if a new T1 is taken for each session 
    elseif get(handles.cb_new_struct,'Value') == 1
      
        dicom_imp('struct', subID, watchFolder, projFolder,...
            get(handles.eb_imp_t1_2_sn, 'String'), 0, 1, ['Session_' sprintf('%02s', get(handles.eb_session,'String'))], 192);
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
    fprintf('\nAnalyzing first images of resting state to get EPI template...')
    
    subinfo.subID       = get(handles.eb_subjID, 'String');
    subinfo.projFolder  = get(handles.eb_projectFolder, 'String');
    subinfo.watchFolder = get(handles.eb_watchFolder, 'String');  
    subinfo.dcmSeries   = get(handles.eb_analyze_rs_2_sn, 'String');
    subinfo.session     = ['Session_' sprintf('%02s', get(handles.eb_session,'String'))];
    subinfo.new_struct  = get(handles.cb_new_struct,'Value');
    subinfo.old_struct  = get(handles.cb_old_struct,'Value');
    
    analyze_rs(subinfo);

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
        fprintf('Subject ID not specified!\n')
    else
        subinfo.subID       = get(handles.eb_subjID,'String');
        subinfo.session     = str2double(get(handles.eb_session,'String'));
        subinfo.projFolder  = get(handles.eb_projectFolder, 'String');
        
        fprintf(['\nROIs Sess ' num2str(subinfo.session) ' --> ROIs Sess1 coregristration...\n'])
        Coreg_ROIs_gui(subinfo);
    end
    
  


% --- Executes on button press in pb_coreg_results.
function pb_coreg_results_Callback(hObject, eventdata, handles)
    subinfo.subID       = get(handles.eb_subjID,'String');
    subinfo.projFolder  = get(handles.eb_projectFolder, 'String');
    coreg_results(subinfo)
    

% --- Executes on button press in pb_create_ini_2.
function pb_create_ini_2_Callback(hObject, eventdata, handles)
    subID       = get(handles.eb_subjID,'String');
    projFolder  = get(handles.eb_projectFolder, 'String');
    watchFolder = get(handles.eb_watchFolder, 'String'); 
    create_ini(subID, watchFolder, projFolder, 'Session_02')

% --- Executes on button press in cb_stimSet1_2.
function cb_stimSet1_2_Callback(hObject, eventdata, handles)
   
    if get(handles.cb_stimSet2_2,'Value') == 1
        set(handles.cb_stimSet2_2,'Value', 0);
    end
    
    guidata(hObject, handles);

% --- Executes on button press in cb_stimSet2_2.
function cb_stimSet2_2_Callback(hObject, eventdata, handles)

    if get(handles.cb_stimSet1_2,'Value') == 1
        set(handles.cb_stimSet1_2,'Value',0);
    end

    guidata(hObject, handles);

    
% --- Executes on button press in pb_task_param_2.
function pb_task_param_2_Callback(hObject, eventdata, handles)
    % create familiarization task parameters
    subID       = get(handles.eb_subjID,'String');
    projFolder  = get(handles.eb_projectFolder, 'String');
    
    creat_fam_param(subID, projFolder, 'Session_02')
    
    % create task parameters 
    create_task_param(subID, projFolder, 'Session_02')

% --- Executes on button press in pb_run_famTask_2.
function pb_run_famTask_2_Callback(hObject, eventdata, handles)
    subID       = get(handles.eb_subjID,'String');
    projFolder  = get(handles.eb_projectFolder, 'String');
    
    run_fam_task(subID, projFolder, 'Session_02')



% --- Executes on button press in pb_quit.
function pb_quit_Callback(hObject, eventdata, handles)
   quit_dlg()
   


% --- Executes on button press in pb_save_settings.
function pb_save_settings_Callback(hObject, eventdata, handles)
% hObject    handle to pb_save_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    settings.projFolder       = get(handles.eb_projectFolder, 'String');
    settings.watchFolder      = get(handles.eb_watchFolder, 'String');
    
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
    fprintf('\nSettings main window saved in Settings folder\n')

function eb_nr_sessions_Callback(hObject, eventdata, handles)
% hObject    handle to eb_nr_sessions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eb_nr_sessions as text
%        str2double(get(hObject,'String')) returns contents of eb_nr_sessions as a double


% --- Executes during object creation, after setting all properties.
function eb_nr_sessions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_nr_sessions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lb_feedback_window.
function lb_feedback_window_Callback(hObject, eventdata, handles)
% hObject    handle to lb_feedback_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lb_feedback_window contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lb_feedback_window

% --- Executes during object creation, after setting all properties.
function lb_feedback_window_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lb_feedback_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
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
handles.user_fb{12,1} = ['Watch Folder: ' wfolder];
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
        
    
    
%     writecell(user_fb,[save_dir, filesep, 'logfile_' datestr(now,'dd-mm-yyyy HH-MM') '.txt'])
    
