function [histograms] = getINTERPatchDistHistogram_v2(patchData,dims)

    boxSize=patchData.boxSize ;
    
    for k=1:numel(patchData.patchData)
        patch = patchData.patchData(k).patch;
        descriptors(k).data = getSelfSimData_inter(patch);
        
 %      disp(['patch',num2str(k),'descriptors has size ... ',num2str(size(descriptors(k).data)),' ',num2str(size(patch))]);
            

%          mat = pdist2(descriptors,descriptors);
%          mat = mat./max(mat(:)); % normalized distance / dissimilarity
%          dissimilarityMatrix = mat;
    
    end
    
        histograms =[];
        L = numel(patchData.patchData);
        disp(['LL = ',num2str(L)]);

        NBins=20;

    for i=1:L
            curPatchDescriptors = descriptors(i).data;
 %           disp(i);
            neighbours =  findNeighbours_v2(i,2*boxSize,dims,L);
%             disp(neighbours);
            
            curVal = [];
            
            for j=1:numel(neighbours)    
                   
               %  size(descriptors(neighbours(j)).data)
                 curNeighbourDescriptors = descriptors(neighbours(j)).data;                            
                corrResult = SAD_v2(curPatchDescriptors,curNeighbourDescriptors);
                curVal = [curVal corrResult];
            end
            
            %disp('neigh');
            %disp(neighbours)
            histVals = hist(curVal,NBins);
            % normalize histogram here
            normalizedHist = histVals./sum(histVals(:));
            histograms = [histograms; normalizedHist ];
    
    end

    
end