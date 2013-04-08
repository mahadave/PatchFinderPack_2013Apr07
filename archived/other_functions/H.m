function entropy = H(p)

    entropy=0;
    for i =1:numel(p)
        if(p(i)==0)
            continue;
        end
        entropy = entropy -p(i)*log2(p(i));
        
    end
    
end