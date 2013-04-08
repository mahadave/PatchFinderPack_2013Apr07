function [I]= readImg(folder,name)
% reads image from path and converts to gray scale
% Input:
%   folder - folder path to file
%   name - filename of image
% Outputs:  
%    I - image read in grayscale

    path=fullfile(folder,name);
    I=imread(path);

end