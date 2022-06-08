function varargout = create_protocol(varargin)
% CREATE_PROTOCOL MATLAB code for create_protocol.fig
%      CREATE_PROTOCOL, by itself, creates a new CREATE_PROTOCOL or raises the existing
%      singleton*.
%
%      H = CREATE_PROTOCOL returns the handle to a new CREATE_PROTOCOL or the handle to
%      the existing singleton*.
%
%      CREATE_PROTOCOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATE_PROTOCOL.M with the given input arguments.
%
%      CREATE_PROTOCOL('Property','Value',...) creates a new CREATE_PROTOCOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before create_protocol_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to create_protocol_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help create_protocol

% Last Modified by GUIDE v2.5 17-Mar-2020 09:13:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @create_protocol_OpeningFcn, ...
                   'gui_OutputFcn',  @create_protocol_OutputFcn, ...
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


% --- Executes just before create_protocol is made visible.
function create_protocol_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to create_protocol (see VARARGIN)

% Choose default command line output for create_protocol
handles.output = hObject;

handles.conditions = [];
handles.data4table = [];
handles.col4table  = [];
handles.onsets   = [];
handles.conflict_flag = 0;

handles.projFolder = varargin{:};

% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes create_protocol wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = create_protocol_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in pb_clear_row.
function pb_clear_row_Callback(hObject, eventdata, handles)
% hObject    handle to pb_clear_row (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% uitable_protocol_CellEditCallback(handles.uitable_protocol, [handles.uitable.rowSelection...
%     handles.uitable.colSelection], handles)

% row2remove = handles.uitable.rowSelection;


% --- Executes on button press in pb_clear_all.
function pb_clear_all_Callback(hObject, eventdata, handles)
% hObject    handle to pb_clear_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nrVol   = str2double(get(handles.eb_nr_volumes, 'String'));

handles.conditions = [];
handles.data4table = [];
handles.col4table  = [];
handles.uniqueCond = [];
handles.onsets     = [];

axes(handles.axes_preview);
cla()
set(handles.axes_preview ,'XTickLabel', {' '});

set(handles.uitable_protocol, 'Data', []);

set(handles.text_run_duration, 'String', {'0 min 0 sec'});
set(handles.eb_nr_volumes, 'String', ' ');

% message
user_fb_update({'All entries cleared'},0,2)

guidata(hObject, handles);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function eb_duration_Callback(hObject, eventdata, handles)
% hObject    handle to eb_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function eb_duration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eb_name_Callback(hObject, eventdata, handles)
% hObject    handle to eb_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function eb_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_info.
function pb_info_Callback(hObject, eventdata, handles)
% hObject    handle to pb_info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function eb_nr_volumes_Callback(hObject, eventdata, handles)
% hObject    handle to eb_nr_volumes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eb_nr_volumes as text
%        str2double(get(hObject,'String')) returns contents of eb_nr_volumes as a double

nrVol   = str2double(get(handles.eb_nr_volumes, 'String'));
TR      = str2double(get(handles.eb_TR, 'String'));

if nrVol > 0 && TR > 0

    total_seconds = nrVol * TR;
    
    minutes = floor(total_seconds/60);
    seconds = round(rem(total_seconds,60));
    
    set(handles.text_run_duration, 'String', [num2str(minutes) ' min ' num2str(seconds) ' sec'])
    
    user_fb_update({['Nr Vol: ' num2str(nrVol)];['TR: ' num2str(TR)]; ['Run Duration: ' num2str(minutes) ' min ' num2str(seconds) ' sec']},0,1)
end

set(handles.axes_preview ,'XLim', [0 nrVol]);
set(handles.axes_preview ,'XTick', [ceil(nrVol/2) nrVol]);
set(handles.axes_preview ,'XTickLabel', {num2str(ceil(nrVol/2)); num2str(nrVol)});


% --- Executes during object creation, after setting all properties.
function eb_nr_volumes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_nr_volumes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_add.
function pb_add_Callback(hObject, eventdata, handles)
% hObject    handle to pb_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

nrVol   = str2double(get(handles.eb_nr_volumes, 'String'));
TR      = str2double(get(handles.eb_TR, 'String'));

name    = get(handles.eb_name, 'String');
dur     = str2double(get(handles.eb_duration, 'String'));

try 
    col     = handles.color;
catch
   user_fb_update({'Select color!'}, 0, 2)
   return
end

condNR = size(handles.conditions,2)+1;

user_fb_update({'Condition added';['Name: ' name]; ['Duration: ' num2str(dur) ' Volumes']},0,1)

% determine first and last volume of added condition
if condNR == 1
    frst_vol = 1;
elseif condNR > 1
    frst_vol = handles.conditions(condNR-1).durations(2) + 1;
end

last_vol = frst_vol + (dur-1);     

% record added conditions
handles.conditions(condNR).name          = name;
handles.conditions(condNR).durations     = [frst_vol last_vol];
handles.conditions(condNR).color         = col;
handles.conditions(condNR).dur           = dur;

% record intial inputs (these will not be adapted during repetitions)
handles.uniqueCond(condNR).name       = name;
handles.uniqueCond(condNR).durations  = [frst_vol last_vol];
handles.uniqueCond(condNR).color      = col;

% (re-)plot what we have so far
axes(handles.axes_preview);
cla() % reset the figure first
hold on
for cond = 1:size(handles.conditions,2)
    a = handles.conditions(cond).durations(1); % first vol
    b = handles.conditions(cond).durations(2); % last vol
    
    curr_color = handles.conditions(cond).color; 
 
    h=stem(b,1);
    set(h,'Marker','None');

    % add patch
    patch([a b b a], [0 0 1 1], curr_color)
    alpha(0.3)  
    
end

% reset the graph settings in GUI
set(handles.axes_preview ,'ytick', [])
set(handles.axes_preview ,'XLim', [0 nrVol]);
set(handles.axes_preview ,'XTick', [ceil(nrVol/2) nrVol]);
set(handles.axes_preview ,'XTickLabel', {num2str(ceil(nrVol/2)); num2str(nrVol)});

hold off

% reset options in GUI
set(handles.eb_name, 'String', '');
set(handles.eb_duration, 'String', '');
set(handles.axes_color,'Color', 'w');

% add the condition to the protocol table
input4table = [{name} {num2str([frst_vol last_vol])} num2str(dur)];
handles.data4table = [handles.data4table; input4table];
handles.col4table = [handles.col4table; col];

set(handles.uitable_protocol, 'Data', handles.data4table);

% set(handles.uitable_protocol, 'Data',{'<HTML><TDBGCOLOR="#FF0000">hello</TD>'})

% add color to color cell
set(handles.uitable_protocol, 'BackgroundColor', handles.col4table);

% Update handles structure
guidata(hObject, handles);


function eb_TR_Callback(hObject, eventdata, handles)
% hObject    handle to eb_TR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nrVol   = str2double(get(handles.eb_nr_volumes, 'String'));
TR      = str2double(get(handles.eb_TR, 'String'));

if nrVol > 0 && TR > 0
    
    total_seconds = nrVol * TR;
    
    minutes = floor(total_seconds/60);
    seconds = round(rem(total_seconds,60));
    
    set(handles.text_run_duration, 'String', [num2str(minutes) ' min ' num2str(seconds) ' sec'])
    
    user_fb_update({['Nr Vol: ' num2str(nrVol)];['TR: ' num2str(TR)]; ['Run Duration: ' num2str(minutes) ' min ' num2str(seconds) ' sec']},0,1)
end



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


% --- Executes on button press in pb_color.
function pb_color_Callback(hObject, eventdata, handles)

    handles.color = uisetcolor;
    
    set(handles.axes_color,'Color', handles.color);
    
    guidata(hObject, handles);


function eb_file_name_Callback(hObject, eventdata, handles)
% hObject    handle to eb_file_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eb_file_name as text
%        str2double(get(hObject,'String')) returns contents of eb_file_name as a double


% --- Executes during object creation, after setting all properties.
function eb_file_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_file_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_save_prt.
function pb_save_prt_Callback(hObject, eventdata, handles)
% hObject    handle to pb_save_prt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



saveDir = get(handles.eb_saveDir,'String');
fn      = get(handles.eb_file_name, 'String');

if ~isdir(saveDir)
    user_fb_update({'Enter a directory to save your protocol'}, 0, 2)
    return 
elseif isempty(fn)
    user_fb_update({'Name your protocol before saving'}, 0, 2)
    return 
else 

    FP = [saveDir, filesep, fn '.json'];

    all_names           = {handles.conditions.name};
%     condition_names     = unique(all_names);
    condition_names     = unique(all_names, 'stable');

    all_colors          = cell2mat({handles.conditions.color}');
    colors_mat          = unique(all_colors,'stable','rows');
    colors_rgb          = [round(colors_mat*255) repmat(75,size(colors_mat,1),1)];
    condition_colors    = colors_rgb;%unique(num2str((cell2mat({handles.conditions.color}'))),'rows');

    all_OnsOffs = {handles.conditions.durations};

    nrCond = numel(condition_names);

    % find indices for each condition
    for cond = 1:nrCond
%         idxs(cond,:)        = find(strcmp(all_names, condition_names{cond}));
%         OnOffsets(cond,:)   = all_OnsOffs(idxs(cond,:));
        idxs{cond}          = find(strcmp(all_names, condition_names{cond}));
        OnOffsets{cond}     = all_OnsOffs(idxs{cond});
    end

    if nrCond == 2
        prt.BaselineName    = condition_names{1};
        prt.CondName        = condition_names{2};   

    elseif nrCond == 3
%         prt.BaselineName    = condition_names{1};
%         prt.CondName        = condition_names{2};
%         prt.TaskName        = condition_names{4};
        prt.BaselineName    = condition_names{2};
        prt.CondName        = condition_names{3};
        prt.TaskName        = condition_names{1};
    elseif nrCond == 4
        prt.BaselineName    = condition_names{2};
        prt.CondName        = condition_names{3};
        prt.TaskName        = condition_names{1};
        prt.SumName         = condition_names{4};   
    end

    for this_cond = 1:nrCond
        prt.Cond{1,this_cond}.ConditionName  = condition_names{this_cond};
        prt.Cond{1,this_cond}.ConditionColor = condition_colors(this_cond,:);
        prt.Cond{1,this_cond}.OnOffsets      = OnOffsets{this_cond};
    end

    user_fb_update({['Protocol: ' fn '.json saved']}, 1, 1)

    savejson('', prt, FP); % json_prt = 
end


% --- Executes on button press in pb_save_settings.
function pb_save_settings_Callback(hObject, eventdata, handles)
% hObject    handle to pb_save_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function eb_repeat_Callback(hObject, eventdata, handles)
% hObject    handle to eb_repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eb_repeat as text
%        str2double(get(hObject,'String')) returns contents of eb_repeat as a double

repetitions = str2double(get(hObject,'String'));
nrVol       = str2double(get(handles.eb_nr_volumes, 'String'));

% some checks for validity of entry
try 
   rows2repeat = eval(get(handles.eb_row_selection, 'String'));
catch 
   user_fb_update({'Incorrect selection entry!'},0,3) 
   return
end

if max(rows2repeat) > size(handles.conditions,2)
   user_fb_update({'Row to repeat does not exist!'},0,3) 
   return
end

absNRconds = size(handles.conditions,2); % absolute nr of conditions before repetition

% extend the conditions by repetition amount of times
for rep = 1:repetitions
    % define number of rows currently in table
    nrConds = size(handles.conditions,2);
    
    % based on this, define start index and finish index
    s       = nrConds+1;
%     f       = s + absNRconds-1;
    f       = s + numel(rows2repeat)-1;
    
    % condition counter to get the right condition info from table
    cond_c = 1;
    % add the conditions to the table new rows s to f
    for this_cond = s:f
        % condition name
        name    = handles.conditions(rows2repeat(cond_c)).name;
        dur     = handles.conditions(rows2repeat(cond_c)).dur;
        
         % define new first and last volume
        frst_vol = handles.conditions(this_cond-1).durations(2) + 1;
        last_vol = frst_vol + dur-1;
        
        % get the right color
        col = handles.conditions(rows2repeat(cond_c)).color;
        
        % add the new entrie in the handles.condition struct
        handles.conditions(this_cond).name          = name;
        handles.conditions(this_cond).durations     = [frst_vol last_vol];
        handles.conditions(this_cond).color         = col;
        handles.conditions(this_cond).dur           = dur;

        % add the condition to the protocol table
        input4table         = [{name} {num2str([frst_vol last_vol])} num2str(dur)];
        handles.data4table  = [handles.data4table; input4table];
        handles.col4table   = [handles.col4table; col];
        handles.onsets      = [handles.onsets; handles.conditions(this_cond).durations];
        
        
        cond_c = cond_c+1;
    end
    
end

set(handles.uitable_protocol, 'Data', handles.data4table);
set(handles.uitable_protocol, 'BackgroundColor', handles.col4table);

% (re-)plot what we have so far
axes(handles.axes_preview); % activate figure in gui
cla();                      % clear the graph before replotting

% replot
hold on
for cond = 1:size(handles.conditions,2)
    a = handles.conditions(cond).durations(1); % first vol
    b = handles.conditions(cond).durations(2); % last vol

    curr_color = handles.conditions(cond).color; 

    h=stem(b,1);
    set(h,'Marker','None');

    % add patch
    patch([a b b a], [0 0 1 1], curr_color)
    alpha(0.3)  
    
end
hold off

% reset the graph settings in GUI
set(handles.axes_preview ,'ytick', [])

% set the NRvol according to current protocol if it exceeds nrVol
xl = handles.conditions(end).durations(2);
if xl > nrVol
    set(handles.eb_nr_volumes, 'String', xl);
    
    % redefine nrVol
    nrVol = str2double(get(handles.eb_nr_volumes, 'String'));
    
    % correct run timer
    TR              = str2double(get(handles.eb_TR, 'String'));    
    total_seconds   = nrVol * TR; 
    minutes         = floor(total_seconds/60);
    seconds         = round(rem(total_seconds,60));
    set(handles.text_run_duration, 'String', [num2str(minutes) ' min ' num2str(seconds) ' sec'])
    
end

set(handles.axes_preview ,'XLim', [0 nrVol]);
set(handles.axes_preview ,'XTick', [ceil(nrVol/2) nrVol]);
set(handles.axes_preview ,'XTickLabel', {num2str(ceil(nrVol/2)); num2str(nrVol)});

% message
user_fb_update({['Protocol repeated ' num2str(repetitions) ' times']; ['Nr of Volumes: ' num2str(xl)]},0,1)

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eb_repeat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function uitable_protocol_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uitable_protocol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when entered data in editable cell(s) in uitable_protocol.
function uitable_protocol_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable_protocol (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

r = eventdata.Indices(1);
c = eventdata.Indices(2);

% if changes were made in the duration column, update the volumes cell
% which will then be passed to the routine below and treated accordingly.
if c == 3
    tmp     = str2num(eventdata.Source.Data{r,2});
    tmp_dur = str2num(eventdata.Source.Data{r,c});
    vol1 = tmp(1);
    
    eventdata.Source.Data{r,2} = num2str([vol1 vol1+(tmp_dur-1)]);
    
end

for ii = 1:size(eventdata.Source.Data,1)
    handles.conditions(ii).durations = str2num(eventdata.Source.Data{ii,2});
    handles.conditions(ii).dur       = diff(handles.conditions(ii).durations)+1;
    eventdata.Source.Data{ii,3}      = num2str(handles.conditions(ii).dur);

    handles.onsets(ii,:)            = handles.conditions(ii).durations(1,:);
end

axes(handles.axes_preview);
cla();
hold on
for cond = 1:size(handles.conditions,2)
    a = handles.conditions(cond).durations(1); % first vol
    b = handles.conditions(cond).durations(2); % last vol

    curr_color = handles.conditions(cond).color; 

    h=stem(b,1);
    set(h,'Marker','None');

    % add patch
    patch([a b b a], [0 0 1 1], curr_color)
    alpha(0.3)  

end
hold off

% reset the graph settings in GUI
set(handles.axes_preview ,'ytick', [])

% set the NRvol according to current protocol if it exceeds nrVol
xl      = handles.conditions(end).durations(2);
nrVol   = str2double(get(handles.eb_nr_volumes, 'String'));
if xl > nrVol
    set(handles.eb_nr_volumes, 'String', xl);

    % redefine nrVol
    nrVol = str2double(get(handles.eb_nr_volumes, 'String'));

    % correct run timer
    TR              = str2double(get(handles.eb_TR, 'String'));    
    total_seconds   = nrVol * TR; 
    minutes         = floor(total_seconds/60);
    seconds         = round(rem(total_seconds,60));
    set(handles.text_run_duration, 'String', [num2str(minutes) ' min ' num2str(seconds) ' sec'])

end

set(handles.axes_preview ,'XLim', [0 nrVol]);
set(handles.axes_preview ,'XTick', [ceil(nrVol/2) nrVol]);
set(handles.axes_preview ,'XTickLabel', {num2str(ceil(nrVol/2)); num2str(nrVol)});

% check for conflict
handles.conflict_flag = 0;
for r = 1:size(handles.onsets,1)
    % check if current offset is the same or greater then all the other 
    % onsets: returns a 1 if the case.
    k = handles.onsets(r,2) >= handles.onsets(r+1:end,1);
    % if the case
    if any(k)
        % mark conflict
        handles.conflict_flag = 1;
        % redifine the row color to white
        handles.col4table(r,:) = [1 1 1];
    % if it is NOT the case AND the row color is white (previously marked
    % as conflict)
    elseif ~any(k) && isequal(handles.col4table(r,:),[1 1 1])
        % find the condition integer by comparing agains the unique
        % conditions
        currCond = find(strcmp(handles.conditions(r).name, handles.uniqueCond.name) == 1);
        % set the row color back to the original color
        handles.col4table(r,:) = handles.uniqueCond.colors(currCond,:);
    end
end

% set the colors to table
set(handles.uitable_protocol, 'BackgroundColor', handles.col4table);

% update conflict message above the protcol preview accordingly
if handles.conflict_flag == 1
    set(handles.text_conflict, 'String', 'Conflicts!')
    set(handles.text_conflict, 'ForegroundColor', 'red')
elseif handles.conflict_flag == 0
    set(handles.text_conflict, 'String', 'No conflicts')
    set(handles.text_conflict, 'ForegroundColor', 'green')
end
     


guidata(hObject, handles)

% --- Executes when selected cell(s) is changed in uitable_protocol.
function uitable_protocol_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable_protocol (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

% r = eventdata.Indices(1);
% c = eventdata.Indices(2);
% 
% handles.uitable.rowSelection = r;
% handles.uitable.colSelection = c;


guidata(hObject, handles)


% --- Executes on button press in pw_browse_saveDir.
function pw_browse_saveDir_Callback(hObject, eventdata, handles)
% hObject    handle to pw_browse_saveDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    saveDir = uigetdir(handles.projFolder{1});
    handles.saveDir= saveDir;
    set(handles.eb_saveDir, 'String', handles.saveDir);

function eb_saveDir_Callback(hObject, eventdata, handles)
% hObject    handle to eb_saveDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eb_saveDir as text
%        str2double(get(hObject,'String')) returns contents of eb_saveDir as a double


% --- Executes during object creation, after setting all properties.
function eb_saveDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_saveDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_load_prt.
function pb_load_prt_Callback(hObject, eventdata, handles)
    [fn path] = uigetfile('*.json');
    
    if path ~= 0
    
        json_prt = loadjson([path, filesep, fn]);

        % first clear all data if loaded 
        pb_clear_all_Callback(handles.pb_clear_all, [], handles)

        % record added conditions
        handles.conditions = struct('name', '', 'durations', [], 'color', [], 'dur', []);
        handles.data4table = [];
        handles.col4table = [];
        
        % in case not specified in json file
        default_colors = [0 0.4510 0.7412;...
                          0.4706 0.6706 0.1882;...
                          0.8510 0.3294 0.1020;...
                          1 1 0];
        row_c = 1;
        for condNR = 1:size(json_prt.Cond,2)
            nrRepeats = size(json_prt.Cond{condNR}.OnOffsets,1);
            for rep = 1:nrRepeats
               handles.conditions(row_c).name         = json_prt.Cond{condNR}.ConditionName;  
               handles.conditions(row_c).durations    = json_prt.Cond{condNR}.OnOffsets(rep,:);
               try 
                    handles.conditions(row_c).color     = json_prt.Cond{condNR}.ConditionColor(1:3)/255;
                    handles.col4table                   = [handles.col4table; handles.conditions(row_c).color];
               catch 
%                     user_fb_update({'No color defined in prt.json file!'; 'Default color selected'},0,2)          
                    handles.conditions(row_c).color     = default_colors(condNR,:);
                    handles.col4table                   = [handles.col4table; handles.conditions(row_c).color];
               end

               handles.conditions(row_c).dur          = diff(json_prt.Cond{condNR}.OnOffsets(rep,:)')'+1;
               
               onsets(row_c,1) = handles.conditions(row_c).durations(1,1);


                % add the condition to the protocol table
               input4table          = [{handles.conditions(row_c).name}, {num2str(handles.conditions(row_c).durations)},...
                   num2str(handles.conditions(row_c).dur)];
               handles.data4table   = [handles.data4table; input4table];

               row_c = row_c + 1;
            end

        end
        
        all_names               = {handles.conditions.name};
        handles.uniqueCond.name = unique(all_names);

        all_colors                  = cell2mat({handles.conditions.color}');
        handles.uniqueCond.colors   = unique(all_colors,'stable','rows');
        
        [val idx] = sort(onsets,'ascend');

        % sort structure according to onsets
        handles.conditions = handles.conditions(idx);
        handles.data4table = handles.data4table(idx,:);
        handles.col4table  = handles.col4table(idx,:);

        % (re-)plot what we have so far
        axes(handles.axes_preview);
        cla() % reset the figure first
        hold on
        for cond = 1:size(handles.conditions,2)
            a = handles.conditions(cond).durations(1); % first vol
            b = handles.conditions(cond).durations(2); % last vol

            curr_color = handles.conditions(cond).color; 

            h=stem(b,1);
            set(h,'Marker','None');

            % add patch
            patch([a b b a], [0 0 1 1], curr_color)
            alpha(0.3)  

        end

        nrVol =  handles.conditions(end).durations(2);

        % reset the graph settings in GUI
        set(handles.axes_preview ,'ytick', [])
        set(handles.axes_preview ,'XLim', [0 nrVol]);
        set(handles.axes_preview ,'XTick', [ceil(nrVol/2) nrVol]);
        set(handles.axes_preview ,'XTickLabel', {num2str(ceil(nrVol/2)); num2str(nrVol)});

        hold off

        % reset options in GUI
        set(handles.eb_name, 'String', '');
        set(handles.eb_duration, 'String', '');
        set(handles.axes_color,'Color', 'w');

        % set the table in GUI
        set(handles.uitable_protocol, 'Data', handles.data4table);
        % add color to color cell
        set(handles.uitable_protocol, 'BackgroundColor', handles.col4table);

        % set nr of Volumes in GUI
        set(handles.eb_nr_volumes, 'String', num2str(nrVol));

        % correct run timer
        TR              = str2double(get(handles.eb_TR, 'String'));    
        total_seconds   = nrVol * TR; 
        minutes         = floor(total_seconds/60);
        seconds         = round(rem(total_seconds,60));
        set(handles.text_run_duration, 'String', [num2str(minutes) ' min ' num2str(seconds) ' sec'])
        
        % message
        user_fb_update({[fn ' loaded'];['Nr of Volumes: ' num2str(nrVol)];['TR: ' num2str(TR)];['Run Duration: '...
            num2str(minutes) ' min ' num2str(seconds) ' sec']},0,1)
    else
        user_fb_update({'No file selected'}, 0, 2)
    end
    
    % Update handles structure
    guidata(hObject, handles);
    
% --- Executes on button press in pb_resolve.
function pb_resolve_Callback(hObject, eventdata, handles)
% hObject    handle to pb_resolve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    if handles.conflict_flag == 1
        tableDat = handles.uitable_protocol.Data;

        for r = 1:size(handles.onsets,1)
            % check if current offset is the same or greater then all the other 
            % onsets: returns a 1 if the case.
            k = handles.onsets(r,2) >= handles.onsets(r+1:end,1);
            % if the case
            if any(k)
                diff = handles.onsets(r,2)-handles.onsets(r+1,1);        
                handles.onsets(r+1:end,:)=handles.onsets(r+1:end,:)+(diff+1);    
            end

        end

        axes(handles.axes_preview);
        cla();
        hold on
        handles.data4table  = [];
        handles.col4table   = [];
        for cond = 1:size(handles.conditions,2)

            %overwrite the values with updated ones
            handles.conditions(cond).durations(1) = handles.onsets(cond,1);
            handles.conditions(cond).durations(2) = handles.onsets(cond,2);

            name    = handles.conditions(cond).name;
            dur     = handles.conditions(cond).dur;
            col     = handles.conditions(cond).color;

            a = handles.conditions(cond).durations(1); % first vol
            b = handles.conditions(cond).durations(2); % last vol

            curr_color = handles.conditions(cond).color; 

            h=stem(b,1);
            set(h,'Marker','None');

            % add patch
            patch([a b b a], [0 0 1 1], curr_color)
            alpha(0.3)  

            input4table = [{name} {num2str([a b])} num2str(dur)];
            handles.data4table = [handles.data4table; input4table];
            handles.col4table = [handles.col4table; col];
        end
        hold off

        set(handles.uitable_protocol, 'Data', handles.data4table);
        % add color to color cell
        set(handles.uitable_protocol, 'BackgroundColor', handles.col4table);

        % reset the graph settings in GUI
        set(handles.axes_preview ,'ytick', [])

        % set the NRvol according to current protocol if it exceeds nrVol
        xl      = handles.conditions(end).durations(2);
        nrVol   = str2double(get(handles.eb_nr_volumes, 'String'));
        if xl > nrVol
            set(handles.eb_nr_volumes, 'String', xl);

            % redefine nrVol
            nrVol = str2double(get(handles.eb_nr_volumes, 'String'));

            % correct run timer
            TR              = str2double(get(handles.eb_TR, 'String'));    
            total_seconds   = nrVol * TR; 
            minutes         = floor(total_seconds/60);
            seconds         = round(rem(total_seconds,60));
            set(handles.text_run_duration, 'String', [num2str(minutes) ' min ' num2str(seconds) ' sec'])

        end

        set(handles.axes_preview ,'XLim', [0 nrVol]);
        set(handles.axes_preview ,'XTick', [ceil(nrVol/2) nrVol]);
        set(handles.axes_preview ,'XTickLabel', {num2str(ceil(nrVol/2)); num2str(nrVol)});

        set(handles.text_conflict, 'String', 'Resolved!')
        set(handles.text_conflict, 'ForegroundColor', 'green')

    elseif handles.conflict_flag == 0
        user_fb_update({'No conflicts to resolve!'},0,1)
    end

% Update handles structure
guidata(hObject, handles);



function eb_clear_row_Callback(hObject, eventdata, handles)
% hObject    handle to eb_clear_row (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eb_clear_row as text
%        str2double(get(hObject,'String')) returns contents of eb_clear_row as a double


% --- Executes during object creation, after setting all properties.
function eb_clear_row_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_clear_row (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eb_row_selection_Callback(hObject, eventdata, handles)
% hObject    handle to eb_row_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eb_row_selection as text
%        str2double(get(hObject,'String')) returns contents of eb_row_selection as a double

% --- Executes during object creation, after setting all properties.
function eb_row_selection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eb_row_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function tb_save_ClickedCallback(hObject, eventdata, handles)

    pb_save_prt_Callback(handles.pb_save_prt, [], handles)

% --------------------------------------------------------------------
function tb_load_prt_ClickedCallback(hObject, eventdata, handles)

    pb_load_prt_Callback(handles.pb_load_prt, [], handles)
