function [pointList,trainingLabels,patchInfo] = trainingDataAndLabels_v10b_intraPatchInterPatch(trainingLimits,NPoints)
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
%             figure; imshow(image);
            hold on;
        end
        
        %----------------------------------------------------------------------
        %%fixation points
        [resized_image,densityFix,FixPoints]=getFixationKDE_v3(image,users,filename);
        [y x] = find(densityFix==max(densityFix(:)));
        maxProb = max(densityFix(:));
        
        s = size(resized_image,1);

        %----------------------------------------------------------------------
        % use boxSize = 32x32

        threshold = setThreshold(maxProb);
        boxSize=32; % starting value

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

%        box = densityFix(lowerX:upperX,lowerY:upperY);
%        boxRect=[x-boxSize y-boxSize boxSize*2 boxSize*2]; % xStart,yStart,boxSize

        %----------------------------------------------------------------------
        % cut patches from the image (and save as img_IMAGEINDEX_PATCHINDEX=optional)
        %using the "2*boxSize" determined


        %-------------show image

        if(show==1 || boxShow==1)
%             figure,imagesc(densityFix)
        end

        %------------------------------
        %

        index=1;
        positives=0;
        negatives=0;
        probThreshold = threshold/5; % subject to change
        boxSize  = getPatchSize(resized_image,probThreshold,densityFix);
         patchIndex=1;
        for i=1:2*boxSize:(size(resized_image,1))
            for j=1:2*boxSize:(size(resized_image,2))
                
                upperX = i+2*boxSize-1;
                lowerX=i;
                lowerY=j;
                upperY=j+2*boxSize-1;
%              disp([lowerX lowerY upperX upperY]);
            [MX MY]=size(resized_image);
            if(upperY>MY)
%                 disp('here');
                upperY = MY;
            end
            if(upperX>MX)
%                 disp('here2')
                upperX=MX;
            end
%             disp('corrected')
%             disp(size(resized_image))
 %           rectangle('Position',[lowerX lowerY 2*boxSize 2*boxSize],'LineWidth',2,'LineStyle','--');
%             disp([lowerX lowerY upperX upperY]);

                patch = resized_image(lowerX:upperX,lowerY:upperY);
                patchDensity = densityFix(lowerX:upperX,lowerY:upperY);
                meanDensity = mean(patchDensity(:));

                
%             disp(['patch number  ',num2str(patchIndex)]);
            
%             disp(size(patch))
                        if(size(patch,1)*size(patch,2)<NPoints)
                continue; % not ecough points
            end

                %--- self similarity
%                 patchCentreDensityList = [patchCentreDensityList ; [floor((lowerX+upperY)/2) floor((lowerY+upperY)/2) meanDensity]];
%                 meanDensityList = [meanDensityList; meanDensity];  % for saliency map construction          
                
                if(meanDensity>=probThreshold)
%                     countOnes = countOnes+1;
                    label = 1;
                    positives=positives++1;
                    
                       %pixelLabelList =
                         
                    if (show==1 || boxShow==1)
                        boxRect=[lowerY lowerX boxSize*2 boxSize*2]; % xStart,yStart,boxSize
      %               rectangle('Position', boxRect, 'LineWidth',2,'LineStyle','--')
                    end
                    
                else
                    
                    label =-1;
                    negatives=negatives+1;
                end

                
                       %--- label pixels based on self similarity                     
                       ix =  find(FixPoints(:,2)>=lowerX & FixPoints(:,1)>=lowerY & FixPoints(:,2)<=upperX & FixPoints(:,1)<=upperY);
                       [yy]=FixPoints(ix,1);  [xx]=FixPoints(ix,2) ;
                       yy=yy-lowerY; xx = xx-lowerX;
                       arr = makeArray_v2(size(patch,1),size(patch,2));
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
                       patchInfo(imgIndex).sparsityRatio = positives/(positives+negatives);
                       patchInfo(imgIndex).positiveCount = positives;
                       patchInfo(imgIndex).negativeCount = (negatives);
                       patchInfo(imgIndex).boxSize = boxSize;
                       
                       extractColourHists(patch);
                       
                       %------- pixel labeling done
        
                       if ss==1
                           
                        patchInfo(imgIndex).patchData(patchIndex).intraPatchHist  = getINTRAPatchDistHistogram_v2(patch);
                       end
%                 

                %%----- TOP X gradient points -----------------------------------------------------------------%%
                
                d_all = [];
                [FX,FY] = gradient(double(patch));
                u = (abs(FX/2) + abs(FY/2));
                [array] = makeArray_v2(size(patch,1),size(patch,2));
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
                pointList=[pointList;d_all]; % add to training set only if within training bounds -- for universal gmm
                
                trainingLabels = [trainingLabels label];
                
                
%                 disp(size(d_all))
                patchInfo(imgIndex).patchData(patchIndex).pointList= d_all;
                
                patchIndex=patchIndex+1;
            end
            
        end
         patchInfo(imgIndex).indexList = indexList;
     %    disp(['positives:',' boxSize:',num2str(4*boxSize)]);
      
        

 if ss==1
      [SX SY] = size(resized_image);
%       disp([SX SY]);
       patchInfo(imgIndex).interPatchHist = getINTERPatchDistHistogram_v2(patchInfo(imgIndex),[SX SY]);
 end
         
      
%         disp('done');
         
         
       
    end


                
    
    
    
end