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


    index=1;
    positives=0;
    negatives=0;
    patchIndex=1;
    show=META.show;
    boxShow=META.boxShow;
    debug=META.debug;
    NPoints=META.NPoints;
    pixelLoc=[];   
    indexList=ListSet.indexList;
    pointList=ListSet.pointList;
    trainingLabels=ListSet.trainingLabels;
    
    resized_image=KDE_STRUCT.resized_image;
    densityFix=KDE_STRUCT.densityFix;
    Fixed=KDE_STRUCT.Fixed;
    
    boxSize  = getPatchSize(resized_image,probThreshold,densityFix);
    step=2*boxSize;
    [LX LY]=size(resized_image);
    
    
    if(show==1 || boxShow==1)
        figure,imagesc(KDE_STRUCT.densityFix)
    end

    for i=1:step:LX
        for j=1:step:LY

            upperX = i+2*boxSize-1; % set cutting parameters
            lowerX=i;   
            lowerY=j;
            upperY=j+2*boxSize-1;
            [MX MY]=size(resized_image);
            if(upperY>MY)
                upperY = MY;
            end
            if(upperX>MX)
                upperX=MX;
            end

            if(debug)
                size(resized_image);
                size(densityFix);
            end

            patch = resized_image(lowerX:upperX,lowerY:upperY); % snip out the patch
            patchDensity = densityFix(lowerX:upperX,lowerY:upperY); % snip out the corresponding patch from the KDE
            meanDensity = mean(patchDensity(:)); % get the mean patch density


            if(size(patch,1)*size(patch,2)<NPoints)
                continue; % not ecough points
            end

            %----- LABEL patch -------------
            if(meanDensity>=probThreshold) 
                label = 1;
                positives=positives+1;
                visualizeBoxes(lowerX,lowerY,boxSize,META);
            else
                label =-1;
                negatives=negatives+1;
            end



           %--- label pixels 
                      
           lims = [lowerX upperX lowerY upperY];
           [positivePixelsInds negativePixelsInds] = getPixelLabels(Fixed,patch,lims); % mark true fixation points as positive pixels , and non-fixaton points [PIXEL LABELS]
           
           %------STORE INTO PATCH INFO --------
           
           patchInfo(imgIndex).patchData(patchIndex).positivePixelsInds = positivePixelsInds; % can be converted to sub using size(KDE)
           patchInfo(imgIndex).patchData(patchIndex).negativePixelsInds = negativePixelsInds; % hard labeling
           patchInfo(imgIndex).patchData(patchIndex).patchLabel = label;
           patchInfo(imgIndex).patchData(patchIndex).patch = patch;
           patchInfo(imgIndex).sparsityRatio = positives/(positives+negatives);
           patchInfo(imgIndex).positiveCount = positives;
           patchInfo(imgIndex).negativeCount = (negatives);
           patchInfo(imgIndex).boxSize = boxSize;
           
           %------- pixel labeling done

           if META.USE_SELFSIM==1
               if(debug)
                    disp('.... doing INTRA ....');
               end
                %[histogram,selected]= getINTRAPatchDistHistogram_v4(patch);
                [a b]=size(patch);
               if(a~=b)
                   patch_res = imresize(patch,[max([a,b]) max([a,b])]);
               else
                   patch_res = patch;
               end
                [histogram]= getINTRAPatchDistHistogram_v5(patch_res);
                patchInfo(imgIndex).patchData(patchIndex).intraPatchHist = histogram;
                %patchInfo(imgIndex).patchData(patchIndex).selFixPts = selected; 
                if(debug)           
                    disp('.... \done INTRA ....');
                end
           end

            %%----- GET TOP X gradient points
            %%-----------------------------------------------------------------%%

            d_all = [];
            [FX,FY] = gradient(double(patch));
            u = (abs(FX/2) + abs(FY/2));
            [array] = makeArray_v2(size(patch,1),size(patch,2));
            
            ut = u'; ut = ut(:);
            linearArray = [ut array];
            linearArray = sortrows(linearArray);
            p = linearArray(end - (NPoints - 1) : end , : , :);%put last sorted N points of linear array in p

            indexList =[indexList; [index index+size(p,1)]]; % store end index of patch descriptors for cur image
            index = index + size(p,1) +1;

            p=p(:,2:3);  px = p(:,1); py=p(:,2);
            fc = [px py 10*ones(size(px,1),1) zeros(size(px,1),1)]'; % check if this is correct******
            [f,d] = vl_sift(single(patch),'frames',fc) ;
            d_all = [d_all; d'];
            pointList=[pointList;d_all]; % add to training set only if within training bounds -- for universal gmm
            trainingLabels = [trainingLabels label];
            patchInfo(imgIndex).patchData(patchIndex).pointList= d_all;

            patchIndex=patchIndex+1;
        end
    end

    patchInfo(imgIndex).indexList = indexList;        
    patchInfo(imgIndex).numPatches = (patchIndex-1);  
    
    
    if(debug)
        disp('doing INTER');
    end
    
    
    if META.USE_SELFSIM==1
      [SX SY] = size(resized_image);
      patchInfo(imgIndex).interPatchHist = getINTERPatchDistHistogram_v4_tst(patchInfo(imgIndex),[SX SY]);
    end

    if(debug)
        disp('/done INTER');
    end
    
    ListSet.trainingLabels=trainingLabels;
    ListSet.indexList=indexList;
    ListSet.pointList=pointList;
end