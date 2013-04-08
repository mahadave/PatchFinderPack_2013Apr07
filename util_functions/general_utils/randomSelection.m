function [indices,posTrainList, posLabelList,downTrainList ,downLabelList,negTrainList,N] = randomSelection(trainingList,trainingLabels,fr)

    
    [posTrainList,posLabelList] = getPositiveData(trainingList,trainingLabels);
    [negTrainList,negLabelList]= getNegativeData(trainingList,trainingLabels);

    [M,N] = getMN(posTrainList,negTrainList,fr);
    
    khali=randperm(M);
    khali=khali(1:N);
    indices = khali;
    
    %---------------random selection from negatives
	downTrainList = negTrainList(indices,:);
	downLabelList = negLabelList(indices);
    
end