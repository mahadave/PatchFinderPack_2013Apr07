function [ListSet,patchInfo] = trainingDataAndLabels(META,limits)
    % version : _v14_intraPatchInterPatch , Monday 8 April 2013,
    % author=akshat dave
    % INPUTS - META which contains 
    % 1. META.Training limits e.g. [1 50] .. i.e. img 1 to img 50
    % 2. META.NPoints e.g. [10] i.e. number of points to extract from 
    % each patch 
    
    ListSet.labels=[];  
    ListSet.pointList=[];
    patchInfo=[];

    % extract from META
    files=META.files;
    folder=META.folder;
    debug=META.debug;
    users=META.users;
    lowerLim = limits(1);
    upperLim = limits(2);

    for imgIndex = lowerLim:upperLim
        disp(imgIndex);
        ListSet.indexList=[0 1];        
        filename = [files(imgIndex).name]; % Read File        
        image = readGray(folder, filename); % Get image
        if debug disp(['index:',num2str(imgIndex),'-file:',filename]); end
       
        %------------------------------------------------------------------
        %%fixation points
        
        % get fixation points fot the current image           
        FixPoints = getFixData(META.fixationsFolder,filename,users); 
        % resize the image maintaining aspect ratio.
        [scaledFixPoints,resized_image] = rescaleData(image,FixPoints); 
        % determine the KDE
        [KDE_STRUCT]=getFixationKDE(resized_image,scaledFixPoints,0); 
        
        %------------------------------------------------------------------
        %%set threshold
        threshold = setThreshold(KDE_STRUCT.maxProb);
        probThreshold = threshold/5; % subject to change

        %------------------------------------------------------------------
        % cut patches from the image and extract features        
        if (debug) disp('...BEFORE PATCH MAKING .... '); end
        [patchInfo,ListSet]= ...
                        makePatches(KDE_STRUCT,ListSet,patchInfo,...
                        imgIndex,probThreshold,META);
        if (debug) disp('...DONE PATCH MAKING .... '); end
    end
end