imdsTrain = imageDatastore('./xbg_images/train_images',... ?
    'IncludeSubfolders',true,... ?
     'LabelSource','foldernames'); 
imdsTest = imageDatastore('./xbg_images/test_images'); 


% 1. imageDatastore
% imageDatastore��imds = imageDatastore('./images', 'IncludeSubfolders', true, 'labelsource', 'foldernames') 
% ��һ������./images��ʾ�ļ����ڵ�·����
% �����������Ǽ�ֵ�ԣ�key-value������ʽ 
% includesubfolders���Ƿ������ȡ���ļ����е�ͼ�����ݣ�
% labelsource��ͼ�� label ����Դ��ʲô��
% ��ʱ��imds�Ѱ�����ԭʼ���ݼ��ḻ����Ϣ�� 
% tbl = countEachLabel(imds) ? ����֪�⣬����һ�����ĳһlabelͼ�񣬼����Ӧ��ͼ�������
% categories = tbl.Label;�� tbl ��һ�� table��tbl.Label �������Ǳ��е��У�
% imds.Files��ȫ���ļ������ɵ� cell ���ϣ�
% 2. splitEachLabel��������ݼ�
% [imds1,imds2] = splitEachLabel(imds, p); 
% p ������һ��С������ʾ�ٷֱȣ����ݰٷֱȻ��֣�
% Ҳ������һ��������������һ�������л��֣�


%% ��ʾѵ����ͼƬ����Labels������Count
Train_disp = countEachLabel(imdsTrain);
disp(Train_disp);

%%  2 ��ѵ�����е�ÿ��ͼ�����hog������ȡ������ͼ��һ�� 
% Ԥ����ͼ��,��Ҫ�ǵõ�features������С���˴�С��ͼ���С��Hog����������� 
imageSize = [256,256];% ������ͼ����д˳ߴ������ 
image1 = readimage(imdsTrain,1); 
scaleImage = imresize(image1,imageSize); 
[features, visualization] = extractHOGFeatures(scaleImage); 
% disp(features)
% imshow(scaleImage);hold on; plot(visualization) 

% ������ѵ��ͼ�����������ȡ 
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

%% Ԥ�Ⲣ��ʾԤ��Ч��ͼ 
numTest = length(imdsTest.Files); 
for i = 1:numTest 
    testImage = readimage(imdsTest,i); 
    scaleTestImage = imresize(testImage,imageSize); 
    featureTest = extractHOGFeatures(scaleTestImage);
    [predictIndex,score] = predict(classifer,featureTest); 
    figure;imshow(testImage); 
    title(['predictImage: ',char(predictIndex)]); 
end 
