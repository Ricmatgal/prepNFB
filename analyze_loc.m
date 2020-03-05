function varargout = analyze_loc(varargin)
% ANALYZE_LOC MATLAB code for analyze_loc.fig
%      ANALYZE_LOC, by itself, creates a new ANALYZE_LOC or raises the existing
%      singleton*.
%
%      H = ANALYZE_LOC returns the handle to a new ANALYZE_LOC or the handle to
%      the existing singleton*.
%
%      ANALYZE_LOC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANALYZE_LOC.M with the given input arguments.
%
%      ANALYZE_LOC('Property','Value',...) creates a new ANALYZE_LOC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before analyze_loc_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to analyze_loc_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help analyze_loc

% Last Modified by GUIDE v2.5 05-Mar-2020 16:19:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @analyze_loc_OpeningFcn, ...
                   'gui_OutputFcn',  @analyze_loc_OutputFcn, ...
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


% --- Executes just before analyze_loc is made visible.
function analyze_loc_OpeningFcn(hObject, eventdata, handles, varargin)

    % Choose default command line output for analyze_loc
    handles.output = hObject;
    handles.subinfo = varargin{:};
    % % 
    subPath         = [handles.subinfo.projFolder, filesep, handles.subinfo.subID];
    handles.subinfo.subjStructDir   = [subPath, filesep, 'Session_01', filesep, 'T1', filesep];
    handles.subinfo.statsdir        = [subPath, filesep, 'Localizer', filesep 'stats' filesep];

    % handles.subinfo.epiPath         = [subPath, filesep, 'Session_01', filesep, 'EPI_Template_D1'];
    % handles.subinfo.roiPath         = [subPath, filesep, 'Localizer', filesep, 'ROIs', filesep, 'Session_01'];

%     handles.data.contrasts = {};
    
     try
        load([pwd, filesep, 'Settings', filesep, 'Settings_Analyse_Loc.mat']);
        
        try
            set(handles.eb_nrSlices, 'String', settings.nrSlices);
            set(handles.eb_TR,'String',settings.TR);
            set(handles.eb_smoothK,'String',settings.smoothK);
            set(handles.eb_nrVolumes,'String', settings.nrVolumes);
            set(handles.eb_refSlice, 'String', settings.refSlice);

            set(handles.cb_Descending,'Value', settings.Descending);
            set(handles.cb_Ascending, 'Value', settings.Ascending);
            set(handles.cb_Interleaved, 'Value', settings.Interleaved);

            set(handles.cd_importDCM, 'Value', settings.steps.impDcm);
            set(handles.cb_sliceTiming,'Value', settings.steps.sliceTiming);
            set(handles.cb_Coregistration,'Value', settings.steps.Coregistration);
            set(handles.cb_Realign,'Value', settings.steps.Realign);
            set(handles.cb_Smooth,'Value', settings.steps.Smooth);         
            set(handles.cb_run_stats, 'Value', settings.steps.Stats);

            set(handles.uitable_cons,'Data', settings.contrasts);
            handles.data.contrasts = settings.contrasts;

        catch
            user_fb_update({'One or more values not correctly set!'},0,2)
        end

     catch 
         user_fb_update({'No Settings file found! Fill out the parameters and SAVE'},0,2)
         handles.data.contrasts = {};
     end

    % Update handles structure
    guidata(hObject, handles);

% UIWAIT makes analyze_loc wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = analyze_loc_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function eb_nrSlices_Callback(hObject, eventdata, handles)
% hObject    handle to eb_nrSlices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% handles.data.nrSlices = str2double(get(hObject,'String'));

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function eb_nrSlices_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_nrSlices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eb_TR_Callback(hObject, eventdata, handles)
% hObject    handle to eb_TR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eb_TR as text
%        str2double(get(hObject,'String')) returns contents of eb_TR as a double
% handles.data.TR = str2double(get(hObject,'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eb_TR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_TR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function eb_smoothK_Callback(hObject, eventdata, handles)
% hObject    handle to eb_smoothK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% handles.data.smoothK = str2double(get(hObject,'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eb_smoothK_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_smoothK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in cb_Ascending.
function cb_Ascending_Callback(hObject, eventdata, handles)
% hObject    handle to cb_Ascending (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_Ascending
if get(handles.cb_Descending,'Value') == 1
    set(handles.cb_Descending, 'Value', 0);
elseif get(handles.cb_Interleaved,'Value') == 1
    set(handles.cb_Interleaved, 'Value', 0);
end

% --- Executes on button press in cb_Descending.
function cb_Descending_Callback(hObject, eventdata, handles)
% hObject    handle to cb_Descending (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.cb_Ascending,'Value') == 1
    set(handles.cb_Ascending, 'Value', 0);
elseif get(handles.cb_Interleaved,'Value') == 1
    set(handles.cb_Interleaved, 'Value', 0);
end

% --- Executes on button press in cb_Interleaved.
function cb_Interleaved_Callback(hObject, eventdata, handles)
% hObject    handle to cb_Interleaved (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.cb_Ascending,'Value') == 1
    set(handles.cb_Ascending, 'Value', 0);
elseif get(handles.cb_Descending,'Value') == 1
    set(handles.cb_Descending, 'Value', 0);
end


function eb_conName_Callback(hObject, eventdata, handles)
% hObject    handle to eb_conName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eb_conName as text
%        str2double(get(hObject,'String')) returns contents of eb_conName as a double


% --- Executes during object creation, after setting all properties.
function eb_conName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_conName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_save.
function pb_save_Callback(hObject, eventdata, handles)
% hObject    handle to pb_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
input =  [{get(handles.eb_conName,'String')} {get(handles.eb_contrast,'String')}];

handles.data.contrasts = [handles.data.contrasts; input];

set(handles.uitable_cons,'Data', handles.data.contrasts);
set(handles.eb_conName,'String', '');
set(handles.eb_contrast,'String', '');

user_fb_update({'Contrast added!';['Name: ' input{1}];['Conrast: ' input{2}]},0,2)

% message = '';
for ii = 1:size(handles.data.contrasts,1)
    message{ii,1} = [handles.data.contrasts{ii,1} ': ' handles.data.contrasts{ii,2}];
end

user_fb_update({'All contrasts: '; message'},0, 1)

guidata(hObject, handles);



function eb_contrast_Callback(hObject, eventdata, handles)
% hObject    handle to eb_contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eb_contrast as text
%        str2double(get(hObject,'String')) returns contents of eb_contrast as a double


% --- Executes during object creation, after setting all properties.
function eb_contrast_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_clear.
function pb_clear_Callback(hObject, eventdata, handles)
% hObject    handle to pb_clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.uitable_cons,'Data', []);
handles.data.contrasts = {};
guidata(hObject, handles);


% --- Executes on button press in pb_run.
function pb_run_Callback(hObject, eventdata, handles)

    handles.data.nrSlices   = str2double(get(handles.eb_nrSlices,'String'));
    handles.data.TR         = str2double(get(handles.eb_TR,'String'));
    handles.data.smoothK    = str2double(get(handles.eb_smoothK,'String'));
    handles.data.nrVolumes  = str2double(get(handles.eb_nrVolumes, 'String'));
    handles.data.refSlice   = eval(get(handles.eb_refSlice, 'String'));
    
    handles.data.steps.impDcm           = get(handles.cd_importDCM,'Value');    
    handles.data.steps.sliceTiming      = get(handles.cb_sliceTiming,'Value');
    handles.data.steps.Realign          = get(handles.cb_Realign,'Value');
    handles.data.steps.Coregistration   = get(handles.cb_Coregistration,'Value');
    handles.data.steps.Smooth           = get(handles.cb_Smooth,'Value');
    handles.data.steps.Stats            = get(handles.cb_run_stats, 'Value');

    
    if get(handles.cb_Ascending, 'Value')== 1
        handles.data.sliceOrder = 1:1:handles.data.nrSlices;
    elseif get(handles.cb_Descending, 'Value')== 1
        handles.data.sliceOrder = handles.data.nrSlices:-1:1;
    elseif get(handles.cb_Interleaved, 'Value')== 1
        % middle - top
    %     for k = 1:nrslices
    %         order = round((nrslices-k)/2 + (rem((nslices-k), 2) * (nrslices - 1)/2)) + 1;
    %     end

        % bottom --> up
        order = [1:2:handles.data.nrSlices 2:2:handles.data.nrSlices];

        % top --> down
    %     order = [nrslices:-2:1, nrslices-1:-2:1];

        handles.data.sliceOrder = order;
    end

    handles.data.contrasts = get(handles.uitable_cons,'Data');
    
  
    message{1,1} = 'Initiating Analyses..';
    
    user_fb_update(message, 0, 1)
    analyze_loc_func(handles.subinfo, handles.data)



% --- Executes on button press in pb_saveSettings.
function pb_saveSettings_Callback(hObject, eventdata, handles)
    settings.nrSlices   = get(handles.eb_nrSlices,'String');
    settings.TR         = get(handles.eb_TR,'String');
    settings.smoothK    = get(handles.eb_smoothK,'String');
    settings.nrVolumes  = get(handles.eb_nrVolumes, 'String');
    settings.refSlice   = get(handles.eb_refSlice, 'String');
    
    settings.Ascending      = get(handles.cb_Ascending, 'Value');
    settings.Descending  	= get(handles.cb_Descending, 'Value');
    settings.Interleaved    = get(handles.cb_Interleaved, 'Value');
    
    settings.steps.impDcm           = get(handles.cd_importDCM,'Value');
    settings.steps.sliceTiming      = get(handles.cb_sliceTiming,'Value');
    settings.steps.Realign          = get(handles.cb_Realign,'Value');
    settings.steps.Coregistration   = get(handles.cb_Coregistration,'Value');
    settings.steps.Smooth           = get(handles.cb_Smooth,'Value');
    settings.steps.Stats            = get(handles.cb_run_stats, 'Value');
    
%     settings.contrasts = handles.data.contrasts;
    settings.contrasts = get(handles.uitable_cons,'Data');
    
    save([pwd, filesep, 'Settings', filesep, 'Settings_Analyse_Loc'], 'settings')
    user_fb_update({'Localiser Settings saved:';[pwd, filesep, 'Settings']},0,1)



function eb_refSlice_Callback(hObject, eventdata, handles)
% hObject    handle to eb_refSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eb_refSlice as text
%        str2double(get(hObject,'String')) returns contents of eb_refSlice as a double


% --- Executes during object creation, after setting all properties.
function eb_refSlice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_refSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eb_nrVolumes_Callback(hObject, eventdata, handles)
% hObject    handle to eb_nrVolumes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eb_nrVolumes as text
%        str2double(get(hObject,'String')) returns contents of eb_nrVolumes as a double


% --- Executes during object creation, after setting all properties.
function eb_nrVolumes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_nrVolumes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_information.
function pb_information_Callback(hObject, eventdata, handles)
% hObject    handle to pb_information (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cd_importDCM.
function cd_importDCM_Callback(hObject, eventdata, handles)
% hObject    handle to cd_importDCM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cd_importDCM

% --- Executes on button press in cb_sliceTiming.
function cb_sliceTiming_Callback(hObject, eventdata, handles)
% hObject    handle to cb_sliceTiming (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_sliceTiming


% --- Executes on button press in cb_Realign.
function cb_Realign_Callback(hObject, eventdata, handles)
% hObject    handle to cb_Realign (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_Realign


% --- Executes on button press in cb_Coregistration.
function cb_Coregistration_Callback(hObject, eventdata, handles)
% hObject    handle to cb_Coregistration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_Coregistration


% --- Executes on button press in cb_Smooth.
function cb_Smooth_Callback(hObject, eventdata, handles)
% hObject    handle to cb_Smooth (see guieGCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_Smooth


% --- Executes on button press in cb_run_stats.
function cb_run_stats_Callback(hObject, eventdata, handles)
% hObject    handle to cb_run_stats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_run_stats
