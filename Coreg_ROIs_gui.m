function varargout = Coreg_ROIs_gui(varargin)
% COREG_ROIS_GUI MATLAB code for Coreg_ROIs_gui.fig
%      COREG_ROIS_GUI, by itself, creates a new COREG_ROIS_GUI or raises the existing
%      singleton*.
%
%      H = COREG_ROIS_GUI returns the handle to a new COREG_ROIS_GUI or the handle to
%      the existing singleton*.
%
%      COREG_ROIS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COREG_ROIS_GUI.M with the given input arguments.
%
%      COREG_ROIS_GUI('Property','Value',...) creates a new COREG_ROIS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Coreg_ROIs_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Coreg_ROIs_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Coreg_ROIs_gui

% Last Modified by GUIDE v2.5 19-Feb-2020 13:08:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Coreg_ROIs_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @Coreg_ROIs_gui_OutputFcn, ...
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


% --- Executes just before Coreg_ROIs_gui is made visible.
function Coreg_ROIs_gui_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for Coreg_ROIs_gui
handles.output = hObject;
% % % handles.ROIs = [];
% % % % Update handles structure
% % % guidata(hObject, handles);
handles.subinfo         = varargin{:};

subPath                 = [handles.subinfo.projFolder, filesep, handles.subinfo.subID];
handles.subinfo.roiPath = [subPath, filesep, 'Localizer', filesep, 'ROIs'];

ROIs_available = struct;
folderNames = {'Session_01', ['Session_' sprintf('%02d', handles.subinfo.session)]}; % make second folder dependent on prepNFB session nr input

    for ii = 1:numel(folderNames)

        %for session
        tmpSessROIs = dir([handles.subinfo.roiPath, filesep, ['Session_01'], filesep, 'ROI_*.*']);
        tmpNames = {tmpSessROIs.name};
        tmpDirs = {tmpSessROIs.folder};

        for jj = 1:numel(tmpNames)

            % for rois
            % get roi names and put in struct
            tmpROI = dir([tmpDirs{jj}, filesep, tmpNames{jj}, filesep, '*.nii']);

            ROIs_available.Session(ii).ROI(jj).sess = folderNames{ii};
            ROIs_available.Session(ii).ROI(jj).name = tmpROI.name;
            ROIs_available.Session(ii).ROI(jj).path = tmpROI.folder;
            ROIs_available.Session(ii).ROI(jj).Fpath = [tmpROI.folder, filesep, tmpROI.name];    
        end

        % add structural FP and epi FP to the structure so we can use the
        % results of get(lb_) to index... 
        % set paths
        PS = [subPath, filesep, folderNames{ii}, filesep, 'T1', filesep];       % struc path
        PE = [subPath, filesep, folderNames{ii}, filesep, 'EPI_Template_D1'];   % epi path

        % get full path to .nii
        ROIs_available.Session(ii).struct   = spm_select('FPList', PS, ['^s' '.*192-01.nii$']);
        ROIs_available.Session(ii).epi      = spm_select('FPList', PE, ['^mean' '.*.nii$']);
    end

    handles.ROInfo = ROIs_available;

    guidata(hObject, handles);

% --- Executes on button press in cb_struct_templ.
function cb_struct_templ_Callback(hObject, eventdata, handles)
% hObject    handle to cb_struct_templ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	if get(handles.cb_epi_templ,'Value') == 1
        set(handles.cb_epi_templ,'Value', 0);
    end
    if get(handles.cb_struct_templ,'Value') == 1
        set(handles.cb_coreg_struct,'Value', 0);
    end


% --- Executes on button press in cb_epi_templ.
function cb_epi_templ_Callback(hObject, eventdata, handles)
% hObject    handle to cb_epi_templ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	if get(handles.cb_struct_templ,'Value') == 1
        set(handles.cb_struct_templ,'Value', 0);
    end

function varargout = Coreg_ROIs_gui_OutputFcn(hObject, eventdata, handles) 

    varargout{1} = handles.output;


function eb_ref_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function eb_ref_CreateFcn(hObject, eventdata, handles)
    
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in pb_br_ref.
function pb_br_ref_Callback(hObject, eventdata, handles)
    refIm = uigetdir([handles.subinfo.projFolder, filesep, handles.subinfo.subID]);
%     refIm = uigetdir();
    handles.refIm = refIm;
    set(handles.eb_ref, 'String', handles.refIm);
    guidata(hObject, handles);


function eb_source_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function eb_source_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on selection change in lb_ROIs.
function lb_ROIs_Callback(hObject, eventdata, handles)
    
% --- Executes during object creation, after setting all properties.
function lb_ROIs_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in pb_br_source.
function pb_br_source_Callback(hObject, eventdata, handles)
    sourceIm = uigetdir([handles.subinfo.projFolder, filesep, handles.subinfo.subID]);
%     sourceIm = uigetdir();
    handles.sourceIm = sourceIm;
    set(handles.eb_source, 'String', handles.sourceIm);
    guidata(hObject, handles);


% --- Executes on button press in pb_run.
function pb_run_Callback(hObject, eventdata, handles)
    coreg.refPath       = get(handles.eb_ref, 'String');
    coreg.sourcePath    = get(handles.eb_source, 'String');
    coreg.ROIs          = get(handles.lb_ROIs, 'String');
    coreg.structs       = {handles.ROInfo.Session.struct}';
    coreg.sflag         = get(handles.cb_coreg_struct, 'Value');
    coreg.struct_flag   = get(handles.cb_struct_templ, 'Value');
    coreg.epi_flag      = get(handles.cb_epi_templ, 'Value');
    coreg.ROInfo        = handles.ROInfo;
    
    coreg_ROIs(handles.subinfo, coreg)


% --- Executes on button press in pb_clear.
function pb_clear_Callback(hObject, eventdata, handles)
    contents = cellstr(get(handles.lb_ROIs,'String'));
    if ~isempty(contents)
        clearThese = {contents{get(handles.lb_ROIs,'Value')}};
        keepThese = contents(~ismember(contents, clearThese));

        set(handles.lb_ROIs,'String', keepThese);
        set(handles.lb_ROIs,'Value', 1)
        handles.ROIs = keepThese;
    end
    guidata(hObject, handles);


% --- Executes on button press in pb_get.
function pb_get_Callback(hObject, eventdata, handles)
    
    % if coreg templates are structural scans
    if get(handles.cb_struct_templ, 'Value') == 1
        % set the mask names in the available msk list box
        if ~isempty(handles.ROInfo)
            onset = 1;       
            % set reference path
            set(handles.eb_ref, 'String', handles.ROInfo.Session(2).struct(onset:end));       
            % set source path
            set(handles.eb_source, 'String', handles.ROInfo.Session(1).struct(1,onset:end));
            % set ROI paths
            set(handles.lb_ROIs, 'String', {handles.ROInfo.Session(1).ROI.Fpath});

        elseif isempty(ROIs_available)
            folderNames={'ERROR: no session directories'};
            set(handles.lb_ROIs, 'String', msks_available);
        end
    % if coreg templates are epi scans 
    elseif get(handles.cb_epi_templ, 'Value') == 1
          % set the mask names in the available msk list box
        if ~isempty(handles.ROInfo)
            onset = 1;       
            % set reference path
            set(handles.eb_ref, 'String', handles.ROInfo.Session(2).epi(onset:end));       
            % set source path
            set(handles.eb_source, 'String', handles.ROInfo.Session(1).epi(1,onset:end));
            % set ROI paths
            set(handles.lb_ROIs, 'String', {handles.ROInfo.Session(1).ROI.Fpath});

        elseif isempty(ROIs_available)
            folderNames={'ERROR: no session directories'};
            set(handles.lb_ROIs, 'String', msks_available);
        end
    end

% --- Executes on button press in pb_br_ROIs.
function pb_br_ROIs_Callback(hObject, eventdata, handles)
%     [ROI FP] = uigetfile('*.nii');
    [ROI FP] = uigetfile([handles.subinfo.roiPath, filesep '*.nii'], 'select a ROI');
    if ROI ~= 0 
        handles.ROIs = [get(handles.lb_ROIs, 'String'); {[FP, ROI]}];
        set(handles.lb_ROIs, 'String', handles.ROIs);
    end
    guidata(hObject, handles);


% --- Executes on button press in cb_coreg_struct.
function cb_coreg_struct_Callback(hObject, eventdata, handles)
    % hObject    handle to cb_coreg_struct (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
	if get(handles.cb_struct_templ,'Value') == 1
        set(handles.cb_coreg_struct,'Value', 0);
    end
    guidata(hObject, handles);
    % Hint: get(hObject,'Value') returns toggle state of cb_coreg_struct


