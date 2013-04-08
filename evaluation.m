%version : _v0 evaluation 
% script to take off evaluation after datastructures are ready

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
load('./SAVEDATA/trainingData','patchInfo');
load('./SAVEDATA/trainingConcatData', 'trainingList','trainingLabels');%,'histVectorTrain','histVectorTrainIntra');
load('./SAVEDATA/validationData','META','testPatchInfo');
load('./SAVEDATA/testData','META','testFinalPointList','testFinalPatchInfo');
load('./SAVEDATA/validationConcatData', 'testList','testLabels');
load('./SAVEDATA/testConcatData', 'testFinalList','testFinalLabels');
%loaded all

pList = [];
nList = [];
indicesSelectedList = [];
iList=[];
fr =1; %what fraction of positive samples do we want negative to be
iterations = 1; %for boosting
NRandomTimes=10; % for selection of best random selection
save('./SAVEDATA/common','fr','iterations');
saveIndex = 1;
 
 for outer=1:NRandomTimes
    
   for iterations = 1:1
	%%UNDERSAMPLING--------------------------------------------------------
	%%----
    for fr =1:1
%     disp(['random selection ',num2str(outer)])
 	[indices,posTrainList, posLabelList,downTrainList,downLabelList,negTrainList,N] = randomSelection(trainingList,trainingLabels,fr);   
    %----------------train and predict using new classifier 
    [SVMStruct,f] = boosting(posTrainList,downTrainList,posLabelList,downLabelList,negTrainList,N,fr,iterations);
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
load('./SAVEDATA/trainingData','patchInfo');
load('./SAVEDATA/trainingConcatData', 'trainingList','trainingLabels');%,'histVectorTrain','histVectorTrainIntra');
load('./SAVEDATA/validationData','META','testPatchInfo');
load('./SAVEDATA/testData','META','testFinalPointList','testFinalPatchInfo');
load('./SAVEDATA/validationConcatData', 'testList','testLabels');
load('./SAVEDATA/testConcatData', 'testFinalList','testFinalLabels');
load('./SAVEDATA/resultData1','indicesSelectedList');

%%
fr = indicesSelectedList(retrieveIndex).fr;
iterations = indicesSelectedList(retrieveIndex).iterations;
indices = indicesSelectedList(retrieveIndex).indices;
[negTrainList,negLabelList]= getNegativeData(trainingList,trainingLabels);
[posTrainList,posLabelList]= getPositiveData(trainingList,trainingLabels);
N = uint16(round(fr * (size(posTrainList,1))));
downTrainList = negTrainList(indices,:);
downLabelList = negLabelList(indices);
%%
[SVMStruct,f] = boosting(posTrainList,downTrainList,posLabelList,downLabelList,negTrainList,N,fr,iterations);
%%
	[predictedLabelList f]= svmclassify2(SVMStruct,testFinalList);%change here
    %----------------- check values
	[p,n] = QuantTesting(testFinalLabels,predictedLabelList); %change here
    %%
    %To plot
   
    testLimits = [50 80];
    load('./SAVEDATA/validationData','testPatchInfo');
    load('./SAVEDATA/trainingData3','trainingList','trainingLabels');
    load('./SAVEDATA/trainingData','patchInfo');
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