function [pointList,trainingLabels,indexList] = trainingDataAndLabels_v2(trainingLimits,NPoints)
    % Training limits e.g. [1 50] .. i.e. img 1 to img 50
    % NPoints e.g. [10] i.e. number of points to extract from each patch - it
    % is an important parameter

    trainingLabels=[];
    pointList=[];
    sizeList=[];



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

        [resized_image,densityFix]=getFixationKDE(image,users,filename);
        [y x] = find(densityFix==max(densityFix(:)));
        %disp([x y]);

        s = size(resized_image,1);




        %----------------------------------------------------------------------
        % use boxSize = 32x32

        maxProb = max(densityFix(:));
        %------ set threshold
        maxProb = max(densityFix(:));
        [threshold] = setThreshold(maxProb);
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
        probThreshold = threshold; % subject to change
        countOnes=0;

        patchCentreDensityList = [];
        meanDensityList =[];
        %
        while(countOnes==0 && boxSize>0)

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


                    %disp([lowerX upperX lowerY upperY]);
                    %patchesListImage(:,:,(index)) = patch;
                    patchCentreDensityList = [patchCentreDensityList ; [floor((lowerX+upperY)/2) floor((lowerY+upperY)/2) meanDensity]];
                    meanDensityList = [meanDensityList; meanDensity];

                    if(meanDensity>=probThreshold)

                        countOnes = countOnes+1;
                        label = 1;
                        %patchList = [patchList; [class imgIndex]];
                        if (show==1 || boxShow==1)
                            boxRect=[lowerY lowerX boxSize*2 boxSize*2]; % xStart,yStart,boxSize
                            rectangle('Position', boxRect, 'LineWidth',2,'LineStyle','--')
                        end

                    else

                        label =-1;
                    end

                    %%----------------------------------------------------------------------%%
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

                    p=p(:,2:3);
                    px = p(:,1);
                    py=p(:,2);


                    fc = [px py 10*ones(size(px,1),1) zeros(size(px,1),1)]'; % check if this is correct******
                    [f,d] = vl_sift(single(patch),'frames',fc) ;
                    d_all = [d_all; d'];


                    pointList=[pointList;d_all]; % add to training set only if within training bounds

                    trainingLabels = [trainingLabels label];
                    %testLabels = [testLabels label];



                end

            end

            boxSize=boxSize/2; % half box size for concentrated fixation distribution -- keep halving till size =1
        end

        %--- normalize patchCentreList mean Densities
        %disp(patchCentreDensityList)
        %patchCentreDensityList(:,3) = (patchCentreDensityList(:,3))*10;
        mxd = max(patchCentreDensityList(:,3));
        md = mean(patchCentreDensityList(:,3));
        mnd = min(patchCentreDensityList(:,3));
        patchCentreDensityList(:,3) = ((patchCentreDensityList(:,3) - mnd)./(mxd-mnd));

        %disp('after');
        %disp(patchCentreDensityList)

        centres = makeCentresList(patchCentreDensityList);
        size(centres)
        [bandwidthC,densitySaliency,XSaliency,YSaliency]=kde2d(centres,32,[0 0],[256 256]); % estimate kernel density
        if show==1
            figure, surf(XSaliency,YSaliency,densitySaliency);
            imagesc(densityFix);
            figure,imagesc(imresize(densitySaliency,[256 256]));

        end

        %disp(patchCentreDensityList);
        % disp(meanDensityList);

        disp(['positives:',num2str(countOnes),' boxSize:',num2str(4*boxSize)]);

        sizeList = [sizeList; boxSize*2]; % box size per image

        %indexList =[indexList; [imgIndex size(descriptorList,1)]]; % store end index of patch descriptors for cur image

        % visualize box - fix region


        if (show==1 || boxShow==1)
            %visualize Fix Points
            %  for k = 1:length(Fixed)
            %     text ((Fixed(k, 1)), (Fixed(k, 2)), ['{\color{red}\bf', num2str(k), '}'], 'FontSize', 5, 'BackgroundColor', 'y');
            % end
        end

    end


end