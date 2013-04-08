function visualizeImgKDE(resized_image,Fixed,densityFix)    
% INPUTS - resized image, fixation points on the resized image, KDE map

        % visualize points
        figure,imshow(resized_image);
        for k = 1:length(Fixed)
            text ((Fixed(k, 1)), (Fixed(k, 2)), ['{\color{red}\bf', num2str(k), '}'], 'FontSize', 5, 'BackgroundColor', 'g');
        end
        
        [MX MY] = size(resized_image);
        xlabel(num2str([MX MY]));    
        % visualize the KDE
        figure, imagesc(1:1:size(resized_image,2), 1:1:size(resized_image,1),densityFix);
        
end