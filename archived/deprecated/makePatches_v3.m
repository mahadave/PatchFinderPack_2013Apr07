function [patchInfo,ListSet]=makePatches(KDE_STRUCT,ListSet,patchInfo,imgIndex,probThreshold,META)
% INPUTS 
% 1. resizd_image - the image on which the patches are to be extracted
% 2. boxSize - size of patches
% 3. densityFix - KDE of fixation points with same size as the
% resized_image
% 4. imgIndex - index of image whose patch is being made
% 5. META - for chechink meta data (e.g. META.USE_SELFSIM)
%
% OUTPUTS - 
% PatchInfo - Data structure containing the information about the image
% patches


    positives=0;
    negatives=0;
    patchIndex=1;
    show=META.show;
    boxShow=META.boxShow;
    debug=META.debug;
    NPoints=META.NPoints;
    indexList=ListSet.indexList;
    pointList=ListSet.pointList;
    labels=ListSet.labels;
    
    resized_image=KDE_STRUCT.resized_image;
    densityFix=KDE_STRUCT.densityFix;
    
    boxSize  = getPatchSize(resized_image,probThreshold,densityFix);
    step=2*boxSize;
    [LX LY]=size(resized_image);
    
    
    if(show==1 || boxShow==1)
        figure,imagesc(KDE_STRUCT.densityFix)
    end

    for i=1:step:LX
        for j=1:step:LY

            
            %----------- PATCH SLIPPING ---------------------------
            upperX = i+2*boxSize-1; % set cutting parameters
            lowerX=i;   
            lowerY=j;
            upperY=j+2*boxSize-1;
            [MX MY]=size(resized_image);
            if(upperY>MY) upperY=MY;  end
            if(upperX>MX) upperX=MX;    end

            patch = resized_image(lowerX:upperX,lowerY:upperY); % snip out the patch
            patchDensity = densityFix(lowerX:upperX,lowerY:upperY); % snip out the corresponding patch from the KDE
            meanDensity = mean(patchDensity(:)); % get the mean patch density

            if(size(patch,1)*size(patch,2)<NPoints)
                continue; % not ecough points
            end

            %----------- PATCH LABELING ---------------------------
            if(meanDensity>=probThreshold) 
                label = 1;
                positives=positives+1;
                visualizeBoxes(lowerX,lowerY,boxSize,META);
            else
                label =-1;
                negatives=negatives+1;
            end

           labels = [labels label]; % label the patch

           %------STORE INTO PATCH INFO --------
           
           patchInfo(imgIndex).patchData(patchIndex).patchLabel = label;
           patchInfo(imgIndex).patchData(patchIndex).patch = patch;
           patchInfo(imgIndex).sparsityRatio = positives/(positives+negatives);
           patchInfo(imgIndex).positiveCount = positives;
           patchInfo(imgIndex).negativeCount = (negatives);
           patchInfo(imgIndex).boxSize = boxSize;
           
           %----------- INTRA PATCH ---------------------------

           if META.USE_SELFSIM
                if(debug) disp('.... doing INTRA ....'); end
                patch_res = adjustPatch(patch);
                [histogram]= getINTRAPatchDistHistogram_v5(patch_res);
                patchInfo(imgIndex).patchData(patchIndex).intraPatchHist = histogram;
                if(debug) disp('.... \done INTRA ....'); end
           end
           
           patchIndex=patchIndex+1;
        end
    end

    patchInfo(imgIndex).indexList = indexList;        
    patchInfo(imgIndex).numPatches = (patchIndex-1);  
    
    
    %----------- INTER PATCH ---------------------------
    
    
    if META.USE_SELFSIM==1
        if(debug) disp('doing INTER'); end
        [SX SY] = size(resized_image);
        patchInfo(imgIndex).interPatchHist = getINTERPatchDistHistogram_v6(patchInfo(imgIndex),[SX SY],META.NBins);
        if(debug) disp('/done INTER'); end
    end

    ListSet.labels=labels;
    
end