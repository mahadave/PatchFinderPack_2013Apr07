function [Fixed] = extractFixPoints(trainingLimits)

[folder,files,users,color] =setDirs();
    [show, boxShow]= showSettings();
    %[NPoints]=setNPoints();
    lowerLim = trainingLimits(1);
    upperLim = trainingLimits(2);

    Fixed = [];
    
    for imgIndex = lowerLim:upperLim

        filename = files(imgIndex).name;
        disp(['index:',num2str(imgIndex),' - file:',filename]);
        % Get image
        image = readGray(folder, filename);
        disp(['opened : ',filename]);
        
        [resized_image,densityFix,FixPoints]=getFixationKDE_v3(image,users,filename);
        
        Fixed = cat(1,Fixed, FixPoints);
        
        
    end