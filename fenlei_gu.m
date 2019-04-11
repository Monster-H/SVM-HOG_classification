function varargout = fenlei_gu(varargin)
% FENLEI_GU MATLAB code for fenlei_gu.fig
%      FENLEI_GU, by itself, creates a new FENLEI_GU or raises the existing
%      singleton*.
%
%      H = FENLEI_GU returns the handle to a new FENLEI_GU or the handle to
%      the existing singleton*.
%
%      FENLEI_GU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FENLEI_GU.M with the given input arguments.
%
%      FENLEI_GU('Property','Value',...) creates a new FENLEI_GU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fenlei_gu_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fenlei_gu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fenlei_gu

% Last Modified by GUIDE v2.5 29-Mar-2019 16:46:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fenlei_gu_OpeningFcn, ...
                   'gui_OutputFcn',  @fenlei_gu_OutputFcn, ...
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


% --- Executes just before fenlei_gu is made visible.
function fenlei_gu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fenlei_gu (see VARARGIN)

% Choose default command line output for fenlei_gu
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fenlei_gu wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fenlei_gu_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global im   %����һ��ȫ�ֱ���
[filename,pathname]=...
    uigetfile({'*.jpg';'*.bmp';'*.tif';'*.png'},'select picture');  %ѡ��ͼƬ·��
str=[pathname filename];  %�ϳ�·��+�ļ���
im=imread(str);   %��ȡͼƬ
axes(handles.axes1);  %ʹ�õ�һ��axes
imshow(im);title('����ͼƬ');  %��ʾͼƬ


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global im
global scaleImage
global features 
% features ������
imageSize = [256,256];% ������ͼ����д˳ߴ������ ?
% image1 = readimage(im); 
scaleImage = imresize(im,imageSize); 
[features, visualization] = extractHOGFeatures(scaleImage); 
% disp(features)
axes(handles.axes2);
imshow(scaleImage);title('HOG������ȡ��');
hold on; plot(visualization)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global features
global imageSize
global classifer
imageSize = [256,256];
imdsTrain = imageDatastore('./xbg_images/train_images',... ?
    'IncludeSubfolders',true,... ?
     'LabelSource','foldernames'); 
% ������ѵ��ͼ�����������ȡ ?
numImages = length(imdsTrain.Files); 
% disp(numImages)
% ��ʾѵ�����ĸ���
featuresTrain = zeros(numImages,size(features,2),'single'); 
% featuresTrainΪ������(��һ�鲻�Ǻܶ������ǵúú�̽��) 
for i = 1:numImages 
    imageTrain = readimage(imdsTrain,i); 
    imageTrain = imresize(imageTrain,imageSize); 
    featuresTrain(i,:) = extractHOGFeatures(imageTrain); 
    % ѭ����ȡÿ��ѵ��ͼƬ��Ȼ����гߴ�����
end 

% ����ѵ��ͼ���ǩ 
trainLabels = imdsTrain.Labels; 
disp(trainLabels)
% ��ʼsvm�����ѵ����ע�⣺fitcsvm���ڶ����࣬fitcecoc���ڶ����,1 VS 1���� 
classifer = fitcecoc(featuresTrain,trainLabels); 
set(handles.text2,'String','ѵ�����')


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scaleImage
global classifer
featureTest = extractHOGFeatures(scaleImage);
[predictIndex,score] = predict(classifer,featureTest); 
figure;imshow(scaleImage);
title(['predictImage: ',char(predictIndex)]); 
set(handles.text3,'string',char(predictIndex))
