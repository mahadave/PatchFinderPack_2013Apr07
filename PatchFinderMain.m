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
disp(' ----- JEDI TRAINING ------'); 
tic; [ListSet,patchInfo] = trainingDataAndLabels(META,META.trainingLimits); toc;
disp(' ----- /TRAINING COMPLETE ------'); 

trainingLabels=ListSet.labels;
if(META.SAVE) 
    save('./SAVEDATA/trainingData','trainingLabels', 'patchInfo','META'); 
end
%% -- Concatenate feature vector Training Intra and Inter
clear all;
META=startUp();
load('./SAVEDATA/trainingData', 'patchInfo','trainingLabels');

disp(' ----- CONCAT FEATURE VECTOR ------'); 
[trainingList,trainingLabels] = concatInterIntra(patchInfo,trainingLabels,META.USE_INTER);
disp(' ----- /CONCAT COMPLETE ------'); 
if(META.SAVE) 
    save('./SAVEDATA/trainingConcatData', 'trainingList','trainingLabels');
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
save('./SAVEDATA/testData','META','testFinalPointList','testFinalLabels','testFinalPatchInfo'); %'predictedLabelList2',

%% --Concat test Intra and Inter
clear all;
META=startUp();
load('./SAVEDATA/testData', 'testFinalPatchInfo','testFinalLabels','META');
disp(' ----- CONCAT TEST FEATURE VECTOR ------'); 
[testFinalList,testFinalLabels] = concatInterIntra(testFinalPatchInfo,testFinalLabels,META.USE_INTER);
disp(' ----- /CONCAT TEST FEATURE VECTOR ------'); 
save('./SAVEDATA/testConcatData', 'testFinalList','testFinalLabels');

%--------------- CHANGED TILL HERE ----------------------------------------

%%
if META.EVAL
    evaluation;
end