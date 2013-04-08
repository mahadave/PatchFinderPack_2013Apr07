function [histograms] = getINTERPatchDistHistogram_v3(patchData,dims)

    boxSize=patchData.boxSize ;
    
    for k=1:numel(patchData.patchData)
        patch = patchData.patchData(k).patch;
        descriptors(k).data = getSelfSimData_inter(patch);    
    end
    
    histograms =[];
    L = numel(patchData.patchData);
    NBins=20;

    for i=1:L
            curPatchDescriptors = descriptors(i).data;
            neighbours =  findNeighbours_v2(i,2*boxSize,dims,L);
            curVal = [];
            
            for j=1:numel(neighbours)    
                curNeighbourDescriptors = descriptors(neighbours(j)).data;                            
                corrResult = SAD_v2(curPatchDescriptors,curNeighbourDescriptors);
                curVal = [curVal corrResult];
            end
            
            histVals = hist(curVal,NBins);
            % normalize histogram here
            normalizedHist = histVals./sum(histVals(:));
            histograms = [histograms; normalizedHist ];    
    end
end