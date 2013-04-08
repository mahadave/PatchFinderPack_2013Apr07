function [histograms] = getINTERPatchDistHistogram_v5(curImgPatchInfo,dims,NBins)

    boxSize=curImgPatchInfo.boxSize ;
    
    
    for k=1:length(curImgPatchInfo.patchData)
        patch = curImgPatchInfo.patchData(k).patch;
         [a b]=size(patch);
        if(a~=b)
           patch_res = imresize(patch_res,[max([a,b]) max([a,b])]);
        else
           patch_res = patch;
        end        
        descriptors(k).data = getSelfSimData_inter_tst(patch_res);            
    end
    
    histograms =[];
    L = numel(curImgPatchInfo.patchData);

    for i=1:L
            curPatchDescriptors = descriptors(i).data;
            neighbours =  findNeighbours_v2(i,2*boxSize,dims,L);
            
            curVal = [];

            for j=1:numel(neighbours)    
                nikat = neighbours(j);
                if (nikat>length(descriptors)) % if this neighbour exceeds the list of patches, skip
                   continue;
                end
                disp(['j = ',num2str(j),' neighbour = ',num2str(nikat)]);
                curNeighbourDescriptors = descriptors(nikat).data;  
                dResult = pdist2(curPatchDescriptors,curNeighbourDescriptors);
                dResultVect = nonzeros(triu(dResult)') ;
                
              
                clear dResult;
                curVal = [curVal; dResultVect];
                clear dResultVect;
            end
            
            histVals = hist(curVal,NBins);
            % normalize histogram here
            s = sum(histVals(:));
            if(s~=0)
                normalizedHist = histVals./s;
            else
                normalizedHist = histVals;
            end
            histograms = [histograms; normalizedHist ];    
    end
end