% Boilerplate to get GUI running. Do not edit!

function varargout = CANDO_GUI(varargin)
% CANDO_GUI MATLAB code for CANDO_GUI.fig
%      CANDO_GUI, by itself, creates a new CANDO_GUI or raises the existing
%      singleton*.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 09-Mar-2018 15:30:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CANDO_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @CANDO_GUI_OutputFcn, ...
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

% --- Executes just before CANDO_GUI is made visible.
function CANDO_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args

% hObject    handle to figure
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CANDO_GUI (see VARARGIN)

% Choose default command line output for CANDO_GUI
handles.output = hObject;

% initialising the checkboxes to appropriate starting values
set(handles.grounded_PBS_checkbox,'Value',1);
set(handles.impedance_checkbox,'Value',1)
set(handles.controls_checkbox,'Value',1);
set(handles.batch_value,'String','B')
set(handles.select_day_checkbox, 'Value',0)
set(handles.select_day_checkbox,'Enable','on')
set(handles.select_timeline_checkbox,'Value',0)
% set(handles.select_timeline_checkbox,'Enable','off')
set(handles.plot_changes_checkbox, 'Value',0)
set(handles.plot_changes_checkbox, 'Enable','off')


%import CANDO data
handles.impedance = cando_import('impedance.csv',1);
handles.phase = cando_import('phase.csv',1);
handles.test_info = cando_import('test_numbers.csv',2);
handles.data_file = 1;
% handles = import_data(hObject, eventdata, handles);

file = load('frequencies.mat');
handles.freq = fliplr(file.file');  % import frequencies in separate file

% select B batch as IDEs to initialise plot
handles.current_Z = handles.impedance(15:27,:,1);
handles.current_phase = handles.phase(15:27,:,1);
handles.batch = 2;
handles.list_size = 1;
handles.first_IDE = 1;

% cando_plot_update(handles.freq,handles.current_Z,handles.current_phase,0,handles);
cando_plot('impedance',handles, 0);
update_function(hObject, eventdata, handles)
% Update handles structure
guidata(hObject, handles);


% *** ------------ 1. USED CALLBACKS FOR BUTTONS/LISTS ------------ *** %

% these functions control properties such as whether a button can be
% selected if another button is already checked

% --- Executes on button press in update_button.
function update_function(hObject, eventdata, handles)
% testing the data_change function

% Determine which batch has been requested
text = char(get(handles.batch_value,'String'));
handles.batch = double(lower(text(1))-96);  % converting letter (upper or lowercase) into integer value
set(handles.batch_value, 'String', char(handles.batch + 64));  % storing uppercase value of batch

batch_no = handles.batch - 1;  % zero indexing batch numbers to calculate ID numbers
handles.first_IDE = 1 + (batch_no*14);  % first IDE to plot
handles.last_IDE = handles.first_IDE + 13;  % last IDE to plot

% Populate lists - see Section 2 below
populate_lists(hObject,handles);

% find the number of tests performed for the current batch being plotted
% and remove NaNs
list = handles.test_info(handles.batch,:);
list(isnan(list)) = [];
handles.list_size = size(list,2);

% update plot based on above parameters - see Section 3 below
plot_samples(handles,0)

% need to work out what this is for...
index = get(handles.sample_list, 'Value');
file_list = get(handles.sample_list,'String');
filename = file_list(index);
guidata(hObject, handles);


function single_sample_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to single_sample_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of single_sample_checkbox
if get(handles.single_sample_checkbox,'Value') == 1
    set(handles.select_timeline_checkbox,'Enable','on');
    set(handles.plot_changes_checkbox,'Enable','on')
else
    set(handles.select_timeline_checkbox,'Enable','off');
    set(handles.plot_changes_checkbox,'Enable','off')
end

update_function(hObject, eventdata, handles)


function select_day_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to select_day_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of select_day_checkbox
if get(handles.select_day_checkbox,'Value') == 1
    set(handles.select_timeline_checkbox,'Enable','off')
    set(handles.select_timeline_checkbox,'Value',0)
    set(handles.plot_changes_checkbox, 'Enable','off')
    set(handles.plot_changes_checkbox, 'Value',0)
elseif (get(handles.single_sample_checkbox,'Value') == 1) && (get(handles.select_day_checkbox,'Value') == 0)
    set(handles.select_timeline_checkbox,'Enable','on')
    set(handles.plot_changes_checkbox, 'Enable','on')
end

update_function(hObject, eventdata, handles)


function select_timeline_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to select_timeline_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of select_timeline_checkbox
if get(handles.select_timeline_checkbox,'Value') == 1
    set(handles.select_day_checkbox,'Enable','off')
    set(handles.plot_changes_checkbox,'Enable','on')
else 
    set(handles.select_day_checkbox,'Enable','on')
    set(handles.plot_changes_checkbox,'Enable','off')
    set(handles.plot_changes_checkbox, 'Value',0)
end

update_function(hObject, eventdata, handles)


function print_fig_Callback(hObject, eventdata, handles)
% hObject    handle to print_fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
plot_samples(handles,1)





% *** ------------ 2. FUNCTIONS TO POPULATE LISTBOXES ------------ *** %

function populate_lists(hObject, handles)
    populate_IDE_list(handles)
    populate_day_list(hObject,handles)
    populate_freq_list(handles)

function populate_IDE_list(handles)
% lists the ID numbers for the samples in the batch selected 

list = [];
 for x = handles.first_IDE:handles.last_IDE
     list = [list;x];
     set(handles.sample_list,'String',list);
 end

function populate_day_list(hObject,handles)
% lists the days of tests for the sample(s) selected

list = handles.test_info(handles.batch,:);
list(isnan(list)) = [];  % remove nans from timeline values
handles.list_size = size(list,2);
set(handles.day_box,'String',list)
guidata(hObject, handles);

function populate_freq_list(handles)
% lists the major frequencies to select

list = [];
frequencies = handles.freq;

 for n = 1:size(handles.freq,2)
     if mod(n,5) == 1
        list = [list;frequencies(n)];
     end
     set(handles.freq_list,'String',list);
 end
 
 
 
 
 
% *** ------------ 3. FUNCTION TO PLOT GRAPHS ------------ *** %
 
function plot_samples(handles,print)

% plotting all samples 

first_IDE = handles.first_IDE;
last_IDE = handles.last_IDE;
first_day = 1;
last_day = 1;
first_freq = 1;
last_freq = 36;

if get(handles.controls_checkbox,'Value') == 1
    last_IDE = handles.last_IDE - 1;
end

% if looking at a single IDE, get ID value from the menu
if get(handles.single_sample_checkbox,'Value') == 1
    first_IDE = get(handles.sample_list, 'Value')+((handles.batch-1)*14);
    last_IDE = first_IDE;  % make the range limited to a single IDE
end

% if looking at single day, get day value from listbox
if get(handles.select_day_checkbox,'Value') == 1
    first_day = get(handles.day_box,'Value');
    last_day = first_day;  % make the range limited to a single day
end

% if looking at at entire timeline make the day range the entire list of days 
if get(handles.select_timeline_checkbox,'Value') == 1
    first_day = 1;
    last_day = handles.list_size;
end

% if looking at changes of impedance/phase over time get single frequency
% of interest
if get(handles.plot_changes_checkbox,'Value') == 1
    first_freq = (get(handles.freq_list,'Value')-1)*5 + 1;
    last_freq = first_freq;  % make frequency range limited to single value
end

% update Z and phase data to only include the range of samples, days and frequencies of interest 
handles.current_Z = handles.impedance(first_IDE:last_IDE,first_freq:last_freq,first_day:last_day);
handles.current_phase = handles.phase(first_IDE:last_IDE,first_freq:last_freq,first_day:last_day);

% plot the samples in GUI window, not in separate figure window
cla

% determine which type of graph is to be plotted
if get(handles.impedance_checkbox,'Value') == 1 && get(handles.phase_checkbox,'Value') == 0
    graph_type = 'impedance';
elseif get(handles.impedance_checkbox,'Value') == 0 && get(handles.phase_checkbox,'Value') == 1
    graph_type = 'phase';
else
    graph_type = 'impedance+phase';
end

cando_plot(graph_type, handles, print);





% *** ----------- 4. INITIALISATION FUNCTIONS -------------- ***

% CAN PROBABLY DELETE THESE FIRST 3 FUNCTIONS

% --- Outputs from this function are returned to the command line.
function varargout = CANDO_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% *** ----------- CreateFcn CALLS -------------- ***
% --- Executes during object creation, after setting all properties.

function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function batch_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to batch_value (see GCBO)
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function day_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to day_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function sample_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sample_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function freq_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freq_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ***--- CALLBACKS FOR BUTTONS AND LISTS - NOT SURE IF NEEDED --- *** %

%  --- Executes on button press in controls_checkbox.
function controls_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to controls_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of controls_checkbox

update_function(hObject, eventdata, handles)


% --- Executes on button press in impedance_checkbox.
function impedance_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to impedance_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of impedance_checkbox

update_function(hObject, eventdata, handles)


% --- Executes on button press in phase_checkbox.
function phase_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to phase_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of phase_checkbox

update_function(hObject, eventdata, handles)


% --- Executes on selection change in day_box.
function day_box_Callback(hObject, eventdata, handles)
% hObject    handle to day_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns day_box contents as cell array
%        contents{get(hObject,'Value')} returns selected item from day_box

update_function(hObject, eventdata, handles)

% --- Executes on selection change in sample_list.
function sample_list_Callback(hObject, eventdata, handles)
% hObject    handle to sample_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sample_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sample_list

update_function(hObject, eventdata, handles)

function plot_changes_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to plot_changes_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plot_changes_checkbox

update_function(hObject, eventdata, handles)


% --- Executes on selection change in freq_list.
function freq_list_Callback(hObject, eventdata, handles)
% hObject    handle to freq_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns freq_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from freq_list

update_function(hObject, eventdata, handles)

function batch_value_Callback(hObject, eventdata, handles)
% hObject    handle to batch_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of batch_value as text
%        str2double(get(hObject,'String')) returns contents of batch_value as a double

% Change the day of test selected to prevent errors when switching between
% experiments
set(handles.day_box, 'Value', 1)
update_function(hObject, eventdata, handles)


% --- Executes on button press in grounded_PBS_checkbox.
function grounded_PBS_checkbox_Callback(hObject, eventdata, handles)
handles.data_change = 1;
% hObject    handle to grounded_PBS_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of grounded_PBS_checkbox
handles.data_file = get(handles.grounded_PBS_checkbox,'Value');

if handles.data_file == 1
    handles.impedance = cando_import('impedance.csv',1);
    handles.phase = cando_import('phase.csv',1);
    handles.test_info = cando_import('test_numbers.csv',2);
else 
    handles.impedance = cando_import('impedance_pre-ammendment.csv',1);
    handles.phase = cando_import('phase_pre-ammendment.csv',1);
    handles.test_info = cando_import('test_numbers_pre-ammendment.csv',2);  
end

update_function(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function grounded_PBS_checkbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to grounded_PBS_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
