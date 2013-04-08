%%This file runs the sift algorithm
    % version : _v4_shuddh , Monday 8 April 2013,
    % author=akshat dave
%% bag is a patch and the instances are the randomly selected points 
% fischer extracts a feature vector for each bag based on the universal GMM
% trained using all the instances


%Note testData is validation/training set only which is used to improve accuracy
% testFinalData is test set on which the    actual and final accuracies are
% noted
% so while testing you will need to replace testData with testFinalData and
% vice versa until code is made cleaner

clear all;
setUpPaths;
[META]=startUp(); 

%% --------------------------TRAIN----------------------------------------

% -- Training data-1

%[pointList,trainingLabels,patchInfo] = trainingDataAndLabels_v12_intraPatchInterPatch(META);
disp(' ----- JEDI TRAINING ------'); 
tic; [ListSet,patchInfo] = trainingDataAndLabels(META,META.trainingLimits); toc;
disp(' ----- /TRAINING COMPLETE ------'); 
trainingLabels=ListSet.labels;
if(META.SAVE)
    info=['using image indices : ',num2str(META.trainingLimits)];
    save('./SAVEDATA/trainingData1','trainingLabels', 'patchInfo','info','META');
end
%% -- Concate Training Intra and Inter
clear all;
META=startUp();
load('./SAVEDATA/trainingData1', 'patchInfo','trainingLabels');
disp(' ----- CONCAT FEATURE VECTOR ------'); 
[trainingList,trainingLabels] = concatInterIntra(patchInfo,trainingLabels,META.USE_INTER);
disp(' ----- /CONCAT COMPLETE ------'); 
if(META.SAVE)
    save('./SAVEDATA/trainingConcatData', 'trainingList','trainingLabels');%,'histVectorTrain','histVectorTrainIntra');
end
%% -------------------------- Validation Data Preparation -------------------------------------------
clear all;
% -- Generate Validation Data
META=startUp();
disp(' ----- LA VALIDATION ------'); 
[valListSet,testPatchInfo] = validatingDataAndLabels(META);
disp(' ----- /VALIDATION COMPLETE ------'); 
testPointList=valListSet.pointList; testLabels=valListSet.labels; 
save('./SAVEDATA/validationData','META','testPointList','testLabels','testPatchInfo'); %'predictedLabelList2',
%% -- Concat validation Intra and Inter
clear all;
META=startUp();
disp(' ----- CONCAT FEATURE VECTOR FOR TEST ------'); 
load('./SAVEDATA/validationData', 'testPatchInfo','testLabels','META');
[testList,testLabels] = concatInterIntra(testPatchInfo,testLabels,META.USE_INTER);
disp(' ----- /CONCAT VECTOR FOR TEST COMPLETE ------'); 
save('./SAVEDATA/validationConcatData', 'testList','testLabels');



%% -------------------------- Test Data Preparation -------------------------------------------

%% --Generate Test data_1
META=startUp();
disp(' ----- TESTING TIME ------'); 
[testListSet,testFinalPatchInfo] = testingDataAndLabels(META);
disp(' ----- /TESTING COMPLETE ------'); 
testFinalPointList=testListSet.pointList; testFinalLabels=testListSet.labels; 
%testFinalInfo = ['testing from ',num2str(testLimits2)];
save('./SAVEDATA/testFinalData1','META','testFinalPointList','testFinalLabels','testFinalPatchInfo'); %'predictedLabelList2',

%% --Concat test Intra and Inter
clear all;
META=startUp();
load('./SAVEDATA/testFinalData1', 'testFinalPatchInfo','testFinalLabels','META');
disp(' ----- CONCAT TEST FEATURE VECTOR ------'); 
[testFinalList,testFinalLabels] = concatInterIntra(testFinalPatchInfo,testFinalLabels,META.USE_INTER);
disp(' ----- /CONCAT TEST FEATURE VECTOR ------'); 
save('./SAVEDATA/testConcatData', 'testFinalList','testFinalLabels');

%--------------- CHANGED TILL HERE ----------------------------------------

%% -- Replace NANs with zeros
%{
clear all;
load('./SAVEDATA/trainingConcatData', 'trainingList','trainingLabels');%,'histVectorTrain','histVectorTrainIntra');
load('./SAVEDATA/validationConcatData', 'testList','testLabels');
load('./SAVEDATA/testConcatData', 'testFinalList','testFinalLabels');

trainingList(isnan(trainingList)) = 0; 
testList(isnan(testList)) = 0; 
testFinalList(isnan(testFinalList)) = 0; 

save('./SAVEDATA/trainingData4', 'trainingList','trainingLabels');%,'histVectorTrain','histVectorTrainIntra');
save('./SAVEDATA/validationConcatData', 'testList','testLabels');
save('./SAVEDATA/testConcatData', 'testFinalList','testFinalLabels');
%}
%% -- Random selection with boosting

clear all;
load('./SAVEDATA/trainingData1','pointList', 'patchInfo');
load('./SAVEDATA/trainingConcatData', 'trainingList','trainingLabels');%,'histVectorTrain','histVectorTrainIntra');
load('./SAVEDATA/validationData','META','testPointList','testPatchInfo');
load('./SAVEDATA/testFinalData1','META','testFinalPointList','testFinalPatchInfo');
load('./SAVEDATA/validationConcatData', 'testList','testLabels');
load('./SAVEDATA/testConcatData', 'testFinalList','testFinalLabels');
pList = [];
nList = [];
indicesSelectedList = [];
iList=[];
fr =1; %what fraction of positive samples do we want negative to be
iterations = 1; %for boosting
NRandomTimes=10; % for selection of best random selection
save('common','fr','iterations');
saveIndex = 1;
 
 for outer=1:NRandomTimes
    
   for iterations = 1:1
	%%UNDERSAMPLING--------------------------------------------------------
	%%----
    for fr =1:1
%     disp(['random selection ',num2str(outer)])
 	[indices,posTrainList, posLabelList,downTrainList,downLabelList,negTrainList,N] = randomSelection(trainingList,trainingLabels,fr);   
    %----------------train and predict using new classifier 
    [SVMStruct,f] = boosting_v3(posTrainList,downTrainList,posLabelList,downLabelList,negTrainList,N,fr,iterations);
	%------------------ validate here
	predictedLabelList = svmclassify(SVMStruct,testList);
    %----------------- check values
	[p,n] = QuantTesting(testLabels,predictedLabelList);
    %---------------- keep track of values for each random selection
	pList = [pList;p]; 	nList = [nList;n];
      
    if(p>=0.7 && n>=0.3)
         indicesSelectedList(saveIndex).indices = indices;
         indicesSelectedList(saveIndex).p = p;
         indicesSelectedList(saveIndex).n = n;
         indicesSelectedList(saveIndex).iterations = iterations;
         indicesSelectedList(saveIndex).fr = fr;
         saveIndex = saveIndex + 1;
         iList = [iList ; [iterations fr]];
         save('./SAVEDATA/resultData1','indicesSelectedList');
     end
    end
  end
    
 end

%%
%Code to reproduce accuracy------------------------------------------------

clear all
retrieveIndex = 3;
load('./SAVEDATA/trainingConcatData','pointList', 'patchInfo');
load('./SAVEDATA/trainingData4', 'trainingList','trainingLabels');%,'histVectorTrain','histVectorTrainIntra');
load('./SAVEDATA/validationData','META','testPointList','testPatchInfo');
load('./SAVEDATA/testFinalData1','META','testFinalPointList','testFinalPatchInfo');
load('./SAVEDATA/validationConcatData', 'testList','testLabels');
load('./SAVEDATA/testConcatData', 'testFinalList','testFinalLabels');
load('./SAVEDATA/resultData1','indicesSelectedList');
fr = indicesSelectedList(retrieveIndex).fr;
iterations = indicesSelectedList(retrieveIndex).iterations;
indices = indicesSelectedList(retrieveIndex).indices;
[negTrainList,negLabelList]= getNegativeData(trainingList,trainingLabels);
[posTrainList,posLabelList]= getPositiveData(trainingList,trainingLabels);
N = uint16(round(fr * (size(posTrainList,1))));
downTrainList = negTrainList(indices,:);
downLabelList = negLabelList(indices);
%%
[SVMStruct,f] = boosting_v3(posTrainList,downTrainList,posLabelList,downLabelList,negTrainList,N,fr,iterations);
%%
	[predictedLabelList f]= svmclassify2(SVMStruct,testFinalList);%change here
    %----------------- check values
	[p,n] = QuantTesting(testFinalLabels,predictedLabelList); %change here
    %%
    %To plot
   
    testLimits = [50 80];
    load('./SAVEDATA/validationData','testPatchInfo');
    load('./SAVEDATA/trainingData3','trainingList','trainingLabels');
    load('./SAVEDATA/trainingData1','patchInfo');
    load('./SAVEDATA/PCAhistData','trainingList','testList');
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
%% Improve and eliminate FPs i.e. thresholding   
      f= [];
      TPR = [];
      FPR = [];
      [predictedLabelList f] = svmclassify2(SVMStruct,testFinalList); %change here
      [p,n] = QuantTesting(testFinalLabels,predictedLabelList); %change here
      disp('......');
      
         f = -f;
         k = sortrows(f);
        predictedLabelList = [];
        for thres = -0.3:0.01:0.3
            for r = 1: size(f,1)      
                if( f(r) < 0.18) %change threshold here
                    predictedLabelList(r) = -1;
                else
                    predictedLabelList(r) = 1;
                end
            end
           [p,n] = QuantTesting(testFinalLabels,predictedLabelList); %change this
           TPR = [p TPR];
           FPR = [1-n FPR];
           
        end


save('./SAVEDATA/resultData2','predictedLabelList');
%save('ROC3_Inter','FPR','TPR');%change this
%%
clear all;
load('./SAVEDATA/ROC3_Inter','FPR','TPR');
stem(FPR,TPR,'LineStyle','none');