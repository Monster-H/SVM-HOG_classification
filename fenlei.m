
%% ��hog������ͼ����ж���࣬svmѵ����1 VS 1 ?
%% 1 ���ݼ�������ѵ���ĺͲ��Ե� (ע���Լ�ͼƬ���·������¼�Ҹ���ʾ������ͼƬ����)?
imdsTrain = imageDatastore('./svm_images/train_images',... ?
    'IncludeSubfolders',true,... ?
     'LabelSource','foldernames'); 
imdsTest = imageDatastore('./svm_images/test_image'); 


%% ��ʾѵ����ͼƬ����Labels������Count
Train_disp = countEachLabel(imdsTrain);
disp(Train_disp);

%% ? 2 ��ѵ�����е�ÿ��ͼ�����hog������ȡ������ͼ��һ�� ?
% Ԥ����ͼ��,��Ҫ�ǵõ�features������С���˴�С��ͼ���С��Hog����������� ?
imageSize = [256,256];% ������ͼ����д˳ߴ������ ?
image1 = readimage(imdsTrain,1); 
scaleImage = imresize(image1,imageSize); 
[features, visualization] = extractHOGFeatures(scaleImage); 
imshow(scaleImage);hold on; plot(visualization) 

% ������ѵ��ͼ�����������ȡ ?
numImages = length(imdsTrain.Files); 
featuresTrain = zeros(numImages,size(features,2),'single'); % featuresTrainΪ������ ?
for i = 1:numImages 
    imageTrain = readimage(imdsTrain,i); 
    imageTrain = imresize(imageTrain,imageSize); 
    featuresTrain(i,:) = extractHOGFeatures(imageTrain); 
end 

% ����ѵ��ͼ���ǩ ?
trainLabels = imdsTrain.Labels; 

% ��ʼsvm�����ѵ����ע�⣺fitcsvm���ڶ����࣬fitcecoc���ڶ����,1 VS 1���� ?
classifer = fitcecoc(featuresTrain,trainLabels); 

%% Ԥ�Ⲣ��ʾԤ��Ч��ͼ ?
numTest = length(imdsTest.Files); 
for i = 1:numTest 
    testImage = readimage(imdsTest,i); 
    scaleTestImage = imresize(testImage,imageSize); 
    featureTest = extractHOGFeatures(scaleTestImage);
    [predictIndex,score] = predict(classifer,featureTest); 
    figure;imshow(testImage); 
    title(['predictImage: ',char(predictIndex)]); 
end 
