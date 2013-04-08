%%This file runs the sift algorithm
%% bag is a patch and the instances are the randomly selected points 
% fischer extracts a feature vector for each bag based on the universal GMM
% trained using all the instances

startUp();
clear all;
[folder,files,users,color] =setDirs();
showSettings();

%% --------------------------TRAIN----------------------------------------

%decide number of files to run for


%% -- Training data-1

trainingLimits = [1 50];

predictedLabelList2 = [];

NPoints = 25;

close all
[pointList,trainingLabels,indexList] = trainingDataAndLabels_v7(trainingLimits,NPoints);
info=['using image indices : ',num2str(trainingLimits) ];

%save('trainingData1','pointList','trainingLabels', 'indexList','predictedLabelList2','info');
save('common','NPoints');

%% -- Build Gaussian Mixture Model

disp('building gmm...');
clear all;
load('trainingData1','pointList');
k=5;
[GMMList,gmm] = makeGMM(pointList,k);

%save('trainingData2','gmm','GMMList'); 

%% -- Extract Fisher Feature Vectors
  
disp('extracting fishers...');
clear all;
load('trainingData1','indexList','trainingLabels');
load('trainingData2','gmm','GMMList')
[fishers] = extractFishers(GMMList, gmm, indexList);
[trainingList,trainingLabels] = prepTraining(fishers,trainingLabels);

%save('trainingData3','trainingList','trainingLabels','fishers');
%%
% 
% load('trainingData1','predictedLabelList2');
% 
% [p,n] = QuantTesting(trainingLabels,predictedLabelList2);

%% -------------------------- TANHAYEE -------------------------------------

%% --------------------------TEST-------------------------------------------


%% -- Test data-1
NPoints = 25;
testLimits = [81 90];
slider = 16;
%
[testPointList,testLabels,indexListTesting] = testingDataAndLabels_v6(testLimits,NPoints);
%[testPointList,testLabels,indexListTesting,centerList] = testingDataAndLabels_v8_slidingwindow(testLimits,NPoints,slider);
testInfo = ['testing from ',num2str(testLimits)];
save('testData1','testPointList','testLabels','indexListTesting','testLimits','testInfo'); %'predictedLabelList2',

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

% clear all;
% load('trainingData3','trainingList','trainingLabels');
% load('testData1','testLabels');
% load('testData2','testList');
% 
% pList = [];
% nList = [];
% indicesSelectedList = [];
% iList=[];
% fr =0.6;
% iterations = 1;
% 
% save('common','fr','iterations');
% saveIndex = 1;
%  NRandomTimes=50;
%  for outer=1:NRandomTimes
%     
%    for iterations = 1:10
% 	%%UNDERSAMPLING--------------------------------------------------------
% 	%%----
%     for fr =0.6:0.1:1
% %     disp(['random selection ',num2str(outer)])
%  	[indices,newUnderTrainList,newUnderLabelList,posTrainList, posLabelList,downTrainList,downLabelList,negTrainList,N] = randomSelection(trainingList,trainingLabels,fr);
%         
%     %----------------train and predict using new classifier 
%     [SVMStruct,f] = boosting_v3(posTrainList,downTrainList,posLabelList,downLabelList,negTrainList,N,fr,iterations);
% 	%------------------ validate here
% 	predictedLabelList = svmclassify(SVMStruct,testList);
%     %----------------- check values
% 	[p,n] = QuantTesting(testLabels,predictedLabelList);
%     %---------------- keep track of values for each random selection
% 	pList = [pList;p]; 	nList = [nList;n];
%  %%   
% %     load('testdata1', 'predictedLabelList2');
% %     [p,n] = QuantTesting(testLabels,predictedLabelList2);
%     %%
%      if(p>=0.7 && n>=0.3)
%          indicesSelectedList(saveIndex).indices = indices;
%          indicesSelectedList(saveIndex).p = p;
%          indicesSelectedList(saveIndex).n = n;
%          indicesSelectedList(saveIndex).iterations = iterations;
%          indicesSelectedList(saveIndex).fr = fr;
%          saveIndex = saveIndex + 1;
%          iList = [iList ; [iterations fr]];
%          %save('resultData1','indicesSelectedList');
%      end
%     end
%   end
%     
%  end
 
%%
%Extract Self Similarity---------------------------------------------------
NPoints = 25;
testLimits = [51 80];

%

[testPointList,testLabels,indexListTesting,corrMax,predictedLabelList2] = testingDataAndLabels_v7(testLimits,NPoints);
testInfo = ['testing from ',num2str(testLimits)];
%save('testData3','corrMax','predictedLabelList2');

%%
%Code to reproduce accuracy------------------------------------------------
 retrieveIndex = 30;
% 
 load('trainingData3','trainingList','trainingLabels');
 load('testData1','testLabels');
 load('testData2','testList');
 load('resultData1','indicesSelectedList');
% 
 fr = indicesSelectedList(retrieveIndex).fr;
 iterations = indicesSelectedList(retrieveIndex).iterations;
 indices = indicesSelectedList(retrieveIndex).indices;
 
 [posTrainList,posLabelList] = getPositiveData(trainingList,trainingLabels);
 [negTrainList,negLabelList]= getNegativeData(trainingList,trainingLabels);
 [M,N] = getMN(posTrainList,negTrainList,fr);
 
 downTrainList = negTrainList(indices,:);
 downLabelList = negLabelList(indices);
 
 [SVMStruct,f] = boosting_v3(posTrainList,downTrainList,posLabelList,downLabelList,negTrainList,N,fr,iterations);
 
 	[predictedLabelList m]= svmclassify2(SVMStruct,testList);
     %----------------- check values
 	[p,n] = QuantTesting(testLabels,predictedLabelList);
%% Improve and eliminate FPs

     load('trainingData3','trainingList','trainingLabels');
     load('testData1','testLabels');
     load('testData2','testList');
     load('resultData1','indicesSelectedList');
  	 f= [];
% %      %     %----------------- check values
 %       SVMStruct = trainSVM(trainingList,trainingLabels);
       [predictedLabelList f] = svmclassify2(SVMStruct,testList); 
      [p,n] = QuantTesting(testLabels,predictedLabelList);
% %           
%        load('testdata3', 'predictedLabelList2');
% % %      [p,n] = QuantTesting(testLabels,predictedLabelList);
% %         
% % 
          f = -f;
          k = sortrows(f);
% % %   %   predictedLabelList = ones(size(temp));
%         predictedLabelList = [];
%         for r = 1: size(f,1)
% %  %         
%             if( f(r) < 0) % .6 && predictedLabelList2(r) == -1
%                 predictedLabelList(r) = -1;
%             else
%                 predictedLabelList(r) = 1;
%             end
%         end
% % %      
%    	[p,n] = QuantTesting(testLabels,predictedLabelList);
