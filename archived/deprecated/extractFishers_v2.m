function [fishers] = extractFishers_v2(vectList, gmm, patchInfo)

    instances = vectList;
  
    fishers = [];

    for img = 1:numel(patchInfo)
        
        indexList = patchInfo(img).indexList;
        L = size(indexList,1);
%         disp(size(indexList))
        for i = 2:L% jump in steps of NPoints since NPoints belong to the same patch and we want to form a Fisher Feature Vector of these


            range= indexList(i,1) : indexList(i,2) ;
%             disp(indexList(i,1))
%             disp(indexList(i,2))
            in = instances(range,:);
            F = extract_fisher_vector(in, gmm); 
            fishers = [fishers ; F'];
        end

        disp(['fisher vectors extracted for img !',num2str(img)]);
        
    end
end