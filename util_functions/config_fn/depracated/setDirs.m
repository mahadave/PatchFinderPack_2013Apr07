function [folder,files,users,color]=setDirs()
% Setting Directories and Parameters for processing
    folder = '../ALLSTIMULI/Faces';
    % Tilke Judd June 26, 2008
    % ShowEyeDataForImage should show the eyetracking data for all users in
    % 'users' on a specified image.

    users = {'CNG', 'ajs', 'emb', 'ems', 'ff', ...
        'hp', 'jcw', 'jw', 'kae',...
        'krl', 'po', 'tmj', 'tu', 'ya', 'zb'};

    color={'m','y','b','w','g','y','w','k','g','b','y','w','k','g','b'};

    % Cycle through all images
    files = dir(strcat(folder, '/*.jpeg'));

end