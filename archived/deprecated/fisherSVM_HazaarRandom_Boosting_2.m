%%This file runs the sift algorithm
%% bag is a patch and the instances are the randomly selected points 
% fischer extracts a feature vector for each bag based on the universal GMM
% trained using all the instances
%

startUp();

%--------------------------TRAIN-------------------------------------------
%---
%-


%%

[folder,files,users,color] =setDirs();

%%
%decide number of files to run for
trainingLimits = [1 50];

%%


D=[];

labelList=[];
testLabels=[];

close all

    %%---------------------------------------------------------------------
    %%--
    %%sift computation params
    %%

    [pointList,trainingLabels,indexList] = trainingDataAndLabels(trainingLimits);
    
    save('trainingData1','pointList','trainingLabels', 'indexList');
%%
% 
% D=1; %divisions of data
% trainingLowerLimit = 1;
% trainingUpperLimit = numel(labelList)/D;
%%
    k=5;
    [GMMList,gmm] = makeGMM(pointList,k);
    save(['GMM_',num2str(k)],'gmm'); 
%%
    
    [fishers] = extractFishers(GMMList, gmm, indexList);
    
%%
 [trainingList,trainingLabels] = prepTraining(fishers,trainingLabels);
 info=['using image indices : ',num2str(trainingLimits) ];
 save('trainingData2','trainingList','info')
%%
    

    load trainingData2
    SVMStruct = trainSVM(trainingList,trainingLabels);
    save('SVMStruct','SVMStruct');

%%

%--------------------------TEST-------------------------------------------
%---
%-

testLimits = [51 80];
[testPointList,testLabels,indexListTesting] = testingDataAndLabels(testLimits);
testInfo = ['testing from ',num2str(testLimits)];
save('testData1','testPointList','testLabels','indexListTesting','testLimits','testInfo');

%%

load gmm_5
testPointList = double(testPointList);
[fishers]=extractFishers(testPointList,gmm,indexListTesting);
testList = fishers;
save('testData2','testList');
%%
predictedLabelList = svmclassify(SVMStruct,testList);
save('testData3','predictedLabelList');
%%
[p,n] = QuantTesting(testLabels,predictedLabelList);
%% small test code


%% expts

indices = find(trainingLabels==1);
posList = trainingList(indices,:);
%size(posList)

repList = repmat(posList,[15 1]);
disp(size(repList))

%%
newTrainingList = [trainingList ; repList];

newLabelList    = [trainingLabels ;ones(1,size(repList,1))'];

save('balanced','newTrainingList','newLabelList');
%%
SVMStruct = trainSVM(newTrainingList,newLabelList);
%%
predictedLabelList = svmclassify(SVMStruct,testList);
[p,n] = QuantTesting(testLabels,predictedLabelList);
%%

pList = [];
nList = [];
indicesSelectedList = [];

NTimes=25;
for outer=1:NTimes
    
	%%UNDERSAMPLING------------------------------------------------------------
	[indices,posLabelList,negLabelList] = randomSelection(trainingList,trainingLabels); % select random indices
    indicesSelectedList = [indicesSelectedList ; indices];
    
	%
 	downTrainList = [];
 	downLabelList = [];

    %---------------random selection from negatives
	downTrainList = negTrainList(indices,:);
	downLabelList = negLabelList(indices);

    newUnderTrainList = [];
    newUnderLabelList = [];
	newUnderTrainList = [posTrainList; downTrainList];
	newUnderLabelList = [posLabelList'; downLabelList'];

    %----------------train and predict using new classifier 
% 	SVMStruct = trainSVM(newUnderTrainList,newUnderLabelList);
% 	[predictedLabelList f]= svmclassify2(SVMStruct,negTrainList);
	iterations = 7;
    N = 0.9 * (size(posTrainList,1));
    SVMStruct = boosting(posTrainList,downTrainList,posLabelList,downLabelList,negTrainList,N,iterations);

	%------------------ validate here
	predictedLabelList = svmclassify(SVMStruct,testList);

    %----------------- check values
	[p,n] = QuantTesting(testLabels,predictedLabelList);

    %---------------- keep track of values for each random selection
	pList = [pList;p];
	nList = [nList;n];
    
	
end

%deterrmine the best starting point for boosting here
%---------------------------------------
%getBest(pList,nList,indicesSelectedList); %%make this function/manual

%% proceed with boosting
downTrainList = negTrainList(indicesSelectedList(18,:),:);
iterations = 2;
SVMStruct2 = boosting(posTrainList,downTrainList,posLabelList,downLabelList,negTrainList,N,iterations);
 
%%
predictedLabelList = svmclassify(SVMStruct2,testList);

    %----------------- check values
[p,n] = QuantTesting(testLabels,predictedLabelList);