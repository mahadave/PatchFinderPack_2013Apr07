function [histograms] = getINTRAPatchDistHistogram(patch)

        histograms =[];
        [descriptors] = getSelfSimData_1(patch);

         mat = pdist2(descriptors,descriptors);
         mat = mat./max(mat(:)); % normalized distance / dissimilarity
         dissimilarityMatrix = mat;
         
         
        L = size(dissimilarityMatrix,1);
        NBins=20;

        for i=1:L
            curVal = dissimilarityMatrix(i,:);
            histVals = hist(curVal,NBins);
            % normalize histogram here
            normalizedHist = histVals./sum(histVals);
            histograms = [histograms; normalizedHist ];
        end
    
end