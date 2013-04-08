function [KDE_STRUCT]=getFixationKDE(resized_image,Fixed,show)
% ver : _v5 , added : Monday 8-Apr-2013 , author=akshat dave
% function plots the KDE of a 2D distribution of fixation points
% INPUTS - 1. IMAGE - resized_image 2. Fixation Points on Resized Image -
% Fixed 
% OUTPUTS - KDE_STRUCT containing
%
%************ NEED TO IMPOROVE THIS CODE
    
    %----------------------------------------------------------------------
    % determine KDE for fixation points
     
    Fixed = Fixed((intersect( find(Fixed(:,1)>0), find(Fixed(:,2)>0))),:);
    validPoints =[] ; row=1;
    for i=1:size(Fixed,1)
        x = Fixed(i,1);
        y = Fixed(i,2);
        if(x>0 && y>0)
           validPoints(row,:) = [x y] ;  % flip
           row=row+1;
        end
    end
 
    gridx1=1:1:size(resized_image,2); gridx2=1:1:size(resized_image,1); bw=[5 5];
    densityFix =  kde2(validPoints,gridx1,gridx2,bw);
    densityFix = densityFix';
    
    %----------------------------------------------------------------------
    % Visual
    
    if show==1
        visualizeImgKDE(resized_image,Fixed,densityFix);
    end

    [My Mx] = find(densityFix==max(densityFix(:)));
    maxProb = max(densityFix(:));
    
    KDE_STRUCT.resized_image=resized_image;
    KDE_STRUCT.densityFix=densityFix;
    KDE_STRUCT.Fixed=validPoints;
    KDE_STRUCT.My=My;
    KDE_STRUCT.Mx=Mx;
    KDE_STRUCT.maxProb=maxProb;
end