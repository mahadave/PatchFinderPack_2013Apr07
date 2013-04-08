function [fishers,patchInfo] = extractFishers_v3(gmm, patchInfo)

    fishers = [];

    for img = 1:numel(patchInfo)
        
        L = numel(patchInfo(img).patchData); % number of patches

        for i = 1:L% jump in steps of NPoints since NPoints belong to the same patch and we want to form a Fisher Feature Vector of these

            pointList = patchInfo(img).patchData(i).pointList ;
            pointList = double(pointList);
            F = extract_fisher_vector(pointList , gmm); 
            fishers = [fishers ; F'];
            patchInfo(img).patchData(i).fisher =  F';
        end

        disp(['fisher vectors extracted for img !',num2str(img)]);
        
    end
end