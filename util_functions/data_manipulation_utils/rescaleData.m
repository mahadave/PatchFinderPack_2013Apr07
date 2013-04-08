function [ScaledFixPoints,resized_image] = rescaleData(image,FixPoints)
% version : _v2 , Monday 8 April 2013,
    % author=akshat dave
    
% rescale fixation points ---------------------------------------------
    [X Y]=size(image);
    [nX,nY,alpha]=findResizeParam(X,Y);
    newFixPoints = FixPoints.*alpha;
    newX = uint16(round(X*alpha)); newY = uint16(round(Y*alpha));
    resized_image = imresize(image,[newX newY]);
    ScaledFixPoints = newFixPoints;
end