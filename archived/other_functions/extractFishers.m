function [fishers] = extractFishers(vectList, gmm, indexList)

    instances = vectList;
  
    fishers = [];

    L = size(indexList,1);
    
    for i = 2:L% jump in steps of NPoints since NPoints belong to the same patch and we want to form a Fisher Feature Vector of these

        
        range= indexList(i,1) : indexList(i,2) ;
        in = instances(range,:);
        F = extract_fisher_vector(in, gmm); 
        fishers = [fishers ; F'];
    end
    
    disp('fisher vectors extracted !');
end