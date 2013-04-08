function [resized_image,densityFix]=getFixationKDE(image,users,filename)

show=0;
    FixPoints= [];
    for j = 1:length(users) % for all users find Fixation Points
        user = users{j};
        Pts = getFixationPointsAcrossUsers(filename,user);
        FixPoints = [FixPoints ; Pts];
    end        
    FixPoints = round(FixPoints);

    if (show==1)
            %visualize Fix Points
            for k = 1:length(FixPoints)
                text ((FixPoints(k, 1)), (FixPoints(k, 2)), ['{\color{red}\bf', num2str(k), '}'], 'FontSize', 5, 'BackgroundColor', 'y');
            end     
    end


    %----------------------------------------------------------------------
    % rescale fixation points ---------------------------------------------
    scale=256;
    sc_FixX=256.*FixPoints(:,1)./size(image,2);
    sc_FixY=256.*FixPoints(:,2)./size(image,1);
    Fixed=[sc_FixX sc_FixY];
        
    %----------------------------------------------------------------------
    %resize image for consistency
    resized_image = imresize(image,[256 256]);
    
    % visualize points
    if show==1
        figure,imshow(resized_image);
        for k = 1:length(FixPoints)
            text ((Fixed(k, 1)), (Fixed(k, 2)), ['{\color{red}\bf', num2str(k), '}'], 'FontSize', 5, 'BackgroundColor', 'y');
        end
    end

    %----------------------------------------------------------------------
    % determine KDE for fixation points
      
    [bandwidthFix,densityFix,XFix,YFix]=kde2d(Fixed,256,[0 0],[256 256]); % estimate kernel density
    densityFix = removeZeros(densityFix);

    % visualize the KDE
    if show==1
        figure, surf(XFix,YFix,densityFix)
    end

end