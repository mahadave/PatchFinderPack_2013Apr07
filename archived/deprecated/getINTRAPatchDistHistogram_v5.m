function [histogram] = getINTRAPatchDistHistogram_v5(patch)
% version : _v5 , added : Monday 8-Apr-2013 , author = akshat dave
% create intra patch self dissimilarity histogram
        [descriptors] = getSelfSimData_intra(patch);     
        % normalize histogram here
        histogram = 1-mean(descriptors);    
end

    