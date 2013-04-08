function [resized_image,densityFix,Fixed,My,Mx,maxProb]=getFixationKDE_v4(META)
% function plots the KDE of a 2D distribution of fixation points
% INPUTS - 
% OUTPUTS - resize_image ... My
%
%************ NEED TO IMPOROVE THIS CODE
    image=META.image;
    users=META.users;
    filename=META.curFile;
    FixPoints = getFixData_v2(filename,users,META);    
    [Fixed,resized_image] = rescaleData(FixPoints,image);
    
    [MX MY] = size(resized_image);
    
    %----------------------------------------------------------------------
    % determine KDE for fixation points
     
    Fixed = Fixed((intersect( find(Fixed(:,1)>0), find(Fixed(:,2)>0))),:);
    
    
    gridx1=1:2:size(resized_image,2); gridx2=1:2:size(resized_image,1); bw=[5 5];
    densityFix =  kde2(Fixed,gridx1,gridx2,bw);
    densityFix=rot90(densityFix,-1); densityFix=fliplr(densityFix);
    densityFix=imresize(densityFix,size((resized_image))); 
    
    %----------------------------------------------------------------------
    % Visual
    show=0;  
    if show==1
        % visualize points
        figure,imshow(resized_image);
        for k = 1:length(Fixed)
            text ((Fixed(k, 1)), (Fixed(k, 2)), ['{\color{red}\bf', num2str(k), '}'], 'FontSize', 5, 'BackgroundColor', 'g');
        end
        xlabel(num2str([MX MY]));
    
        % visualize the KDE
        figure, imagesc(1:1:size(resized_image,2), 1:1:size(resized_image,1),densityFix)
    end

    [My Mx] = find(densityFix==max(densityFix(:)));
    maxProb = max(densityFix(:));
    
end