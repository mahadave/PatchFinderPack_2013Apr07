function [pointList,trainingLabels,indexList,corrMax,predictedLabelList2] = testingDataAndLabels_v7(trainingLimits,NPoints)
    % Training limits e.g. [1 50] .. i.e. img 1 to img 50
    % NPoints e.g. [10] i.e. number of points to extract from each patch - it
    % is an important parameter
    predictedLabelList2 = [];
    trainingLabels=[];
    pointList=[];
    sizeList=[];
    patchSimData=[];
    patchDistData=[];
    pixelLoc=[];


    [folder,files,users,color] =setDirs();
    [show, boxShow]= showSettings();
    %[NPoints]=setNPoints();
    lowerLim = trainingLimits(1);
    upperLim = trainingLimits(2);
    indexList=[0 1];



    for imgIndex = lowerLim:upperLim

        filename = files(imgIndex).name;
        
        disp(filename);
        disp(imgIndex);
        % Get image

        image = readGray(folder, filename);
        disp(['opened : ',filename]);

        if show==1
            figure;
            imshow(image);
            hold on;

        end



        %----------------------------------------------------------------------
        %%fixation points
        % find peak of KDE for determining box seed point

%        [resized_image,densityFix]=getFixationKDE(image,users,filename);
        [resized_image,densityFix,FixPoints]=getFixationKDE_v2(image,users,filename);
        [y x] = find(densityFix==max(densityFix(:)));
        %disp([x y]);

        s = size(resized_image,1);




        %----------------------------------------------------------------------
        % use boxSize = 32x32

        f=0.2; % percentage of max for threshold
        maxProb = max(densityFix(:));
        threshold = f*maxProb;
        %clc;


        boxSize=16;

        lowerX = (x-boxSize);
        upperX = (x+boxSize);

        lowerY = (y-boxSize);
        upperY = (y+boxSize);

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
        patchSimData=[];
        patchCentreDensityList = [];
        meanDensityList =[];
        %
        
                
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
                meanDensity = mean(patchDensity);
                                 
                
                 [descriptors]=getSelfSimData_vtest(patch);
                 patchSimData(ind).data=descriptors;
                  patchSimData(ind).meanData=mean(descriptors);
                
                
                if(meanDensity>=probThreshold)
                    countOnes = countOnes+1;
                    label = 1;
                    
                    
                                            
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
                         
                         
                    if (show==1 || boxShow==1)
                        boxRect=[lowerY lowerX boxSize*2 boxSize*2]; % xStart,yStart,boxSize
                        rectangle('Position', boxRect, 'LineWidth',2,'LineStyle','--')
                    end
                    
                else
                    
                    label =-1;
                    
                end
                patchSimData(ind).label=label;
                
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
                
            end
        end

         disp(['positives:',num2str(countOnes),' boxSize:',num2str(4*boxSize)]);
         
         
         % visualize box - fix region
         %meanDescriptor=[];
         
         
         patchLabelList=[];
         corrMax = [];
         numPatches = size(patchSimData);
         for c = 1: numel(patchSimData)
             current= patchSimData(c).data;
             corrData=[]; maxVals=[];
             for a=1:size(current,1)
                 A = current(a,:);
                 [neighboursList] = findNeighbours(a,2*boxSize,resized_image,numPatches);
                 maxVals=[]; corrData=[];
                 for b = 1: numel(neighboursList)
                     if (b==a)
                         corrData(b).data=0;
                         continue;
                     end
                     B= current(b,:) ;
                     corrData(b).data = pdist2(A,B);
                     maxVals(b) =max(corrData(b).data(:));
                     
                 end
             end
             
             corrMax(c) =mean(maxVals(:)) ; % not sure
             patchLabelList(c) = patchSimData(c).label;
             %meanData= mean(descriptors')';
         end
%          distData= pdist2(meanDescriptor,meanDescriptor); %see if this is too big
%          meanDistData = mean(distData')';
%         size(distData)
%         size(meanDistData)
        
        
        helperList = [];
        
        N=numel(patchSimData); 
        lo= round(0.3*N);
        helperList = [-1*ones(1,N-lo) ones(1,lo)]';
   
        %patchDistData(imgIndex).data = [meanDistData patchLabelList];
        tempList =[];
        tempList2 = [];
        tempList = sortrows([corrMax;(1:N)]');
              
        tempList = [tempList helperList];
        
        tempList2 = tempList(:,2:3);
        
        helperList = sortrows(tempList2);
        
        helperList = helperList(:,2);
        patchDistData(imgIndex).data = [corrMax' patchLabelList' helperList];      
%       patchDistData(imgIndex).data =
%       sortrows(patchDistData(imgIndex).data);
        
        
        predictedLabelList2 = [predictedLabelList2 ; helperList];
        
        
        disp('done');
         
         
       
    end


                
    
    
    
end