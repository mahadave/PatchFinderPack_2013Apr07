function [bcMeasure,predictedFixPts,FixPoints,densityFix,densityFixReal] = throwFixPoints(imgIndex,patchInfo,predictedLabel)
% Training limits e.g. [1 50] .. i.e. img 1 to img 50
% NPoints e.g. [10] i.e. number of points to extract from each patch - it
% is an important parameter
ss = 1;
index=1;
trainingLabels=[];
pointList=[];
sizeList=[];
pixelLoc=[];
brayCurtis=[];

[folder,files,users,color] =setDirs();
[show, boxShow]= showSettings();
%[NPoints]=setNPoints();

show = 1;
    
    filename = files(imgIndex).name;
    
    disp(filename);
    disp(imgIndex);
    % Get image
    
    image = readGray(folder, filename);
    disp(['opened : ',filename]);
    [resized_image,densityFixReal,FixPoints]=getFixationKDE_v3(image,users,filename);
    
    
    if show==1
        figure;
        imshow(resized_image);
        hold on;
        
    end
    
    %----------------------------------------------------------------------
    % use boxSize = 32x32
    
    boxSize=patchInfo(imgIndex).boxSize ;
    
    % box size for each image is 2*boxSize
    %----------------------------------------------------------------------
    % cut patches from the image (and save as img_IMAGEINDEX_PATCHINDEX=optional)
    %using the "2*boxSize" determined
    
    patchIndex=1;
    predictedFixPts=[];
    for i=1:2*boxSize:(size(resized_image,1))
        for j=1:2*boxSize:(size(resized_image,2))
            
            upperX = i+2*boxSize-1;
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
            
            patch = resized_image(lowerX:upperX,lowerY:upperY);
            
            
            label=predictedLabel(index);
            index=index+1;
            
            if label==1
                selected = patchInfo(imgIndex).patchData(patchIndex).selFixPts ;
                save('tatti','selected','imgIndex','patchIndex');
                predictedFixPts = [predictedFixPts ; [selected(:,1)+lowerY selected(:,2)+lowerX]];
                
                if(show == 1)
                    for ix=1:size(selected,1)
                        rectangle('Position',[selected(ix,2)-1+lowerY selected(ix,1)-1+lowerX 2 2],'LineWidth',2,'LineStyle','--','EdgeColor','red');
                        rectangle('Position',[lowerY lowerX 2*boxSize 2*boxSize],'LineWidth',2,'LineStyle','--','EdgeColor','green');
                        
                    end
                    for ix=1:size(FixPoints,1)
                        rectangle('Position',[FixPoints(ix,1)-1 FixPoints(ix,2)-1 2 2],'LineWidth',2,'LineStyle','--','EdgeColor','white');
                    end
                end
            end
            
            %                     disp('pi = '); disp(patchIndex);
            patchIndex=patchIndex+1;
        end
    end
    
    
    Fixed = predictedFixPts;
    gridx1=1:2:size(resized_image,2); gridx2=1:2:size(resized_image,1); bw=[5 5];
    densityFix =  kde2(Fixed,gridx1,gridx2,bw);
    densityFix=rot90(densityFix,-1); densityFix=fliplr(densityFix);
    densityFix=imresize(densityFix,size((resized_image)));
    
    if show==1
        figure, imagesc(1:1:size(resized_image,2), 1:1:size(resized_image,1),densityFix)
        figure, imagesc(1:1:size(resized_image,2), 1:1:size(resized_image,1),densityFixReal)
    end
    
    
    
    disp('data')
   
    bcMeasure = computeBrayCurtisDist(densityFix,densityFixReal);
    
    disp('measure BC');
    disp(bcMeasure);
    
    FixPoints = [FixPoints(:,2) FixPoints(:,1)];