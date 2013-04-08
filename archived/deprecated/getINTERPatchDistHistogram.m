function [histograms] = getINTERPatchDistHistogram(patchData)

    boxSize=patchData.boxSize ;
    resized_image = ones([256 256]);
    for k=1:numel(patchData.patchData)
        patch = patchData.patchData(k).patch;
        descriptors(k).data = getSelfSimData_2(patch);

%          mat = pdist2(descriptors,descriptors);
%          mat = mat./max(mat(:)); % normalized distance / dissimilarity
%          dissimilarityMatrix = mat;
    
    end
    
        histograms =[];
        L = numel(patchData.patchData);

        NBins=20;

    for i=1:L
            curPatchDescriptors = descriptors(i).data;
            neighbours =  findNeighbours(i,2*boxSize,resized_image,L);
           curVal = [];
            for j=1:numel(neighbours)
                 curNeighbourDescriptors = descriptors(neighbours(j)).data;                
                corrResult = SAD(curPatchDescriptors,curNeighbourDescriptors);
                curVal = [curVal corrResult];
            end
            
%             disp('neigh');
%             disp(neighbours)
            histVals = hist(curVal,NBins);
            % normalize histogram here
            normalizedHist = histVals./sum(histVals(:));
            histograms = [histograms; normalizedHist ];
    
    end

    
end