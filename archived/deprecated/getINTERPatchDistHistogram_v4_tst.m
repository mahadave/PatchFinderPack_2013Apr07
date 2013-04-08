
function [histograms] = getINTERPatchDistHistogram_v4_tst(curImgPatchInfo,dims)

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
    NBins=20;

    for i=1:L
            curPatchDescriptors = descriptors(i).data;
            neighbours =  findNeighbours_v2(i,2*boxSize,dims,L);
            
            curVal = [];
            
            for j=1:numel(neighbours)    
                curNeighbourDescriptors = descriptors(neighbours(j)).data;  
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
            end
            histograms = [histograms; normalizedHist ];    
    end
end