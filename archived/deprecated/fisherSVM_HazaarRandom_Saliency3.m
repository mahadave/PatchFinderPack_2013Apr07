%%This file runs the sift algorithm
%% bag is a patch and the instances are the randomly selected points 
% fischer extracts a feature vector for each bag based on the universal GMM
% trained using all the instances

clc
startUp();
clear all;
[folder,files,users,color] =setDirs();
showSettings();

%% --------------------------TRAIN----------------------------------------

%decide number of files to run for
% -- Training data-1
trainingLimits = [1 50];
predictedLabelList2 = [];
NPoints = 25;
close all
[pointList,trainingLabels,patchInfo] = trainingDataAndLabels_v11b_intraPatchInterPatch(trainingLimits,NPoints);
info=['using image indices : ',num2str(trainingLimits)];
save('trainingData1','pointList','trainingLabels', 'patchInfo');
%save('common','NPoints');

%% -- Build Gaussian Mixture Model

disp('building gmm...');
%clear all;
load('trainingData1','pointList');
k=5;
[gmm] = makeGMM_v2(pointList,k);
save('trainingData2','gmm'); 

%% -- Extract Fisher Feature Vectors
fishers = [];
disp('extracting fishers...');
clear all;
load('trainingData1','trainingLabels','patchInfo');
load('trainingData2','gmm')
[fishers,patchInfo] = extractFishers_v3(gmm, patchInfo);
[trainingList,trainingLabels] = prepTraining(fishers,trainingLabels);

save('trainingData3','trainingList','trainingLabels','fishers','patchInfo');
%%
clear all
load('trainingData3','trainingList');
[normTrainingList scale] = normalizeFeatVect(trainingList);
save('scaledData1','normTrainingList','scale');

%%
%
clear all;
NBins = 20;
load('trainingData1', 'patchInfo');
load('trainingData3', 'fishers');
newfisherVector = concatFisherSAD_v2(fishers,patchInfo);
histVectorTrain = extractHist(newfisherVector,NBins);
histVectorTrainIntra = extractHistIntra(newfisherVector,NBins);
save('trainingData4', 'newfisherVector','histVectorTrain','histVectorTrainIntra');
%% -------------------------- TANHAYEE -------------------------------------

%% --------------------------TEST-------------------------------------------


%% -- Test data-1
NPoints = 25;
testLimits = [51 80];
[testPointList,testLabels,testPatchInfo] = testingDataAndLabels_v11b_intraPatchInterPatch(testLimits,NPoints);
testInfo = ['testing from ',num2str(testLimits)];
save('testData1','testPointList','testLabels','testLimits','testPatchInfo','testInfo'); %'predictedLabelList2',

%% -- Extract test image fisher feature vectors based on the training GMM

disp('extracting test fishers...')
clear all;
load('trainingData2','gmm');
load('testData1','testPointList','indexListTesting','testPatchInfo')
testPointList = double(testPointList);
[testFishers, testPatchInfo]=extractFishers_v3(gmm, testPatchInfo);
testList = testFishers;
save('testData2','testList','testFishers');

%%
clear all
load('testData2','testList');
load('scaledData1','scale');
normTestList = normalizeFeatVectTest(testList, scale);
save('scaledData2','normTestList');

%%
clear all;
NBins=20; %change here
load('testData1', 'testPatchInfo');
load('testData2', 'testFishers');
testFisherVector = concatFisherSAD_v2(testFishers,testPatchInfo);
histVector = extractHist(testFisherVector,NBins);
histVectorTestIntra = extractHistIntra(testFisherVector,NBins);
save('testData3', 'testFisherVector','histVector','histVectorTestIntra');
%%
%Apply PCA after concatenating trainlist and testlist
clear all;
load('testData2', 'testList');
load('trainingData3','trainingList');
AllData = [trainingList; testList];
[rel, reducedData] = pca_own(AllData);
%%
%[U, mu, variances] = pca( AllData);
 trainingList_PCA = reducedData(1:6110,:);
 testList_PCA = reducedData(6111:end,:);
 save('PCAdata','trainingList_PCA','testList_PCA');
 %%
 clear all;
 load('PCAdata','trainingList_PCA','testList_PCA');
 load('testData3', 'histVector','histVectorTestIntra');
 load('trainingData4', 'histVectorTrain','histVectorTrainIntra');
 
 trainingList_v2 = [trainingList_PCA histVectorTrain histVectorTrainIntra];
 testList_v2 = [testList_PCA histVector histVectorTestIntra];
 
 save('PCAhistData','trainingList_v2','testList_v2');

%% -- Random selection with boosting

clear all;
load('trainingData3','trainingList','trainingLabels','fishers');
load('testData1','testLabels');
load('testData2','testList');
 load('trainingData4', 'newfisherVector','histVectorTrain');
 load('testData3', 'testFisherVector','histVector');
% load('scaledData1','normTrainingList');
% load('scaledData2','normTestList');
%load('PCAdata','trainingList_PCA','testList_PCA');
load('PCAhistData','trainingList_v2','testList_v2');
pList = [];
nList = [];
indicesSelectedList = [];
iList=[];
fr =1;
iterations = 1;

save('common','fr','iterations');
saveIndex = 1;
 NRandomTimes=10;
 for outer=1:NRandomTimes
    
   for iterations = 1:5
	%%UNDERSAMPLING--------------------------------------------------------
	%%----
    for fr =1:1
%     disp(['random selection ',num2str(outer)])
 	[indices,newUnderTrainList,newUnderLabelList,posTrainList, posLabelList,downTrainList,downLabelList,negTrainList,N] = randomSelection(trainingList_v2,trainingLabels,fr);   
    %----------------train and predict using new classifier 
    [SVMStruct,f] = boosting_v3(posTrainList,downTrainList,posLabelList,downLabelList,negTrainList,N,fr,iterations);
	%------------------ validate here
	predictedLabelList = svmclassify(SVMStruct,testList_v2);
    %----------------- check values
	[p,n] = QuantTesting(testLabels,predictedLabelList);
    %---------------- keep track of values for each random selection
	pList = [pList;p]; 	nList = [nList;n];
 %%   
%     load('testdata1', 'predictedLabelList2');
%     [p,n] = QuantTesting(testLabels,predictedLabelList2);
    %%
     if(p>=0.8 && n>=0.3)
         indicesSelectedList(saveIndex).indices = indices;
         indicesSelectedList(saveIndex).p = p;
         indicesSelectedList(saveIndex).n = n;
         indicesSelectedList(saveIndex).iterations = iterations;
         indicesSelectedList(saveIndex).fr = fr;
         saveIndex = saveIndex + 1;
         iList = [iList ; [iterations fr]];
         save('resultData1','indicesSelectedList');
     end
    end
  end
    
 end
 
%%
NPoints = 25;
testLimits = [51 80];

%

[testPointList,testLabels,indexListTesting,corrMax,predictedLabelList2] = testingDataAndLabels_v7(testLimits,NPoints);
testInfo = ['testing from ',num2str(testLimits)];
%save('testData3','corrMax','predictedLabelList2');

%%
%Code to reproduce accuracy------------------------------------------------

clear all
retrieveIndex = 4;
load('trainingData3','trainingList','trainingLabels','fishers');
load('testData1','testLabels');
load('testData2','testList','testFishers');
load('resultData1','indicesSelectedList');
load('PCAhistData','trainingList_v2','testList_v2');
%  load('trainingData4', 'newfisherVector','histVectorTrain');
%  load('testData3', 'testFisherVector','histVector');
 load('PCAdata','trainingList_PCA','testList_PCA');
fr = indicesSelectedList(retrieveIndex).fr;
iterations = indicesSelectedList(retrieveIndex).iterations;
indices = indicesSelectedList(retrieveIndex).indices;
[negTrainList,negLabelList]= getNegativeData(trainingList_v2,trainingLabels);
[posTrainList,posLabelList]= getPositiveData(trainingList_v2,trainingLabels);
N = uint16(round(fr * (size(posTrainList,1))));
downTrainList = negTrainList(indices,:);
downLabelList = negLabelList(indices);
%%
[SVMStruct,f] = boosting_v3(posTrainList,downTrainList,posLabelList,downLabelList,negTrainList,N,fr,iterations);
%%
	[predictedLabelList f]= svmclassify2(SVMStruct,testList_v2);
    %----------------- check values
	[p,n] = QuantTesting(testLabels,predictedLabelList);
    %%
   
    testLimits = [50 80];
    load('testData1','testPatchInfo');
    load('trainingData3','trainingList','trainingLabels');
    load('trainingData1','patchInfo');
    load('PCAhistData','trainingList_v2','testList_v2');
    FP_Img_Patch =[];
    for x=testLimits(1):testLimits(2)
        curImg = testPatchInfo(x);
        for y=1:numel(curImg.patchData)
           trueLabel = curImg.patchData(y).patchLabel;
           disp([x y])
           FP_Img_Patch = [FP_Img_Patch ; [x y trueLabel] ];
        end
    end
    FP_Img_Patch = [ f FP_Img_Patch predictedLabelList];
    %%
    fpindices = find(FP_Img_Patch(:,4)==1 & FP_Img_Patch(:,5)==-1); 
    FP_Plot = FP_Img_Patch(fpindices,1:3);
    %%
    [folder,files,users,color] =setDirs();
    a = FP_Plot(3:7,3);
    fa = FP_Plot(3:7,1);
    plotFPPatch(files,folder,testPatchInfo,52,a',fa');
%% Improve and eliminate FPs
        
        f= [];
%      %     %----------------- check values
      [predictedLabelList f] = svmclassify2(SVMStruct,testList_v2); 
      [p,n] = QuantTesting(testLabels,predictedLabelList);
      disp('......');
%           
  %     load('testdata3', 'predictedLabelList2');
% %      [p,n] = QuantTesting(testLabels,predictedLabelList);
%         
% 
         f = -f;
         k = sortrows(f);
% %   %   predictedLabelList = ones(size(temp));
        predictedLabelList = [];
        for r = 1: size(f,1)
%  %         
            if( f(r) < 0.011) % .6 && predictedLabelList2(r) == -1
                predictedLabelList(r) = -1;
            else
                predictedLabelList(r) = 1;
            end
        end
% %      
   	[p,n] = QuantTesting(testLabels,predictedLabelList);
%%
save('resultData2','predictedLabelList');
%%
%Throw fixation points after thresholding

load('resultData2','predictedLabelList');
load('testData1','testPatchInfo');
testLimits = [51 52];
throwFixPoints(testLimits,testPatchInfo,predictedLabelList);