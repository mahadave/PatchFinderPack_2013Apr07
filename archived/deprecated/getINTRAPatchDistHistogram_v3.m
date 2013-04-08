function [histogram,selected] = getINTRAPatchDistHistogram_v3(patch)

        histogram =[]; selected=[];
        [descriptors] = getSelfSimData_1(patch);

         mat = pdist2(descriptors,descriptors);
         mat = mat./max(mat(:)); % normalized distance / dissimilarity
         dissimilarityMatrix = mat;

         
        L = size(dissimilarityMatrix,1);
        NBins=20;
% 
%         disp(['LL = ',num2str(L)]);
%         
        vals=[];
        for i=1:L
            %disp(['index',num2str(i)]);disp(size(patch)); 
            neighbours =  findNeighbours_v3(i,size(patch),L);
            %disp(neighbours);
            curVal = dissimilarityMatrix(i,neighbours);
%             disp('pixel')
%             disp(i)
%             disp('row')
%             disp(curVal)
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

    