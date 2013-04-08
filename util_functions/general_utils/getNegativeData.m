function [negTrainList,negLabelList]= getNegativeData(trainingList,trainingLabels)


	indices = find(trainingLabels==-1);
	negTrainList = trainingList(indices,:);
	negLabelList = trainingLabels(indices);

    
end

