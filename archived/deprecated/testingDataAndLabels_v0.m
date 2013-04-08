function [pointList,testLabels,indexList] = testingDataAndLabels_v2(testingLimits,NPoints)
% testing script...
% testingLimits e.g. [120 150] .. i.e. img indices
% NPoiints .. e.g. [10] .. i.e. number of points to extract from each patch


    testLabels=[];
    sizeList=[];
    pointList=[];
    indexList = [0 1];

    [folder,files,users,color] =setDirs();
    [show, boxShow]= showSettings();
    %[NPoints]=setNPoints();
    lowerLim = testingLimits(1);
    upperLim = testingLimits(2);

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

        [resized_image,densityFix]=getFixationKDE(image,users,filename);
        [y x] = find(densityFix==max(densityFix(:)));
        disp([x y])

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

                    %disp([lowerX upperX lowerY upperY]);
                    %patchesListImage(:,:,(index)) = patch;

                    if(meanDensity>=probThreshold)

                        countOnes = countOnes+1;
                        label = 1;
                        %patchList = [patchList; [class imgIndex]]; 
                        if (show==1 || boxShow==1)
                            boxRect=[lowerY lowerX boxSize*2 boxSize*2]; % xStart,yStart,boxSize
                            rectangle('Position', boxRect, 'FaceColor','k')
                        end

                    else

                        label =-1;
                    end
                    
                    %%------------------------
                    d_all = [];
                        
                         
                         [FX,FY] = gradient(double(patch));
                     
                         u = (abs(FX/2) + abs(FY/2)); 
                         [array] = makeArray(size(patch,1));
                            
                         ut = u';                       
                                
                         ut = ut(:);
                         linearArray = [];
                         
                         linearArray = [ ut array];

                          linearArray = sortrows(linearArray);
                         
                          if size(linearArray,1) < (NPoints - 1)
                              p = linearArray;
                              
                          else
                           p = linearArray(end - (NPoints - 1) : end , : , :);%put last sorted N points of linear array in p
                          end 
                          
                          
                          indexList =[indexList; [index index+size(p,1)]]; % store end index of patch descriptors for cur image
                          index = index + size(p,1); 
                          
                          p=p(:,2:3);
                           px = p(:,1);
                           py=p(:,2);

                           %  for z = 1 : size(px,1)
                                 fc = [px py 10*ones(size(px,1),1) zeros(size(px,1),1)]'; % check if this is correct******
                                
                                 [f,d] = vl_sift(single(patch),'frames',fc) ;
%                               if(size(d,2) > 1 )
%                                  d=d(:,1); % why do I need to do this? read paper  Lowe 
%                                  continue
%                               end

                          d_all = [d_all; d'];
                          
%                           for z = 1 : size(px,1)
%                                     fc = [px(z) py(z) 10 0]'; % check if this is correct******
%                                  [f,d] = vl_sift(single(patch),'frames',fc,'orientations') ;
% %  %                               d=d(:,1); % why do I need to do this? read paper  Lowe 
%                                   d_all = [d_all; d'];
%                             end

                    testLabels = [testLabels label];
                    pointList=[pointList;d_all]; % add to training set only if within training bounds
                    %testLabels = [testLabels label];

                    index=index+1;

                end

            end


        sizeList = [sizeList; boxSize*2]; % box size per image
        %indexList =[indexList; [imgIndex size(descriptorList,1)]]; % store end index of patch descriptors for cur image

        % visualize box - fix region
        if show==1
            figure,imagesc(densityFix)
            rectangle('Position', boxRect, 'LineWidth',2,'LineStyle','--')
        end


        if (show==1 || boxShow==1)
                %visualize Fix Points
              %  for k = 1:length(Fixed)
               %     text ((Fixed(k, 1)), (Fixed(k, 2)), ['{\color{red}\bf', num2str(k), '}'], 'FontSize', 5, 'BackgroundColor', 'y');
               % end     
        end

    end


end