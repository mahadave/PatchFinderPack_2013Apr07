function [posTrainList,posLabelList] = getPositiveData(trainingList,trainingLabels)

	indices = find(trainingLabels==1);
	posTrainList = trainingList(indices,:);
	posLabelList = trainingLabels(indices);
    
end