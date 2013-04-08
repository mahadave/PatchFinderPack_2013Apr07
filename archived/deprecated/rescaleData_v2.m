function [ScaledFixPoints,resized_image] = rescaleData_v2(image,FixPoints)

% rescale fixation points ---------------------------------------------
    [X Y]=size(image);
    [nX,nY,alpha]=findResizeParam(X,Y);
    newFixPoints = FixPoints.*alpha;
    newX = uint16(round(X*alpha)); newY = uint16(round(Y*alpha));
    resized_image = imresize(image,[newX newY]);
    ScaledFixPoints = newFixPoints;
end