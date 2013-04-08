function [histogram,selected] = getINTRAPatchDistHistogram_v4(patch)

        histogram =[]; 
        [descriptors] = getSelfSimData_intra(patch);
        
         mat = pdist2(descriptors,descriptors);
         mat = mat./max(mat(:)); % normalized distance / dissimilarity
         dissimilarityMatrix = mat;

        L = size(dissimilarityMatrix,1);
        NBins=20;
        vals=[];
        for i=1:L
            neighbours =  findNeighbours_v3(i,size(patch),L);
            pruned_neighbours = neighbours(neighbours(:)<=L & neighbours(:)>0);
            disp(i)
            disp(pruned_neighbours);
            curVal = dissimilarityMatrix(i,pruned_neighbours);
            curVal = mean(curVal(:));
            vals = [vals;curVal];
        end
        
        [B,IX] = sort(vals);
        selected=IX(end-9:end);
        [array] = makeArray_v2(size(patch,1),size(patch,2));
        array = [array [1:size(patch,1)*size(patch,2)]'];
        
        selected=array(selected,1:2);
        
        histVals = hist(vals,NBins);
        % normalize histogram here
        histogram = [histogram; histVals ];
        normalizedHist = histogram./sum(histogram);

        %bar(normalizedHist)
    
end

    