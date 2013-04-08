function [positivePixels,negativePixels] = getPixelLabels(mapPoints,patch,lims)

        lowerX = lims(1);
        lowerY = lims(2);
        upperX = lims(3);
        upperY = lims(4);

        ix =  find(mapPoints(:,2)>=lowerX & mapPoints(:,1)>=lowerY & mapPoints(:,2)<=upperX & mapPoints(:,1)<=upperY); % pixels in patch
        positivePixels =  ind2sub(size(mapPoints),ix);
        
        totpixels=length(patch(:)); 
        nix = setdiff(1:totpixels , ix); % 
        negativePixels = ind2sub(size(mapPoints),nix);
end