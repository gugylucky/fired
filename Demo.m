function varargout = Demo(varargin)
% Demo MATLAB code for Demo.fig
%      Demo, by itself, creates a new Demo or raises the existing
%      singleton*.
%
%      H = Demo returns the handle to a new Demo or the handle to
%      the existing singleton*.
%
%      Demo('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in Demo.M with the given input arguments.
%
%      Demo('Property'n,'Value',...) creates a new Demo or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the Demo before Demo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Demo_OpeningFcn via varargin.
%
%      *See Demo Options on GUIDE's Tools menu.  Choose "Demo allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 11-Dec-2015 23:26:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Demo_OpeningFcn, ...
                   'gui_OutputFcn',  @Demo_OutputFcn, ...
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


% --- Executes just before Demo is made visible.
function Demo_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for Demo
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes Demo wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% tambahan
set(handles.toggleButton,'UserData',0);

% --- Outputs from this function are returned to the command line.
function varargout = Demo_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in browseButton.
function browseButton_Callback(hObject, eventdata, handles)

%% bersihin supaya tidak menuhin RAM
clearvars -global volumedata_RGB;
clearvars -global volumedata_gray;
%% inisialisasi global
global video_source numberOfFrames;
global volumedata_RGB volumedata_gray;
global threshold interval minimumPixel;
global thFrame i;
global parameterLBPTOP Offset;

% browse file
[filename, path] = uigetfile({'*.avi*'},'pilih video');
if path ~= 0
    %baca video, masukkan frame ke volumedata
    [video_source, volumedata_RGB, volumedata_gray] = bacavideo([path filename]);
    numberOfFrames = video_source.NumberOfFrames;
    
    % init parameter three-frame
    threshold = 5;
    interval = 10;
    minimumPixel = 10;
    % init i dan thFrame
    thFrame = 1+interval+interval;
    i = 1+interval+interval;
    % init parameter LBPTOP GLCM
    FxRadius = 3;
    FyRadius = 3;
    TInterval = 3;
    TimeLength = 3;
    BorderLength = 3;
    NeighborPoints = [8 8 8];
    T = 10;
    parameterLBPTOP = [FxRadius; FyRadius; TInterval; TimeLength; BorderLength; NeighborPoints(1); NeighborPoints(2); NeighborPoints(3); T;];
    Offset = [0 1] * 4;
    % init slider
    set(handles.frameNumberTextField,'String',int2str(thFrame));
    set(handles.frameSlider,'min',thFrame);
    set(handles.frameSlider,'max',numberOfFrames);
    set(handles.frameSlider,'value',thFrame);

    % show in panel 1
    axes(handles.axesVideo1);
    imshow(uint8(volumedata_RGB(:,:,:,1)));
    axes(handles.axesVideo2);
    imshow(uint8(volumedata_RGB(:,:,:,1)));
    % show in panel 2
    axes(handles.axes2);
    imshow(uint8(volumedata_RGB(:,:,:,1)));
    axes(handles.axes3);
    imshow(uint8(volumedata_RGB(:,:,:,1)));
    axes(handles.axes4);
    imshow(uint8(volumedata_RGB(:,:,:,1)));
end

% --- Executes on button press in nextButton.
% --- tombol nextButton akan memproses frame selanjutnya untuk dideteksi.
% --- bagian utama proses pendeteksian terletak pada fungsi nextFrame.
function nextButton_Callback(hObject, eventdata, handles)
%% inisialisasi
global thFrame threshold volumedata_RGB volumedata_gray interval minimumPixel numberOfFrames;
% bbox
global finalBbox bboxIndex show;
bboxIndex = 1;
% parameter LBPTOP
global parameterLBPTOP Offset;

if thFrame < numberOfFrames
    thFrame = thFrame + 1;
    [show, ~, finalBbox] = nextFrame( volumedata_RGB, volumedata_gray, thFrame, threshold, interval, minimumPixel, parameterLBPTOP, Offset );
    % show in panel 2
    axes(handles.axes2);
    imshow(show.threeframe);
    axes(handles.axes3);
    imshow(show.firecolor);
    axes(handles.axes4);
    imshow(show.lbptopglcm);
    imwrite(show.lbptopglcm,'tes.bmp');

    set(handles.frameSlider,'value',thFrame);
    set(handles.frameNumberTextField,'String',int2str(thFrame));
end

% --- Executes on button press in prevButton.
% --- tombol prevButton akan memproses frame sebelumnya untuk dideteksi.
% --- bagian utama proses pendeteksian terletak pada fungsi nextFrame.
function prevButton_Callback(hObject, eventdata, handles)
%% inisialisasi
global thFrame threshold volumedata_RGB volumedata_gray interval minimumPixel numberOfFrames;
% bbox
global finalBbox bboxIndex show;
bboxIndex = 1;
% parameter LBPTOP
global parameterLBPTOP Offset;

if thFrame > 1+interval+interval
    thFrame = thFrame - 1;
    [show, ~, finalBbox] = nextFrame( volumedata_RGB, volumedata_gray, thFrame, threshold, interval, minimumPixel, parameterLBPTOP, Offset );
    % show in panel 2
    axes(handles.axes2);
    imshow(show.threeframe);
    axes(handles.axes3);
    imshow(show.firecolor);
    axes(handles.axes4);
    imshow(show.lbptopglcm);

    set(handles.frameSlider,'value',thFrame);
    set(handles.frameNumberTextField,'String',int2str(thFrame));
end

% --- Executes on button press in detailButton.
function detailButton_Callback(hObject, eventdata, handles)
%% inisialisasi
global thFrame interval volumedata_gray parameterLBPTOP Offset finalBbox bboxIndex show;

% selecting and displaying current boundingbox
if ~isempty(finalBbox)
    if bboxIndex == 1
        prevBbox = finalBbox(size(finalBbox,1),:);
        show.lbptopglcm = insertShape(show.lbptopglcm,'Rectangle',[prevBbox(1),prevBbox(2),prevBbox(3),prevBbox(4)], 'color', 'red');
        thisBbox = finalBbox(bboxIndex,:);
        show.lbptopglcm = insertShape(show.lbptopglcm,'Rectangle',[thisBbox(1),thisBbox(2),thisBbox(3),thisBbox(4)], 'color', 'green');
        axes(handles.axes4);
        imshow(show.lbptopglcm);
    elseif bboxIndex <= size(finalBbox,1) && bboxIndex > 1
        prevBbox = finalBbox(bboxIndex-1,:);
        show.lbptopglcm = insertShape(show.lbptopglcm,'Rectangle',[prevBbox(1),prevBbox(2),prevBbox(3),prevBbox(4)], 'color', 'red');
        thisBbox = finalBbox(bboxIndex,:);
        show.lbptopglcm = insertShape(show.lbptopglcm,'Rectangle',[thisBbox(1),thisBbox(2),thisBbox(3),thisBbox(4)], 'color', 'green');
        axes(handles.axes4);
        imshow(show.lbptopglcm);
    else
        disp('index exceeding the total number of bounding boxes');
    end
    if bboxIndex == size(finalBbox,1)
        bboxIndex = 0;
    end
    bboxIndex = bboxIndex+1;
end

% displaying XY, XT, YT in a figure
volData = volumedata_gray(thisBbox(2):thisBbox(2)+thisBbox(4),thisBbox(1):thisBbox(1)+thisBbox(3),thFrame-interval:thFrame+interval);
[Planes,feature] = LBPTOPGLCM(volData, parameterLBPTOP(1), parameterLBPTOP(2), parameterLBPTOP(3), [parameterLBPTOP(6) parameterLBPTOP(7) parameterLBPTOP(8)], parameterLBPTOP(4), parameterLBPTOP(5), Offset);

formatSpec = '\n Contrast : %f\n Correlation : %f\n Energy : %f\n Homogenity : %f\n';
stringXY = sprintf(formatSpec,feature(1:4));
stringYT = sprintf(formatSpec,feature(5:8));
stringXT = sprintf(formatSpec,feature(9:12));

figure(),
    subplot(3,2,1),imshow(Planes.XYplaneLBP),title('XY');
    subplot(3,2,3),imshow(Planes.XTplaneLBP),title('YT');
    subplot(3,2,5),imshow(Planes.YTplaneLBP),title('XT');
    xy = subplot(3, 2, 2);text(0,0.5,stringXY),set(xy,'visible','off');
    yt = subplot(3, 2, 4);text(0,0.5,stringYT),set(yt,'visible','off');
    xy = subplot(3, 2, 6);text(0,0.5,stringXT),set(xy,'visible','off');
    disp(stringXY);
    disp(stringXT);
    disp(stringYT);

% --- Executes on slider movement.
function frameSlider_Callback(hObject, eventdata, handles)

global thFrame;
thFrame = round(get(hObject,'Value'));
set(hObject,'Value', thFrame);
set(handles.frameNumberTextField,'String',int2str(thFrame));

% --- Executes during object creation, after setting all properties.
function frameSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function frameNumberTextField_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function frameNumberTextField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameNumberTextField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in toggleButton.
% --- ini tombol play/pause. terbaik.
% --- cc: Bening Qias Ranum, Gede Candrayana Giri
function toggleButton_Callback(hObject, eventdata, handles)
%% inisialisasi
global threshold volumedata_RGB volumedata_gray interval minimumPixel numberOfFrames i parameterLBPTOP Offset;

buttonState = get(hObject,'value');
if buttonState == get(hObject,'Max')
    set(handles.toggleButton,'String','Pause');
    set(handles.toggleButton,'UserData',1);
    for j = i : numberOfFrames
        if get(handles.toggleButton,'UserData')==0  % if pause
            i = j;  % simpen indeks sebelum di break/pause
            break;
        end
        % memproses frame
        [show, ~, ~] = nextFrame( volumedata_RGB, volumedata_gray, j, threshold, interval, minimumPixel, parameterLBPTOP, Offset );
        % dan menampilkan frame pada panel 1
        axes(handles.axesVideo1);
        imshow(uint8(volumedata_RGB(:,:,:,j)));
        axes(handles.axesVideo2);
        imshow(show.lbptopglcm);
    end
    if j == numberOfFrames    % kalo udah sampe ujung video, ulang lagi dari awal
        set(handles.toggleButton,'String','Start');
        set(handles.toggleButton,'UserData',0);
        set(handles.toggleButton,'value',0);
        i = 1+interval+interval;
    end
elseif buttonState == get(hObject,'Min')    % if resume
    set(handles.toggleButton,'String','Resume');
    set(handles.toggleButton,'UserData',0);
end
