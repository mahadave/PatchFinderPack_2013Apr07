function [pointList,trainingLabels,indexList,patchInfo] = trainingDataAndLabels_v9_intraPatchInterPatch(trainingLimits,NPoints)
    % Training limits e.g. [1 50] .. i.e. img 1 to img 50
    % NPoints e.g. [10] i.e. number of points to extract from each patch - it
    % is an important parameter
    ss=1; % use self similarity histograms
    trainingLabels=[];  pointList=[];
    sizeList=[];    pixelLoc=[];
    patchInfo=[];

    [folder,files,users,color] =setDirs();
    [show, boxShow]= showSettings();
    %[NPoints]=setNPoints();
    lowerLim = trainingLimits(1);
    upperLim = trainingLimits(2);


    for imgIndex = lowerLim:upperLim
            indexList=[0 1];
        % Read File
        filename = files(imgIndex).name;
        disp(['index:',num2str(imgIndex),' - file:',filename]);
        % Get image
        image = readGray(folder, filename);
        disp(['opened : ',filename]);

        if show==1
            figure; imshow(image);
            hold on;
        end
        
        %----------------------------------------------------------------------
        %%fixation points
        [resized_image,densityFix,FixPoints]=getFixationKDE_v2(image,users,filename);
        [y x] = find(densityFix==max(densityFix(:)));
        maxProb = max(densityFix(:));
        
        s = size(resized_image,1);

        %----------------------------------------------------------------------
        % use boxSize = 32x32

        threshold = setThreshold(maxProb);
        boxSize=16; % starting value

        lowerX = (x-boxSize);   upperX = (x+boxSize);
        lowerY = (y-boxSize);  upperY = (y+boxSize);

        if(lowerX<=0)
            lowerX = (1);
        end
        if(upperX>size(resized_image,1))
            upperX = (size(resized_image,1));
        end
        if(lowerY<=0)
            lowerY =  (1);
        end
        if (upperY>size(resized_image,1))
            upperY = (size(resized_image,2));
        end

        % box size for each image is 2*boxSize

        box = densityFix(lowerX:upperX,lowerY:upperY);
        boxRect=[x-boxSize y-boxSize boxSize*2 boxSize*2]; % xStart,yStart,boxSize

        %----------------------------------------------------------------------
        % cut patches from the image (and save as img_IMAGEINDEX_PATCHINDEX=optional)
        %using the "2*boxSize" determined


        %-------------show image

        if(show==1 || boxShow==1)
            figure,imagesc(densityFix)
        end

        %------------------------------
        %

        index=1;
        probThreshold = threshold/5; % subject to change
        countOnes=0;
        ind=1;
        patchCentreDensityList = [];
        meanDensityList =[];
        %
        %--------------------------------------------------------------
        % determine box size if it needs to be reduced
        
        while(countOnes==0 && boxSize>0)
            for i=1:2*boxSize:(size(resized_image,1))
                for j=1:2*boxSize:(size(resized_image,2))
                    
                    upperX = i+2*boxSize-1;
                    lowerX=i;     lowerY=j;
                    upperY=j+2*boxSize-1;
                    if(upperY>size(resized_image,2))
                        upperY = size(resized_image,2);
                    end
                    if(upperX>size(resized_image,1))
                        upperX=size(resized_image,2);
                    end
                                      
                    %-- determine patch from image
                    patch = resized_image(lowerX:upperX,lowerY:upperY);
                    patchDensity = densityFix(lowerX:upperX,lowerY:upperY);
                    meanDensity = mean(patchDensity(:));
    
                    if(meanDensity>=probThreshold)
                        countOnes = countOnes+1;
                        label = 1;
                    else
                        label =-1;
                    end
                end
            end
            boxSize=boxSize/2; % half box size for concentrated fixation distribution -- keep halving till size =1
        end
        
        boxSize = boxSize*2;
         countOnes=0;
         patchIndex=1;
        for i=1:2*boxSize:(size(resized_image,1))
            for j=1:2*boxSize:(size(resized_image,2))
                
                upperX = i+2*boxSize-1;
                lowerX=i;
                lowerY=j;
                upperY=j+2*boxSize-1;
                if(upperY>size(resized_image,2))
                    upperY = size(resized_image,2);
                end
                if(upperX>size(resized_image,1))
                    upperX=size(resized_image,2);
                end
                patch = resized_image(lowerX:upperX,lowerY:upperY);
                patchDensity = densityFix(lowerX:upperX,lowerY:upperY);
                meanDensity = mean(patchDensity(:));
                
                %--- self similarity
                patchCentreDensityList = [patchCentreDensityList ; [floor((lowerX+upperY)/2) floor((lowerY+upperY)/2) meanDensity]];
                meanDensityList = [meanDensityList; meanDensity];  % for saliency map construction          
                
                if(meanDensity>=probThreshold)
                    countOnes = countOnes+1;
                    label = 1;
                    
                       %pixelLabelList =
                         
                    if (show==1 || boxShow==1)
                        boxRect=[lowerY lowerX boxSize*2 boxSize*2]; % xStart,yStart,boxSize
                        rectangle('Position', boxRect, 'LineWidth',2,'LineStyle','--')
                    end
                    
                else
                    
                    label =-1;
                    
                end

                
                       %--- label pixels based on self similarity                     
                       ix =  find(FixPoints(:,2)>=lowerX & FixPoints(:,1)>=lowerY & FixPoints(:,2)<=upperX & FixPoints(:,1)<=upperY);
                       [yy]=FixPoints(ix,1);  [xx]=FixPoints(ix,2) ;
                       yy=yy-lowerY; xx = xx-lowerX;
                       arr = makeArray(size(patch,1));
                       arr2 = 1:size(arr,1);
                       arr = [arr  arr2'];
                       for v=1:numel(yy)
                           a=uint8(xx(v));
                           b=uint8(yy(v));
                           lix =  find( (arr(:,1)==a) & (arr(:,2)==b) );
                           pixelLoc =[ pixelLoc ;  arr(lix,3) ];
                       end
                       %------CHANGED HERE --------
                       %cX=mean(dissimilarityMatrix')'; % mean distance from all the pixels in the patch - not only neighbours
                       %dissimDataList=cX(pixelLoc,:); % -- actual fixation patches
                       totpixels=size(patch,1);
                       %disp('totPixels'); disp(totpixels);
                       otherPixels = setdiff(1:totpixels , pixelLoc);
                       %disp(otherPixels);
                       
                       %disp([imgIndex patchIndex])
                       patchInfo(imgIndex).patchData(patchIndex).positivePixels = pixelLoc;
                       patchInfo(imgIndex).patchData(patchIndex).negativeLabels = otherPixels; % hard labeling
                       patchInfo(imgIndex).patchData(patchIndex).patchLabel = label;
                       patchInfo(imgIndex).patchData(patchIndex).patch = patch;
                       patchInfo(imgIndex).boxSize = boxSize;
                       %------- pixel labeling done
        
%                        if ss==1
%                         patchInfo(imgIndex).patchData(patchIndex).intraPatchHist  = getINTRAPatchDistHistogram(patch);
%                        end
%                 
                ind = ind+1;
                %%----- TOP X gradient points -----------------------------------------------------------------%%
                
                d_all = [];
                [FX,FY] = gradient(double(patch));
                u = (abs(FX/2) + abs(FY/2));
                [array] = makeArray(size(patch,1));
                ut = u';
                ut = ut(:);
                linearArray = [];
                linearArray = [ ut array];
                linearArray = sortrows(linearArray);
                p = linearArray(end - (NPoints - 1) : end , : , :);%put last sorted N points of linear array in p
                
                indexList =[indexList; [index index+size(p,1)]]; % store end index of patch descriptors for cur image
                index = index + size(p,1) +1;
                
                p=p(:,2:3);  px = p(:,1); py=p(:,2);
                
                fc = [px py 10*ones(size(px,1),1) zeros(size(px,1),1)]'; % check if this is correct******
                [f,d] = vl_sift(single(patch),'frames',fc) ;
                d_all = [d_all; d'];
                pointList=[pointList;d_all]; % add to training set only if within training bounds
                trainingLabels = [trainingLabels label];
                patchIndex=patchIndex+1;
                patchInfo(imgIndex).patchData(patchIndex).pointList= d_all;
            end
            
        end
         patchInfo(imgIndex).indexList = indexList;
         disp(['positives:',num2str(countOnes),' boxSize:',num2str(4*boxSize)]);
      
      
%{    
     patchLabelList=[];
         numPatches = size(patchSimData);
         
         for a = 1: numel(patchSimData)
             A= patchSimData(a).data;   
             corrData=[]; maxVals=[];
             [neighboursList] = findNeighbours(a,2*boxSize,resized_image,numPatches);
             for b = 1: numel(neighboursList)
                 if (b==a)
                     corrData(b).data=0;
                     continue;
                 end
                B= patchSimData(b).data;   
                corrData(b).data = xcorr2(A,B);
                 maxVals(b) =max(corrData(b).data(:));
             end
             corrMax(a) =mean(maxVals(:)) ; % not sure
             patchLabelList(a) = patchSimData(a).label;
         %meanData= mean(descriptors')'; 
         end
         
    %}     
         
%         centres = makeCentresList(patchCentreDensityList);
%         size(centres)
%         [bandwidthC,densitySaliency,XSaliency,YSaliency]=kde2d(centres,32,[0 0],[256 256]); % estimate kernel density
%         %if show==1
%             figure, surf(XSaliency,YSaliency,densitySaliency);
%             imagesc(densityFix);
%             figure,imagesc(imresize(densitySaliency,[256 256]));
% 
%         %end
        

if ss==1
      patchInfo(imgIndex).interPatchHist = getINTERPatchDistHistogram(patchInfo(imgIndex));
end
         % visualize box - fix region
         %meanDescriptor=[];
         
         
      
        disp('done');
         
         
       
    end


                
    
    
    
end