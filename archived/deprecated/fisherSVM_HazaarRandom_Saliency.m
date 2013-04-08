%%This file runs the sift algorithm
%% bag is a patch and the instances are the randomly selected points 
% fischer extracts a feature vector for each bag based on the universal GMM
% trained using all the instances

startUp();
clear all;
[folder,files,users,color] =setDirs();

%% --------------------------TRAIN----------------------------------------

%decide number of files to run for


%% -- Training data-1

trainingLimits = [1 50];

NPoints = 25;
close all
[pointList,trainingLabels,indexList] = trainingDataAndLabels_v0(trainingLimits,NPoints);
info=['using image indices : ',num2str(trainingLimits) ];

save('trainingData1','pointList','trainingLabels', 'indexList','info');
save('common','NPoints');

%% -- Build Gaussian Mixture Model

disp('building gmm...');
clear all;
load('trainingData1','pointList');
k=5;
[GMMList,gmm] = makeGMM(pointList,k);

save('trainingData2','gmm','GMMList'); 

%% -- Extract Fisher Feature Vectors
  
disp('extracting fishers...');
clear all;
load('trainingData1','indexList','trainingLabels');
load('trainingData2','gmm','GMMList')
[fishers] = extractFishers(GMMList, gmm, indexList);
[trainingList,trainingLabels] = prepTraining(fishers,trainingLabels);

save('trainingData3','trainingList','trainingLabels','fishers');

%% -------------------------- TANHAYEE -------------------------------------

%% --------------------------TEST-------------------------------------------


%% -- Test data-1
NPoints = 25;
testLimits = [51 80];

[testPointList,testLabels,indexListTesting] = testingDataAndLabels_v0(testLimits,NPoints);
testInfo = ['testing from ',num2str(testLimits)];
save('testData1','testPointList','testLabels','indexListTesting','testLimits','testInfo');

%% -- Extract test image fisher feature vectors based on the training GMM

disp('extracting test fishers...')
clear all;
load('trainingData2','gmm');
load('testData1','testPointList','indexListTesting')
testPointList = double(testPointList);
[testFishers]=extractFishers(testPointList,gmm,indexListTesting);
testList = testFishers;
save('testData2','testList','testFishers');

%% -- Random selection with boosting
clear all;
load('trainingData3','trainingList','trainingLabels');
load('testData1','testLabels');
load('testData2','testList');

pList = [];
nList = [];
indicesSelectedList = [];
fr =0.9;
iterations = 1;

save('common','fr','iterations');

NRandomTimes=25;
for outer=1:NRandomTimes
    
	%%UNDERSAMPLING--------------------------------------------------------
	%%----
    disp(['random selection ',num2str(outer)])
	[indices,newUnderTrainList,newUnderLabelList] = randomSelection(trainingList,trainingLabels,fr);
    %indicesSelectedList = [indicesSelectedList ; indices];
    
    %----------------train and predict using new classifier 
    SVMStruct = boosting(trainingList,trainingLabels,fr,indices,iterations);
	%------------------ validate here
	predictedLabelList = svmclassify(SVMStruct,testList);
    %----------------- check values
	[p,n] = QuantTesting(testLabels,predictedLabelList);
    %---------------- keep track of values for each random selection
	pList = [pList;p]; 	nList = [nList;n];
    
	
end

%% -- testing on test data (....er. validation data) 
predictedLabelList = svmclassify(SVMStruct,testList);
%----------------- check values
[p,n] = QuantTesting(testLabels,predictedLabelList);