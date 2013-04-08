function union = findUnion(a,b)

    union=zeros(256);
    for i = 1:size(a,1)
        for j = 1:size(b,1)
            
            union(i,j)=max([a(i,j) b(i,j)]);
        end
    end
    
end