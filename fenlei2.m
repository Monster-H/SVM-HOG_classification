imdsTrain = imageDatastore('./xbg_images/train_images',... ?
    'IncludeSubfolders',true,... ?
     'LabelSource','foldernames'); 
imdsTest = imageDatastore('./xbg_images/test_images'); 


% 1. imageDatastore
% imageDatastore：imds = imageDatastore('./images', 'IncludeSubfolders', true, 'labelsource', 'foldernames') 
% 第一个参数./images表示文件所在的路径；
% 后续参数都是键值对（key-value）的形式 
% includesubfolders：是否继续读取子文件夹中的图像数据；
% labelsource：图像 label 的来源是什么；
% 此时的imds已包含了原始数据集丰富的信息； 
% tbl = countEachLabel(imds) ? 见名知意，创建一个表格，某一label图像，及其对应的图像个数；
% categories = tbl.Label;（ tbl 是一个 table，tbl.Label 索引的是表中的列）
% imds.Files：全部文件名构成的 cell 集合；
% 2. splitEachLabel：拆分数据集
% [imds1,imds2] = splitEachLabel(imds, p); 
% p 可以是一个小数，表示百分比，根据百分比划分；
% 也可以是一个整数，根据这一整数进行划分；


%% 显示训练的图片种类Labels和数量Count
Train_disp = countEachLabel(imdsTrain);
disp(Train_disp);

%%  2 对训练集中的每张图像进行hog特征提取，测试图像一样 
% 预处理图像,主要是得到features特征大小，此大小与图像大小和Hog特征参数相关 
imageSize = [256,256];% 对所有图像进行此尺寸的缩放 
image1 = readimage(imdsTrain,1); 
scaleImage = imresize(image1,imageSize); 
[features, visualization] = extractHOGFeatures(scaleImage); 
% disp(features)
% imshow(scaleImage);hold on; plot(visualization) 

% 对所有训练图像进行特征提取 
numImages = length(imdsTrain.Files); 
% disp(numImages)
% 显示训练集的个数
featuresTrain = zeros(numImages,size(features,2),'single'); 
% featuresTrain为单精度(这一块不是很懂，但是得好好探究) 
for i = 1:numImages 
    imageTrain = readimage(imdsTrain,i); 
    imageTrain = imresize(imageTrain,imageSize); 
    featuresTrain(i,:) = extractHOGFeatures(imageTrain); 
    % 循环读取每张训练图片，然后进行尺寸缩放
end 

% 所有训练图像标签 
trainLabels = imdsTrain.Labels; 
disp(trainLabels)
% 开始svm多分类训练，注意：fitcsvm用于二分类，fitcecoc用于多分类,1 VS 1方法 
classifer = fitcecoc(featuresTrain,trainLabels); 

%% 预测并显示预测效果图 
numTest = length(imdsTest.Files); 
for i = 1:numTest 
    testImage = readimage(imdsTest,i); 
    scaleTestImage = imresize(testImage,imageSize); 
    featureTest = extractHOGFeatures(scaleTestImage);
    [predictIndex,score] = predict(classifer,featureTest); 
    figure;imshow(testImage); 
    title(['predictImage: ',char(predictIndex)]); 
end 
