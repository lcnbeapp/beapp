function varargout = REST(varargin)
% REST M-untitled_1 for REST.fig
%      REST, by itself, creates a new REST or raises the existing
%      singleton*.
%
%      H = REST returns the handle to a new REST or the handle to
%      the existing singleton*.
%
%      REST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REST.M with the given input arguments.
%
%      REST('Property','Value',...) creates a new REST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before REST_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to REST_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help REST

% Last Modified by GUIDE v2.5 18-Mar-2017 21:56:06

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @REST_OpeningFcn, ...
    'gui_OutputFcn',  @REST_OutputFcn, ...
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

% -------------------------------------------------------------------------
% add the paths
% -------------
RESTpath = which('REST.m');
RESTpath = RESTpath(1:end-length('REST.m'));
if strcmpi(RESTpath, './') || strcmpi(RESTpath, '.\'), 
    RESTpath = [ pwd filesep ]; 
end;

% test for local SCCN copy
% ------------------------
if ~isNITdeployed2
    addpath(RESTpath);
    if exist( fullfile( RESTpath, 'function') ) ~= 7
        warning('REST subfolders not found');
    end;
end;

% add paths
% ---------
if ~isNITdeployed2
    % myaddpath( NITpath, 'BrainMask_61x73x61.img','Mask');
    myaddpath( RESTpath, 'REST_Version.m', ['function', filesep, 'Loading']);
else
    warning('REST subfolders not added !!!');
end;
% -------------------------------------------------------------------------
% End initialization code - DO NOT EDIT


% --- Executes just before REST is made visible.
function REST_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to REST (see VARARGIN)

% Choose default command line output for REST
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = REST_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global File_List;
File_List = {};


% --- Executes on selection change in listbox_files.
function listbox_files_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns listbox_files contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_files


% --- Executes during object creation, after setting all properties.
function listbox_files_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Data_load_Callback(hObject, eventdata, handles)
% hObject    handle to Data_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global File_List;
global pathname;
global cur_data;
% [filename, pathname] = uigetfile('*.mat', 'Pick an M-untitled_1', 'MultiSelect', 'on');
[filename, pathname] = uigetfile({'*.mat;*.cnt;*.vhdr',...
    'Data Files (*.mat;*.cnt;*.vhdr)';...
    '*.mat', 'Matlab Data (*.mat)';...
    '*.cnt', 'Neuroscan Data (*.cnt)';...
    '*.vhdr', 'Brain Products Data (*.vhdr)';...
    '*.*', 'All Files (*.*)';}, ....
    'Select data file', ...
    'MultiSelect', 'on');

if isequal(filename,0)
    return;
end
if iscell(filename)
    for i = 1:length(filename)
        File_List{i} = strcat(pathname,filename{i});
    end
else
    File_List{1} = strcat(pathname,filename);
end

%----------- Data Loading -------------
for i = 1:length(File_List)
    set(handles.listbox_files, 'Value', i);
    try
        cur_file = File_List{i};
        [pathstr, name, exe] = fileparts(cur_file);
        switch exe
            case '.cnt'
%                 cur_data{i} = loadcnt(cur_file);
                if length(File_List) == 1
                    cur_data{i} = pop_loadcnt(filename);
                else
                    cur_data{i} = pop_loadcnt(filename{i});
                end
            case '.mat'
                cur_data{i} = load(cur_file);
            case '.vhdr'                
                cur_data{i} = pop_loadbv(pathname, [name exe]);
        end        
    catch
        disp(['error occuring for ' File_List{i}]);
    end
end
if ~isempty(cur_data)
    msgbox('Data has been successully imported.', 'Data');
    set(handles.listbox_files, 'String', File_List);
    set(handles.listbox_files, 'Value', 1);
else
    errordlg('Error occuring for data importing !!!','Error');
end


% --------------------------------------------------------------------
function REST_Reference_Callback(hObject, eventdata, handles)
% hObject    handle to REST_Reference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global File_List;
global Lead_Field;
global cur_data;
if ~isempty(File_List)
    if ~isempty(Lead_Field)
        if (size(Lead_Field, 2) == size(cur_data{1}.data, 1))
            G = Lead_Field;
            G = G';
            G_ave = mean(G);
            G_ave = G-repmat(G_ave,size(G,1),1);
            Ra = G*pinv(G_ave,0.05);   %the value 0.05 is for real data; for simulated data, it may be set as zero.
            clear G G_ave;
            for i = 1:length(File_List)
                set(handles.listbox_files, 'Value', i);
                try
                    cur_file = File_List{i};
                    [pathstr, name, exe] = fileparts(cur_file);
                    save_dir = strcat(pathstr,filesep);
                    save_dir = strcat(save_dir,name);
                    save_dir = strcat(save_dir,'_REST_Ref.mat');
                    
                    current_data = cur_data{i};
                    Fields_list = fields(current_data);
                    %---------------------
                    Ref_data = [];
                    for k = 1:length(Fields_list)
                        if strcmp(Fields_list{k}, 'data')
                            cur_var = current_data.(Fields_list{k});
                            cur_ave = mean(cur_var);
                            cur_var1 = cur_var - repmat(cur_ave,size(cur_var,1),1);
                            cur_var = Ra * cur_var1;
                            cur_var = cur_var1 + repmat(mean(cur_var),size(cur_var,1),1); % edit by Li Dong (2017.8.28)
                                                                                          % Vr = V_avg + AVG(V_0)
                            Ref_data.(Fields_list{k}) = cur_var;
                        else
                            Ref_data.(Fields_list{k}) = current_data.(Fields_list{k});
                        end
                    end
                    save(save_dir, '-struct', 'Ref_data');
                catch
                    disp(['error occuring for ' File_List{i}]);
                end
            end
            msgbox('Calculation completed', 'REST');
        else
            errordlg('Wrong Leadfield has been imported, please import the right Leadfield !!!','Error');
            return;
        end
    else
        errordlg('No Leadfield has been imported, please import Leadfield !!!','Error');
        return;
    end
else
    errordlg('No EEG data has been imported, please import data !!!','Error');
    return
end


% --------------------------------------------------------------------
function Load_exsiting_Callback(hObject, eventdata, handles)
% hObject    handle to Load_exsiting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cur_data;
global File_List;
[ProgramPath, ~, ~] = fileparts(which('REST.m'));
cur_data{1} = pop_loadbv([ProgramPath,filesep, 'sample_data'], 'sample.vhdr');
File_List{1} = [ProgramPath, filesep, 'sample_data', filesep, 'sample.vhdr'];
if ~isempty(cur_data)
    msgbox('Sample data has been successully imported.', 'Data');
    set(handles.listbox_files, 'String', File_List);
    set(handles.listbox_files, 'Value', 1);
else
    errordlg('Error occuring for sample data importing !!!','Error');
end


% --------------------------------------------------------------------
function Clear_space_Callback(hObject, eventdata, handles)
% hObject    handle to Clear_space (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global File_List;
if isempty(File_List)
    errordlg('No EEG data has been imported, please import data !!!','Error');
    return
else
    set(handles.listbox_files,'string','')
    clear all
    clc
end


% --------------------------------------------------------------------
function Quit_Callback(hObject, eventdata, handles)
% hObject    handle to Quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear all
close all
clc


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Data_plot_Callback(hObject, eventdata, handles)
% hObject    handle to Data_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global File_List;
global cur_data;
if ~isempty(cur_data)
    for i = 1:length(File_List)
        [pathstr, name{i}, exe] = fileparts(File_List{i});
    end
    name = name';
    data_plot = pop_chansel(cellstr(name));
    if ~isempty(data_plot)
        Fields_list = fields(cur_data{data_plot});
        for ii = 1:length(Fields_list)
            if strcmp(Fields_list{ii}, 'srate')
                sratelabel(ii) = 1;
            else
                sratelabel(ii) = 0;
            end
        end
        sratenum = find(sratelabel == 1);
        for ii = 1:length(Fields_list)
            if strcmp(Fields_list{ii}, 'chanlocs')
                chanlocslabel(ii) = 1;
            else
                chanlocslabel(ii) = 0;
            end
        end
        chanlocsnum = find(chanlocslabel == 1);
        if ~isempty(sratenum)
            if ~isempty(chanlocsnum)
                eegplot(cur_data{data_plot}.data, 'srate', cur_data{data_plot}.srate, 'eloc_file', ...
                    cur_data{data_plot}.chanlocs);
            else
                eegplot(cur_data{data_plot}.data, 'srate', cur_data{data_plot}.srate);
            end
        else
            srate = inputdlg('Please input the srate');
            eegplot(cur_data{data_plot}.data, 'srate', str2num(cell2mat(srate)));
        end
    else
        errordlg('No subject has been slected, please select one subject !!!','Error');
    end        
else
    errordlg('No EEG data has been imported, please import data !!!','Error');
end


% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Exclude_channels1_Callback(hObject, eventdata, handles)
% hObject    handle to Exclude_channels1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global File_List;
global cur_data;
if ~isempty(File_List)
    cur_file = File_List{1};
    [pathstr, name, exe] = fileparts(cur_file);
    current_data = cur_data{1};
    if ~strcmp(exe, '.mat')
        if ~isempty(current_data)
            if isempty(current_data.chanlocs)
                Nchanns = size(current_data.data,1);
                chanlist = pop_chansel(cellstr(num2str((1:Nchanns)')),'withindex','off');
            else
                chanlist = pop_chansel({current_data.chanlocs.labels},'withindex','on');
            end
            if isempty(chanlist)
                errordlg('No channel would be removed !!!','Error');
            else
                msgbox('The selected channels have been excluded', 'Channels');
                fprintf('%d channel has been removed ! \n', chanlist)
            end
        else
            errordlg('No EEG data has been imported, please import data !!!','Error');
            return;
        end
    else
        if ~isempty(current_data)
            Fields_list = fields(current_data);
            for ii = 1:length(Fields_list)
                if strcmp(Fields_list{ii}, 'chanlocs')
                    chanlocslabel(ii) = 1;
                else
                    chanlocslabel(ii) = 0;
                end
            end
           numbe = find(chanlocslabel == 1);
           if isempty(numbe)
               Nchanns = size(current_data.data,1);
               chanlist = pop_chansel(cellstr(num2str((1:Nchanns)')),'withindex','off');
           else
               if ~isempty(current_data.chanlocs)
                   chanlist = pop_chansel({current_data.chanlocs.labels},'withindex','on');
               else
                   Nchanns = size(current_data.data,1);
                   chanlist = pop_chansel(cellstr(num2str((1:Nchanns)')),'withindex','off');
               end
           end
            if isempty(chanlist)
                errordlg('No channel would be removed !!!','Error');
            else
                msgbox('The selected channels have been excluded', 'Channels');
                fprintf('%d channel has been removed ! \n', chanlist)
            end
        else
            errordlg('No EEG data has been imported, please import data !!!','Error');
            return;
        end
    end
    for i = 1:length(cur_data)
        Fields_list = fields(cur_data{i});
        for ii = 1:length(Fields_list)
            if strcmp(Fields_list{ii}, 'data')
                cur_data{i}.data(chanlist, :) = [];
            elseif strcmp(Fields_list{ii}, 'nbchan')
                cur_data{i}.nbchan = cur_data{i}.nbchan-length(chanlist);
            elseif strcmp(Fields_list{ii}, 'chanlocs')
                cur_data{i}.chanlocs(:, chanlist) = [];
            else
                continue;
            end
        end
    end
else
    errordlg('No EEG data has been imported, please import data !!!','Error');
    return;
end


% --------------------------------------------------------------------
function Untitled_4_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Leadfield_Calculation_Callback(hObject, eventdata, handles)
% hObject    handle to Leadfield_Calculation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[ProgramPath, ~, ~] = fileparts(which('REST.m'));
eval(['!',[ProgramPath,filesep, 'function', filesep, 'LeadField', filesep],'LeadField.exe']);


% --------------------------------------------------------------------
function Load_Leadfield_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Leadfield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Lead_Field;
global File_List;
if isempty(File_List)
    errordlg('No EEG data has been imported, please import data !!!','Error');
    return
else
    [Name_lf, pathname_lf] = uigetfile({'*.dat',...
    'Leadfield Files (*.dat)';'*.*', 'All Files (*.*)';}, ...
    'Select leadfield file');
    if (Name_lf == 0)
        errordlg('Leadfield matrix is not imported, please import Leadfield matrix !!!','Error');
    else
        Lead_Field = load([pathname_lf, Name_lf]);
        msgbox('Successfully import .', 'Lead Field');
    end
end


% --------------------------------------------------------------------
function Untitled_5_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function About_REST_Callback(hObject, eventdata, handles)
% hObject    handle to About_REST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox({'  This GUI is used to do the REST transformation processing for EEG data.';...
       ' ';...
       '        [1]. Calculate leadfield matrix;';...
       '        [2]. Import data;';...
       '        [3]. Plot data (optional);';...
       '        [4]. Exclude channels (e.g., ECG, EKG, and bad channels, etc);';...
       '        [5]. Import corresponding leadfield matrix;';...
       '        [6]. Run REST & export data;';...
       '        [7]. Clear dataset(s) (optioanl);';...
       '        [8]. Quit;';...
        }, 'About REST')


% --------------------------------------------------------------------
function Manual_Callback(hObject, eventdata, handles)
% hObject    handle to Manual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[ProgramPath, ~, ~] = fileparts(which('REST.m'));
open([ProgramPath, filesep,'docs', filesep, 'Userguide.pdf']);


% --------------------------------------------------------------------
function Website_Callback(hObject, eventdata, handles)
% hObject    handle to Website (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('http://www.neuro.uestc.edu.cn/REST/');


% -------------------------------------------------------------------------
% find a function path and add path if not present
function myaddpath(NITpath, functionname, pathtoadd)

tmpp = which(functionname);
tmpnewpath = [ NITpath pathtoadd ];
if ~isempty(tmpp)
    tmpp = tmpp(1:end-length(functionname));
    if length(tmpp) > length(tmpnewpath), tmpp = tmpp(1:end-1); end; % remove trailing filesep
    if length(tmpp) > length(tmpnewpath), tmpp = tmpp(1:end-1); end; % remove trailing filesep
    %disp([ tmpp '     |        ' tmpnewpath '(' num2str(~strcmpi(tmpnewpath, tmpp)) ')' ]);
    if ~strcmpi(tmpnewpath, tmpp)
        warning('off', 'MATLAB:dispatcher:nameConflict');
        addpath(tmpnewpath);
        warning('on', 'MATLAB:dispatcher:nameConflict');
    end;
else
    %disp([ 'Adding new path ' tmpnewpath ]);
    addpath(tmpnewpath);
end;

function addpathexist(p)
if exist(p) == 7
    addpath(p);
end;

function val = isNITdeployed2
%val = 1; return;
if exist('isdeployed')
    val = isdeployed;
else val = 0;
end;

