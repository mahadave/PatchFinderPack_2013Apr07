function [ListSet,patchInfo] = testingDataAndLabels(META)
    % version : _v13_intraPatchInterPatch , Monday 8 April 2013,
    % author=akshat dave
    % Training limits e.g. [1 50] .. i.e. img 1 to img 50
    % NPoints e.g. [10] i.e. number of points to extract from each patch - it
    % is an important parameter
    
    tic; [ListSet,patchInfo] = trainingDataAndLabels(META,META.testLimits); toc;
     
end