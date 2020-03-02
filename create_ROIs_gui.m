function varargout = create_ROIs_gui(varargin)



% Last Modified by GUIDE v2.5 05-Feb-2020 10:11:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @create_ROIs_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @create_ROIs_gui_OutputFcn, ...
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


% --- Executes just before create_ROIs_gui is made visible.
function create_ROIs_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to create_ROIs_gui (see VARARGIN)

% set paths to use and store in handels.subinfo
handles.output  = hObject;
handles.subinfo = varargin{:};

subPath         = [handles.subinfo.projFolder, filesep, handles.subinfo.subID];
handles.subinfo.subjStructDir   = [subPath, filesep, 'Session_01', filesep, 'T1', filesep];
handles.subinfo.epiPath         = [subPath, filesep, 'Session_01', filesep, 'EPI_Template_D1'];
handles.subinfo.statsdir        = [subPath, filesep, 'Localizer', filesep 'stats' filesep];
handles.subinfo.roiPath         = [subPath, filesep, 'Localizer', filesep, 'ROIs', filesep, 'Session_01'];

% load sub specific SPM mat file 
load([handles.subinfo.statsdir, filesep, 'SPM']);

% set the contrast names for list box (available contrasts)
set(handles.lb_contrasts, 'String', {SPM.xCon.name});

% % set first default in lb
% contents            = cellstr(get(handles.lb_contrasts,'String'));
% handles.ROInfo.conName = contents{get(handles.lb_contrasts,'Value')};

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes create_ROIs_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = create_ROIs_gui_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in lb_contrasts.
function lb_contrasts_Callback(hObject, eventdata, handles)

% Get the selected contrast. 
contents = cellstr(get(hObject,'String'));
handles.ROInfo.conName=contents{get(hObject,'Value')};

guidata(hObject, handles); 

% --- Executes during object creation, after setting all properties.
function lb_contrasts_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

guidata(hObject, handles);


% --- Executes on button press in cb_FWE.
function cb_FWE_Callback(hObject, eventdata, handles)

% handles.ROI.FWE = get(hObject,'Value');

if get(handles.cb_none,'Value') == 1
    set(handles.cb_none, 'Value', 0)
end

guidata(hObject, handles);

function eb_p_fwe_Callback(hObject, eventdata, handles)

% handles.ROI.FWE_p = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eb_p_fwe_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% handles.ROI.FWE_p = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes on button press in cb_none.
function cb_none_Callback(hObject, eventdata, handles)
% hObject    handle to cb_none (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_none
% handles.ROI.none = get(hObject,'Value');

if get(handles.cb_FWE,'Value') == 1
    set(handles.cb_FWE, 'Value', 0)
end

guidata(hObject, handles);

function eb_none_p_Callback(hObject, eventdata, handles)

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eb_none_p_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% handles.ROI.none_p = str2double(get(hObject,'String'));
guidata(hObject, handles);

function eb_extend_tresh_Callback(hObject, eventdata, handles)

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eb_extend_tresh_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% handles.ROI.ext_tresh = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes on button press in cb_str.
function cb_str_Callback(hObject, eventdata, handles)

handles.ROInfo.struct = get(hObject,'Value');

if get(handles.cb_epi,'Value') == 1
    set(handles.cb_epi, 'Value', 0)
end

guidata(hObject, handles);

% --- Executes on button press in cb_epi.
function cb_epi_Callback(hObject, eventdata, handles)
% hObject    handle to cb_epi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ROInfo.epi = get(hObject,'Value');

if get(handles.cb_str,'Value') == 1
    set(handles.cb_str, 'Value', 0)
end

guidata(hObject, handles);

% --- Executes on button press in pb_show_results.
function pb_show_results_Callback(hObject, eventdata, handles)
    % set first default in lb
    contents                = cellstr(get(handles.lb_contrasts,'String'));
    handles.ROInfo.conName  = contents{get(handles.lb_contrasts,'Value')};

    % get all the flag settings in current state and store in ROI struct
    handles.ROInfo.FWE         = get(handles.cb_FWE,'Value');
    handles.ROInfo.FWE_p       = str2double(get(handles.eb_p_fwe,'String'));
    handles.ROInfo.none        = get(handles.cb_none,'Value');
    handles.ROInfo.none_p      = str2double(get(handles.eb_none_p,'String'));
    handles.ROInfo.ext_tresh   = str2double(get(handles.eb_extend_tresh,'String'));
    handles.ROInfo.struct      = get(handles.cb_str,'Value');
    handles.ROInfo.epi         = get(handles.cb_epi,'Value');
    
    show_contrast_results(handles.subinfo, handles.ROInfo);
    
    % update the ROIinfo structure to contain the contrast info
    try
        handles.ROInfo.conInfo = conInfo;
         % save the ROInfo structure
        ROInfo = handles.ROInfo;
        save([handles.subinfo.roiPath, filesep, 'roiPrep', filesep,...
            'ROI_' num2str(handles.ROInfo.conInfo.conNr), filesep...
            'ROInfo_ROI_' num2str(handles.ROInfo.conInfo.conNr)], 'ROInfo');
    catch
        return
    end
    
   

    guidata(hObject, handles);


% --- Executes on button press in pb_save_msk.
function pb_save_msk_Callback(hObject, eventdata, handles)
% hObject    handle to pb_save_msk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles  and user data (see GUIDATA)

    write_clust(handles.subinfo, handles.ROInfo)
    
    handles.ROInfo.ccoords = outp.centre;
    handles.ROInfo.path = outp.path;
    ROInfo = handles.ROInfo;
    % save updated handles.ROI (overwrite)
    save([handles.subinfo.roiPath, filesep, 'roiPrep', filesep,...
        'ROI_' num2str(handles.ROInfo.conInfo.conNr), filesep...
        'ROInfo_ROI_' num2str(handles.ROInfo.conInfo.conNr)], 'ROInfo');


% --- Executes on selection change in lb_ROIs.
function lb_ROIs_Callback(hObject, eventdata, handles)

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function lb_ROIs_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_show_msk.
function pb_show_msk_Callback(hObject, eventdata, handles)
    % prep visualisation
    if get(handles.cb_str,'Value') == 1
        templ1 = spm_select('FPList', handles.subinfo.subjStructDir, ['^s' '.*192-01.nii$']);
    elseif get(handles.cb_epi,'Value') == 1
        templ1 = spm_select('FPList', handles.subinfo.epiPath, ['^mean' '.*.nii$']);
    end
    try 
        my_spm_check_registration([{templ1}],{{handles.tmpData.mskFP{get(handles.lb_ROIs,'Value')}}},{}, 1);
    catch
        user_fb_update({'Did you create the masks and refresh?'},0,3)
        warning('something went wrong, did you create the ROI masks and refresh?')
        
    end

% --- Executes on button press in pb_refresh.
function pb_refresh_Callback(hObject, eventdata, handles)

    % The routine below checks the roiPrep folder for valid folder content
    % (i.e. roi files). It's dynamic, first determing how many folders there
    % are listed in the roiPrep folder. After it will extract possible content
    % from those folders. If nothing is found it will move to the next folder. 
    msks_available={};
    S = dir([handles.subinfo.roiPath, filesep, 'roiPrep']);
    
    % or:
%     S = dir([handles.subinfo.roiPath, filesep, 'roiPrep', filesep, 'ROI_*.*']);
%     in this case b and c are not needed, but in a sense less flexible as the 
%     % subfolders need to be have prefix ROI_  

    a = find([S.isdir] == 1);
    b = find(~ismember({S.name},{'.','..'}) == 1);
    c = intersect(a,b);
    folderNames = {S(c).name};
    folderDirs  = {S(c).folder};
    cc = 1;
    for ii = 1:numel(folderNames)
        % this routine could potentially be replaced by spm_select(.nii) function.
        tmpdir  = [folderDirs{ii}, filesep, folderNames{ii}];%
%         tmpd    = dir([tmpdir]);
%         check   = find(~ismember({tmpd.name},{'.','..'}) == 1);
        tmpImgPath = spm_select('FPList', tmpdir,  ['^msk.*' '.nii$']);
        
        if ~isempty(tmpImgPath)      
            tmpImgName = spm_select('List', tmpdir,  ['^msk.*' '.nii$']);
            % add name to cell
%             msks_available{cc} = tmpd(check).name;
            msks_available{cc} = tmpImgName;

            % store full path to be used during visualization
%             handles.ROInfo.mskFP{cc} = [tmpdir, filesep, tmpd(check).name];
%             handles.ROInfo.mskFP{cc} = tmpImgPath;
            handles.tmpData.mskFP{cc} = tmpImgPath;
            
            handles.tmpData.mskName{cc}   = tmpImgName;
%             handles.ROInfo.mskName    = tmpImgName;
            % add one to counter 
            cc=cc+1;
        end    
    end

    guidata(hObject, handles);
    
    % set the mask names in the available msk list box
    if ~isempty(msks_available)
        set(handles.lb_ROIs, 'String', msks_available);
    elseif isempty(msks_available)
        msks_available={'no masks found!'};
        set(handles.lb_ROIs, 'String', msks_available);
    end



function eb_ROIsize_Callback(hObject, eventdata, handles)
% hObject    handle to eb_ROIsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eb_ROIsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_ROIsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in cb_equate_ROIs.
function cb_equate_ROIs_Callback(hObject, eventdata, handles)

guidata(hObject, handles);

function cb_funcClust_Callback(hObject, eventdata, handles)

% Hint: get(hObject,'Value') returns toggle state of cb_funcClust

if get(handles.cb_sphere, 'Value') == 1
    set(handles.cb_sphere, 'Value', 0)
end

guidata(hObject, handles);

% --- Executes on button press in cb_sphere.
function cb_sphere_Callback(hObject, eventdata, handles)

if get(handles.cb_funcClust, 'Value') == 1
    set(handles.cb_funcClust, 'Value', 0)
end

guidata(hObject, handles);

% --- Executes on button press in pb_show_roi.
function pb_show_roi_Callback(hObject, eventdata, handles)

% execute main body of ROI creation here. ROI specifics will be put in the
% handle.ROI struct at the end of the sequence to make it available for the
% create roi function, which writes out the final cluster
handles.ROInfo = {};
rois = get(handles.lb_ROIs,'Value');
for ii = 1:length(rois)
    tmpPath = [handles.subinfo.roiPath, filesep, 'roiPrep', filesep,...
        'ROI_' num2str(rois(ii)), filesep, 'ROInfo_ROI_' num2str(rois(ii))];
    a = load(tmpPath);
    handles.ROInfo.ROI{ii} = a.ROInfo;
    handles.ROInfo.ROI{ii}.mskName = handles.tmpData.mskName{rois(ii)};
end

handles.ROInfo.funcClust    = get(handles.cb_funcClust,'Value');
handles.ROInfo.sphere       = get(handles.cb_sphere,'Value');
handles.ROInfo.size         = str2double(get(handles.eb_ROIsize,'String'));
handles.ROInfo.equate       = get(handles.cb_equate_ROIs,'Value');
handles.ROInfo.whichNR      = get(handles.lb_ROIs,'Value');
handles.ROInfo.mskName      = handles.tmpData.mskName;
% handles.ROInfo.whichPath    = {handles.tmpData.mskFP{get(handles.lb_ROIs,'Value')}};

ROIsfinal = show_ROIs(handles.subinfo, handles.ROInfo);

handles.ROInfo.final = ROIsfinal;
guidata(hObject, handles);


% --- Executes on button press in pb_create_roi.
function pb_create_roi_Callback(hObject, eventdata, handles)
    write_ROIs(handles.subinfo, handles.ROInfo)
