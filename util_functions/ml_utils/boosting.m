function [SVMStruct,f] = boosting(posTrainList,downTrainList,posLabelList,downLabelList,negTrainList,N,fr,iterations)
    % version : _v3 , Monday 8 April 2013,
    % author=akshat dave
    for v = 1:iterations
    
%     downLabelList = -1 * ones(size(downTrainList,1),1);
    newUnderTrainList = [];
    newUnderLabelList = [];
    
	newUnderTrainList = [posTrainList; downTrainList];
	newUnderLabelList = [posLabelList downLabelList];
    
     SVMStruct = trainSVM(newUnderTrainList,newUnderLabelList);
	[predictedLabelList f]= svmclassify2(SVMStruct,negTrainList);
	f = -f;
    downTrainList  = updateDownTrainList(f,N,negTrainList);
    end
 

