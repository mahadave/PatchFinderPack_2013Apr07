function SVMStruct = trainSVM(trainingList,trainingLabels)


    SMO_OptsStruct = svmsmoset('MaxIter', 150000);
    
    disp(size(trainingList));
    disp(size(trainingLabels));
    SVMStruct = svmtrain(trainingList,trainingLabels,'Kernel_Function','rbf','RBF_Sigma',10,'Method', 'SMO', 'SMO_Opts', SMO_OptsStruct);
    disp('SVM training complete !')
end