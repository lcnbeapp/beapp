%% add_10_20_equivalents_gui
% prompt users to add 10_20 equivalents for a new net
% called by add_nets_to_library

function varargout = add_10_20_equivalents_gui(varargin)
% ADD_10_20_EQUIVALENTS_GUI MATLAB code for add_10_20_equivalents_gui.fig
%      ADD_10_20_EQUIVALENTS_GUI, by itself, creates a new ADD_10_20_EQUIVALENTS_GUI or raises the existing
%      singleton*.
%
%      H = ADD_10_20_EQUIVALENTS_GUI returns the handle to a new ADD_10_20_EQUIVALENTS_GUI or the handle to
%      the existing singleton*.
%
%      ADD_10_20_EQUIVALENTS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADD_10_20_EQUIVALENTS_GUI.M with the given input arguments.
%
%      ADD_10_20_EQUIVALENTS_GUI('Property','Value',...) creates a new ADD_10_20_EQUIVALENTS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before add_10_20_equivalents_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to add_10_20_equivalents_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help add_10_20_equivalents_gui

% Last Modified by GUIDE v2.5 21-Jun-2017 15:11:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @add_10_20_equivalents_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @add_10_20_equivalents_gui_OutputFcn, ...
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


% --- Executes just before add_10_20_equivalents_gui is made visible.
function add_10_20_equivalents_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to add_10_20_equivalents_gui (see VARARGIN)

% Choose default command line output for add_10_20_equivalents_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes add_10_20_equivalents_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = add_10_20_equivalents_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%uiwait(handles.
% Get default command line output from handles structure
guidata(hObject, handles);
uiwait(handles.figure1);
whole_table = get(handles.uitable1,'Data');
varargout{1} = cell2mat(whole_table(:,2)');
close(handles.figure1);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
guidata(hObject, handles);
uiresume;
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
