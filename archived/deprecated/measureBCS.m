function [bcMeasure] = measureBCS(imgIndex)
% Training limits e.g. [1 50] .. i.e. img 1 to img 50
% NPoints e.g. [10] i.e. number of points to extract from each patch - it
% is an important parameter

[folder,files,users,color] =setDirs();
[show, boxShow]= showSettings();
%[NPoints]=setNPoints();

show = 0;
    
    filename = files(imgIndex).name;
    
    disp(filename);
    disp(imgIndex);
    % Get image
    
    image = readGray(folder, filename);
    disp(['opened : ',filename]);
    [resized_image,densityFixReal,FixPoints]=getFixationKDE_v3(image,users,filename);
    
%     
%     if show==1
%         figure;
%         imagesc(resized_image);
%         hold on;
%         
%     end
%     
    %----------------------------------------------------------------------
    % use boxSize = 32x32
    
    
    
    %--------------- applying SIFT
    peakThreshold=10;
    edgeThreshold=5;
    [f,d] = produceSiftPoints(resized_image,peakThreshold,edgeThreshold);
    siftPoints = f(1:2,:,:)'; % siftPoints coordinates are stored here
    siftPoints = round(siftPoints);
    
    if (show==1)
        figure;
        imagesc(resized_image);
        hold on;
        plotSiftPoints(resized_image,f);
        hold off;
    end
    
    if(size(siftPoints,1)<=5) % for no sift points
        disp('no pt');
        return;
    end
    
    
    %--------------- making FIXED KDE
    Fixed = siftPoints;
    gridx1=1:2:size(resized_image,2); gridx2=1:2:size(resized_image,1); bw=[5 5];
    densityFix =  kde2(Fixed,gridx1,gridx2,bw);
    densityFix=rot90(densityFix,-1); densityFix=fliplr(densityFix);
    densityFix=imresize(densityFix,size((resized_image)));
    
    if(show==1)
        figure, imagesc(1:1:size(resized_image,2), 1:1:size(resized_image,1),densityFix)
    end
    
    
    Fixed = FixPoints;
    gridx1=1:2:size(resized_image,2); gridx2=1:2:size(resized_image,1); bw=[5 5];
    densityFixReal =  kde2(Fixed,gridx1,gridx2,bw);
    densityFixReal=rot90(densityFixReal,-1); densityFixReal=fliplr(densityFixReal);
    densityFixReal=imresize(densityFixReal,size((resized_image)));
    
    if(show==1)
        figure;
        %visualize Fix Points
        for k = 1:length(FixPoints)
            text ((FixPoints(k, 1)), (FixPoints(k, 2)), ['{\color{red}\bf', num2str(k), '}'], 'FontSize', 5, 'BackgroundColor', 'y');
        end
    end


    
    if show==1
        
        figure, imagesc(1:1:size(resized_image,2), 1:1:size(resized_image,1),densityFixReal)
    end
    
    
    
    disp('data')
   
    bcMeasure = computeBrayCurtisDist(densityFix,densityFixReal);
    
    disp('measure BC');
    disp(bcMeasure);