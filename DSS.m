function varargout = DSS(varargin)
% DSS MATLAB code for DSS.fig
%      DSS, by itself, creates a new DSS or raises the existing
%      singleton*.
%
%      H = DSS returns the handle to a new DSS or the handle to
%      the existing singleton*.
%
%      DSS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DSS.M with the given input arguments.
%
%      DSS('Property','Value',...) creates a new DSS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DSS_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DSS_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DSS

% Last Modified by GUIDE v2.5 16-Dec-2015 21:18:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DSS_OpeningFcn, ...
                   'gui_OutputFcn',  @DSS_OutputFcn, ...
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


% --- Executes just before DSS is made visible.
function DSS_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DSS (see VARARGIN)
% 

handles.nets   = varargin{1};
handles.labels = varargin{2};
handles.inputs = ones(size(handles.labels)) ;

[ ~, ~, handles.enZscore ] = applyANNensemble ( handles.inputs', handles.nets) ;
 
handles.regimes = handles.enZscore.mean ;
 
update_plot ( handles )

% Choose default command line output for DSS
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DSS wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DSS_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
ind1 = get(hObject,'Value') ;
%min = get(hObject,'Min') ;
%max = get(hObject,'Max') ;
set(hObject,'SliderStep',[1/4 1/4]);
% Save the new volume value
handles.inputs(1) = ind1;
update_plot ( handles ) ;

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
ind2 = get(hObject,'Value') ;
min = get(hObject,'Min') ;
max = get(hObject,'Max') ;
set(hObject,'SliderStep',[1/4 1/4]);

% Save the new volume value
handles.inputs(2) = ind2;
update_plot ( handles ) ;

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
ind3 = get(hObject,'Value') ;
min = get(hObject,'Min') ;
max = get(hObject,'Max') ;
set(hObject,'SliderStep',[1/4 1/4]);

% Save the new volume value
handles.inputs(3) = ind3;
update_plot ( handles ) ;

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
ind4 = get(hObject,'Value') ;
min = get(hObject,'Min') ;
max = get(hObject,'Max') ;
set(hObject,'SliderStep',[1/4 1/4]);

% Save the new volume value
handles.inputs(4) = ind4 ;
update_plot ( handles ) ;

guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
ind5 = get(hObject,'Value') ;
min = get(hObject,'Min') ;
max = get(hObject,'Max') ;
set(hObject,'SliderStep',[1/4 1/4],'Min',1,'Max',5);

% Save the new volume value
handles.inputs(5) = ind5 ;

update_plot ( handles ) ;

guidata(hObject,handles)



% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% % --- Executes on button press in pushbutton1.
% function pushbutton1_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbutton1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% axes(handles.axes1);
% bar(handles.inputs,'FaceColor','k');
% set(handles.axes1, 'XLim', [0.5 5.5], 'YLim', [0.5 5.5],...
%     'xticklabel',handles.labels,...
%     'xticklabelrotation',15);
% 
% % --- Executes on button press in pushbutton2.
% function pushbutton2_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbutton2 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)

function update_plot (handles)

axes(handles.axes1);
bar(handles.inputs,'FaceColor','k');
set(handles.axes1, 'XLim', [0.5 5.5], 'YLim', [0.5 5.5],...
    'xticklabel',handles.labels,...
    'xticklabelrotation',15);

[ ~, handles.enZ, handles.enZscore ] = applyANNensemble ( handles.inputs, handles.nets) ;
%disp(handles.params.enZscore.mean);
handles.regimes = handles.enZscore.mean;

axes(handles.axes2);
hBar = bar(handles.regimes);
hold on;
errorbar(handles.regimes, handles.enZscore.stdev,'k','LineWidth',1);

set(handles.axes2, 'XLim', [0.5 3.5], 'YLim', [0.5 1.0],'XTickLabel',{'Regime1','Regime2','Regime3'});
ylabel('score');

hBarChildren = get(hBar, 'Children');
% Set the colors we want to use
clrCerulean = [0.0, 0.48, 0.65];
clrOrangeRed = [1.0, 0.27, 0.0];
myBarColors = [clrCerulean; clrOrangeRed];
% This defines which bar will be using which index of "myBarColors", i.e. the first
%  two bars will be colored in "clrCerulean", the next 6 will be colored in "clrOrangeRed"
%  and the last 4 bars will be colored in "clrOliveGreen"
tt=1:numel(handles.enZscore.mean);
tt(handles.enZ.mean)=[];
index (tt) = 1 ;
index (handles.enZ.mean) = 2;
% Set the index as CData to the children
set(hBarChildren, 'CData', index);
colormap(myBarColors);
hold off;
