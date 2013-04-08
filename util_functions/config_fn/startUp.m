function [meta] = startUp()
% start up and set all parameters
% OUTPUT -  returns a data structure META which contains
% 1. meta.folder - folder containg data
% 2. meta.users
% 3. meta.files - to read from the folder
% 4. meta.show 
% 5. meta.color - options for colouring clusters/graph pts etc
% 6. meta.show - display option 
% 7. meta.boxShow - display option/debugging output print
% 8. meta.trainingLimits - image indices for training e.g. [1 100]
% 9. meta.NPoints - number of points to sample in a patch
% 10.meta.debug - printing debug statements
% 11. meta.stimuliFolder  - all stimuli photos
% 12. meta.fixationsFolder - all fixation data
% 13. meta.USE_SELFSIM - use the self similarity feature vector
%
% @auth=akshat dave , @date=25-March-2013
%-----------------------------------------------------------------------

    clc
    disp('starting up...');
    clear all
    close all


    
    %installSift();

    faceFolder = '../DATA_FOLDER/ALLSTIMULI/';
    fixationsFolder = '../DATA_FOLDER/ALL_FIXATIONS/';
    folder = '../DATA_FOLDER/FACES/';
    folder = faceFolder;
        % Tilke Judd June 26, 2008
        % ShowEyeDataForImage should show the eyetracking data for all users in
        % 'users' on a specified image.

    users = {'CNG', 'ajs', 'emb', 'ems', 'ff', ...
        'hp', 'jcw', 'jw', 'kae',...
        'krl', 'po', 'tmj', 'tu', 'ya', 'zb'};

    color={'m','y','b','w','g','y','w','k','g','b','y','w','k','g','b'};

    % Cycle through all images
    files = dir(strcat(folder, '/*.jpeg'));

    % display options of figure/dubugging prints
    boxShow=0;    
    
    
    trainingLimits = [1 100];
    testLimits = [151 200];
    validationLimits = [101 150];
    
    meta.EVAL=0;
    meta.LABEL_PIX = 0;
    meta.GET_GRAD_PTS = 0;
    meta.SAVE=1;
    meta.USE_SELFSIM=1; % use the self similarity feature
    meta.USE_INTER = 1;
    meta.color=color;
    meta.files=files;
    meta.users=users;
    meta.show=0;
    meta.boxShow=boxShow;
    meta.trainingLimits=trainingLimits;
    meta.NPoints= 20;
    meta.NBins= 25;
    meta.folder=folder;
    meta.faceFolder =faceFolder;
    meta.fixationsFolder =fixationsFolder ;
    meta.debug=0;
    meta.testLimits = testLimits;
    meta.validationLimits = validationLimits;
    
    % FOLDER POINTER
    meta.folder=faceFolder;
    disp('start up complete...');
end