function varargout = coreg_results(varargin)
    
% COREG_RESULTS MATLAB code for coreg_results.fig
%      COREG_RESULTS, by itself, creates a new COREG_RESULTS or raises the existing
%      singleton*.
%
%      H = COREG_RESULTS returns the handle to a new COREG_RESULTS or the handle to
%      the existing singleton*.
%
%      COREG_RESULTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COREG_RESULTS.M with the given input arguments.
%
%      COREG_RESULTS('Property','Value',...) creates a new COREG_RESULTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before coreg_results_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to coreg_results_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help coreg_results

% Last Modified by GUIDE v2.5 14-Jun-2019 22:59:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @coreg_results_OpeningFcn, ...
                   'gui_OutputFcn',  @coreg_results_OutputFcn, ...
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


% --- Executes just before coreg_results is made visible.
function coreg_results_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to coreg_results (see VARARGIN)

% niiFiles = dir([subPath, '\**\*.nii']);

% Choose default command line output for coreg_results
handles.output          = hObject;
handles.subinfo         = varargin{:};

subPath                 = [handles.subinfo.projFolder, filesep, handles.subinfo.subID];
handles.subinfo.roiPath = [subPath, filesep, 'Localizer', filesep, 'ROIs'];

ROIs_available = struct;
S = dir([handles.subinfo.roiPath, filesep, 'Session_*.*']);
% clear the S struct if the directoy has nothinh


folderNames = {S.name};
folderDirs  = {S.folder};

counter_session = 1;

for ii = 1:numel(folderNames)
    
    %for session
    tmpSessCont = dir([folderDirs{1}, filesep, folderNames{ii}, filesep, 'ROI_*.*']);
    tmpNames = {tmpSessCont.name};
    tmpDirs = {tmpSessCont.folder};

    
    for jj = 1:numel(tmpNames)

        if size(dir([tmpDirs{jj}, filesep, tmpNames{jj}]),1)>2 % check for ROIS
            % for rois
            % get roi names and put in struct
            tmpROI = dir([tmpDirs{jj}, filesep, tmpNames{jj}, filesep, '*.nii']);
            
            ROIs_available.Session(ii).ROI(jj).sess = folderNames{ii};
            ROIs_available.Session(ii).ROI(jj).name = tmpROI.name;
            ROIs_available.Session(ii).ROI(jj).Fpath = [tmpROI.folder, filesep, tmpROI.name];    

            counter_session = counter_session + 1;
        end

    end

        if size(dir([subPath, filesep, folderNames{ii}, filesep, 'T1', filesep]),1)>2 % check for the T1 and EPI


            % add structural FP and epi FP to the structure so we can use the
            % results of get(lb_) to index... 
            % set paths
            PS = [subPath, filesep, folderNames{ii}, filesep, 'T1', filesep];       % struc path
            PE = [subPath, filesep, folderNames{ii}, filesep, 'EPI_Template_D1'];   % epi path
            
            % get full path to .nii
    %         ROIs_available.Session(ii).struct   = spm_select('FPList', PS, ['^s' '.*192-01.nii$']);
            ROIs_available.Session(ii).struct   = spm_select('FPList', PS, ['^MF' '.*.nii$']);
            ROIs_available.Session(ii).epi      = spm_select('FPList', PE, ['^mean' '.*.nii$']);

        end
end

handles.ROInfo = ROIs_available;
      
guidata(hObject, handles);

folderNames = folderNames(1:floor(counter_session/2));

% set the mask names in the available msk list box
if ~isempty(ROIs_available)
    set(handles.lb_sess1, 'String', folderNames);
    set(handles.lb_sess2, 'String', folderNames);
    set(handles.lb_rois, 'String', {ROIs_available(1).Session(1).ROI.name});
elseif isempty(ROIs_available)
    folderNames={'ERROR: no session directories'};
    set(handles.lb_ROIs, 'String', msks_available);
end


% --- Outputs from this function are returned to the command line.
function varargout = coreg_results_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in lb_sess1.
function lb_sess1_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns lb_sess1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lb_sess1


% --- Executes during object creation, after setting all properties.
function lb_sess1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lb_sess1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lb_sess2.
function lb_sess2_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function lb_sess2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in lb_rois.
function lb_rois_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function lb_rois_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end    


% --- Executes on button press in cb_struct.
function cb_struct_Callback(hObject, eventdata, handles)
% handles.cb_struct = get(hObject,'Value');
% handles.flags.struct = get(hObject,'Value');
   
% % if get(handles.cb_epi,'Value') == 1
% %     set(handles.cb_epi, 'Value', 0)
% % end
% % if get(handles.cb_none,'Value') == 1
% %     set(handles.cb_none, 'Value', 0)
% % end
guidata(hObject, handles);


% --- Executes on button press in cb_epi.
function cb_epi_Callback(hObject, eventdata, handles)
% handles.cb_epi = get(hObject,'Value');

% % if get(handles.cb_struct,'Value') == 1
% %     set(handles.cb_struct, 'Value', 0)
% % end
% % if get(handles.cb_none,'Value') == 1
% %     set(handles.cb_none, 'Value', 0)
% % end
guidata(hObject, handles);

% --- Executes on button press in cb_none.
function cb_none_Callback(hObject, eventdata, handles)
% handles.cb_none = get(hObject,'Value');
% handles.flags.none = get(hObject,'Value');
if get(handles.cb_struct,'Value') == 1 
    set(handles.cb_struct, 'Value', 0)
end
if get(handles.cb_epi,'Value') == 1
    set(handles.cb_epi, 'Value', 0)
end

guidata(hObject, handles);


% --- Executes on button press in pb_show.
function pb_show_Callback(hObject, eventdata, handles)

% define arguments
templ1 = {};
templ2 = {};
ROI_1 = {};         % All available ROIs from Session A
ROI_2 = {};         % All available ROIs from Session B
epi_overlay_1 = {};
epi_overlay_2 = {};
overlay_flag = 1;

% is overlay is struct and not epi
if get(handles.cb_struct,'Value') == 1 && get(handles.cb_epi,'Value') == 0
    % get path to struct based on first window
    templ1 = handles.ROInfo.Session(get(handles.lb_sess1,'Value')).struct;
    
    % record session name for reporting to user in gui
    sess_name{1,1} = handles.ROInfo.Session(get(handles.lb_sess1,'Value')).ROI(1).sess;
    templ_name{1,1} = 'Structural template(s)';
    % if not a single session display
    if get(handles.cb_single_sess,'Value') == 0
        % also get the path to the struct of the second window
        templ2 = handles.ROInfo.Session(get(handles.lb_sess2,'Value')).struct;
        sess_name{1,2} = handles.ROInfo.Session(get(handles.lb_sess2,'Value')).ROI(1).sess;
    end
    
% if overlay is epi and not struct    
elseif get(handles.cb_epi,'Value') == 1 && get(handles.cb_struct,'Value') == 0 
    % get path to epi from first window
    templ1 = handles.ROInfo.Session(get(handles.lb_sess1,'Value')).epi;
    
    sess_name{1,1} = handles.ROInfo.Session(get(handles.lb_sess1,'Value')).ROI(1).sess;
    templ_name{1,1} = 'EPI template(s)';
    % if not a single session 
    if get(handles.cb_single_sess,'Value') == 0
        % also get the path to the current session epi based on second
        % window
        templ2 = handles.ROInfo.Session(get(handles.lb_sess2,'Value')).epi;
        sess_name{1,2} = handles.ROInfo.Session(get(handles.lb_sess2,'Value')).ROI(1).sess;
    end
    
% if overlay are both struct and epi (functional overlay on struct)    
elseif get(handles.cb_struct,'Value') == 1 && get(handles.cb_epi,'Value') == 1
    % get overlays from first window 
    templ1 = handles.ROInfo.Session(get(handles.lb_sess1,'Value')).struct;
    
    sess_name{1,1} = handles.ROInfo.Session(get(handles.lb_sess1,'Value')).ROI(1).sess;
    templ_name{1,1} = 'Structural + EPI template(s)';
    
    epi_overlay_1 = handles.ROInfo.Session(get(handles.lb_sess1,'Value')).epi;
    
    % and of second window if not single session
    if get(handles.cb_single_sess,'Value') == 0
        templ2 = handles.ROInfo.Session(get(handles.lb_sess2,'Value')).struct;
        sess_name{1,2} = handles.ROInfo.Session(get(handles.lb_sess2,'Value')).ROI(1).sess;
        epi_overlay_2 = handles.ROInfo.Session(get(handles.lb_sess2,'Value')).epi;
    end   
end

% get the ROIs accordingly of first session (based in windows)
ROI_1 = {handles.ROInfo.Session(get(handles.lb_sess1,'Value')).ROI(get(handles.lb_rois,'Value')).Fpath};
roi_names = {handles.ROInfo.Session(get(handles.lb_sess1,'Value')).ROI(get(handles.lb_rois,'Value')).name};

% and if not single session also of the current session
if get(handles.cb_single_sess,'Value') == 0
    ROI_2 = {handles.ROInfo.Session(get(handles.lb_sess2,'Value')).ROI(get(handles.lb_rois,'Value')).Fpath};
end

% move ROIs to template position if no overlay selected
if get(handles.cb_none,'Value') == 1
    my_spm_check_registration([ROI_1;ROI_2],{}, 0);
else
    % otherwise display as default
    my_spm_check_registration([{templ1};{templ2}],{ROI_1, ROI_2},{epi_overlay_1, epi_overlay_2}, overlay_flag);
end

message{1,1} = 'Showing ROI(s): ';
message{2,1} = roi_names;
message{3,1} = 'Of: ';
message{4,1} = sess_name;
message{5,1} = 'On: ';
message{6,1} = templ_name;

user_fb_update(message,0,1);

% --- Executes on button press in cb_single_sess.
function cb_single_sess_Callback(hObject, eventdata, handles)

% Hint: get(hObject,'Value') returns toggle state of cb_single_sess
if get(hObject,'Value') == 1
    set(handles.lb_sess2, 'Enable', 'off')
elseif get(hObject,'Value') == 0
    set(handles.lb_sess2, 'Enable', 'on');
end
guidata(hObject, handles);
