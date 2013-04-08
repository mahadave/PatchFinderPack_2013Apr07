%%This file runs the sift algorithm
%% bag is a patch and the instances are the randomly selected points 
% fischer extracts a feature vector for each bag based on the universal GMM
% trained using all the instances

startUp();
[folder,files,users,color] =setDirs();

%% --------------------------TRAIN----------------------------------------

%decide number of files to run for
trainingLimits = [1 50];

%% -- Training data-1

close all
[pointList,trainingLabels,indexList] = trainingDataAndLabels(trainingLimits);
save('trainingData1','pointList','trainingLabels', 'indexList');

%% -- Build Gaussian Mixture Model

k=5;
[GMMList,gmm] = makeGMM(pointList,k);
save(['GMM_',num2str(k)],'gmm'); 

%% -- Extract Fisher Feature Vectors
  
[fishers] = extractFishers(GMMList, gmm, indexList);
[trainingList,trainingLabels] = prepTraining(fishers,trainingLabels);
info=['using image indices : ',num2str(trainingLimits) ];
save('trainingData2','trainingList','info');

%% -------------------------- TANHAYEE -------------------------------------

%% --------------------------TEST-------------------------------------------

testLimits = [51 80];

%% -- Test data-1

[testPointList,testLabels,indexListTesting] = testingDataAndLabels(testLimits);
testInfo = ['testing from ',num2str(testLimits)];
save('testData1','testPointList','testLabels','indexListTesting','testLimits','testInfo');

%% -- Extract test image fisher feature vectors based on the training GMM

load gmm_5
testPointList = double(testPointList);
[fishers]=extractFishers(testPointList,gmm,indexListTesting);
testList = fishers;
save('testData2','testList');

%% -- Random selection with boosting

pList = [];
nList = [];
indicesSelectedList = [];
fr =0.7;
iterations = 7;

NTimes=25;
for outer=1:NTimes
    
	%%UNDERSAMPLING------------------------------------------------------------
    fr=0.9;% fraction of positives to select from negatives
	[indices,newUnderTrainList,newUnderLabelList] = randomSelection(trainingList,trainingLabels,fr);
    indicesSelectedList = [indicesSelectedList ; indices];
    
    %----------------train and predict using new classifier 
    SVMStruct = boosting(trainingList,trainingLabels,iterations);
	%------------------ validate here
	predictedLabelList = svmclassify(SVMStruct,testList);
    %----------------- check values
	[p,n] = QuantTesting(testLabels,predictedLabelList);
    %---------------- keep track of values for each random selection
	pList = [pList;p]; 	nList = [nList;n];
    
	
end

%% -- testing on test data (....er. validation data) 
predictedLabelList = svmclassify(SVMStruct2,testList);
%----------------- check values
[p,n] = QuantTesting(testLabels,predictedLabelList);