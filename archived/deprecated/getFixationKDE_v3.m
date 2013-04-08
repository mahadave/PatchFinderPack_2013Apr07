function [resized_image,densityFix,Fixed]=getFixationKDE_v3(image,users,filename)
show=0;

    FixPoints = getFixData(users,filename);
    
    [Fixed,resized_image] = rescaleData(FixPoints,image);
    %FixPoints = 0.2*FixPoints;
    
    %FixPoints = round(FixPoints);

   
% 
% 
%     %----------------------------------------------------------------------
%     % rescale fixation points ---------------------------------------------
%     scale=256;
%     sc_FixX=256.*FixPoints(:,1)./size(image,2);
%     sc_FixY=256.*FixPoints(:,2)./size(image,1);
%     Fixed=[sc_FixX sc_FixY];
%     
%     %[resized_image,densityFix]=rescaleData(Fixed,image) ;       
%     %----------------------------------------------------------------------
%     %resize image for consistency
%     resized_image = imresize(image,[256 256]);
    
    [MX MY] = size(resized_image);
    % visualize points
    if show==1
        figure,imshow(resized_image);
        for k = 1:length(Fixed)
            text ((Fixed(k, 1)), (Fixed(k, 2)), ['{\color{red}\bf', num2str(k), '}'], 'FontSize', 5, 'BackgroundColor', 'g');
        end
        xlabel(num2str([MX MY]));
    end

    %----------------------------------------------------------------------
    % determine KDE for fixation points
     
    %[bandwidthFix,densityFix,XFix,YFix]=kde2d(Fixed,256,[1,1],[MX,MY]); % estimate kernel density
    %XFix = MX; YFix = MY;
    %densityFix=imresize(densityFix,size(resized_image));
    
    Fixed = Fixed((intersect( find(Fixed(:,1)>0), find(Fixed(:,2)>0))),:); %Fixed=[Fixed(:,2) Fixed(:,1)];
    gridx1=1:2:size(resized_image,2); gridx2=1:2:size(resized_image,1); bw=[5 5];
    densityFix =  kde2(Fixed,gridx1,gridx2,bw);
    densityFix=rot90(densityFix,-1); densityFix=fliplr(densityFix);
    densityFix=imresize(densityFix,size((resized_image))); 
     
    %densityFix = removeZeros(densityFix);

    % visualize the KDE
    if show==1
        figure, imagesc(1:1:size(resized_image,2), 1:1:size(resized_image,1),densityFix)
    end

end