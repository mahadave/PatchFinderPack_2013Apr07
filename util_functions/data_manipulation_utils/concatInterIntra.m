function [histList,trainingLabels] = concatInterIntra(patchInfo,trainingLabels,USE_INTER)
    
	histList = [];
    continueListLabels = [];% continueListLabels is to skip the labels of those intra patches which we are not selecting 
    k = 1;
    N = numel(patchInfo);
    	for i=1:N
            
            continueList = []; %to put only those patches whose intra patch histogram is > 36
            cur = patchInfo(i).patchData;
            tmp=[];
            for j=1:numel(cur)
                
                if size(cur(j).intraPatchHist,2) < 36     
                    k= k+1;
                    continue;
                end
                tmp = [tmp ; cur(j).intraPatchHist];
                continueList = [continueList j];
                continueListLabels = [continueListLabels k];
                k = k+1;
            end
            
           if(USE_INTER == 1)           
                interTmp = patchInfo(i).interPatchHist(continueList,:);
                histList = [histList ; [interTmp tmp] ]; % concat here
           else
               histList = [histList; tmp];
           end
        end
    
        trainingLabels = trainingLabels(continueListLabels);
 end