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
	ix = find(trainingLabels==1);
	indices = find(trainingLabels==1);
	posTrainList = trainingList(indices,:);
	posLabelList = trainingLabels(indices);

	indices = find(trainingLabels==-1);
	negTrainList = trainingList(indices,:);
	negLabelList = trainingLabels(indices);

	M = size(negTrainList,1);
	N = 0.5 * (size(posTrainList,1));
    indices = [];
    khali = [];
    khali = 1:M;
    khali=randperm(M);
    khali=khali(1:N);
    indices = khali;
% 	indices = uint8(M*rand(1,N)+1);
    indicesSelectedList = [indicesSelectedList ; indices];
    
	% Limit = numel(ix);
	% indices =uint8(setdiff((Limit-1)*rand([1,0.3*size(posTrainList,1)])+1,ix));


	%%
% 	downTrainList = [];
% 	downLabelList = [];
	downTrainList = negTrainList(indices,:);
	downLabelList = negLabelList(indices);


	for v = 1:1

	newUnderTrainList = [posTrainList; downTrainList];
% 	if (v>1)
% 		downLabelList = negLabelList(indices);
% 	end
	newUnderLabelList = [posLabelList'; downLabelList'];

	SVMStruct = trainSVM(newUnderTrainList,newUnderLabelList);

	[predictedLabelList f]= svmclassify2(SVMStruct,negTrainList);
	f = -f;

	f_p = [];
	f_n = [];
	temp = [];
	temp2 = [];
	downTrainList = [];

	posIndices = find (f >= 0);
	f_p = [f(posIndices) posIndices];

	negIndices = find (f < 0);
	f_n = [f(negIndices) negIndices];

	f_p = sortrows(f_p);
	f_n = sortrows(f_n);

	if(size(f_p,1)<N)
		 temp = negTrainList(f_p(:,2),:);
		 s = N - size(temp,1);
		 downTrainList = [temp ; negTrainList(f_n(end - (s-1): end,2),:)];
	else
		downTrainList = negTrainList(f_p(end-(N-1):end,2),:);
	end


	  newUnderTrainList = [];
	  newUnderLabelList = [];
	% if(size(f_p,1) == N)
	%     downTrainList = f_p;
	% elseif(size(f_p,1) < N)
	%     temp = f_p;
	%     sortrows(f_n);
	%     temp2 = f_n(1: (N-size(f_p,1)));
	%     downTrainList = [temp : temp2];
	% elseif(size(f_p,1) > N)
	%     sortrows(f_p);
	%     downTrainList = f_p((end-N):end);
	% end
	 end
	%%

	predictedLabelList = svmclassify(SVMStruct,testList);

	[p,n] = QuantTesting(testLabels,predictedLabelList);


	pList = [pList;p];
	nList = [nList;n];
	
end

for v = 1:5

	newUnderTrainList = [posTrainList; downTrainList];
% 	if (v>1)
% 		downLabelList = negLabelList(indices);
% 	end
	newUnderLabelList = [posLabelList'; downLabelList'];

	SVMStruct = trainSVM(newUnderTrainList,newUnderLabelList);

	[predictedLabelList f]= svmclassify2(SVMStruct,negTrainList);
	f = -f;

	f_p = [];
	f_n = [];
	temp = [];
	temp2 = [];
	downTrainList = [];

	posIndices = find (f >= 0);
	f_p = [f(posIndices) posIndices];

	negIndices = find (f < 0);
	f_n = [f(negIndices) negIndices];

	f_p = sortrows(f_p);
	f_n = sortrows(f_n);

	if(size(f_p,1)<N)
		 temp = negTrainList(f_p(:,2),:);
		 s = N - size(temp,1);
		 downTrainList = [temp ; negTrainList(f_n(end - (s-1): end,2),:)];
	else
		downTrainList = negTrainList(f_p(end-(N-1):end,2),:);
	end


	  newUnderTrainList = [];
	  newUnderLabelList = [];
	% if(size(f_p,1) == N)
	%     downTrainList = f_p;
	% elseif(size(f_p,1) < N)
	%     temp = f_p;
	%     sortrows(f_n);
	%     temp2 = f_n(1: (N-size(f_p,1)));
	%     downTrainList = [temp : temp2];
	% elseif(size(f_p,1) > N)
	%     sortrows(f_p);
	%     downTrainList = f_p((end-N):end);
	% end
	 end