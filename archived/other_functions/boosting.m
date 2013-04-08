function [SVMStruct,f] = boosting(trainingList,trainingLabels,fr,iterations)

	  

      
    [posTrainList,posLabelList] = getPositiveData(trainingList,trainingLabels);
    [negTrainList,negLabelList]= getNegativeData(trainingList,trainingLabels);
    [M,N] = getMN(posTrainList,negTrainList,fr);
    
            downTrainList = negTrainList(:,:);
            downLabelList = negLabelList(:);

%         downTrainList = negTrainList(indices,:);
%         downLabelList = negLabelList(indices);

    for v = 1:iterations
    
    downLabelList = -1 * ones(size(downTrainList,1),1);
        
	newUnderTrainList = [posTrainList; downTrainList];
	newUnderLabelList = [posLabelList; downLabelList];
    
     SVMStruct = trainSVM(newUnderTrainList,newUnderLabelList);
	[predictedLabelList f]= svmclassify2(SVMStruct,negTrainList);
	f = -f;
    downTrainList  = updateDownTrainList(f,N,negTrainList);
    end
 

