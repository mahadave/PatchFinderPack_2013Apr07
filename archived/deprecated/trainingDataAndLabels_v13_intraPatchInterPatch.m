function [ListSet,patchInfo] = trainingDataAndLabels_v13_intraPatchInterPatch(META)
    % INPUTS - META which contains 
    % 1. META.Training limits e.g. [1 50] .. i.e. img 1 to img 50
    % 2. META.NPoints e.g. [10] i.e. number of points to extract from 
    % each patch 
    
    
    ListSet.trainingLabels=[];  
    ListSet.pointList=[];
    patchInfo=[];

    % 00 extract from META
    files=META.files;
    folder=META.folder;
    show=META.show;
    debug=META.debug;
    users=META.users;
    lowerLim = META.trainingLimits(1);
    upperLim = META.trainingLimits(2);

    for imgIndex = lowerLim:upperLim
        disp(imgIndex);
        ListSet.indexList=[0 1];        
        filename = [files(imgIndex).name]; % Read File        
        image = readGray(folder, filename); % Get image

        if show==1 
            figure; imshow(image);  hold on;
        end
        if debug
            disp(['index:',num2str(imgIndex),' - file:',filename]);
            disp(['opened : ',filename]); 
        end
        
        %----------------------------------------------------------------------
        %%fixation points
        
        FixPoints = getFixData_v2(META.fixationsFolder,filename,users); % get fixation points fot the current image           
        [scaledFixPoints,resized_image] = rescaleData_v2(image,FixPoints); % resize the image maintaining aspect ratio.
        [KDE_STRUCT]=getFixationKDE_v5(resized_image,scaledFixPoints,0); % determine the KDE
        
        %----------------------------------------------------------------------
        
        threshold = setThreshold(KDE_STRUCT.maxProb);
        probThreshold = threshold/5; % subject to change

        %----------------------------------------------------------------------
        % cut patches from the image (and save as img_IMAGEINDEX_PATCHINDEX=optional)
                
        disp('...BEFORE PATCH MAKING .... ');
        [patchInfo,ListSet]=makePatches(KDE_STRUCT,ListSet,patchInfo,imgIndex,probThreshold,META);
        disp('...DONE PATCH MAKING .... ');
      
    end
end